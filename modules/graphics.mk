#
# Copyright 2023 Rockchip Limited
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

# mali-G610 的 GPU 架构实际上是 Mali valhall, 但 ARM 对 bifrost 和 valhall 提供同一套的 gralloc 和 DDK 源码.
ifneq (,$(filter  mali-tDVx mali-G52 mali-G610, $(TARGET_BOARD_PLATFORM_GPU)))
BOARD_VENDOR_GPU_PLATFORM := bifrost
endif

ifneq (,$(filter  mali-t860 mali-t760, $(TARGET_BOARD_PLATFORM_GPU)))
BOARD_VENDOR_GPU_PLATFORM := midgard
endif

#For CTS
PRODUCT_PROPERTY_OVERRIDES += \
    ro.surface_flinger.has_HDR_display=false

# For EGL
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.egl=${TARGET_BOARD_HARDWARE_EGL}

# TEMP: Hack for mali gles
PRODUCT_PACKAGES += \
    android.hardware.graphics.common-V3-ndk.vendor

# For screen hw rotation
ifneq ($(filter 90 180 270, $(strip $(SF_PRIMARY_DISPLAY_ORIENTATION))), )
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
	ro.surface_flinger.primary_display_orientation=ORIENTATION_$(SF_PRIMARY_DISPLAY_ORIENTATION)
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += debug.sf.ignore_hwc_physical_display_orientation=true
endif

PRODUCT_COPY_FILES += \
    hardware/rockchip/libgraphicpolicy/graphic_profiles.conf:$(TARGET_COPY_OUT_VENDOR)/etc/graphic/graphic_profiles.conf

# opengl aep feature
ifeq ($(BOARD_OPENGL_AEP),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml
endif

# define MPP_BUF_TYPE_DRM 1
# define MPP_BUF_TYPE_ION_LEGACY 2
# define MPP_BUF_TYPE_ION_404 3
# define MPP_BUF_TYPE_ION_419 4
# define MPP_BUF_TYPE_DMA_BUF 5
$(call soong_config_set,gralloc_rockchip,aidl,$(TARGET_RK_GRALLOC_AIDL))
ifeq ($(TARGET_RK_GRALLOC_AIDL),true)
# Gralloc AIDL
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator-V1-service \
    android.hardware.graphics.allocator-V1-$(BOARD_VENDOR_GPU_PLATFORM) \
    android.hardware.graphics.allocator-V1-arm \
    android.hardware.graphics.mapper@4.0-impl-$(BOARD_VENDOR_GPU_PLATFORM)

DEVICE_MANIFEST_FILE += \
    device/rockchip/common/manifests/android.hardware.graphics.mapper@4.0.xml
else # Use HIDL
ifeq ($(TARGET_RK_GRALLOC_VERSION),4)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.mpp_buf_type=1
# Gralloc HAL
PRODUCT_PACKAGES += \
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
endif

PRODUCT_PACKAGES += \
    rkhelper

# HW Composer
PRODUCT_PACKAGES += \
    hwcomposer.$(TARGET_BOARD_HARDWARE)

ifeq ($(TARGET_USES_HWC3_AIDL),true)
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer3-service.rockchip
else
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.1-service
endif
