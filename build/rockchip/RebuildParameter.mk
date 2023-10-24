ifdef PRODUCT_PARAMETER_TEMPLATE

$(info build parameter.txt with $(PRODUCT_PARAMETER_TEMPLATE)....)

ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
partition_list := security:4M,uboot_a:4M,trust_a:4M,misc:4M
else
partition_list := security:4M,uboot:4M,trust:4M,misc:4M
endif # BOARD_USES_AB_IMAGE

ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
# Header V3, add vendor_boot and resource.
ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 3)))
partition_list := $(partition_list),resource_a:$(BOARD_RESOURCEIMAGE_PARTITION_SIZE),vendor_boot_a:$(BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE)
ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 4)))
partition_list := $(partition_list),init_boot_a:$(BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE)
# pKVM can be used only for GKI
ifeq ($(BOARD_ROCKCHIP_PKVM),true)
partition_list := $(partition_list),pvmfw_a:$(BOARD_PVMFWIMAGE_PARTITION_SIZE)
endif
endif # Header V4
endif # Header V3
partition_list := $(partition_list),dtbo_a:$(BOARD_DTBOIMG_PARTITION_SIZE),vbmeta_a:1M,boot_a:$(BOARD_BOOTIMAGE_PARTITION_SIZE)
else # None-A/B
partition_list := $(partition_list),dtbo:$(BOARD_DTBOIMG_PARTITION_SIZE),vbmeta:1M,boot:$(BOARD_BOOTIMAGE_PARTITION_SIZE),recovery:$(BOARD_RECOVERYIMAGE_PARTITION_SIZE)
endif # BOARD_USES_AB_IMAGE

partition_list := $(partition_list),backup:384M,cache:$(BOARD_CACHEIMAGE_PARTITION_SIZE)
ifeq ($(call math_gt_or_eq,$(ROCKCHIP_LUNCHING_API_LEVEL),34),true)
partition_list := $(partition_list),metadata:64M
else
partition_list := $(partition_list),metadata:16M
endif

ifeq ($(strip $(BUILD_WITH_GOOGLE_FRP)), true)
partition_list := $(partition_list),frp:512K
endif

ifneq ($(strip $(BOARD_WITH_SPECIAL_PARTITIONS)), )
partition_list := $(partition_list),$(BOARD_WITH_SPECIAL_PARTITIONS)
endif

ifeq ($(strip $(BOARD_SUPER_PARTITION_GROUPS)),rockchip_dynamic_partitions)
partition_list := $(partition_list),super:$(BOARD_SUPER_PARTITION_SIZE)
else # BOARD_USE_DYNAMIC_PARTITIONS
partition_list := $(partition_list),system:$(BOARD_SYSTEMIMAGE_PARTITION_SIZE),vendor:$(BOARD_VENDORIMAGE_PARTITION_SIZE),odm:$(BOARD_ODMIMAGE_PARTITION_SIZE)
endif

ifdef BOARD_USERDATAIMAGE_PARTITION_SIZE
partition_list := $(partition_list),data:$(BOARD_USERDATAIMAGE_PARTITION_SIZE)
endif

intermediates := $(call intermediates-dir-for,FAKE,rockchip_parameter)
rebuild_parameter := $(intermediates)/parameter.txt

ROCKCHIP_PARAMETER_TOOLS := $(SOONG_HOST_OUT_EXECUTABLES)/parameter_tools

$(rebuild_parameter) : $(PRODUCT_PARAMETER_TEMPLATE) $(ROCKCHIP_PARAMETER_TOOLS)
	@echo "Building parameter.txt $@."
	$(ROCKCHIP_PARAMETER_TOOLS) --input $(PRODUCT_PARAMETER_TEMPLATE) \
	--start-offset 8192 \
	--firmware-version $(BOARD_PLATFORM_VERSION) \
	--machine-model "$(PRODUCT_MODEL)" \
	--manufacturer "$(PRODUCT_MANUFACTURER)" \
	--machine $(PRODUCT_DEVICE) \
	--partition-list $(partition_list) \
	--output $(rebuild_parameter)

INSTALLED_RK_PARAMETER := $(PRODUCT_OUT)/$(notdir $(rebuild_parameter))
$(INSTALLED_RK_PARAMETER) : $(rebuild_parameter)
	$(call copy-file-to-new-target-with-cp)

ALL_DEFAULT_INSTALLED_MODULES += $(INSTALLED_RK_PARAMETER)
endif
