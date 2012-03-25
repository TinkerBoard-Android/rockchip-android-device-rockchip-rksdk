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


PRODUCT_COPY_FILES := \
        device/rockchip/rk30sdk/vold.fstab:system/etc/vold.fstab \
        device/rockchip/rk30sdk/egl.cfg:system/lib/egl/egl.cfg

########################################################
# Kernel
########################################################
PRODUCT_COPY_FILES += \
    $(TARGET_PREBUILT_KERNEL):kernel

###########################################################
## Find all of the apk files under the named directories.
## Meant to be used like:
##    SRC_FILES := $(call all-apk-files-under,src tests)
###########################################################
define all-apk-files-under
$(patsubst ./%,%, \
  $(shell cd $(LOCAL_PATH)/$(1) ; \
          find ./ -maxdepth 1  -name "*.apk" -and -not -name ".*") \
 )
endef

#########################################################
#  copy proprietary apk
#########################################################
COPY_APK_TARGET := $(call all-apk-files-under,apk)
PRODUCT_COPY_FILES += $(foreach apkName, $(COPY_APK_TARGET), \
	$(addprefix $(LOCAL_PATH)/apk/, $(apkName)):$(addprefix system/app/, $(apkName)))

PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/apk/flashplayer:system/app/flashplayer


########################################################
#  RKUpdateService: RKUpdateService.apk
########################################################
rk_apps_files := $(shell ls $(LOCAL_PATH)/apk/RKUpdateService | grep .apk)
PRODUCT_COPY_FILES += $(foreach file, $(rk_apps_files), \
        $(LOCAL_PATH)/apk/RKUpdateService/$(file):system/app/$(file))

########################################################
#  RKUpdateService: librockchip_update_jni.so
########################################################
PRODUCT_COPY_FILES += $(LOCAL_PATH)/apk/RKUpdateService/librockchip_update_jni.so:system/lib/librockchip_update_jni.so

PRODUCT_COPY_FILES += \
        device/rockchip/rk30sdk/init.rc:root/init.rc \
        device/rockchip/rk30sdk/init.rk30board.rc:root/init.rk30board.rc \
        device/rockchip/rk30sdk/init.rk30board.usb.rc:root/init.rk30board.usb.rc \
        device/rockchip/rk30sdk/ueventd.rk30board.rc:root/ueventd.rk30board.rc  

PRODUCT_COPY_FILES += \
        device/rockchip/rk30sdk/rk30xxnand_ko.ko.3.0.8+:root/rk30xxnand_ko.ko.3.0.8+ 
        
PRODUCT_COPY_FILES += \
        device/rockchip/rk30sdk/proprietary/libmali/libMali.so:system/lib/libMali.so \
        device/rockchip/rk30sdk/proprietary/libmali/libUMP.so:system/lib/libUMP.so \
        device/rockchip/rk30sdk/proprietary/libmali/libEGL_mali.so:system/lib/egl/libEGL_mali.so \
        device/rockchip/rk30sdk/proprietary/libmali/libGLESv1_CM_mali.so:system/lib/egl/libGLESv1_CM_mali.so \
        device/rockchip/rk30sdk/proprietary/libmali/libGLESv2_mali.so:system/lib/egl/libGLESv2_mali.so \
        device/rockchip/rk30sdk/proprietary/libmali/mali.ko:system/modules/mali.ko \
        device/rockchip/rk30sdk/proprietary/libmali/ump.ko:system/modules/ump.ko \
        device/rockchip/rk30sdk/proprietary/libmali/gralloc.rk30board.so:system/lib/hw/gralloc.rk30board.so

PRODUCT_COPY_FILES += \
	device/rockchip/rk30sdk/proprietary/bin/io:system/xbin/io \
	device/rockchip/rk30sdk/proprietary/bin/busybox:system/bin/busybox 

#########################################################
#       vpu lib
#########################################################        
targetFile := $(shell ls $(LOCAL_PATH)/proprietary/libvpu )
PRODUCT_COPY_FILES += \
        $(foreach file, $(targetFile), $(LOCAL_PATH)/proprietary/libvpu/$(file):system/lib/$(file))

PRODUCT_COPY_FILES += \
        $(foreach file, $(targetFile), $(LOCAL_PATH)/proprietary/libvpu/$(file):obj/lib/$(file))

# These are the hardware-specific features
PRODUCT_COPY_FILES += \
        frameworks/base/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
        frameworks/base/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
		frameworks/base/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \
        frameworks/base/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
        frameworks/base/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
        frameworks/base/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
        packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:system/etc/permissions/android.software.live_wallpaper.xml \
         frameworks/base/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
         frameworks/base/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
         frameworks/base/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
	 frameworks/base/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml

# Live Wallpapers
PRODUCT_PACKAGES += \
        LiveWallpapersPicker \
        NoiseField \
        PhaseBeam \
        librs_jni \
        libjni_pinyinime \
		charger \
		charger_res_images \
		hostapd_rtl

PRODUCT_CHARACTERISTICS := tablet

# Filesystem management tools
# EXT3/4 support
PRODUCT_PACKAGES += \
	mke2fs \
	e2fsck \
	tune2fs \
	resize2fs \
	mkdosfs


PRODUCT_PROPERTY_OVERRIDES += \
        persist.sys.usb.config=mtp \
        persist.sys.strictmode.visual=false \
        dalvik.vm.jniopts=warnonly \
        ro.sf.hwrotation=270 \
        ro.sf.fakerotation=true \

PRODUCT_TAGS += dalvik.gc.type-precise

# NTFS support
PRODUCT_PACKAGES += \
    ntfs-3g

PRODUCT_PACKAGES += \
        com.android.future.usb.accessory

# for bugreport
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_COPY_FILES += device/rockchip/rk30sdk/bugreport.sh:system/bin/bugreport.sh
endif

$(call inherit-product, frameworks/base/build/phone-xhdpi-1024-dalvik-heap.mk)
