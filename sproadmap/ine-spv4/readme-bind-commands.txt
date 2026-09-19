# Deploy ONCE
sudo containerlab deploy -t csr-bind.clab.yml

# Verify host directory is visible through the CSR container's TFTP root
./scripts/verify-bind.sh

# Check scenario file structure before loading
./scripts/check-config-format.sh

##### CSR NODES #####

conf t
 ip tftp source-interface GigabitEthernet1
end

configure replace tftp://10.0.0.2/configs/isis.cfg force


##### XRd NODES #####

conf t
  load config:labconfigs/isis.cfg

  commit replace confirmed minutes 1

