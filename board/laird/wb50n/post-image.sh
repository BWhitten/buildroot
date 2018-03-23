#!/bin/sh

BOARD_DIR="$(dirname $0)"
GENIMAGE_CFG="${BOARD_DIR}/genimage.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

# Tooling checks
mkimage=$HOST_DIR/bin/mkimage
ubinize=$HOST_DIR/sbin/ubinize
veritysetup=$HOST_DIR/sbin/veritysetup
genimage=$HOST_DIR/bin/genimage

run() { echo "$@"; "$@"; }
die() { echo "$@" >&2; exit 1; }
test -f $BINARIES_DIR/zImage || \
	        die "No kernel image found"
test -f $BINARIES_DIR/at91-wb50n.dtb || \
	        die "No kernel dtb found"
test -f $BINARIES_DIR/rootfs.squashfs || \
	        die "No squashfs found"
test -x $mkimage || \
	        die "No mkimage found (host-uboot-tools has not been built?)"
test -x $ubinize || \
	        die "No ubinize found (host-mtd has not been built?)"
test -x $veritysetup || \
	        die "No veritysetup found (host-cryptsetup has not been built?)"
test -x $genimage || \
	        die "No genimage found (host-genimage has not been built?)"

# kernel.its references zImage and at91-wb50n.dtb, and all three
# files must be in current directory for mkimage.
run cp $BOARD_DIR/kernel.its $BINARIES_DIR/kernel.its || exit 1
echo "# entering $BINARIES_DIR for the next command"
(cd $BINARIES_DIR && run $mkimage -f kernel.its kernel.itb) || exit 1
run rm -f $BINARIES_DIR/kernel.its

# Generate the hash table for squashfs
$veritysetup format $BINARIES_DIR/rootfs.squashfs $BINARIES_DIR/rootfs.verity > $BINARIES_DIR/rootfs.verity.header

# Build the UBI
run rm -rf "${GENIMAGE_TMP}"
run $genimage                          \
	--rootpath "${TARGET_DIR}"     \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
