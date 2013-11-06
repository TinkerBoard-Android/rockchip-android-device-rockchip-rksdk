# config.mk
# 
# Product-specific compile-time definitions.
#
TARGET_PREBUILT_KERNEL ?= kernel/arch/arm/boot/Image
TARGET_BOARD_PLATFORM ?= rk30xx
TARGET_BOARD_PLATFORM_GPU ?= mali400
TARGET_BOARD_HARDWARE ?= rk30board
BOARD_USE_LCDC_COMPOSER ?= false
BOARD_USE_LOW_MEM ?= false
TARGET_NO_BOOTLOADER ?= true
TARGET_CPU_VARIANT := cortex-a9
TARGET_RELEASETOOLS_EXTENSIONS := device/rockchip/rk30sdk

DEVICE_PACKAGE_OVERLAYS += device/rockchip/rk30sdk/overlay

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali400)
ifeq ($(TARGET_BOARD_PLATFORM),rk2928)
BOARD_EGL_CFG := device/rockchip/common/gpu/libmali/egl.cfg
else
BOARD_EGL_CFG := device/rockchip/common/gpu/libmali_smp/egl.cfg
endif
else
BOARD_EGL_CFG := device/rockchip/common/gpu/libpvr/egl.cfg
endif

TARGET_PROVIDES_INIT_RC ?= true

TARGET_NO_KERNEL ?= false
TARGET_NO_RECOVERY ?= false
TARGET_ROCHCHIP_RECOVERY ?= true

# to flip screen in recovery 
BOARD_HAS_FLIPPED_SCREEN := false

# To use bmp as kernel logo, uncomment the line below to use bgra 8888 in recovery
#TARGET_RECOVERY_PIXEL_FORMAT := "BGRA_8888"
TARGET_ROCKCHIP_PCBATEST ?= true
#TARGET_RECOVERY_UI_LIB ?= librecovery_ui_rk30sdk
TARGET_USERIMAGES_USE_EXT4 ?= true
RECOVERY_UPDATEIMG_RSA_CHECK ?= false
RECOVERY_BOARD_ID ?= false
TARGET_CPU_SMP ?= true
BOARD_USES_GENERIC_AUDIO ?= true

//MAX-SIZE=512M, for generate out/.../system.img
BOARD_SYSTEMIMAGE_PARTITION_SIZE ?= 536870912
BOARD_FLASH_BLOCK_SIZE ?= 131072

include device/rockchip/$(TARGET_PRODUCT)/wifi_bt.mk

# Wifi related defines
BOARD_WPA_SUPPLICANT_DRIVER ?= WEXT
WPA_SUPPLICANT_VERSION      ?= VER_0_8_X
BOARD_WPA_SUPPLICANT_PRIVATE_LIB ?= lib_driver_cmd_bcmdhd
BOARD_HOSTAPD_DRIVER        ?= NL80211
BOARD_HOSTAPD_PRIVATE_LIB   ?= lib_driver_cmd_bcmdhd
BOARD_WLAN_DEVICE           ?= bcmdhd
#WIFI_DRIVER_FW_PATH_PARAM   := "/sys/module/bcmdhd/parameters/firmware_path"
WIFI_DRIVER_FW_PATH_STA     ?= "/system/etc/firmware/fw_bcm4329.bin"
WIFI_DRIVER_FW_PATH_P2P     ?= "/system/etc/firmware/fw_bcm4329_p2p.bin"
WIFI_DRIVER_FW_PATH_AP      ?= "/system/etc/firmware/fw_bcm4329_apsta.bin"

