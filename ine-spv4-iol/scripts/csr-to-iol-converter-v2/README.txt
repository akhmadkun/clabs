CSR1000v -> IOL converter v2

Uses per-node management IPs from mgmt-map.csv.

Current mapping from the topology supplied in chat:
R1  10.200.255.2/24
R2  10.200.255.3/24
R3  10.200.255.4/24
R4  10.200.255.5/24
R5  10.200.255.6/24
R6  10.200.255.7/24

The CSV currently uses 10.200.255.1 as gateway. Verify that gateway in your
fixedips management network before applying configs.

Run:
python convert_csr_to_iol_v2.py \
  --src ./lab_configs \
  --dst ./lab_configs_iol \
  --template ./iol-blank.cfg \
  --mgmt-map ./mgmt-map.csv

Interface mapping:
Gi2 -> Ethernet0/1
Gi3 -> Ethernet0/2
Gi4 -> Ethernet0/3
Gi5 -> Ethernet0/4

Original lab_configs is never modified.
