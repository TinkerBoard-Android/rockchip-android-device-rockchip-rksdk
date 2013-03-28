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

include frameworks/native/build/tablet-7in-hdpi-1024-dalvik-heap.mk

PRODUCT_PACKAGES += Email

#########################################################
# Copy proprietary apk
#########################################################
include device/rockchip/common/app/rkapk.mk

########################################################
# Google applications
########################################################
ifeq ($(strip $(BUILD_WITH_GOOGLE_MARKET)),true)
include device/rockchip/common/app/googleapp.mk
endif

########################################################
# Face lock
########################################################
ifeq ($(strip $(BUILD_WITH_FACELOCK)),true)
include device/rockchip/common/app/facelock.mk
endif


PRODUCT_COPY_FILES += \
    device/rockchip/rk30sdk/init.rc:root/init.rc \
    device/rockchip/rk30sdk/init.$(TARGET_BOARD_HARDWARE).rc:root/init.$(TARGET_BOARD_HARDWARE).rc \
    device/rockchip/rk30sdk/init.$(TARGET_BOARD_HARDWARE).usb.rc:root/init.$(TARGET_BOARD_HARDWARE).usb.rc \
    device/rockchip/rk30sdk/ueventd.$(TARGET_BOARD_HARDWARE).rc:root/ueventd.$(TARGET_BOARD_HARDWARE).rc \
    device/rockchip/rk30sdk/media_profiles.xml:system/etc/media_profiles.xml \
    device/rockchip/rk30sdk/alarm_filter.xml:system/etc/alarm_filter.xml \
    device/rockchip/rk30sdk/rk29-keypad.kl:system/usr/keylayout/rk29-keypad.kl

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/audio_policy.conf:system/etc/audio_policy.conf


PRODUCT_COPY_FILES += \
    device/rockchip/rk30sdk/vold.fstab:system/etc/vold.fstab 

# For audio-recoard 
PRODUCT_PACKAGES += \
    libsrec_jni

ifeq ($(TARGET_BOARD_PLATFORM),rk30xx)
include device/rockchip/common/gpu/rk30xx_gpu.mk  
else
include device/rockchip/common/gpu/rk3168_gpu.mk
endif

include device/rockchip/common/ipp/rk29_ipp.mk
include device/rockchip/common/ion/rk30_ion.mk
include device/rockchip/common/bin/rk30_bin.mk
include device/rockchip/common/nand/rk30_nand.mk
include device/rockchip/common/webkit/rk31_webkit.mk
include device/rockchip/common/vpu/rk30_vpu.mk
include device/rockchip/common/wifi/rk30_wifi.mk
ifeq ($(strip $(BOARD_HAVE_BLUETOOTH)),true)
    include device/rockchip/common/bluetooth/rk30_bt.mk
endif
include device/rockchip/common/app/rkupdateservice.mk
include device/rockchip/common/app/chrome.mk
include device/rockchip/common/etc/adblock.mk
include device/rockchip/common/phone/rk30_phone.mk
include device/rockchip/common/features/rk-core.mk
include device/rockchip/common/features/rk-camera.mk
include device/rockchip/common/features/rk-camera-front.mk

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
    audio.r_submix.default

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
    acoustics.default

PRODUCT_PACKAGES += \
	alsa.audio.primary.$(TARGET_BOARD_HARDWARE)\
	alsa.audio_policy.$(TARGET_BOARD_HARDWARE)

$(call inherit-product-if-exists, external/alsa-lib/copy.mk)
$(call inherit-product-if-exists, external/alsa-utils/copy.mk)


PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.strictmode.visual=false \
    dalvik.vm.jniopts=warnonly \
    ro.rksdk.version=RK30_ANDROID$(PLATFORM_VERSION)-SDK-v1.00.00 \
    sys.hwc.compose_policy=6 \
    sf.power.control=2073600 \
    ro.sf.fakerotation=true \
    ro.sf.hwrotation=270 \
    ro.rk.MassStorage=false \
    ro.rk.systembar.voiceicon=false \
    wifi.interface=wlan0 \
    ro.tether.denied=false \
    ro.sf.lcd_density=160 \
    ro.rk.screenoff_time=60000 \
    ro.rk.def_brightness=200\
    ro.rk.homepage_base=http://www.google.com/webhp?client={CID}&amp;source=android-home\
    ro.rk.install_non_market_apps=false\
    ro.default.size=100\
    persist.sys.timezone=Atlantic/Azores\
    ro.product.usbfactory=rockchip_usb \
    wifi.supplicant_scan_interval=15 \
    ro.opengles.version=131072 \
    ro.factory.tool=0 \
    ro.kernel.android.checkjni=0


ifeq ($(strip $(BOARD_HAVE_BLUETOOTH)),true)
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.bt_enable=true
else
    PRODUCT_PROPERTY_OVERRIDES += ro.rk.bt_enable=false
endif

PRODUCT_TAGS += dalvik.gc.type-precise


# if no flash partition,set this property
ifeq ($(strip $(BUILD_WITH_NOFLASH)),true)
PRODUCT_PROPERTY_OVERRIDES += \
       ro.factory.storage_policy=1 \
       persist.sys.usb.config=mtp \
       testing.mediascanner.skiplist = /storage/sdcard0/Android/
else
PRODUCT_PROPERTY_OVERRIDES += \
       ro.factory.storage_policy=0 \
       persist.sys.usb.config=mass_storage \
       testing.mediascanner.skiplist = /mnt/sdcard/Android/
endif


# NTFS support
PRODUCT_PACKAGES += \
    ntfs-3g

PRODUCT_PACKAGES += \
    com.android.future.usb.accessory

PRODUCT_PACKAGES += \
    librecovery_ui_rk30sdk

# for bugreport
ifneq ($(TARGET_BUILD_VARIANT),user)
    PRODUCT_COPY_FILES += device/rockchip/rk30sdk/bugreport.sh:system/bin/bugreport.sh
endif


ifeq ($(strip $(BOARD_BOOT_READAHEAD)),true)
    PRODUCT_COPY_FILES += \
        $(LOCAL_PATH)/proprietary/readahead/readahead:root/sbin/readahead \
        $(LOCAL_PATH)/proprietary/readahead/readahead_list.txt:root/readahead_list.txt
endif

#whtest for bin
PRODUCT_COPY_FILES += \
    device/rockchip/rk30sdk/whtest.sh:system/bin/whtest.sh

$(call inherit-product, external/wlan_loader/wifi-firmware.mk)

