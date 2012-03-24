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

PRODUCT_COPY_FILES += \
        device/rockchip/rk30sdk/init.rc:root/init.rc \
        device/rockchip/rk30sdk/init.rk30board.rc:root/init.rk30board.rc \
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

#########################################################
#       vpu lib
#########################################################        
targetFile := $(shell ls $(LOCAL_PATH)/proprietary/libvpu )
PRODUCT_COPY_FILES += \
        $(foreach file, $(targetFile), $(LOCAL_PATH)/proprietary/libvpu/$(file):system/lib/$(file))

PRODUCT_COPY_FILES += \
        $(foreach file, $(targetFile), $(LOCAL_PATH)/proprietary/libvpu/$(file):obj/lib/$(file))



PRODUCT_COPY_FILES += \
        frameworks/base/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml 
        
PRODUCT_PROPERTY_OVERRIDES := \
        hwui.render_dirty_regions=false \
        vold.encrypt_progress=close

PRODUCT_CHARACTERISTICS := tablet

PRODUCT_TAGS += dalvik.gc.type-precise

PRODUCT_PACKAGES += \
        librs_jni \
        com.android.future.usb.accessory

# Filesystem management tools
#PRODUCT_PACKAGES += \
#        make_ext4fs

$(call inherit-product, frameworks/base/build/tablet-dalvik-heap.mk)
