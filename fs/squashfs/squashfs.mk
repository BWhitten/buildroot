################################################################################
#
# Build the squashfs root filesystem image
#
################################################################################

ROOTFS_SQUASHFS_DEPENDENCIES = host-squashfs
ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS_VERITY),y)
ROOTFS_SQUASHFS_DEPENDENCIES += host-cryptsetup
endif

ROOTFS_SQUASHFS_ARGS = -noappend -processors $(PARALLEL_JOBS)

ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_LZ4),y)
ROOTFS_SQUASHFS_ARGS += -comp lz4 -Xhc
else ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_LZO),y)
ROOTFS_SQUASHFS_ARGS += -comp lzo
else ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_LZMA),y)
ROOTFS_SQUASHFS_ARGS += -comp lzma
else ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS4_XZ),y)
ROOTFS_SQUASHFS_ARGS += -comp xz
else
ROOTFS_SQUASHFS_ARGS += -comp gzip
endif

define ROOTFS_SQUASHFS_CMD
	$(HOST_DIR)/bin/mksquashfs $(TARGET_DIR) $@ $(ROOTFS_SQUASHFS_ARGS)
endef

ifeq ($(BR2_TARGET_ROOTFS_SQUASHFS_VERITY),y)
define ROOTFS_SQUASHFS_VERITY
	$(HOST_DIR)/sbin/veritysetup format $@ $@.verity > $@.verity.table
endef
ROOTFS_SQUASHFS_POST_GEN_HOOKS += ROOTFS_SQUASHFS_VERITY
endif

$(eval $(rootfs))
