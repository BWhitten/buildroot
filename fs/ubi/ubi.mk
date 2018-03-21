################################################################################
#
# Embed the ubifs image into an ubi image
#
################################################################################

ifneq ($(BR2_TARGET_ROOTFS_UBI_MINIOSIZE),0)
UBI_UBINIZE_OPTS := -m $(BR2_TARGET_ROOTFS_UBI_MINIOSIZE)
else
UBI_UBINIZE_OPTS := -m $(BR2_TARGET_ROOTFS_UBIFS_MINIOSIZE)
endif

UBI_UBINIZE_OPTS += -p $(BR2_TARGET_ROOTFS_UBI_PEBSIZE)
ifneq ($(BR2_TARGET_ROOTFS_UBI_SUBSIZE),0)
UBI_UBINIZE_OPTS += -s $(BR2_TARGET_ROOTFS_UBI_SUBSIZE)
endif

UBI_UBINIZE_OPTS += $(call qstrip,$(BR2_TARGET_ROOTFS_UBI_OPTS))

ifeq ($(BR2_TARGET_ROOTFS_UBI_CONTAINS_UBIFS),y)
ROOTFS_UBI_DEPENDENCIES = rootfs-ubifs
ROOTFS_UBI_ROOTFS_EXT = .ubifs
else ifeq ($(BR2_TARGET_ROOTFS_UBI_CONTAINS_SQUASHFS),y)
ROOTFS_UBI_DEPENDENCIES = rootfs-squashfs
ROOTFS_UBI_ROOTFS_EXT = .squashfs
endif
ROOTFS_UBI_DEPENDENCIES += host-mtd

ifeq ($(BR2_TARGET_ROOTFS_UBI_USE_CUSTOM_CONFIG),y)
UBINIZE_CONFIG_FILE_PATH = $(call qstrip,$(BR2_TARGET_ROOTFS_UBI_CUSTOM_CONFIG_FILE))
else
UBINIZE_CONFIG_FILE_PATH = fs/ubi/ubinize.cfg
endif

# don't use sed -i as it misbehaves on systems with SELinux enabled when this is
# executed through fakeroot (see #9386)
define ROOTFS_UBI_CMD
	sed 's;BR2_ROOTFS_PATH;$(BINARIES_DIR)/rootfs$(ROOTFS_UBI_ROOTFS_EXT);' \
		$(UBINIZE_CONFIG_FILE_PATH) > $(BUILD_DIR)/ubinize.cfg
	$(HOST_DIR)/sbin/ubinize -o $@ $(UBI_UBINIZE_OPTS) $(BUILD_DIR)/ubinize.cfg
	rm $(BUILD_DIR)/ubinize.cfg
endef

$(eval $(rootfs))
