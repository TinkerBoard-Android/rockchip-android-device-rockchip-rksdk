# Copyright (C) 2011 rockchip Limited
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

# Everything in this directory will become public


$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)


########################################################
# Kernel
########################################################
PRODUCT_COPY_FILES += \
    $(TARGET_PREBUILT_KERNEL):kernel

ifeq ($(strip $(BOARD_USE_LCDC_COMPOSER)), true)
include frameworks/native/build/tablet-10in-xhdpi-2048-dalvik-heap.mk
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.lockprof.threshold=500 \
    dalvik.vm.dexopt-flags=m=y \
    dalvik.vm.stack-trace-file=/data/anr/traces.txt \
    ro.hwui.texture_cache_size=72 \
    ro.hwui.layer_cache_size=48 \
    ro.hwui.path_cache_size=16 \
    ro.hwui.shape_cache_size=4 \
    ro.hwui.gradient_cache_size=1 \
    ro.hwui.drop_shadow_cache_size=6 \
    ro.hwui.texture_cache_flush_rate=0.4 \
    ro.hwui.text_small_cache_width=1024 \
    ro.hwui.text_small_cache_height=1024 \
    ro.hwui.text_large_cache_width=2048 \
    ro.hwui.text_large_cache_height=1024 \
    ro.hwui.disable_scissor_opt=true \
    persist.sys.ui.hw=true

else
ifeq ($(strip $(BOARD_USE_LOW_MEM)), true)
include frameworks/native/build/tablet-dalvik-heap.mk
else
include frameworks/native/build/tablet-7in-hdpi-1024-dalvik-heap.mk
endif
endif

PRODUCT_PACKAGES += WifiDisplay
PRODUCT_PACKAGES += Email
PRODUCT_PACKAGES += StressTest

#########################################################
# Copy proprietary apk
#########################################################
include device/rockchip/common/app/rkapk.mk

########################################################
# Google applications
########################################################
ifeq ($(strip $(BUILD_WITH_GOOGLE_MARKET)),true)
include vendor/google/googleapp.mk
endif

########################################################
# Face lock
########################################################
ifeq ($(strip $(BUILD_WITH_FACELOCK)),true)
include vendor/google/facelock.mk
endif

########################################################
#rksu
########################################################
ifeq ($(strip $(BUILD_WITH_RKSU)),true)
PRODUCT_COPY_FILES += \
	device/rockchip/$(TARGET_PRODUCT)/rksu:system/xbin/rksu
endif

PRODUCT_COPY_FILES += \
    device/rockchip/$(TARGET_PRODUCT)/init.rc:root/init.rc \
    device/rockchip/$(TARGET_PRODUCT)/init.environ.rc:root/init.environ.rc \
    device/rockchip/$(TARGET_PRODUCT)/init.$(TARGET_BOARD_HARDWARE).rc:root/init.$(TARGET_BOARD_HARDWARE).rc \
    device/rockchip/$(TARGET_PRODUCT)/init.$(TARGET_BOARD_HARDWARE).usb.rc:root/init.$(TARGET_BOARD_HARDWARE).usb.rc \
    $(call add-to-product-copy-files-if-exists,device/rockchip/$(TARGET_PRODUCT)/init.$(TARGET_BOARD_HARDWARE).bootmode.emmc.rc:root/init.$(TARGET_BOARD_HARDWARE).bootmode.emmc.rc) \
    $(call add-to-product-copy-files-if-exists,device/rockchip/$(TARGET_PRODUCT)/init.$(TARGET_BOARD_HARDWARE).bootmode.unknown.rc:root/init.$(TARGET_BOARD_HARDWARE).bootmode.unknown.rc) \
    device/rockchip/$(TARGET_PRODUCT)/ueventd.$(TARGET_BOARD_HARDWARE).rc:root/ueventd.$(TARGET_BOARD_HARDWARE).rc \
    device/rockchip/$(TARGET_PRODUCT)/media_profiles_default.xml:system/etc/media_profiles_default.xml \
    device/rockchip/$(TARGET_PRODUCT)/alarm_filter.xml:system/etc/alarm_filter.xml \
    device/rockchip/$(TARGET_PRODUCT)/rk29-keypad.kl:system/usr/keylayout/rk29-keypad.kl

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio_policy.conf:system/etc/audio_policy.conf


PRODUCT_COPY_FILES += \
    device/rockchip/$(TARGET_PRODUCT)/fstab.rk30board:root/fstab.rk30board 

# For audio-recoard 
PRODUCT_PACKAGES += \
    libsrec_jni

