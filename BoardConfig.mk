# config.mk
# 
# Product-specific compile-time definitions.
#

TARGET_BOARD_PLATFORM := rockchip
TARGET_ROCHCHIP_RECOVERY := true
TARGET_NO_BOOTLOADER := true 
#TARGET_NO_KERNEL := false
TARGET_NO_KERNEL := true
#KERNEL_CONFIG := android_origen_defconfig
#TARGET_USE_UBOOT := true
#UBOOT_CONFIG := origen_config

# uboot
#TARGET_USE_XLOADER := false
#XLOADER_BINARY := out/target/product/origen/obj/u-boot/mmc_spl/u-boot-mmc-spl.bin

TARGET_NO_RECOVERY := false
#TARGET_NO_RADIOIMAGE := true
TARGET_PROVIDES_INIT_RC := true
TARGET_CPU_SMP := true
BOARD_USES_GENERIC_AUDIO := true
#BOARD_USES_ALSA_AUDIO := true
#OMAP_ENHANCEMENT := false
#HARDWARE_OMX := false
#USE_CAMERA_STUB := true

#BOARD_HAVE_BLUETOOTH := true
#BOARD_HAVE_BLUETOOTH_BCM := false
#BOARD_HAVE_BLUETOOTH_CSR := true

#WPA_SUPPLICANT_VERSION := VER_0_8_X
#BOARD_WPA_SUPPLICANT_DRIVER := WEXT
#BOARD_WPA_SUPPLICANT_PRIVATE_LIB := private_lib_driver_cmd
#WIFI_DRIVER_MODULE_PATH := "/system/modules/ath6kl.ko"
#WIFI_DRIVER_MODULE_NAME := "ath6kl"

TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi

# Enable NEON feature
TARGET_ARCH_VARIANT := armv7-a-neon
ARCH_ARM_HAVE_TLS_REGISTER := true

#EXTRA_PACKAGE_MANAGEMENT := false

#TARGET_USERIMAGES_USE_EXT4 := true
#TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true

USE_OPENGL_RENDERER := true

# bootargs
#BOARD_KERNEL_CMDLINE := console=ttySAC2 root=/dev/mmcblk0p2

# Origen uses an Exynos4 -- Cortex A9
TARGET_EXTRA_CFLAGS += $(call cc-option,-mtune=cortex-a9,$(call cc-option,-mtune=cortex-a8)) $(call cc-option,-mcpu=cortex-a9,$(call cc-option,-mcpu=cortex-a8))

# ARMs gator (DS-5)
#TARGET_USE_GATOR := true

#BOARD_HAVE_CODEC_SUPPORT := SAMSUNG_CODEC_SUPPORT

DEVICE_PACKAGE_OVERLAYS := device/rockchip/rk30sdk/overlay

BOARD_LIB_DUMPSTATE := 
TARGET_RECOVERY_UI_LIB :=
