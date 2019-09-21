ifdef PRODUCT_FSTAB_TEMPLATE

$(info build fstab file with $(PRODUCT_FSTAB_TEMPLATE)....)
FSTAB_FLAGS := wait
FSTAB_PREFIX := /dev/block/by-name/
ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
    FSTAB_FLAGS := $(FSTAB_FLAGS),slotselect
endif # BOARD_USES_AB_IMAGE

ifeq ($(strip $(BOARD_AVB_ENABLE)), true)
    FSTAB_FLAGS := $(FSTAB_FLAGS),avb
endif # BOARD_AVB_ENABLE

ifeq ($(strip $(BOARD_SUPER_PARTITION_GROUPS)),rockchip_dynamic_partitions)
    FSTAB_PREFIX := none
    FSTAB_FLAGS := $(FSTAB_FLAGS),logical
endif # BOARD_USE_DYNAMIC_PARTITIONS

intermediates := $(call intermediates-dir-for,FAKE,rockchip_fstab)
rebuild_fstab := $(intermediates)/fstab.rk30board

ROCKCHIP_FSTAB_TOOLS := $(SOONG_HOST_OUT_EXECUTABLES)/fstab_tools

$(rebuild_fstab) : $(PRODUCT_FSTAB_TEMPLATE) $(ROCKCHIP_FSTAB_TOOLS)
	@echo "Building fstab file $@."
	$(ROCKCHIP_FSTAB_TOOLS) -I fstab \
	-i $(PRODUCT_FSTAB_TEMPLATE) \
	-p $(FSTAB_PREFIX) \
	-f $(FSTAB_FLAGS) \
	-o $(rebuild_fstab)

INSTALLED_RK_VENDOR_FSTAB := $(PRODUCT_OUT)/$(TARGET_COPY_OUT_VENDOR)/etc/$(notdir $(rebuild_fstab))
$(INSTALLED_RK_VENDOR_FSTAB) : $(rebuild_fstab)
	$(call copy-file-to-new-target-with-cp)

INSTALLED_RK_RAMDISK_FSTAB := $(PRODUCT_OUT)/$(TARGET_COPY_OUT_RAMDISK)/$(notdir $(rebuild_fstab))
$(INSTALLED_RK_RAMDISK_FSTAB) : $(rebuild_fstab)
	$(call copy-file-to-new-target-with-cp)

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_RK_VENDOR_FSTAB) $(INSTALLED_RK_RAMDISK_FSTAB)

endif
