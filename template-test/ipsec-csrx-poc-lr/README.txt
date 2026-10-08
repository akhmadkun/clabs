CSRX 23.4R1.9 LOAD-REPLACE PoC

Purpose
-------
1. Verify meekley/csrx:23.4R1.9 works with containerlab kind juniper_csrx.
2. Verify a host directory containing config files is bind-mounted into the running cSRX.
3. Verify Junos "load replace" works after the node is already running.

Host bridge
-----------
This lab expects an existing Linux bridge named br-univ.
Containerlab does not create external bridges.

Files
-----
poc-csrx.clab.yml
configs/01-startup.conf   -> startup config
configs/02-replace.conf   -> partial config with replace: tag

Deploy
------
containerlab deploy -t poc-csrx.clab.yml

Connect to CLI
--------------
docker exec -it clab-ipsec-csrx-poc-lr-csrx-a cli

Verify startup config
---------------------
show system host-name
show interfaces ge-0/0/0 terse

Expected:
  poc-csrx-a
  ge-0/0/0.0  up/up  198.18.10.11/24

Verify the bind mount (from Junos CLI)
---------------------------------------
start shell
ls -l /lab-config
exit

Expected files:
  /lab-config/01-startup.conf
  /lab-config/02-replace.conf

Test load replace
-----------------
configure
load replace /lab-config/02-replace.conf
show | compare

Expected diff includes:
  system host-name: poc-csrx-a -> poc-csrx-b
  ge-0/0/0 address: 198.18.10.11/24 -> 198.18.20.11/24

Then:
commit

Verify:
run show system host-name
run show interfaces ge-0/0/0 terse

Expected:
  poc-csrx-b
  ge-0/0/0.0  up/up  198.18.20.11/24

Important
---------
"load replace" is NOT the same as "load override".
Junos load replace looks for replace: tags and replaces those configuration
objects. The sample 02-replace.conf deliberately uses:

interfaces {
    replace:
    ge-0/0/0 { ... }
}

so the old ge-0/0/0 subtree is replaced instead of merged.

Destroy
-------
Exit CLI, then:
containerlab destroy -t poc-csrx.clab.yml
