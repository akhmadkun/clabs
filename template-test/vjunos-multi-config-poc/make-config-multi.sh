#!/bin/bash

# Based on the vJunos-router vrnetlab make-config.sh.
# Adds all files from /labconfigs/ into config/labconfigs/
# inside the vJunos configuration disk.

usage() {
    echo "Usage : make-config.sh <juniper-config> <config-disk>"
    exit 0
}

cleanup () {
    echo "Cleaning up..."
    umount -f -q $MNTDIR
    losetup -d $LOOPDEV
    rm -rfv $STAGING
    rm -rfv $MNTDIR
}

cleanup_failed () {
    cleanup
    rm -rfv $2
    exit 1
}

if [ $# != 2 ]; then
    usage
fi

STAGING=$(mktemp -d -p /var/tmp)
MNTDIR=$(mktemp -d -p /var/tmp)

mkdir -p "$STAGING/config"
cp -v "$1" "$STAGING/config/"

# Copy all user scenario files into the config filesystem.
if [ -d /labconfigs ]; then
    mkdir -p "$STAGING/config/labconfigs"
    cp -av /labconfigs/. "$STAGING/config/labconfigs/"
fi

qemu-img create -f raw "$2" 32M

LOOP_EXITCODE=1
while [ $LOOP_EXITCODE != 0 ]; do
    LOOPDEV=$(losetup -f)

    if [ ! -b "${LOOPDEV}" ]; then
        LOOPINDEX=$(echo "${LOOPDEV}" | grep -Po "\d+")
        mknod "${LOOPDEV}" b 7 "${LOOPINDEX}"
    fi

    losetup "${LOOPDEV}" "$2"
    LOOP_EXITCODE=$?
done

mkfs.vfat -v -n "vmm-data" "$LOOPDEV"
if [ $? != 0 ]; then
    echo "Failed to format disk $LOOPDEV; exiting"
    cleanup_failed
fi

mount -t vfat "$LOOPDEV" "$MNTDIR"
if [ $? != 0 ]; then
    echo "Failed to mount metadisk $LOOPDEV; exiting"
    cleanup_failed
fi

echo "Config files going into config disk:"
find "$STAGING/config" -maxdepth 2 -type f -print

(cd "$STAGING"; tar cvzf "$MNTDIR/vmm-config.tgz" .)

cleanup
echo "Config disk $2 created"
exit 0
