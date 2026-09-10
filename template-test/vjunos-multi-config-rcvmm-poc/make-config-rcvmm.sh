#!/bin/bash
set -e

if [ $# != 2 ]; then
    echo "Usage: make-config.sh <juniper-config> <config-disk>"
    exit 1
fi

JUNIPER_CONFIG="$1"
CONFIG_DISK="$2"
STAGING="$(mktemp -d -p /var/tmp)"
MNTDIR="$(mktemp -d -p /var/tmp)"

cleanup() {
    set +e
    umount -f -q "$MNTDIR" || true
    losetup -d "$LOOPDEV" 2>/dev/null || true
    rm -rf "$STAGING" "$MNTDIR"
}
trap cleanup EXIT

mkdir -p "$STAGING/config"
cp -v "$JUNIPER_CONFIG" "$STAGING/config/juniper.conf"

# Put scenario files on the vJunos config-drive under /var/db/vmm.
# rc.vmm will copy them to normal guest storage during initialization.
mkdir -p "$STAGING/var/db/vmm/labconfigs"
cp -av /labconfigs/. "$STAGING/var/db/vmm/labconfigs/"

# Initialization script executed by Junos/vMM during boot.
mkdir -p "$STAGING/var/db/vmm/etc"
cat > "$STAGING/var/db/vmm/etc/rc.vmm" <<'EOF'
#!/bin/sh

echo "=== vJunos multi-config PoC rc.vmm ===" >/var/log/multi-config-poc.log 2>&1

mkdir -p /var/tmp/labconfigs >>/var/log/multi-config-poc.log 2>&1
cp -av /var/db/vmm/labconfigs/. /var/tmp/labconfigs/ >>/var/log/multi-config-poc.log 2>&1

echo "Files copied to /var/tmp/labconfigs:" >>/var/log/multi-config-poc.log
ls -la /var/tmp/labconfigs/ >>/var/log/multi-config-poc.log 2>&1
EOF
chmod 0755 "$STAGING/var/db/vmm/etc/rc.vmm"

echo "=== Staging tree ==="
find "$STAGING" -maxdepth 5 -type f -print

qemu-img create -f raw "$CONFIG_DISK" 32M >/dev/null

LOOPDEV="$(losetup -f)"
losetup "$LOOPDEV" "$CONFIG_DISK"
mkfs.vfat -v -n "vmm-data" "$LOOPDEV" >/dev/null
mount -t vfat "$LOOPDEV" "$MNTDIR"

(cd "$STAGING" && tar cvzf "$MNTDIR/vmm-config.tgz" .)

sync
echo "=== Config disk contents ==="
tar tzf "$MNTDIR/vmm-config.tgz"
