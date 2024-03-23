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
PRODUCT_KERNEL_VERSION ?= 6.1
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

BOARD_PLATFORM_VERSION := 14.0

# Enable android verified boot 2.0
BOARD_AVB_ENABLE ?= false
BOARD_BOOT_HEADER_VERSION ?= 2
BOARD_MKBOOTIMG_ARGS :=
BOARD_PREBUILT_DTBOIMAGE ?= $(TARGET_DEVICE_DIR)/dtbo.img
BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE ?= false
BOARD_SELINUX_ENFORCING ?= false
PRODUCT_KERNEL_ARCH ?= arm
BOARD_ROCKCHIP_PKVM ?= false

#TWRP
BOARD_TWRP_ENABLE ?= false

# Android T requires thermal HAL.
BOARD_ROCKCHIP_THERMAL ?= true

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

# Android GO configuration
BUILD_WITH_GO_OPT ?= false

# Android 64-bit only
DEVICE_IS_64BIT_ONLY ?= $(if $(filter %_64,$(TARGET_PRODUCT)),true,false)

PRODUCT_FSTAB_TEMPLATE ?= device/rockchip/common/scripts/fstab_tools/fstab.in

# Set var for building swap fstab files
$(call soong_config_set,fstab_rockchip,low_ram,$(BUILD_WITH_GO_OPT))

# default.prop & build.prop split
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED ?= true

DEVICE_MANIFEST_FILE ?= device/rockchip/common/manifests/manifest_level_$(ROCKCHIP_LUNCHING_API_LEVEL).xml
ifeq ($(call math_gt_or_eq,$(ROCKCHIP_LUNCHING_API_LEVEL),31),true)
# Android S deprecate schedulerservice, use ioprio in init.rc
DEVICE_MATRIX_FILE   ?= device/rockchip/common/manifests/compatibility_matrix_level_$(ROCKCHIP_LUNCHING_API_LEVEL).xml
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
ifeq ($(filter atv box car, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
DEVICE_PACKAGE_OVERLAYS += device/rockchip/common/overlay
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

# Audio
BOARD_USES_GENERIC_AUDIO ?= true

# Wifi&Bluetooth
include device/rockchip/common/wifi_bt_common.mk

#Camera flash
BOARD_HAVE_FLASH ?= true

#HDMI support
BOARD_SUPPORT_HDMI ?= true
BOARD_SUPPORT_HDMI_CEC ?= false
# Address  Device
# 0        TV
# 1        Recording Device 1
# 2        Recording Device 2
# 3        Tuner 1
# 4        Playback Device 1
# 5        Audio System
# 6        Tuner 2
# 7        Tuner 3
# 8        Playback Device 2
# 9        Recording Device 3
# 10       Tuner 4
# 11       Playback Device 3
# 12       Reserved
# 13       Reserved
# 14       Specific Use
# 15       Unregistered (as Initiator address)
#          Broadcast (as Destination address)
BOARD_HDMI_CEC_TYPE ?= 4

# gralloc 4.0
include device/rockchip/common/gralloc.device.mk


# google apps
BUILD_BOX_WITH_GOOGLE_MARKET ?= false
BUILD_WITH_GOOGLE_MARKET ?= false
BUILD_WITH_GOOGLE_MARKET_ALL ?= false
BUILD_WITH_GOOGLE_GMS_EXPRESS ?= false
BUILD_WITH_GOOGLE_FRP ?= true

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
BOARD_HS_ETHERNET ?= true

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

# CTS require faketouch
ifneq ($(TARGET_BOARD_PLATFORM_PRODUCT), atv)
BOARD_USER_FAKETOUCH ?= true
endif

# disable BOARD_SUPPORT_MULTIAUDIO default
BOARD_SUPPORT_MULTIAUDIO ?= false

#for Camera autofocus support
CAMERA_SUPPORT_AUTOFOCUS ?= false

# Enable UsbDevice to Mtp mode,default is charge mode
BOARD_USB_ALLOW_DEFAULT_MTP ?= false

BOARD_DEFAULT_CAMERA_HAL_VERSION ?=3.3

# rktoolbox
BOARD_WITH_RKTOOLBOX ?=true
BOARD_MEMTRACK_SUPPORT ?= false

#PRODUCT_DEFAULT_DEV_CERTIFICATE := device/rockchip/common/security/testkey

PRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true

BOARD_BASEPARAMETER_SUPPORT ?= true
ifeq ($(strip $(BOARD_BASEPARAMETER_SUPPORT)), true)
    ifneq ($(filter rk356x rk3588 rk3576, $(strip $(TARGET_BOARD_PLATFORM))), )
        TARGET_BASE_PARAMETER_IMAGE ?= device/rockchip/common/baseparameter/v2.0/baseparameter.img
    else
        TARGET_BASE_PARAMETER_IMAGE ?= device/rockchip/common/baseparameter/v1.0/baseparameter.img
    endif
        BOARD_WITH_SPECIAL_PARTITIONS := baseparameter:1M
endif

ifeq ($(strip $(BOARD_AUTOPQ_SUPPORT)), true)
    TARGET_AUTO_PQ_IMAGE ?= device/rockchip/common/autopq/autopq.img
    BOARD_WITH_SPECIAL_PARTITIONS := autopq:1M
endif

ifeq ($(strip $(BOARD_BUILD_GKI)), true)
    # AB image definition
    BOARD_USES_AB_IMAGE := true
    BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE := true
    BOARD_ROCKCHIP_VIRTUAL_AB_COMPRESSION := true
else
    BOARD_USES_AB_IMAGE ?= false
    BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE ?= false
    BOARD_ROCKCHIP_VIRTUAL_AB_COMPRESSION ?= false
endif

ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
    include device/rockchip/common/BoardConfig_AB.mk
endif

# Use HWC2
TARGET_USES_HWC2 ?= true

# for gralloc 0.3
TARGET_RK_GRALLOC_VERSION ?= 1

# Android 14 and above
ifeq ($(call math_gt_or_eq,$(ROCKCHIP_LUNCHING_API_LEVEL),34),true)
    # Enable AIDL CAMERA HAL for Android14
    BOARD_CAMERA_AIDL ?= true
    # Use HWC3-AIDL for Android14
    TARGET_USES_HWC3_AIDL := true
endif

# SVEP for Android.mk
# SR enable macro
BOARD_USES_LIBSVEP_SR ?= false
# MEMC enable macro
BOARD_USES_LIBSVEP_MEMC ?= false
#biometric face
BOARD_BIOMETRICS_FACE ?= false