ifeq ($(strip $(TARGET_BOARD_PLATFORM_GPU)), pvr)
include device/rockchip/common/gpu/rk3168_gpu.mk
include device/rockchip/common/vpu/rk30_vpu.mk
include device/rockchip/common/wifi/rk30_wifi.mk
include device/rockchip/common/nand/rk30_nand.mk
include device/rockchip/common/ipp/rk29_ipp.mk
else
ifeq ($(strip $(TARGET_BOARD_PLATFORM)), rk2928)
include device/rockchip/common/gpu/rk2928_gpu.mk
include device/rockchip/common/vpu/rk2928_vpu.mk
include device/rockchip/common/wifi/rk2928_wifi.mk
include device/rockchip/common/nand/rk2928_nand.mk
else
ifeq ($(strip $(TARGET_BOARD_PLATFORM)), rk3026)
include device/rockchip/common/gpu/rk30xx_gpu.mk
include device/rockchip/common/vpu/rk3026_vpu.mk
include device/rockchip/common/wifi/rk30_wifi.mk
include device/rockchip/common/nand/rk3026_nand.mk
include device/rockchip/common/ipp/rk29_ipp.mk
else
include device/rockchip/common/gpu/rk30xx_gpu.mk  
#include device/rockchip/common/vpu/rk30_vpu.mk
include device/rockchip/common/wifi/rk30_wifi.mk
include device/rockchip/common/nand/rk30_nand.mk
include device/rockchip/common/ipp/rk29_ipp.mk
endif
endif
endif

include device/rockchip/common/ion/rk30_ion.mk
include device/rockchip/common/bin/rk30_bin.mk
include device/rockchip/common/webkit/rk31_webkit.mk
ifeq ($(strip $(BOARD_HAVE_BLUETOOTH)),true)
    include device/rockchip/common/bluetooth/rk30_bt.mk
endif
include device/rockchip/common/gps/rk30_gps.mk
include device/rockchip/common/app/rkupdateservice.mk
#include vendor/google/chrome.mk
include device/rockchip/common/etc/adblock.mk

# uncomment the line bellow to enable phone functions
include device/rockchip/common/phone/rk30_phone.mk

include device/rockchip/common/features/rk-core.mk
include device/rockchip/common/features/rk-camera.mk
include device/rockchip/common/features/rk-camera-front.mk
include device/rockchip/common/features/rk-gms.mk

ifeq ($(strip $(BUILD_WITH_RK_EBOOK)),true)
include device/rockchip/common/app/rkbook.mk
endif

# Live Wallpapers
PRODUCT_PACKAGES += \
    LiveWallpapersPicker \
    NoiseField \
    PhaseBeam \
    librs_jni \
    libjni_pinyinime \
    hostapd_rtl

# HAL
PRODUCT_PACKAGES += \
    power.$(TARGET_BOARD_PLATFORM) \
    sensors.$(TARGET_BOARD_HARDWARE) \
    gralloc.$(TARGET_BOARD_HARDWARE) \
    hwcomposer.$(TARGET_BOARD_HARDWARE) \
    lights.$(TARGET_BOARD_HARDWARE) \
    camera.$(TARGET_BOARD_HARDWARE) \
    Camera \
    akmd 

# charge
PRODUCT_PACKAGES += \
    charger \
    charger_res_images 

# drmservice
PRODUCT_PACKAGES += \
    drmservice

PRODUCT_CHARACTERISTICS := tablet

# audio lib
PRODUCT_PACKAGES += \
    audio_policy.$(TARGET_BOARD_HARDWARE) \
    audio.primary.$(TARGET_BOARD_HARDWARE) \
    audio.a2dp.default\
    audio.r_submix.default\
    audio.usb.default

# Filesystem management tools
# EXT3/4 support
PRODUCT_PACKAGES += \
    mke2fs \
    e2fsck \
    tune2fs \
    resize2fs \
    mkdosfs

# audio lib
PRODUCT_PACKAGES += \
    libasound \
    alsa.default \
    acoustics.default \
    libtinyalsa

PRODUCT_PACKAGES += \
	alsa.audio.primary.$(TARGET_BOARD_HARDWARE)\
	alsa.audio_policy.$(TARGET_BOARD_HARDWARE)

$(call inherit-product-if-exists, external/alsa-lib/copy.mk)
$(call inherit-product-if-exists, external/alsa-utils/copy.mk)


PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.strictmode.visual=false \
    dalvik.vm.jniopts=warnonly

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

ifeq ($(strip $(MT7601U_WIFI_SUPPORT)),true)
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.wifichip=mt7601u
endif


PRODUCT_TAGS += dalvik.gc.type-precise


PRODUCT_PROPERTY_OVERRIDES += \
       persist.sys.usb.config=mtp,adb \
       testing.mediascanner.skiplist = /storage/sdcard0/Android/


# NTFS support
PRODUCT_PACKAGES += \
    ntfs-3g

PRODUCT_PACKAGES += \
    com.android.future.usb.accessory

PRODUCT_PACKAGES += \
#    librecovery_ui_$(TARGET_PRODUCT)

# for bugreport
ifneq ($(TARGET_BUILD_VARIANT),user)
    PRODUCT_COPY_FILES += device/rockchip/$(TARGET_PRODUCT)/bugreport.sh:system/bin/bugreport.sh
endif


ifeq ($(strip $(BOARD_BOOT_READAHEAD)),true)
    PRODUCT_COPY_FILES += \
        $(LOCAL_PATH)/proprietary/readahead/readahead:root/sbin/readahead \
        $(LOCAL_PATH)/proprietary/readahead/readahead_list.txt:root/readahead_list.txt
endif

#whtest for bin
PRODUCT_COPY_FILES += \
    device/rockchip/$(TARGET_PRODUCT)/whtest.sh:system/bin/whtest.sh
    
# for data clone
include device/rockchip/common/data_clone/packdata.mk

$(call inherit-product, external/wlan_loader/wifi-firmware.mk)

