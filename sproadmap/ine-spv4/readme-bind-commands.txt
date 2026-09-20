# Deploy ONCE
sudo containerlab deploy -t csr-bind.clab.yml


##### CSR NODES #####

conf t
 ip tftp source-interface GigabitEthernet1
end

configure replace tftp://10.0.0.2/configs/isis.cfg force


##### XRd NODES #####

dir config:labconfigs/
conf t
  load config:labconfigs/isis.cfg

  commit replace confirmed minutes 1


#### Cisco IOL ####

dir unix:/labconfigs
configure replace unix:/labconfigs/iol-base.ipv4.cfg force