# bluetooth support
ifeq ($(strip $(BROADCOM_BT_SUPPORT)),true)
BOARD_HAVE_BLUETOOTH ?= true
BOARD_HAVE_BLUETOOTH_BCM ?= true
BLUETOOTH_USE_BPLUS ?= false
# Default value, if not overridden else where. 
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR ?= device/rockchip/$(TARGET_PRODUCT)/bluetooth
else
ifeq ($(strip $(MT6622_BT_SUPPORT)),true)
BOARD_HAVE_BLUETOOTH ?= true
BOARD_HAVE_BLUETOOTH_BCM ?= false
BLUETOOTH_USE_BPLUS ?= false
# Default value, if not overridden else where.
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR ?= device/common/libbt_mtk6622
else
ifeq ($(strip $(RTL8723AS_BT_SUPPORT)),true)
BOARD_HAVE_BLUETOOTH ?= true
BOARD_HAVE_BLUETOOTH_BCM ?= false
BLUETOOTH_HCI_USE_RTK_H5 ?= true
BLUETOOTH_USE_BPLUS ?= false
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR ?= device/rockchip/$(TARGET_PRODUCT)/bluetooth
else
ifeq ($(strip $(RDA587X_BT_SUPPORT)),true)
BOARD_HAVE_BLUETOOTH ?= true
BOARD_HAVE_BLUETOOTH_BCM ?= false
BLUETOOTH_USE_BPLUS ?= false
# Default value, if not overridden else where.
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR ?= device/common/libbt_rda/
else
ifeq ($(strip $(RTL8723AS_VAU_BT_SUPPORT)),true)
BOARD_HAVE_BLUETOOTH ?= true
BOARD_HAVE_BLUETOOTH_BCM ?= false
BLUETOOTH_USE_BPLUS ?= false
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR ?= device/rockchip/$(TARGET_PRODUCT)/bluetooth
else
ifeq ($(strip $(BK3515_BT_SUPPORT)),true)
BOARD_HAVE_BLUETOOTH ?= true
BOARD_HAVE_BLUETOOTH_BCM ?= false
BLUETOOTH_USE_BPLUS ?= false
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR ?= device/rockchip/$(TARGET_PRODUCT)/bluetooth
else
endif # BK3515_BT_SUPPORT
endif # RTL8723AS_VAU_BT_SUPPORT
endif # RDA587x_BT_SUPPORT
endif # RTL8723AS_BT_SUPPORT
endif # MT6622_BT_SUPPORT 
endif # BROADCOM_BT_SUPPORT
# bluetooth end

TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi

# Enable NEON feature
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
ARCH_ARM_HAVE_TLS_REGISTER := true

#BOARD_LIB_DUMPSTATE := libdumpstate.$(TARGET_BOARD_PLATFORM)

# google apps
BUILD_WITH_GOOGLE_MARKET ?= false

# face lock
BUILD_WITH_FACELOCK ?= false

# ebook
BUILD_WITH_RK_EBOOK ?= false

# rksu
BUILD_WITH_RKSU ?= false

USE_OPENGL_RENDERER ?= true

# rk30sdk uses Cortex A9
TARGET_EXTRA_CFLAGS += $(call cc-option,-mtune=cortex-a9,$(call cc-option,-mtune=cortex-a8)) $(call cc-option,-mcpu=cortex-a9,$(call cc-option,-mcpu=cortex-a8))

# sensors
BOARD_SENSOR_ST := true
#BOARD_SENSOR_COMPASS_AK8963 := true    #if use akm8963
#BOARD_SENSOR_ANGLE := true		#if need calculation angle between two gsensors
#BOARD_SENSOR_CALIBRATION := true	#if need calibration

TARGET_BOOTLOADER_BOARD_NAME ?= rk30sdk

# readahead files to improve boot time
# BOARD_BOOT_READAHEAD ?= true

BOARD_BP_AUTO := true

#phone pad codec list
BOARD_CODEC_WM8994 := false
BOARD_CODEC_RT5625_SPK_FROM_SPKOUT := false
BOARD_CODEC_RT5625_SPK_FROM_HPOUT := false
BOARD_CODEC_RT3261 := false
BOARD_CODEC_RT3224 := true
BOARD_CODEC_RT5631 := false
BOARD_CODEC_RK616 := false
