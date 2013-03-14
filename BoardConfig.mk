# config.mk
# 
# Product-specific compile-time definitions.
#
TARGET_PREBUILT_KERNEL ?= kernel/arch/arm/boot/Image
TARGET_BOARD_PLATFORM ?= rk30xx
TARGET_BOARD_HARDWARE ?= rk30board
BOARD_USE_LCDC_COMPOSER ?= false
TARGET_NO_BOOTLOADER ?= true
TARGET_RELEASETOOLS_EXTENSIONS := device/rockchip/rk30sdk

DEVICE_PACKAGE_OVERLAYS += device/rockchip/rk30sdk/overlay

ifeq ($(TARGET_BOARD_PLATFORM),rk30xx)
BOARD_EGL_CFG := device/rockchip/common/gpu/libmali/egl.cfg
else
BOARD_EGL_CFG := device/rockchip/common/gpu/libpvr/egl.cfg
endif

TARGET_PROVIDES_INIT_RC ?= true

TARGET_NO_KERNEL ?= false
TARGET_NO_RECOVERY ?= false
TARGET_ROCHCHIP_RECOVERY ?= true
TARGET_ROCKCHIP_PCBATEST ?= true
TARGET_RECOVERY_UI_LIB ?= librecovery_ui_rk30sdk
TARGET_USERIMAGES_USE_EXT4 ?= true
TARGET_CPU_SMP ?= true
BOARD_USES_GENERIC_AUDIO ?= true

//MAX-SIZE=512M, for generate out/.../system.img
BOARD_SYSTEMIMAGE_PARTITION_SIZE ?= 536870912
BOARD_FLASH_BLOCK_SIZE ?= 131072

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
BOARD_HAVE_BLUETOOTH ?= true
BOARD_HAVE_BLUETOOTH_BCM ?= true
BLUETOOTH_USE_BPLUS ?= true
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

USE_OPENGL_RENDERER ?= true

# rk30sdk uses Cortex A9
TARGET_EXTRA_CFLAGS += $(call cc-option,-mtune=cortex-a9,$(call cc-option,-mtune=cortex-a8)) $(call cc-option,-mcpu=cortex-a9,$(call cc-option,-mcpu=cortex-a8))

BOARD_SENSOR_ST := true
#BOARD_SENSOR_COMPASS_AK8963 := true    #if use akm8963

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

# merge partition data and flash together
BUILD_WITH_NOFLASH := false
