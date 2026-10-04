#!/usr/bin/env python3
"""
CSR1000v -> Cisco IOL converter v3.

v3 converts the ORIGINAL CSR file in place-style; it does NOT prepend
iol-blank.cfg. This is intentional because the CSR source already contains
one complete baseline + scenario config with a single final "end".

For each input config:
  - keep the source baseline and scenario
  - map Gi1 -> IOL Ethernet0/0
  - map Gi2 -> Ethernet0/1
  - map Gi3 -> Ethernet0/2
  - map Gi4 -> Ethernet0/3
  - map Gi5 -> Ethernet0/4
  - replace management IP/gateway from --mgmt-map
  - remove CSR-only constructs
  - remove MOP/negotiation settings
  - keep one final "end"

Original lab_configs is never modified.

Usage:
  python convert_csr_to_iol_v3.py \
    --src ./lab_configs \
    --dst ./lab_configs_iol \
    --mgmt-map ./mgmt-map-v3.csv
"""
from __future__ import annotations
import argparse, csv, re
from pathlib import Path

CSR_BLOCKS = (
    r"^(crypto pki trustpoint|crypto pki certificate chain|call-home|redundancy|subscriber templating|multilink bundle-name authenticated)\b",
)
CSR_SINGLE = (
    r"^(license udi|diagnostic bootup|memory free low-watermark processor|platform\b|service call-home\b)",
)

def load_map(path):
    result={}
    with path.open(newline="") as f:
        reader=csv.DictReader(f)
        req={"node","ipv4","mask","gateway"}
        if not req.issubset(set(reader.fieldnames or [])):
            raise SystemExit(f"ERROR: mgmt-map requires columns {sorted(req)}")
        for row in reader:
            node=row["node"].strip()
            result[node]={k:row[k].strip() for k in ("ipv4","mask","gateway")}
    return result

def convert(text, node, mgmt):
    lines=text.replace("\r\n","\n").splitlines()
    out=[]; i=0; in_iface=False; iface=None

    def skip_indented(idx):
        while idx<len(lines) and (lines[idx].startswith((" ","\t")) or lines[idx].strip() in ("!","")):
            idx+=1
        return idx

    while i<len(lines):
        line=lines[i]

        if any(re.match(p,line) for p in CSR_BLOCKS):
            i=skip_indented(i+1); continue
        if any(re.match(p,line) for p in CSR_SINGLE):
            i+=1; continue
        if re.match(r"^enable password\b", line):
            i+=1; continue
        if re.match(r"^version\s+\S+", line):
            out.append("version 17.15"); i+=1; continue

        m=re.match(r"^interface\s+(\S+)\s*$",line)
        if m:
            orig=m.group(1)
            if orig=="GigabitEthernet1":
                mapped="Ethernet0/0"
            else:
                mm=re.match(r"^GigabitEthernet([2-5])(\S*)$",orig)
                mapped=f"Ethernet0/{int(mm.group(1))-1}{mm.group(2)}" if mm else orig
            out.append(f"interface {mapped}")
            iface=mapped; in_iface=True; i+=1; continue

        if in_iface and line and not line.startswith((" ","\t")) and line.strip()!="!":
            in_iface=False; iface=None
            continue

        if in_iface:
            if re.match(r"^\s*service instance \d+ ethernet\b",line):
                i+=1
                while i<len(lines) and lines[i].startswith((" ","\t")):
                    i+=1
                continue
            if re.match(r"^\s*(negotiation auto|no mop enabled|no mop sysid)\b",line):
                i+=1; continue
            if iface=="Ethernet0/0" and re.match(r"^\s*(ip address|shutdown)\b",line):
                i+=1; continue
            out.append(line); i+=1; continue

        line=re.sub(r"\bGigabitEthernet1\b","Ethernet0/0",line)
        if re.match(r"^ip route vrf clab-mgmt 0\.0\.0\.0 0\.0\.0\.0\b",line):
            out.append(f"ip route vrf clab-mgmt 0.0.0.0 0.0.0.0 Ethernet0/0 {mgmt['gateway']}")
            i+=1; continue
        out.append(line); i+=1

    # Rewrite management block.
    final=[]; i=0; have=False
    while i<len(out):
        if out[i]=="interface Ethernet0/0":
            final.append(out[i]); i+=1
            while i<len(out) and (out[i].startswith((" ","\t"))):
                if re.match(r"^\s*(ip address|shutdown|negotiation auto|no mop enabled|no mop sysid)\b",out[i]):
                    i+=1; continue
                final.append(out[i]); i+=1
            final += [f" ip address {mgmt['ipv4']} {mgmt['mask']}", " no shutdown"]
            have=True
            continue
        final.append(out[i]); i+=1

    if not have:
        idx=next((n for n,x in enumerate(final) if x.startswith("interface ")),len(final))
        final[idx:idx]=[
            "interface Ethernet0/0"," description clab-mgmt",
            " vrf forwarding clab-mgmt",
            f" ip address {mgmt['ipv4']} {mgmt['mask']}",
            " no shutdown","!"
        ]

    final=[f"hostname {node}" if re.match(r"^hostname\s+\S+$",x) else x for x in final]

    # Only one final end.
    first_end=next((n for n,x in enumerate(final) if x.strip()=="end"),None)
    if first_end is not None:
        final=final[:first_end]
    while final and final[-1].strip() in ("!",""):
        final.pop()
    final += ["!","end"]
    return "\n".join(final)+"\n"

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--src",default="./lab_configs")
    ap.add_argument("--dst",default="./lab_configs_iol")
    ap.add_argument("--mgmt-map",required=True)
    a=ap.parse_args()
    src,dst=Path(a.src),Path(a.dst)
    mapping=load_map(Path(a.mgmt_map))
    count=0
    for node_dir in sorted(p for p in src.iterdir() if p.is_dir()):
        node=node_dir.name
        if node not in mapping:
            print(f"WARNING: no mapping for {node}; skipped")
            continue
        for src_file in sorted(node_dir.glob("*.cfg")):
            dst_file=dst/src_file.relative_to(src)
            dst_file.parent.mkdir(parents=True,exist_ok=True)
            dst_file.write_text(convert(src_file.read_text(errors="replace"),node,mapping[node]))
            count+=1
    print(f"Converted {count} config files to {dst.resolve()}")

if __name__=="__main__":
    main()
