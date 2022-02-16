#
# Copyright 2014 Rockchip Limited
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
include vendor/rockchip/common/BoardConfigVendor.mk

# mali-G610 的 GPU 架构实际上是 Mali valhall, 但 ARM 对 bifrost 和 valhall 提供同一套的 gralloc 和 DDK 源码.
ifneq (,$(filter  mali-tDVx mali-G52 mali-G610, $(TARGET_BOARD_PLATFORM_GPU)))
BOARD_VENDOR_GPU_PLATFORM := bifrost
endif

ifneq (,$(filter  mali-t860 mali-t760, $(TARGET_BOARD_PLATFORM_GPU)))
BOARD_VENDOR_GPU_PLATFORM := midgard
endif

ifeq ($(strip $(TARGET_ARCH)), arm64)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
endif

PRODUCT_AAPT_CONFIG ?= normal large xlarge hdpi tvdpi xhdpi xxhdpi
PRODUCT_AAPT_PREF_CONFIG ?= xhdpi

PRODUCT_PACKAGES += \
    ExactCalculator

ifdef TARGET_PREBUILT_KERNEL
# Copy kernel if exists
PRODUCT_COPY_FILES += \
    $(TARGET_PREBUILT_KERNEL):kernel
endif

# SDK Version
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rksdk.version=ANDROID$(PLATFORM_VERSION)_RKR6

TARGET_SYSTEM_PROP += device/rockchip/common/build/rockchip/rksdk.prop

# Set system properties identifying the chipset
PRODUCT_VENDOR_PROPERTIES += ro.soc.manufacturer=Rockchip

# Filesystem management tools
PRODUCT_PACKAGES += \
    fsck.f2fs \
    mkfs.f2fs \
    fsck_f2fs
PRODUCT_PACKAGES += \
    vndservicemanager

# Prebuild apps
$(call inherit-product, device/rockchip/common/modules/preinstall.mk)
$(call inherit-product, device/rockchip/common/modules/optimize.mk)
$(call inherit-product, device/rockchip/common/modules/build_dm.mk)

# Inherit product config
ifeq ($(strip $(TARGET_BOARD_PLATFORM_PRODUCT)), atv)
  $(call inherit-product, device/google/atv/products/atv_base.mk)
  $(call inherit-product-if-exists, frameworks/base/data/sounds/AllAudio.mk)
  PRODUCT_PACKAGES += DocumentsUI \
                      PlayAutoInstallConfig \
                      ATVContentProvider \

else ifeq ($(strip $(TARGET_BOARD_PLATFORM_PRODUCT)), box)
  $(call inherit-product, device/rockchip/common/tv/tv_base.mk)
else ifeq ($(strip $(BUILD_WITH_GO_OPT))|$(strip $(TARGET_ARCH)) ,true|arm)
  # For arm Go tablet.
  $(call inherit-product, $(SRC_TARGET_DIR)/product/generic_no_telephony.mk)
  $(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)
  $(call inherit-product-if-exists, frameworks/base/data/sounds/AudioPackageGo.mk)
  PRODUCT_PACKAGES += Launcher3QuickStepGo
