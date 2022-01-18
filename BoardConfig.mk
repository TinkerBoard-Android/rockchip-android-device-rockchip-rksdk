#
# Copyright 2014 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#binder protocol(8)
TARGET_USES_64_BIT_BINDER := true
TARGET_BOARD_PLATFORM ?= rk3288
TARGET_BOARD_HARDWARE ?= rk30board
PRODUCT_KERNEL_VERSION ?= 4.19
PRODUCT_KERNEL_PATH ?= kernel-$(PRODUCT_KERNEL_VERSION)

# value: tablet,box,phone
# It indicates whether to be tablet platform or not

# Export this prop for Mainline Modules.
ROCKCHIP_LUNCHING_API_LEVEL := $(PRODUCT_SHIPPING_API_LEVEL)

ifneq ($(filter %box, $(TARGET_PRODUCT)), )
TARGET_BOARD_PLATFORM_PRODUCT ?= box
else
ifneq ($(filter %vr, $(TARGET_PRODUCT)), )
TARGET_BOARD_PLATFORM_PRODUCT ?= vr
else
TARGET_BOARD_PLATFORM_PRODUCT ?= tablet
endif
endif

TARGET_ARCH ?= arm
TARGET_ARCH_VARIANT ?= armv7-a-neon
ARCH_ARM_HAVE_TLS_REGISTER ?= true
TARGET_CPU_ABI ?= armeabi-v7a
TARGET_CPU_ABI2 ?= armeabi
TARGET_CPU_VARIANT ?= cortex-a9
TARGET_CPU_SMP ?= true

BOARD_PLATFORM_VERSION := 12.0

# Enable android verified boot 2.0
BOARD_AVB_ENABLE ?= false
BOARD_BOOT_HEADER_VERSION ?= 2
BOARD_MKBOOTIMG_ARGS :=
BOARD_PREBUILT_DTBOIMAGE ?= $(TARGET_DEVICE_DIR)/dtbo.img
BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE ?= false
BOARD_SELINUX_ENFORCING ?= false
PRODUCT_KERNEL_ARCH ?= arm

#TWRP
BOARD_TWRP_ENABLE ?= false

ifeq ($(PRODUCT_FS_COMPRESSION), 1)
include device/rockchip/common/build/rockchip/F2fsCompression.mk
endif

include device/rockchip/common/build/rockchip/Partitions.mk

# Use the non-open-source parts, if they're present
ifeq ($(PRODUCT_KERNEL_ARCH), arm)
TARGET_PREBUILT_KERNEL ?= $(PRODUCT_KERNEL_PATH)/arch/arm/boot/zImage
BOARD_PREBUILT_DTBIMAGE_DIR ?= $(PRODUCT_KERNEL_PATH)/arch/arm/boot/dts
else
TARGET_PREBUILT_KERNEL ?= $(PRODUCT_KERNEL_PATH)/arch/arm64/boot/Image
BOARD_PREBUILT_DTBIMAGE_DIR ?= $(PRODUCT_KERNEL_PATH)/arch/arm64/boot/dts/rockchip
endif

TARGET_PREBUILT_RESOURCE ?= $(PRODUCT_KERNEL_PATH)/resource.img
PRODUCT_PARAMETER_TEMPLATE ?= device/rockchip/common/scripts/parameter_tools/parameter.in
TARGET_BOARD_HARDWARE_EGL ?= mali

#Android GO configuration
BUILD_WITH_GO_OPT ?= false

ifeq ($(BUILD_WITH_GO_OPT), true)
PRODUCT_FSTAB_TEMPLATE ?= device/rockchip/common/scripts/fstab_tools/fstab_go.in
PRODUCT_KERNEL_CONFIG += android-11-go.config
else
PRODUCT_FSTAB_TEMPLATE ?= device/rockchip/common/scripts/fstab_tools/fstab.in
PRODUCT_KERNEL_CONFIG += android-11.config
endif

ifeq ($(TARGET_BUILD_VARIANT), user)
PRODUCT_KERNEL_CONFIG += non_debuggable.config
endif

ROCKCHIP_ANDROID_BOOT_CMDLINE ?= androidboot.console=ttyFIQ0 androidboot.wificountrycode=CN
ROCKCHIP_ANDROID_BOOT_CMDLINE += androidboot.hardware=$(TARGET_BOARD_HARDWARE)
ROCKCHIP_ANDROID_BOOT_CMDLINE += androidboot.boot_devices=$(PRODUCT_BOOT_DEVICE)

BOARD_KERNEL_CMDLINE := console=ttyFIQ0 firmware_class.path=/vendor/etc/firmware init=/init rootwait ro
BOARD_KERNEL_CMDLINE += loop.max_part=7

