# Lab 001 | One topology, one initial load per router

Start with Lab001-Tasks-and-Solutions.docx. The diagram in docs/lab001-topology.png applies to all phases. The final configuration from each phase is the starting point for the next phase.

## Existing deployment
Extract the archive into a separate directory. From its ISIS-Lab01 folder, copy the six new files into their matching active bind mounts:

```bash
FABRIC=/path/to/active/deployment
for r in r1 r2 r3 r4 r5 r6; do
  cp "configs_crpd/$r/isis.lab001.conf" "$FABRIC/configs_crpd/$r/"
done
```

## Fresh deployment
Use a Linux host with Docker, containerlab and the two images specified in juniper-isis.clab.yml. From the extracted directory:

```bash
ip link show br-univ >/dev/null 2>&1 || sudo ip link add br-univ type bridge
sudo ip link set br-univ up
sudo containerlab deploy -t juniper-isis.clab.yml
sudo containerlab inspect -t juniper-isis.clab.yml
```

If the bridge uses vlan_filtering=1, allow these tagged VLANs once: r1_eth1 12/101/123, r2_eth1 12/102/123, r3_eth1 123/34/35, r4_eth1 34, r5_eth1 35, h1_eth1 101 and h2_eth1 102. Inspect the host configuration with bridge vlan show.

## Initial load
Open each router CLI (for example, docker exec -it r1 cli). Run the block from Phase A1 once on R1-R6. Each /labconfigs directory maps to a different router's folder. The base.conf files are the deployment boot configurations. isis.lab001.conf is the single exercise baseline. A load override replaces the full candidate configuration; review show | compare before committing.

## Continue in place
A uses VLAN 12. B adds IS-IS on VLAN 123 and keeps VLAN 12 as a backup. C adds IS-IS on VLANs 34 and 35. VLAN membership and endpoint addressing are fixed throughout. A deliberate restart of the whole exercise uses the same initial load. To resume a partially completed lab, continue from the last verified step in the guide.
