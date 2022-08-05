ifdef PRODUCT_FSTAB_TEMPLATE

$(info build fstab file with $(PRODUCT_FSTAB_TEMPLATE)....)
fstab_flags := wait
fstab_prefix := /dev/block/by-name/
fstab_dynamic_list :=
ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
    fstab_flags := $(fstab_flags),slotselect
    fstab_chained := slotselect,
endif # BOARD_USES_AB_IMAGE

ifeq ($(strip $(BOARD_AVB_ENABLE)), true)
    fstab_flags := $(fstab_flags),avb
ifdef BOARD_AVB_BOOT_KEY_PATH
    fstab_chained := $(fstab_chained)avb=boot,
endif
endif # BOARD_AVB_ENABLE

ifndef fstab_chained
    fstab_chained := none
endif

# Add partition to fstab_dynamic_list
# $1 part
# Do not add ',' to head
define rockchip_set_dynamic_list
$(if $(fstab_dynamic_list), \
	$(eval fstab_dynamic_list := $(fstab_dynamic_list),$(call word-colon, 1, $(1))), \
	$(eval fstab_dynamic_list := $(call word-colon, 1, $(1))) \
	)
endef

# $1 part
# $2 part need to be ignored
define rockchip_ignrore_base_part_list
$(if $(filter $(1), $(2)),,$(call rockchip_set_dynamic_list, $(1)))
endef

#fstab_dynamic_list := $(fstab_dynamic_list),$(part)
ifeq ($(strip $(BOARD_SUPER_PARTITION_GROUPS)),rockchip_dynamic_partitions)
    fstab_prefix := none
    fstab_flags := $(fstab_flags),logical
    tmp_ignored_part := system vendor odm
    $(foreach part, $(BOARD_ROCKCHIP_DYNAMIC_PARTITIONS_PARTITION_LIST), \
        $(call rockchip_ignrore_base_part_list, $(part), $(tmp_ignored_part)))
else
    fstab_dynamic_list := none
endif # BOARD_USE_DYNAMIC_PARTITIONS

fstab_sdmmc_device := 00000000.dwmmc
ifdef PRODUCT_SDMMC_DEVICE
    fstab_sdmmc_device := $(PRODUCT_SDMMC_DEVICE)
endif

intermediates := $(call intermediates-dir-for,FAKE,rockchip_fstab)
rebuild_fstab := $(intermediates)/fstab.$(TARGET_BOARD_HARDWARE)

ROCKCHIP_FSTAB_TOOLS := $(SOONG_HOST_OUT_EXECUTABLES)/fstab_tools

$(rebuild_fstab) : $(PRODUCT_FSTAB_TEMPLATE) $(ROCKCHIP_FSTAB_TOOLS)
	@echo "Building fstab file $@."
	$(ROCKCHIP_FSTAB_TOOLS) -I fstab \
	-i $(PRODUCT_FSTAB_TEMPLATE) \
	-p $(fstab_prefix) \
	-f $(fstab_flags) \
	-d $(fstab_dynamic_list) \
	-c $(fstab_chained) \
	-s $(fstab_sdmmc_device) \
	-o $(rebuild_fstab)

INSTALLED_RK_VENDOR_FSTAB := $(PRODUCT_OUT)/$(TARGET_COPY_OUT_VENDOR)/etc/$(notdir $(rebuild_fstab))
$(INSTALLED_RK_VENDOR_FSTAB) : $(rebuild_fstab)
	$(call copy-file-to-new-target-with-cp)

# Header V3, add vendor_boot
ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 3)))
INSTALLED_RK_RAMDISK_FSTAB := $(PRODUCT_OUT)/$(TARGET_COPY_OUT_VENDOR_RAMDISK)/$(notdir $(rebuild_fstab))
$(INSTALLED_RK_RAMDISK_FSTAB) : $(rebuild_fstab)
	$(call copy-file-to-new-target-with-cp)
else
INSTALLED_RK_RAMDISK_FSTAB := $(PRODUCT_OUT)/$(TARGET_COPY_OUT_RAMDISK)/$(notdir $(rebuild_fstab))
$(INSTALLED_RK_RAMDISK_FSTAB) : $(rebuild_fstab)
	$(call copy-file-to-new-target-with-cp)
endif

ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
INSTALLED_RK_RECOVERY_FIRST_STAGE_FSTAB := $(PRODUCT_OUT)/$(TARGET_COPY_OUT_RECOVERY)/root/first_stage_ramdisk/$(notdir $(rebuild_fstab))
$(INSTALLED_RK_RECOVERY_FIRST_STAGE_FSTAB) : $(rebuild_fstab)
	$(call copy-file-to-new-target-with-cp)
endif # BOARD_USES_AB_IMAGE

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_RK_VENDOR_FSTAB) $(INSTALLED_RK_RAMDISK_FSTAB)

ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_RK_RECOVERY_FIRST_STAGE_FSTAB)
endif

endif
