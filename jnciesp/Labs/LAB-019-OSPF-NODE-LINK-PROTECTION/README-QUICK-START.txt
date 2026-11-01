QUICK START — LAB-019

1) R1 baseline:
   show ospf neighbor
   show route 4.4.4.4/32 exact detail
   show ospf backup spf detail

2) Replace LP with NLP on R1:
   configure
   delete protocols ospf area 0.0.0.0 interface ge-0/0/0.12 link-protection
   set protocols ospf area 0.0.0.0 interface ge-0/0/0.12 node-link-protection
   commit check
   commit

3) Inspect PPLB policy before adding anything:
   show configuration routing-options forwarding-table | display set
   show configuration policy-options | display set | match load-balance

4) Prove backup SPF and node-protecting metric condition.

5) From a separate host terminal, stop R2 only:
   sudo containerlab stop -t /absolute/path/to/current-core.clab.yml --node r2

6) Restore R2:
   sudo containerlab start -t /absolute/path/to/current-core.clab.yml --node r2

Read TASK.txt and SOLUTION-GUIDE.txt before executing the failure test.