ifneq ($(BOARD_SELINUX_ENFORCING), true)
ROCKCHIP_ANDROID_BOOT_CMDLINE += androidboot.selinux=permissive
endif

ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \<= 3)))
BOARD_KERNEL_CMDLINE += $(ROCKCHIP_ANDROID_BOOT_CMDLINE)
else # Boot header 4 requires bootconfig
BOARD_BOOTCONFIG := $(ROCKCHIP_ANDROID_BOOT_CMDLINE)
endif

# For Header V2, set resource.img as second.
# For Header V3, add vendor_boot and resource.
ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \<= 2)))
BOARD_MKBOOTIMG_ARGS += --second $(TARGET_PREBUILT_RESOURCE)
endif
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)

# Always use header v2 for recovery image,
# - header v4 is using bootconfig, always override cmdline in recovery;
# - header v3+ is used for virtual A/B and GKI;
# - header v2 used for the device with recovery;
ifneq ($(BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE), true)
ifneq ($(BOARD_USES_AB_IMAGE), true)
BOARD_RECOVERY_MKBOOTIMG_ARGS ?= --second $(TARGET_PREBUILT_RESOURCE) \
    --header_version 2 \
    --cmdline "$(BOARD_KERNEL_CMDLINE) $(ROCKCHIP_ANDROID_BOOT_CMDLINE)"
ifeq ($(BOARD_AVB_ENABLE), true)
BOARD_USES_FULL_RECOVERY_IMAGE := true
endif
endif
endif
BOARD_INCLUDE_RECOVERY_DTBO ?= true
BOARD_INCLUDE_DTB_IN_BOOTIMG ?= true

# default.prop & build.prop split
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED ?= true

DEVICE_MANIFEST_FILE ?= device/rockchip/common/manifests/manifest_level_$(ROCKCHIP_LUNCHING_API_LEVEL).xml
ifeq (1,$(strip $(shell expr $(ROCKCHIP_LUNCHING_API_LEVEL) \>= 31)))
# Android S deprecate schedulerservice, use ioprio in init.rc
DEVICE_MATRIX_FILE   ?= device/rockchip/common/manifests/compatibility_matrix_level_31.xml
else
# For Android R and older versions.
DEVICE_MATRIX_FILE   ?= device/rockchip/common/manifests/compatibility_matrix.xml
endif

# GPU configration
TARGET_BOARD_PLATFORM_GPU ?= mali-t760
GRAPHIC_MEMORY_PROVIDER ?= ump
USE_OPENGL_RENDERER ?= true
TARGET_DISABLE_TRIPLE_BUFFERING ?= false
TARGET_RUNNING_WITHOUT_SYNC_FRAMEWORK ?= false

DEVICE_HAVE_LIBRKVPU ?= true

#rotate screen to 0, 90, 180, 270
#0:   ROTATION_NONE      ORIENTATION_0  : 0
#90:  ROTATION_RIGHT     ORIENTATION_90 : 90
#180: ROTATION_DOWN    ORIENTATION_180: 180
#270: ROTATION_LEFT    ORIENTATION_270: 270
# For Recovery Rotation
TARGET_RECOVERY_DEFAULT_ROTATION ?= ROTATION_NONE
# For Surface Flinger Rotation
SF_PRIMARY_DISPLAY_ORIENTATION ?= 0

#Screen to Double, Single
#YES: Screen to Double
#NO: Screen to single
DOUBLE_SCREEN ?= NO

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali400)
BOARD_EGL_CFG := vendor/rockchip/common/gpu/Mali400/lib/arm/egl.cfg
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali450)
BOARD_EGL_CFG := vendor/rockchip/common/gpu/Mali450/lib/x86/egl.cfg
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali-t860)
BOARD_EGL_CFG := vendor/rockchip/common/gpu/MaliT860/etc/egl.cfg
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali-t760)
BOARD_EGL_CFG := vendor/rockchip/common/gpu/MaliT760/etc/egl.cfg
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), mali-t720)
BOARD_EGL_CFG := vendor/rockchip/common/gpu/MaliT720/etc/egl.cfg
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), PVR540)
BOARD_EGL_CFG ?= vendor/rockchip/common/gpu/PVR540/egl.cfg
endif

VENDOR_SECURITY_PATCH := $(PLATFORM_SECURITY_PATCH)

