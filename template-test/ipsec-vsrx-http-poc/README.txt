vSRX VVFAT HOT-PLUG PoC
=======================

Exact image:
  eacik8ssrv6/juniper_vsrx:23.2R2.21

Goal
----
Use a HOST directory as a directory-backed QEMU VVFAT filesystem, but DO NOT
attach the VVFAT device during vSRX boot.

The host directory is bind-mounted into the vrnetlab launcher:
  ./configs -> /lab-config

QEMU creates only a VVFAT BLOCK BACKEND at boot:
  -drive if=none,id=labdisk,format=raw,file=fat:rw:/lab-config

There is intentionally NO -device argument at boot. Therefore the guest does
not see the extra disk during its boot sequence.

After vSRX is fully booted, hot-plug the already-created backend with the QEMU
Human Monitor:

  device_add virtio-blk-pci,drive=labdisk,id=labdiskdev

This should make the VVFAT filesystem appear as a new virtio block device in
the FreeBSD/vSRX guest.

Deploy
------
containerlab deploy -t poc-vsrx-vvfat-hotplug.clab.yml

Wait until the vSRX itself is fully usable. Check:
  docker logs vsrx-a

Enter the QEMU monitor
----------------------
The vrnetlab command line exposes QEMU monitor TCP port 4000 inside the
launcher container.

Try:
  docker exec -it vsrx-a bash

Then:
  telnet 127.0.0.1 4000

If telnet is unavailable, try:
  nc 127.0.0.1 4000

At the (qemu) prompt:
  info block

Then hot-plug:
  device_add virtio-blk-pci,drive=labdisk,id=labdiskdev

Verify:
  info block
  info pci

Do NOT use "quit" or "q" in the QEMU monitor.

Find the disk inside vSRX
-------------------------
From Junos:
  start shell

Then:
  sysctl kern.disks
  dmesg | egrep -i 'vtbd|virtio|disk|fat|msdos'

The existing Junos disk is typically vtbd0. The new hot-plugged virtio disk
is expected to appear as another vtbdN device, often vtbd1. Do not assume;
verify with the commands above.

Mount it
--------
Example if the new device is vtbd1:
  mkdir -p /mnt/lab-config
  mount -t msdosfs -o ro /dev/vtbd1 /mnt/lab-config
  ls -la /mnt/lab-config

Expected:
  startup.conf
  01.conf
  02.conf

Test load replace
-----------------
Exit shell:
  exit

Then:
  configure
  load replace /mnt/lab-config/01.conf
  show | compare
  commit

Then without recreating vSRX:
  load replace /mnt/lab-config/02.conf
  show | compare
  commit

Why this design
---------------
vSRX is a QEMU VM inside a vrnetlab launcher. Containerlab startup-config is
handled by the launcher and converted into its own config.iso. A normal
Docker bind mount is therefore visible to the launcher, not directly to the
Junos guest.

This PoC deliberately separates:
  1. host directory bind
  2. QEMU VVFAT backend creation
  3. guest-visible disk attachment

The key test is whether #3 can be performed AFTER vSRX boot without affecting
normal boot, and whether FreeBSD/Junos can mount the VVFAT disk.

If this works, it gives us the desired model:
  host configs/  -> bind -> QEMU VVFAT -> guest mount -> load replace
without ISO generation, SCP, or "load replace terminal".

No scripts are included.
br-univ must already exist.