else ifeq ($(strip $(BUILD_WITH_GO_OPT))|$(strip $(TARGET_ARCH)) ,true|arm64)
  # For arm64 Go tablet
  $(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
  PRODUCT_PACKAGES += Launcher3QuickStepGo
else
# Normal tablet, add QuickStep for normal product only.
  $(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
  PRODUCT_PACKAGES += Launcher3QuickStep
endif

# PCBA tools
$(call inherit-product, device/rockchip/common/modules/pcba.mk)
# Optee
$(call inherit-product, device/rockchip/common/modules/optee.mk)
# Sepolicy
$(call inherit-product, device/rockchip/common/modules/sepolicy.mk)
# TWRP
$(call inherit-product, device/rockchip/common/modules/twrp.mk)
# GMS
$(call inherit-product, device/rockchip/common/modules/gms.mk)
# Media OMX/C2
$(call inherit-product, device/rockchip/common/modules/mediacodec.mk)
# Android Go configuration
$(call inherit-product, device/rockchip/common/modules/android_go.mk)
# Android Verified Boot
$(call inherit-product, device/rockchip/common/modules/avb.mk)
# init.rc files
$(call inherit-product, device/rockchip/common/rootdir/rootdir.mk)
ifeq ($(strip $(BOARD_HDMI_IN_SUPPORT)), true)
    $(call inherit-product, device/rockchip/common/modules/hdmi_in.mk)
endif
# For screen hw rotation
ifneq ($(filter 90 180 270, $(strip $(SF_PRIMARY_DISPLAY_ORIENTATION))), )
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
	ro.surface_flinger.primary_display_orientation=ORIENTATION_$(SF_PRIMARY_DISPLAY_ORIENTATION)
endif

PRODUCT_COPY_FILES += \
    device/rockchip/common/rk29-keypad.kl:system/usr/keylayout/rk29-keypad.kl \
    device/rockchip/common/ff680030_pwm.kl:system/usr/keylayout/ff680030_pwm.kl \
    device/rockchip/common/alarm_filter.xml:system/etc/alarm_filter.xml \
    device/rockchip/common/ff420030_pwm.kl:system/usr/keylayout/ff420030_pwm.kl

PRODUCT_COPY_FILES += \
    hardware/rockchip/libgraphicpolicy/graphic_profiles.conf:$(TARGET_COPY_OUT_VENDOR)/etc/graphic/graphic_profiles.conf

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/wpa_config.txt:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_config.txt \
    hardware/broadcom/wlan/bcmdhd/config/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    hardware/broadcom/wlan/bcmdhd/config/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    hardware/realtek/wlan/supplicant_overlay_config/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_rtk.conf \
    hardware/realtek/wlan/supplicant_overlay_config/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_rtk.conf

#for ssv6051
PRODUCT_COPY_FILES += \
    vendor/rockchip/common/wifi/ssv6xxx/p2p_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_ssv.conf \

PRODUCT_PACKAGES += \
    iperf \
    libiconv \
    libwpa_client \
    hostapd \
    wificond \
    wifilogd \
    wpa_supplicant \
    wpa_cli \
    wpa_supplicant.conf \
    dhcpcd.conf

ifeq ($(ROCKCHIP_USE_LAZY_HAL),true)
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service-lazy
else
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service
endif

ifeq ($(PRODUCT_HAVE_DLNA),true)
PRODUCT_PACKAGES += \
    MediaCenter \
    DLNA
endif

ifeq ($(strip $(BOARD_HAS_RK_4G_MODEM)),true)
$(call inherit-product, device/rockchip/common/modules/4g_modem.mk)
endif

ifeq ($(filter MediaTek_mt7601 MediaTek RealTek Espressif, $(strip $(BOARD_CONNECTIVITY_VENDOR))), )
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init.connectivity.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.connectivity.rc
endif

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(LOCAL_PATH)/audio_policy_volumes_drc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes_drc.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/a2dp_audio_policy_configuration_7_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration_7_0.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
    frameworks/av/media/libeffects/data/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml

ifndef PRODUCT_FSTAB_TEMPLATE
$(warning Please add fstab.in with PRODUCT_FSTAB_TEMPLATE in your product.mk)
# To use fstab auto generator, define fstab.in in your product.mk,
# Then include the device/rockchip/common/build/rockchip/RebuildFstab.mk in your AndroidBoard.mk
PRODUCT_COPY_FILES += \
    $(TARGET_DEVICE_DIR)/fstab.rk30board:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.$(TARGET_BOARD_HARDWARE) \
    $(TARGET_DEVICE_DIR)/fstab.rk30board:$(TARGET_COPY_OUT_RAMDISK)/fstab.$(TARGET_BOARD_HARDWARE)

# Header V3, add vendor_boot
ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 3)))
PRODUCT_COPY_FILES += \
    $(TARGET_DEVICE_DIR)/fstab.rk30board:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.$(TARGET_BOARD_HARDWARE)
endif
endif # Use PRODUCT_FSTAB_TEMPLATE

ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 3)))
ifneq ($(filter gki_defconfig, $(PRODUCT_KERNEL_CONFIG)), )
$(call inherit-product, vendor/rockchip/common/modular_kernel/modular_kernel.mk)
endif
endif

# For audio-recoard 
PRODUCT_PACKAGES += \
    libsrec_jni

# For tts test
PRODUCT_PACKAGES += \
    libwebrtc_audio_coding

#audio
$(call inherit-product-if-exists, hardware/rockchip/audio/tinyalsa_hal/codec_config/rk_audio.mk)

# SDCardFS deprecate
# https://source.android.google.cn/devices/storage/sdcardfs-deprecate
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