TARGET_BOOTLOADER_BOARD_NAME ?= rk30sdk
TARGET_NO_BOOTLOADER ?= true
ifeq ($(filter atv box, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
DEVICE_PACKAGE_OVERLAYS += device/rockchip/common/overlay
ifneq ($(BOARD_HAS_RK_4G_MODEM), true)
DEVICE_PACKAGE_OVERLAYS += device/rockchip/common/overlay_wifi_only
endif
endif

TARGET_RELEASETOOLS_EXTENSIONS := device/rockchip/common

//MAX-SIZE=512M, for generate out/.../system.img
BOARD_FLASH_BLOCK_SIZE := 131072


# Enable VNDK Check for Android P (MUST after P)
BOARD_VNDK_VERSION := current

# Recovery
#TARGET_NO_RECOVERY ?= false
TARGET_ROCHCHIP_RECOVERY ?= true

# to flip screen in recovery
BOARD_HAS_FLIPPED_SCREEN ?= false

# Auto update package from USB
RECOVERY_AUTO_USB_UPDATE ?= false

# To use bmp as kernel logo, uncomment the line below to use bgra 8888 in recovery
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
TARGET_ROCKCHIP_PCBATEST ?= true
#TARGET_RECOVERY_UI_LIB ?= librecovery_ui_$(TARGET_PRODUCT)

TARGET_USES_MKE2FS ?= true

RECOVERY_BOARD_ID ?= false
# RECOVERY_BOARD_ID ?= true

# for drmservice
BUILD_WITH_DRMSERVICE :=true

# Audio
BOARD_USES_GENERIC_AUDIO ?= true

# Wifi&Bluetooth
BOARD_HAVE_BLUETOOTH ?= true
BLUETOOTH_USE_BPLUS ?= false
BOARD_HAVE_BLUETOOTH_BCM ?= false
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR ?= device/rockchip/$(TARGET_BOARD_PLATFORM)/bluetooth
include device/rockchip/common/wifi_bt_common.mk

#Camera flash
BOARD_HAVE_FLASH ?= true

#HDMI support
BOARD_SUPPORT_HDMI ?= true

# gralloc 4.0
include device/rockchip/common/gralloc.device.mk


# google apps
BUILD_BOX_WITH_GOOGLE_MARKET ?= false
BUILD_WITH_GOOGLE_MARKET ?= false
BUILD_WITH_GOOGLE_MARKET_ALL ?= false
BUILD_WITH_GOOGLE_GMS_EXPRESS ?= false
BUILD_WITH_GOOGLE_FRP ?= false

# define BUILD_NUMBER
#BUILD_NUMBER := $(shell $(DATE) +%H%M%S)

# Configs for lmkd/reclaim service/auto run control/performance/dexmetadata compile...
ROCKCHIP_OEM_CONFIG_FILE ?= device/rockchip/common/configs/cfg_rockchip_default.xml
ROCKCHIP_OEM_CONFIG_PACKAGES ?= device/rockchip/common/configs/rockchip_forbid_packages.xml

# face lock
BUILD_WITH_FACELOCK ?= false

# ebook
BUILD_WITH_RK_EBOOK ?= false

# Sensors
BOARD_SENSOR_ST ?= true
# if use akm8963
#BOARD_SENSOR_COMPASS_AK8963 ?= true
# if need calculation angle between two gsensors
#BOARD_SENSOR_ANGLE ?= true
# if need calibration
#BOARD_SENSOR_CALIBRATION ?= true
# if use mpu
#BOARD_SENSOR_MPU ?= true
#BOARD_USES_GENERIC_INVENSENSE ?= false

# readahead files to improve boot time
# BOARD_BOOT_READAHEAD ?= true

BOARD_BP_AUTO ?= true

# phone pad codec list
BOARD_CODEC_WM8994 ?= false
BOARD_CODEC_RT5625_SPK_FROM_SPKOUT ?= false
BOARD_CODEC_RT5625_SPK_FROM_HPOUT ?= false
BOARD_CODEC_RT3261 ?= false
BOARD_CODEC_RT3224 ?= true
BOARD_CODEC_RT5631 ?= false
BOARD_CODEC_RK616 ?= false

# Vold configrations
# if set to true m-user would be disabled and UMS enabled, if set to disable UMS would be disabled and m-user enabled
BUILD_WITH_UMS ?= false
# if set to true BUILD_WITH_UMS must be false.
BUILD_WITH_CDROM ?= false
BUILD_WITH_CDROM_PATH ?= /system/etc/cd.iso
# multi usb partitions
BUILD_WITH_MULTI_USB_PARTITIONS ?= false
# define tablet support NTFS
BOARD_IS_SUPPORT_NTFS ?= true

# pppoe for cts, you should set this true during pass CTS and which will disable  pppoe function.
BOARD_PPPOE_PASS_CTS ?= false

# ethernet
BOARD_HS_ETHERNET ?= false

# Save commit id into firmware
BOARD_RECORD_COMMIT_ID ?= false

# no battery
BUILD_WITHOUT_BATTERY ?= false

BOARD_CHARGER_ENABLE_SUSPEND ?= true
CHARGER_ENABLE_SUSPEND ?= true
CHARGER_DISABLE_INIT_BLANK ?= true
BOARD_CHARGER_DISABLE_INIT_BLANK ?= true

#stress test
BOARD_HAS_STRESSTEST_APP ?= true

#optimise mem
BOARD_WITH_MEM_OPTIMISE ?= false

#force app can see udisk
BOARD_FORCE_UDISK_VISIBLE ?= true


# disable safe mode to speed up boot time
BOARD_DISABLE_SAFE_MODE ?= true

#enable 3g dongle
BOARD_HAVE_DONGLE ?= false

#for boot and shutdown animation ringing
BOOT_SHUTDOWN_ANIMATION_RINGING ?= false

#for pms multi thead scan
BOARD_ENABLE_PMS_MULTI_THREAD_SCAN ?= false

#for WV keybox provision
ENABLE_KEYBOX_PROVISION ?= false

# product has follow sensors or not,if had override it in product's BoardConfig
BOARD_HAS_GPS ?= false   
BOARD_NFC_SUPPORT ?= false
BOARD_GRAVITY_SENSOR_SUPPORT ?= false
BOARD_GSENSOR_MXC6655XA_SUPPORT ?= false
BOARD_COMPASS_SENSOR_SUPPORT ?= false
BOARD_GYROSCOPE_SENSOR_SUPPORT ?= false
BOARD_PROXIMITY_SENSOR_SUPPORT ?= false
BOARD_LIGHT_SENSOR_SUPPORT ?= false
BOARD_OPENGL_AEP ?= false
BOARD_PRESSURE_SENSOR_SUPPORT ?= false
BOARD_TEMPERATURE_SENSOR_SUPPORT ?= false
BOARD_USB_HOST_SUPPORT ?= false
BOARD_USB_ACCESSORY_SUPPORT ?= true
BOARD_CAMERA_SUPPORT ?= false
BOARD_BLUETOOTH_SUPPORT ?= true
BOARD_BLUETOOTH_LE_SUPPORT ?= true
BOARD_WIFI_SUPPORT ?= true

#for rk 4g modem
BOARD_HAS_RK_4G_MODEM ?= false

#for rk DLNA
PRODUCT_HAVE_DLNA ?= false

#USE_CLANG_PLATFORM_BUILD ?= true

# Android Q, move to device.mk since we can not change PRODUCT_PACKAGES in BoardConfig.mk
# Zoom out recovery ui of box by two percent.
#ifneq ($(filter atv box, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
#    TARGET_RECOVERY_OVERSCAN_PERCENT := 2
#    TARGET_BASE_PARAMETER_IMAGE ?= device/rockchip/common/baseparameter/baseparameter_fb720.img
    # savBaseParameter tool
#    ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
#        PRODUCT_PACKAGES += saveBaseParameter
#    endif
#    DEVICE_FRAMEWORK_MANIFEST_FILE := device/rockchip/common/manifest_framework_override.xml
#endif

#enable cpusets sched policy
ENABLE_CPUSETS := true

# Enable sparse system image
BOARD_USE_SPARSE_SYSTEM_IMAGE ?= false

#Use HWC2
TARGET_USES_HWC2 ?= true

# for gralloc 0.3
TARGET_RK_GRALLOC_VERSION ?= 1

# CTS require faketouch
ifneq ($(TARGET_BOARD_PLATFORM_PRODUCT), atv)
BOARD_USER_FAKETOUCH ?= true
endif

#for Camera autofocus support
CAMERA_SUPPORT_AUTOFOCUS ?= false

# Enable UsbDevice to Mtp mode,default is charge mode
BOARD_USB_ALLOW_DEFAULT_MTP ?= false

BOARD_DEFAULT_CAMERA_HAL_VERSION ?=3.3

# rktoolbox
BOARD_WITH_RKTOOLBOX ?=true
BOARD_MEMTRACK_SUPPORT ?= false

BOARD_BASEPARAMETER_SUPPORT ?= true
ifeq ($(strip $(BOARD_BASEPARAMETER_SUPPORT)), true)
    ifneq ($(filter rk356x rk3588, $(strip $(TARGET_BOARD_PLATFORM))), )
        TARGET_BASE_PARAMETER_IMAGE ?= device/rockchip/common/baseparameter/v2.0/baseparameter.img
    else
        TARGET_BASE_PARAMETER_IMAGE ?= device/rockchip/common/baseparameter/v1.0/baseparameter.img
    endif
        BOARD_WITH_SPECIAL_PARTITIONS := baseparameter:1M
endif
