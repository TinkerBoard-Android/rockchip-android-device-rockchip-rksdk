# config.mk
# 
# Product-specific compile-time definitions.
#

TARGET_PREBUILT_KERNEL := kernel/arch/arm/boot/Image
TARGET_BOARD_PLATFORM := rockchip
TARGET_NO_BOOTLOADER := true 
#TARGET_USE_UBOOT := true
#UBOOT_CONFIG := origen_config

DEVICE_PACKAGE_OVERLAYS := device/rockchip/rk30sdk/overlay

BOARD_EGL_CFG := device/rockchip/rk30sdk/egl.cfg

TARGET_PROVIDES_INIT_RC := true

TARGET_NO_KERNEL := false
TARGET_NO_RECOVERY := false
TARGET_ROCHCHIP_RECOVERY := true
TARGET_RECOVERY_UI_LIB := librecovery_ui_rk30sdk
TARGET_CPU_SMP := true
BOARD_USES_GENERIC_AUDIO := true
#BOARD_USES_ALSA_AUDIO := true
#OMAP_ENHANCEMENT := false
#HARDWARE_OMX := false
#USE_CAMERA_STUB := true

#BOARD_HAVE_BLUETOOTH := true
#BOARD_HAVE_BLUETOOTH_BCM := false
#BOARD_HAVE_BLUETOOTH_CSR := true

# Wifi related defines
BOARD_WPA_SUPPLICANT_DRIVER := WEXT
WPA_SUPPLICANT_VERSION      := VER_0_8_X
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_bcmdhd
#BOARD_HOSTAPD_DRIVER        := NL80211
#BOARD_HOSTAPD_PRIVATE_LIB   := lib_driver_cmd_bcmdhd
BOARD_WLAN_DEVICE           := bcmdhd
#WIFI_DRIVER_FW_PATH_PARAM   := "/sys/module/bcmdhd/parameters/firmware_path"
WIFI_DRIVER_FW_PATH_STA     := "/system/etc/firmware/fw_bcm4329.bin"
WIFI_DRIVER_FW_PATH_P2P     := "/system/etc/firmware/fw_bcm4329_p2p.bin"
WIFI_DRIVER_FW_PATH_AP      := "/system/etc/firmware/fw_bcm4329_apsta.bin"

TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi

# Enable NEON feature
TARGET_ARCH_VARIANT := armv7-a-neon
ARCH_ARM_HAVE_TLS_REGISTER := true

BOARD_LIB_DUMPSTATE := libdumpstate.$(TARGET_BOARD_PLATFORM)

# google apps
BUILD_WITH_GOOGLE_MARKET := true

# face lock
BUILD_WITH_FACELOCK := true

USE_OPENGL_RENDERER := true

# bootargs
#BOARD_KERNEL_CMDLINE := console=ttySAC2 root=/dev/mmcblk0p2

# Origen uses an Exynos4 -- Cortex A9
TARGET_EXTRA_CFLAGS += $(call cc-option,-mtune=cortex-a9,$(call cc-option,-mtune=cortex-a8)) $(call cc-option,-mcpu=cortex-a9,$(call cc-option,-mcpu=cortex-a8))

# ARMs gator (DS-5)
#TARGET_USE_GATOR := true

#BOARD_HAVE_CODEC_SUPPORT := SAMSUNG_CODEC_SUPPORT