ifeq ($(BOARD_NFC_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml
endif

ifeq ($(BOARD_BLUETOOTH_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml
ifeq ($(BOARD_BLUETOOTH_LE_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml
endif
endif

ifeq ($(BOARD_WIFI_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
    frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
    frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml
endif

ifeq ($(BOARD_HAS_GPS),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml
endif

ifeq ($(BOARD_COMPASS_SENSOR_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml
endif

ifeq ($(BOARD_USER_FAKETOUCH),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.faketouch.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.faketouch.xml
endif

ifeq ($(BOARD_GYROSCOPE_SENSOR_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml
endif

ifeq ($(BOARD_PROXIMITY_SENSOR_SUPPORT),true)
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml
endif

ifeq ($(BOARD_LIGHT_SENSOR_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml
endif

# opengl aep feature
ifeq ($(BOARD_OPENGL_AEP),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml
endif


# USB HOST
ifeq ($(BOARD_USB_HOST_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml
endif

# USB ACCESSORY
ifeq ($(BOARD_USB_ACCESSORY_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_PRODUCT)), vr)
    PRODUCT_COPY_FILES += \
        frameworks/native/data/etc/vr_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/vr_core_hardware.xml
else ifeq ($(strip $(TARGET_BOARD_PLATFORM_PRODUCT)), laptop)
    PRODUCT_COPY_FILES += \
        frameworks/native/data/etc/laptop_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/laptop_core_hardware.xml
else ifeq ($(strip $(TARGET_BOARD_PLATFORM_PRODUCT)), tablet)
ifneq ($(strip $(BUILD_WITH_GO_OPT)),true)
    PRODUCT_COPY_FILES += \
        frameworks/native/data/etc/tablet_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/tablet_core_hardware.xml
endif
# add this prop to skip vr test for cts-on-gsi in vts
    PRODUCT_PROPERTY_OVERRIDES += \
        ro.boot.vr=0
endif

# Live Wallpapers
PRODUCT_PACKAGES += \
    NoiseField \
    PhaseBeam \
    librs_jni \
    libjni_pinyinime

ifeq ($(filter atv box, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
# Sensor HAL
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-service \
    android.hardware.sensors@1.0-impl \
    sensors.$(TARGET_BOARD_HARDWARE)

endif

# Include thermal HAL module
$(call inherit-product, device/rockchip/common/modules/thermal.mk)

# include vibrator AIDL module
$(call inherit-product, device/rockchip/common/modules/vibrator.mk)

# Media DRM
$(call inherit-product, device/rockchip/common/modules/media_drm.mk)

# Usb controller detector for GKI
$(call inherit-product, device/rockchip/common/modules/usb.mk)

# Power AIDL
PRODUCT_PACKAGES += \
    android.hardware.power \
    android.hardware.power-service.rockchip

PRODUCT_PACKAGES += \
    akmd

# Light AIDL
ifneq ($(TARGET_BOARD_PLATFORM_PRODUCT), atv)
PRODUCT_PACKAGES += \
    android.hardware.lights \
    android.hardware.lights-service.rockchip
endif

ifeq ($(strip $(BOARD_SUPER_PARTITION_GROUPS)),rockchip_dynamic_partitions)
# Fastbootd HAL
# TODO: develop a hal for GMS...
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-rockchip \
    fastbootd
endif # BOARD_USE_DYNAMIC_PARTITIONS

# define MPP_BUF_TYPE_DRM 1
# define MPP_BUF_TYPE_ION_LEGACY 2
# define MPP_BUF_TYPE_ION_404 3
# define MPP_BUF_TYPE_ION_419 4
# define MPP_BUF_TYPE_DMA_BUF 5
ifeq ($(TARGET_RK_GRALLOC_VERSION),4)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.mpp_buf_type=1
# Gralloc HAL
PRODUCT_PACKAGES += \
    arm.graphics-V1-ndk_platform.so \
    android.hardware.graphics.allocator@4.0-impl-$(BOARD_VENDOR_GPU_PLATFORM) \
    android.hardware.graphics.mapper@4.0-impl-$(BOARD_VENDOR_GPU_PLATFORM) \
    android.hardware.graphics.allocator@4.0-service

DEVICE_MANIFEST_FILE += \
    device/rockchip/common/manifests/android.hardware.graphics.mapper@4.0.xml \
    device/rockchip/common/manifests/android.hardware.graphics.allocator@4.0.xml
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.mpp_buf_type=1
PRODUCT_PACKAGES += \
    gralloc.$(TARGET_BOARD_HARDWARE) \
    android.hardware.graphics.mapper@2.0-impl-2.1 \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service

DEVICE_MANIFEST_FILE += \
    device/rockchip/common/manifests/android.hardware.graphics.mapper@2.1.xml \
    device/rockchip/common/manifests/android.hardware.graphics.allocator@2.0.xml
endif

PRODUCT_PACKAGES += \
    rkhelper

# For EGL
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.egl=${TARGET_BOARD_HARDWARE_EGL}

# HW Composer
PRODUCT_PACKAGES += \
    hwcomposer.$(TARGET_BOARD_HARDWARE) \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.1-service

# iep
ifneq ($(filter rk3188 rk3190 rk3026 rk3288 rk312x rk3126c rk3128 px3se rk3368 rk3326 rk356x rk3328 rk3366 rk3399, $(strip $(TARGET_BOARD_PLATFORM))), )
BUILD_IEP := true
PRODUCT_PACKAGES += \
    libiep
else
BUILD_IEP := false
endif

# charge
PRODUCT_PACKAGES += \
    charger \
    charger_res_images

# Allows healthd to boot directly from charger mode rather than initiating a reboot.
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.enable_boot_charger_mode=0

# Add board.platform default property to parsing related rc
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.board.platform=$(strip $(TARGET_BOARD_PLATFORM)) \
    ro.target.product=$(strip $(TARGET_BOARD_PLATFORM_PRODUCT))

PRODUCT_CHARACTERISTICS := tablet

# audio lib
PRODUCT_PACKAGES += \
    audio_policy.$(TARGET_BOARD_HARDWARE) \
    audio.primary.$(TARGET_BOARD_HARDWARE) \
    audio.alsa_usb.$(TARGET_BOARD_HARDWARE) \
    audio.a2dp.default\
    audio.r_submix.default\
    libaudioroute\
    audio.usb.default\
    libanr

PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-service \
    android.hardware.audio@7.0-impl \
    android.hardware.audio.effect@7.0-impl

#Health hardware
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-service \
    android.hardware.health@2.1-impl

# Filesystem management tools
# EXT3/4 support
PRODUCT_PACKAGES += \
    mke2fs \
    e2fsck \
    tune2fs \
    resize2fs

# audio lib
PRODUCT_PACKAGES += \
    libasound \
    alsa.default \
    acoustics.default \
    libtinyalsa \
    tinymix \
    tinyplay \
    tinycap \
    tinypcminfo

PRODUCT_PACKAGES += \
	alsa.audio.primary.$(TARGET_BOARD_HARDWARE)\
	alsa.audio_policy.$(TARGET_BOARD_HARDWARE)

$(call inherit-product-if-exists, external/alsa-lib/copy.mk)
$(call inherit-product-if-exists, external/alsa-utils/copy.mk)


PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.strictmode.visual=false 

ifeq ($(strip $(BOARD_HAVE_BLUETOOTH)),true)
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.bt_enable=true
else
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.bt_enable=false
endif

ifeq ($(strip $(MT6622_BT_SUPPORT)),true)
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.btchip=mt6622
endif

ifeq ($(strip $(BLUETOOTH_USE_BPLUS)),true)
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.btchip=broadcom.bplus
endif

ifeq ($(strip $(BOARD_HAVE_FLASH)), true)
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.flash_enable=true
else
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.flash_enable=false
endif

ifeq ($(strip $(BOARD_SUPPORT_HDMI)), true)
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.hdmi_enable=true
else
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.hdmi_enable=false
endif

ifeq ($(strip $(MT7601U_WIFI_SUPPORT)),true)
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.wifichip=mt7601u
endif


PRODUCT_TAGS += dalvik.gc.type-precise


########################################################
# build with UMS? CDROM?
########################################################
ifeq ($(strip $(BUILD_WITH_UMS)),true)
PRODUCT_PROPERTY_OVERRIDES +=               \
    ro.factory.hasUMS=true                  \
    persist.sys.usb.config=mass_storage,adb

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init.rockchip.hasUMS.true.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.$(TARGET_BOARD_HARDWARE).environment.rc
else
ifeq ($(strip $(BUILD_WITH_CDROM)),true)
PRODUCT_PROPERTY_OVERRIDES +=                 \
    ro.factory.hasUMS=cdrom                   \
    ro.factory.cdrom=$(BUILD_WITH_CDROM_PATH) \
    persist.sys.usb.config=mass_storage,adb 

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init.rockchip.hasCDROM.true.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.$(TARGET_BOARD_HARDWARE).environment.rc
else
PRODUCT_PROPERTY_OVERRIDES +=       \
    ro.factory.hasUMS=false         \
    testing.mediascanner.skiplist = /mnt/shell/emulated/Android/

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/init.rockchip.hasUMS.false.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.$(TARGET_BOARD_HARDWARE).environment.rc
endif
endif


########################################################
# build with drmservice
########################################################
ifeq ($(strip $(BUILD_WITH_DRMSERVICE)),true)
PRODUCT_PACKAGES += rockchip.drmservice
endif

########################################################
# this product has GPS or not
########################################################
ifeq ($(strip $(BOARD_HAS_GPS)),true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.factory.hasGPS=true
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.factory.hasGPS=false
endif
########################################################
# this product has Ethernet or not
########################################################
ifeq ($(strip $(BOARD_HS_ETHERNET)),true)
PRODUCT_PROPERTY_OVERRIDES += ro.rk.ethernet_settings=true
endif

#######################################################
#build system support ntfs?
########################################################
ifeq ($(strip $(BOARD_IS_SUPPORT_NTFS)),true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.factory.storage_suppntfs=true

PRODUCT_PACKAGES += \
   ntfs-3g \
   ntfsfix \
   mkntfs
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.factory.storage_suppntfs=false
endif

########################################################
# build without barrery
########################################################
ifeq ($(strip $(BUILD_WITHOUT_BATTERY)), true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.factory.without_battery=true
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.factory.without_battery=false
endif
 
PRODUCT_PACKAGES += \
    com.android.future.usb.accessory

#device recovery ui
#PRODUCT_PACKAGES += \
    librecovery_ui_$(TARGET_PRODUCT)

ifeq ($(strip $(BOARD_BOOT_READAHEAD)), true)
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/proprietary/readahead/readahead:$(TARGET_COPY_OUT_VENDOR)/sbin/readahead \
    $(LOCAL_PATH)/proprietary/readahead/readahead_list.txt:$(TARGET_COPY_OUT_VENDOR)/readahead_list.txt
endif

# Copy manifest to vendor/
ifeq ($(strip $(BOARD_RECORD_COMMIT_ID)),true)
PRODUCT_COPY_FILES += \
    $(OUT_DIR)/commit_id.xml:$(TARGET_COPY_OUT_VENDOR)/commit_id.xml
endif

ifeq ($(strip $(BOARD_CONNECTIVITY_MODULE)), ap6xxx_nfc)
#NFC packages
PRODUCT_PACKAGES += \
    nfc_nci.$(TARGET_BOARD_HARDWARE) \
    NfcNci \
    Tag \
    com.android.nfc_extras

# NFCEE access control
ifeq ($(TARGET_BUILD_VARIANT),user)
NFCEE_ACCESS_PATH := $(LOCAL_PATH)/nfc/nfcee_access.xml
else
NFCEE_ACCESS_PATH := $(LOCAL_PATH)/nfc/nfcee_access_debug.xml
endif

copyNfcFirmware = $(subst XXXX,$(strip $(1)),hardware/broadcom/nfc/firmware/XXXX:/system/vendor/firmware/XXXX)
# NFC access control + feature files + configuration
PRODUCT_COPY_FILES += \
    $(NFCEE_ACCESS_PATH):system/etc/nfcee_access.xml \
    frameworks/native/data/etc/com.android.nfc_extras.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/com.android.nfc_extras.xml \
    frameworks/native/data/etc/android.hardware.nfc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.xml \
    frameworks/native/data/etc/android.hardware.nfc.hce.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.nfc.hce.xml \
    $(LOCAL_PATH)/nfc/libnfc-brcm.conf:system/etc/libnfc-brcm.conf \
    $(LOCAL_PATH)/nfc/libnfc-brcm-20791b03.conf:system/etc/libnfc-brcm-20791b03.conf \
    $(LOCAL_PATH)/nfc/libnfc-brcm-20791b04.conf:system/etc/libnfc-brcm-20791b04.conf \
    $(LOCAL_PATH)/nfc/libnfc-brcm-20791b05.conf:system/etc/libnfc-brcm-20791b05.conf \
    $(LOCAL_PATH)/nfc/libnfc-brcm-43341b00.conf:system/etc/libnfc-brcm-43341b00.conf \
    $(call copyNfcFirmware, BCM20791B3_002.004.010.0161.0000_Generic_I2CLite_NCD_Signed_configdata.ncd) \
    $(call copyNfcFirmware, BCM20791B3_002.004.010.0161.0000_Generic_PreI2C_NCD_Signed_configdata.ncd) \
    $(call copyNfcFirmware, BCM20791B5_002.006.013.0011.0000_Generic_I2C_NCD_Unsigned_configdata.ncd) \
    $(call copyNfcFirmware, BCM43341NFCB0_002.001.009.0021.0000_Generic_I2C_NCD_Signed_configdata.ncd) \
    $(call copyNfcFirmware, BCM43341NFCB0_002.001.009.0021.0000_Generic_PreI2C_NCD_Signed_configdata.ncd)
endif

# Bluetooth HAL
PRODUCT_PACKAGES += \
    libbt-vendor \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth@1.0-service \
    android.hardware.bluetooth@1.0-service.rc

ifeq ($(strip $(BOARD_HAVE_BLUETOOTH_RTK)), true)
include hardware/realtek/rtkbt/rtkbt.mk
endif

ifeq ($(strip $(TARGET_BOARD_PLATFORM_PRODUCT)), box)
    #include device/rockchip/common/samba/rk31_samba.mk
    PRODUCT_COPY_FILES += \
      $(LOCAL_PATH)/init.box.samba.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.box.samba.rc \
      device/rockchip/common/cifsmanager.sh:system/bin/cifsmanager.sh

    PRODUCT_PROPERTY_OVERRIDES += \
      ro.rk.screenoff_time=2147483647
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rk.screenoff_time=60000
endif

# incrementalfs config
$(call inherit-product-if-exists, vendor/rockchip/common/modular_kernel/4.19/incrementalfs.mk)

ifeq ($(strip $(BUILD_WITH_MICROSOFT_PLAYREADY)), true)
$(call inherit-product-if-exists, vendor/microsoft/playready.mk)
endif

$(call inherit-product-if-exists, vendor/rockchip/common/device-vendor.mk)

########################################################
# this product has support remotecontrol or not
########################################################
ifeq ($(strip $(BOARD_HAS_REMOTECONTROL)),true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.enable.remotecontrol=true
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.config.enable.remotecontrol=false
endif

ifeq ($(strip $(BUILD_WITH_SKIPVERIFY)),true)
PRODUCT_PROPERTY_OVERRIDES +=               \
    ro.config.enable.skipverify=true
endif

# rktoolbox
ifneq ($(filter atv box, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
ifeq ($(strip $(BOARD_WITH_RKTOOLBOX)),true)
$(call inherit-product-if-exists, external/rktoolbox/rktoolbox.mk)
endif
endif

# hdmi cec
ifneq ($(filter atv box, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
BOARD_SHOW_HDMI_SETTING := true
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.hdmi.cec.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.hdmi.cec.xml \
	$(LOCAL_PATH)/tv/permissions/privapp-permissions-tv-common.xml:system/etc/permissions/privapp-permissions-tv-common.xml

PRODUCT_PROPERTY_OVERRIDES += ro.hdmi.device_type=4
PRODUCT_PACKAGES += \
	hdmi_cec.$(TARGET_BOARD_PLATFORM)

# HDMI CEC HAL
PRODUCT_PACKAGES += \
    android.hardware.tv.cec@1.0-impl \
    android.hardware.tv.cec@1.0-service
endif

ifeq ($(strip $(BOARD_SHOW_HDMI_SETTING)), true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.hdmi_settings=true

USE_PRODUCT_RESOLUTION_WHITE := $(shell test -f $(TARGET_DEVICE_DIR)/resolution_white.xml && echo true)
ifeq ($(strip $(USE_PRODUCT_RESOLUTION_WHITE)), true)
  PRODUCT_COPY_FILES += \
      $(TARGET_DEVICE_DIR)/resolution_white.xml:/system/usr/share/resolution_white.xml
else
  PRODUCT_COPY_FILES += \
      $(LOCAL_PATH)/resolution_white.xml:/system/usr/share/resolution_white.xml
endif

# Hw Output HAL
PRODUCT_PACKAGES += \
    rockchip.hardware.outputmanager@1.0-impl \
    rockchip.hardware.outputmanager@1.0-service

PRODUCT_PACKAGES += hw_output.default

PRODUCT_COPY_FILES += \
    device/rockchip/common/permissions/rockchip.software.display.xml:system/etc/permissions/rockchip.software.display.xml
endif

PRODUCT_PACKAGES += \
	abc

ifeq ($(strip $(TARGET_BOARD_PLATFORM_PRODUCT)), vr)
PRODUCT_COPY_FILES += \
       device/rockchip/common/lowmem_package_filter.xml:system/etc/lowmem_package_filter.xml 
endif

#if force app can see udisk
ifeq ($(strip $(BOARD_FORCE_UDISK_VISIBLE)),true)
PRODUCT_PROPERTY_OVERRIDES += \
	ro.vendor.udisk.visible=true
endif

#if disable safe mode to speed up booting time
ifeq ($(strip $(BOARD_DISABLE_SAFE_MODE)),true)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.safemode.disabled=true
endif

#boot and shutdown animation, ringing
ifeq ($(strip $(BOOT_SHUTDOWN_ANIMATION_RINGING)),true)
include device/rockchip/common/bootshutdown/bootshutdown.mk
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.shutdown_anim.orien=0
endif


#boot video enable 
ifeq ($(strip $(BOOT_VIDEO_ENABLE)),true)
include device/rockchip/common/bootvideo/bootvideo.mk
endif

ifeq ($(strip $(BOARD_ENABLE_PMS_MULTI_THREAD_SCAN)), true)
PRODUCT_PROPERTY_OVERRIDES += \
	ro.pms.multithreadscan=true		
endif

#add for hwui property
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rk.screenshot_enable=true   \
    ro.rk.hdmi_enable=true   \
    sys.status.hidebar_enable=false

PRODUCT_FULL_TREBLE_OVERRIDE := true
#PRODUCT_COMPATIBILITY_MATRIX_LEVEL_OVERRIDE := 27

# Add runtime resource overlay for framework-res
# TODO disable for box
ifeq ($(filter atv box, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
PRODUCT_ENFORCE_RRO_TARGETS := \
    framework-res
endif

#The module which belong to vndk-sp is defined by google
PRODUCT_PACKAGES += \
    android.hardware.renderscript@1.0.vndk-sp\
    android.hardware.graphics.allocator@2.0.vndk-sp\
    android.hardware.graphics.mapper@2.0.vndk-sp\
    android.hardware.graphics.common@1.0.vndk-sp\
    libhwbinder.vndk-sp\
    libbase.vndk-sp\
    libcutils.vndk-sp\
    libhardware.vndk-sp\
    libhidlbase.vndk-sp\
    libhidltransport.vndk-sp\
    libutils.vndk-sp\
    libc++.vndk-sp\
    libRS_internal.vndk-sp\
    libRSDriver.vndk-sp\
    libRSCpuRef.vndk-sp\
    libbcinfo.vndk-sp\
    libblas.vndk-sp\
    libft2.vndk-sp\
    libpng.vndk-sp\
    libcompiler_rt.vndk-sp\
    libbacktrace.vndk-sp\
    libunwind.vndk-sp\
    liblzma.vndk-sp\

#######for target product ########
ifeq ($(TARGET_BOARD_PLATFORM_PRODUCT),box)
  DEVICE_PACKAGE_OVERLAYS += device/rockchip/common/overlay_screenoff
  PRODUCT_PROPERTY_OVERRIDES += \
       ro.target.product=box \

  $(call inherit-product, device/rockchip/common/modules/rockchip_apps_box.mk)

else ifeq ($(TARGET_BOARD_PLATFORM_PRODUCT),atv)
  PRODUCT_PROPERTY_OVERRIDES += \
       ro.target.product=atv \
       ro.com.google.clientidbase=android-rockchip-tv
  PRODUCT_COPY_FILES += \
       $(LOCAL_PATH)/bootanimation.zip:/system/media/bootanimation.zip

  $(call inherit-product, device/rockchip/common/modules/rockchip_apps_box.mk)

else ifeq ($(TARGET_BOARD_PLATFORM_PRODUCT),vr)
  PRODUCT_PROPERTY_OVERRIDES += \
        ro.target.product=vr
else ifeq ($(TARGET_BOARD_PLATFORM_PRODUCT),laptop)
  PRODUCT_PROPERTY_OVERRIDES += \
        ro.target.product=laptop
else # tablet
  PRODUCT_PROPERTY_OVERRIDES += \
        ro.target.product=tablet

  PRODUCT_PACKAGES += \
        SoundRecorder
ifneq ($(strip $(BUILD_WITH_GOOGLE_GMS_EXPRESS)),true)
PRODUCT_PACKAGES += \
    Music \
    WallpaperPicker

$(call inherit-product, device/rockchip/common/modules/rockchip_apps.mk)

ifneq ($(BUILD_WITH_GOOGLE_MARKET), true)
PRODUCT_PACKAGES += \
    InProcessNetworkStack \
    com.android.tethering.inprocess
endif
endif # tablet without GMS-Express
endif

#only box and atv using our audio policy(write by rockchip)
ifneq ($(filter atv box, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
USE_CUSTOM_AUDIO_POLICY := 1
endif

# By default, enable zram; experiment can toggle the flag,
# which takes effect on boot
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.zram_enabled=1

### fix adb-device cannot be identified  ###
### in AOSP-system image (user firmware) ###
ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.logd.kernel=1
PRODUCT_PACKAGES += io
endif

USE_XML_AUDIO_POLICY_CONF := 1

ifeq ($(strip $(BOARD_USE_DRM)),true)
PRODUCT_PACKAGES += \
    modetest
endif

ifeq ($(strip $(BOARD_USB_ALLOW_DEFAULT_MTP)), true)
PRODUCT_PROPERTY_OVERRIDES += \
       ro.usb.default_mtp=true
endif

PRODUCT_PACKAGES += libstdc++.vendor

ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
PRODUCT_PACKAGES += \
    update_engine \
    update_verifier	\
    cppreopts.sh

PRODUCT_PACKAGES += \
    update_engine_sideload \
    sg_write_buffer \
    f2fs_io \
    check_f2fs

PRODUCT_PACKAGES += \
    update_engine_client

AB_OTA_PARTITIONS += \
    boot \
    system	\
    uboot	\
    vendor	\
    odm	\
    dtbo

ifneq ($(strip $(BOARD_ROCKCHIP_TRUST_MERGE_TO_UBOOT)),true)
AB_OTA_PARTITIONS += \
    trust
endif

ifeq ($(strip $(BOARD_AVB_ENABLE)),true)
AB_OTA_PARTITIONS += \
    vbmeta
endif

# Boot control HAL
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-service \
    android.hardware.boot@1.2-impl-rockchip \
    android.hardware.boot@1.2-impl-rockchip.recovery

ifeq ($(strip $(BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE)),true)
ifeq ($(strip $(BOARD_ROCKCHIP_VIRTUAL_AB_COMPRESSION_WITH_GKI_ENABLE)),true)
ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 3)))
$(call inherit-product, \
    $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)
else
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
endif
else
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
endif
endif

ifeq ($(strip $(BOARD_USES_VIRTUAL_AB_RETROFIT)),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota_retrofit.mk)
endif

PRODUCT_PACKAGES += \
  bootctrl.rk30board \
  bootctrl.rk30board.recovery

PRODUCT_PACKAGES_DEBUG += \
    bootctl

ifndef BOARD_USES_AB_LEGACY_RETROFIT
AB_OTA_PARTITIONS += \
    system_ext \
    vendor_dlkm \
    odm_dlkm \
    product
endif

ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 3)))
AB_OTA_PARTITIONS += \
    resource \
    vendor_boot
endif

# A/B OTA dexopt package
PRODUCT_PACKAGES += otapreopt_script

# A/B OTA dexopt update_engine hookup
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true

endif


#Build with UiMode Config
PRODUCT_COPY_FILES += \
    device/rockchip/common/uimode/package_uimode_config.xml:vendor/etc/package_uimode_config.xml

# Zoom out recovery ui of box by two percent.
ifneq ($(filter atv box, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
    TARGET_RECOVERY_OVERSCAN_PERCENT := 2
    TARGET_BASE_PARAMETER_IMAGE ?= device/rockchip/common/baseparameter/baseparameter.img
    # savBaseParameter tool
    ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
        PRODUCT_PACKAGES += saveBaseParameter
    endif
    DEVICE_FRAMEWORK_MANIFEST_FILE := device/rockchip/common/manifest_framework_override.xml
endif

# add AudioSetting
PRODUCT_PACKAGES += \
    rockchip.hardware.rkaudiosetting@1.0-service \
    rockchip.hardware.rkaudiosetting@1.0-impl \
    rockchip.hardware.rkaudiosetting@1.0

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rt_audio_config.xml:/system/etc/rt_audio_config.xml

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rt_video_config.xml:/system/etc/rt_video_config.xml

#Build with Flash IMG
BOARD_FLASH_IMG_ENABLE ?= false
ifeq ($(TARGET_BOARD_PLATFORM_PRODUCT),box)
    BOARD_FLASH_IMG_ENABLE := true
endif
#FLASH_IMG
ifeq ($(strip $(BOARD_FLASH_IMG_ENABLE)), true)
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
        ro.flash_img.enable = true
else
    PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
        ro.flash_img.enable = false
endif
PRODUCT_COPY_FILES += \
    device/rockchip/common/flash_img/flash_img.sh:vendor/bin/flash_img.sh

#read pcie info for Devicetest APK
PRODUCT_COPY_FILES += \
    device/rockchip/common/pcie/read_pcie_info.sh:vendor/bin/read_pcie_info.sh

BOARD_TV_LOW_MEMOPT ?= false
ifeq ($(strip $(BOARD_TV_LOW_MEMOPT)), true)
    include device/rockchip/common/tv/tv_low_ram_device.mk
endif

#bt config for ap bt
PRODUCT_COPY_FILES += \
    $(TARGET_DEVICE_DIR)/bt_vendor.conf:/vendor/etc/bluetooth/bt_vendor.conf

# Camera support
ifeq ($(BOARD_CAMERA_SUPPORT),true)
$(call inherit-product, device/rockchip/common/modules/camera.mk)
endif

# Rockchip HALs
$(call inherit-product, device/rockchip/common/manifests/frameworks/vintf.mk)

ifeq ($(BOARD_MEMTRACK_SUPPORT),true)
$(call inherit-product, device/rockchip/common/modules/memtrack.mk)
endif

PRODUCT_PACKAGES += \
	libbaseparameter

PRODUCT_COPY_FILES += \
     $(LOCAL_PATH)/display_settings.xml:$(TARGET_COPY_OUT_VENDOR)/etc/display_settings.xml

# build libmpimmz for rknn
PRODUCT_PACKAGES += \
	libmpimmz

# prebuild camera binary tools
ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
PRODUCT_PACKAGES += \
	media-ctl \
	v4l2-ctl
endif
