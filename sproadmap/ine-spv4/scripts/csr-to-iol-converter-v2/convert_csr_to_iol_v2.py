#!/usr/bin/env python3
import argparse, csv, re
from pathlib import Path

CSR_BLOCKS = (
    r"^crypto pki trustpoint\b", r"^crypto pki certificate chain\b",
    r"^license udi\b", r"^call-home\b", r"^redundancy\b",
    r"^platform\b", r"^subscriber templating\b",
    r"^multilink bundle-name\b", r"^diagnostic bootup\b",
    r"^service call-home\b",
)

BASELINE = (
    r"^version\b", r"^service timestamps\b", r"^hostname\b",
    r"^boot-start-marker\b", r"^boot-end-marker\b",
    r"^no aaa new-model\b", r"^no ip domain lookup\b",
    r"^ip domain name\b", r"^ip cef\b", r"^login on-success\b",
    r"^ipv6 unicast-routing\b", r"^ipv6 cef\b", r"^username admin\b",
    r"^memory free low-watermark processor\b", r"^spanning-tree mode\b",
    r"^ip forward-protocol nd\b", r"^ip http server\b",
    r"^ip http secure-server\b", r"^ip ssh bulk-mode\b",
    r"^no logging btrace\b",
)

def normalize_show_run(text):
    out = []
    for line in text.replace("\r\n", "\n").splitlines():
        if line.startswith("R1#") or line.startswith("Building configuration"):
            continue
        if re.match(r"^Current configuration\s*:", line):
            continue
        out.append(line)
    return out

def drop_block(lines, predicate):
    out=[]; i=0
    while i < len(lines):
        if predicate(lines[i]):
            i += 1
            while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() in ("!","")):
                i += 1
        else:
            out.append(lines[i]); i += 1
    return out

def drop_iface_prefix(lines, prefixes):
    out=[]; i=0
    while i < len(lines):
        m = re.match(r"^interface\s+(\S+)", lines[i])
        if m and any(m.group(1).startswith(p) for p in prefixes):
            i += 1
            while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() in ("!","")):
                i += 1
            continue
        out.append(lines[i]); i += 1
    return out

def map_iface(line):
    m = re.match(r"^(\s*)interface\s+GigabitEthernet([2-5])(\S*)$", line)
    if m:
        return f"{m.group(1)}interface Ethernet0/{int(m.group(2))-1}{m.group(3)}"
    return re.sub(r"\bGigabitEthernet1\b", "Ethernet0/0", line)

def clean_source(lines):
    lines = drop_iface_prefix(lines, ("GigabitEthernet1",))
    lines = drop_block(lines, lambda x: any(re.match(p, x) for p in CSR_BLOCKS))
    out=[]; i=0
    while i < len(lines):
        line = lines[i]

        if re.match(r"^vrf definition clab-mgmt\b", line):
            i += 1
            while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() in ("!","")):
                i += 1
            continue

        if re.match(r"^\s*(ip route vrf clab-mgmt|ipv6 route vrf clab-mgmt)\b", line):
            i += 1; continue

        if re.match(r"^\s*(enable password|no ip icmp rate-limit unreachable|platform console|memory free low-watermark processor)\b", line):
            i += 1; continue

        if any(re.match(p, line) for p in BASELINE):
            i += 1; continue

        if re.match(r"^(control-plane|line con 0|line aux 0|line vty 0 4)\b", line):
            i += 1
            while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() in ("!","")):
                i += 1
            continue

        if re.match(r"^\s*service instance \d+ ethernet\b", line):
            i += 1
            while i < len(lines) and (lines[i].startswith(" ") or lines[i].strip() in ("!","")):
                i += 1
            continue

        if re.match(r"^ip tftp source-interface GigabitEthernet1\b", line) or \
           re.match(r"^ip http client source-interface GigabitEthernet1\b", line):
            i += 1; continue

        if line.strip() == "end":
            i += 1; continue

        out.append(map_iface(line)); i += 1
    return out

def load_map(path):
    result={}
    with path.open(newline="") as f:
        reader=csv.DictReader(f)
        required={"node","ipv4","mask","gateway"}
        if not required.issubset(set(reader.fieldnames or [])):
            raise SystemExit(f"ERROR: mgmt-map must have columns {sorted(required)}")
        for row in reader:
            node=row["node"].strip()
            result[node]={
                "ipv4":row["ipv4"].strip(),
                "mask":row["mask"].strip(),
                "gateway":row["gateway"].strip(),
            }
    return result

def render_template(template_text, node, mgmt):
    lines = normalize_show_run(template_text)
    lines = drop_iface_prefix(lines, ("Ethernet0/0",))
    filtered=[]
    for line in lines:
        if re.match(r"^\s*(ip route vrf clab-mgmt|ipv6 route vrf clab-mgmt)\b", line):
            continue
        if re.match(r"^\s*ipv6 address 3FFF:172:20:20::2/64\b", line):
            continue
        filtered.append(line)
    lines = [f"hostname {node}" if re.match(r"^hostname\s+\S+", x) else x for x in filtered]

    mgmt = [
        "interface Ethernet0/0",
        " description clab-mgmt",
        " vrf forwarding clab-mgmt",
        f" ip address {mgmt['ipv4']} {mgmt['mask']}",
        " no shutdown",
        "!",
        f"ip route vrf clab-mgmt 0.0.0.0 0.0.0.0 Ethernet0/0 {mgmt['gateway']}",
        "!",
    ]
    idx = next((i for i,x in enumerate(lines) if x.startswith("interface ")), len(lines))
    return lines[:idx] + mgmt + lines[idx:]

def process(src_file, dst_file, template_text, node, mgmt):
    base=render_template(template_text, node, mgmt)
    scenario=clean_source(src_file.read_text(errors="replace").splitlines())
    result=base + ["!"]
    prev=False
    for line in scenario:
        if line.strip()=="!":
            if prev: continue
            prev=True; result.append("!")
        else:
            prev=False; result.append(line.rstrip())
    while result and result[-1].strip() in ("!",""):
        result.pop()
    result += ["!", "end"]
    dst_file.parent.mkdir(parents=True, exist_ok=True)
    dst_file.write_text("\n".join(result)+"\n")

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--src", default="./lab_configs")
    ap.add_argument("--dst", default="./lab_configs_iol")
    ap.add_argument("--template", default="./iol-blank.cfg")
    ap.add_argument("--mgmt-map", required=True)
    a=ap.parse_args()

    src, dst, template = Path(a.src), Path(a.dst), Path(a.template)
    if not src.is_dir(): raise SystemExit(f"Source not found: {src}")
    if not template.is_file(): raise SystemExit(f"Template not found: {template}")

    mapping=load_map(Path(a.mgmt_map))
    template_text=template.read_text(errors="replace")
    count=0
    for node_dir in sorted(p for p in src.iterdir() if p.is_dir()):
        if node_dir.name not in mapping:
            print(f"WARNING: no management mapping for {node_dir.name}; skipped")
            continue
        for src_file in sorted(node_dir.glob("*.cfg")):
            process(src_file, dst/src_file.relative_to(src), template_text, node_dir.name, mapping[node_dir.name])
            count += 1
    print(f"Converted {count} config files.")
    print(f"Output: {dst.resolve()}")

if __name__=="__main__":
    main()
