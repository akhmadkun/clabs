# Lab 002 | Multi-area IS-IS, route leaking and overload

Open **Lab002-Tasks-and-Solutions.docx**. The same English workbook contains the topology, tasks, commands, expected observations and recovery for phases A–C. Each phase builds on the previous commit.

## Already running the cRPD fabric
The YAML and six boot base.conf files are identical to the current Lab 001 package. From the extracted Lab002 directory, copy only the new scenario files into the active per-router mounts:

```bash
FABRIC=/path/to/active/deployment
for r in r1 r2 r3 r4 r5 r6; do
  cp "configs_crpd/$r/isis.lab002.conf" "$FABRIC/configs_crpd/$r/"
done
docker exec r1 ls /labconfigs/isis.lab002.conf
```

## Fresh deployment
Use the local images named in juniper-isis.clab.yml. On the Linux host:

```bash
ip link show br-univ >/dev/null 2>&1 || sudo ip link add br-univ type bridge
sudo ip link set br-univ up
sudo containerlab deploy -t juniper-isis.clab.yml
sudo containerlab inspect -t juniper-isis.clab.yml
```

When vlan_filtering is enabled on br-univ, check tagged VLAN membership after deployment using bridge vlan show. Allow the following on the listed ports:

| Port | VLANs |
|---|---|
| r1_eth1 | 13, 14, 101 |
| r2_eth1 | 25, 26, 102 |
| r3_eth1 | 13, 35 |
| r4_eth1 | 14, 45, 46 |
| r5_eth1 | 25, 35, 45 |
| r6_eth1 | 26, 46 |
| h1_eth1 / h2_eth1 | 101 / 102 respectively |

## Start the exercise
On each of R1–R6 use docker exec -it rX cli, then configure and load override /labconfigs/isis.lab002.conf. Review show | compare, commit check and commit. This replaces the active configuration from the previous lab after commit. One load per router covers the entire workbook. Static checks covered addresses, level membership and expected graph paths. Live cRPD CLI and forwarding results must be confirmed on the installed image.

## If a Docker management default masks the IS-IS default
From the host, compare docker exec r1 ip -4 route show default and docker exec r1 ip route get 192.168.102.10 with show route 0.0.0.0/0 exact detail inside R1. If the management default wins, use docker exec access throughout these checks. On this disposable lab router only, record the complete eth0 default route, including its gateway and any metric. Temporarily remove just that one kernel route with ip route del default via GATEWAY dev eth0 (include its metric if present), run inside R1's container. This can interrupt off-subnet management. Wait for routing to settle. Verify that a dynamic IS-IS default appears and that traffic follows the new exit after A3. Restore the original eth0 route using ip route add followed by the exact saved route at the end. If a supervisor reinstates it or the IS-IS route does not reach the kernel, record the RIB and FIB observations separately; a manually installed route to H2 would invalidate the default-exit experiment.
