CSR1000v -> IOL converter v3

The key correction in v3:
The ORIGINAL CSR files already contain the complete baseline and scenario
configuration and only ONE final "end". v3 does NOT prepend iol-blank.cfg.

It transforms the original file directly:
  Gi1 -> Eth0/0 (management)
  Gi2 -> Eth0/1
  Gi3 -> Eth0/2
  Gi4 -> Eth0/3
  Gi5 -> Eth0/4

It replaces the management IP/gateway per node from mgmt-map-v3.csv and
removes CSR-specific constructs. It preserves the scenario portion and
guarantees one terminal "end".

Run:
python convert_csr_to_iol_v3.py   --src ./lab_configs   --dst ./lab_configs_iol   --mgmt-map ./mgmt-map-v3.csv

Original lab_configs is never modified.
