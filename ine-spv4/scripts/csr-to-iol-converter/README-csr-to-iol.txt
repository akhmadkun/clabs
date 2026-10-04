CSR1000v -> Cisco IOL converter

The original lab_configs tree is never modified.

Expected input:
  ./lab_configs/R1/*.cfg
  ./lab_configs/R2/*.cfg
  ...

Output:
  ./lab_configs_iol/R1/*.cfg
  ./lab_configs_iol/R2/*.cfg
  ...

IOL baseline:
  ./iol-blank.cfg

Interface mapping:
  GigabitEthernet1 = IOL management Ethernet0/0 (template-owned)
  GigabitEthernet2 -> Ethernet0/1
  GigabitEthernet3 -> Ethernet0/2
  GigabitEthernet4 -> Ethernet0/3
  GigabitEthernet5 -> Ethernet0/4

The converter removes CSR-specific constructs such as:
  crypto pki blocks, license udi, call-home, platform lines,
  service-instance blocks, CSR management VRF/routes, and CSR
  baseline/line/control-plane sections already supplied by iol-blank.cfg.

Run:
  python convert_csr_to_iol.py \
    --src ./lab_configs \
    --dst ./lab_configs_iol \
    --template ./iol-blank.cfg

Important:
  The uploaded sample "base.ipv4.cfg" was converted into:
    lab_configs_iol/R1/base.ipv4.cfg

  The full local lab_configs tree was not available as an upload in this
  chat, so the script performs the bulk conversion on your machine.
