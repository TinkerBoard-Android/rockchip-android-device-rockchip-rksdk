#
# Copyright 2021 Rockchip Limited
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

# Camera profiles
$(call inherit-product-if-exists, hardware/rockchip/camera/Config/rk32xx_camera.mk)
$(call inherit-product-if-exists, hardware/rockchip/camera/Config/user.mk)
$(call inherit-product-if-exists, hardware/rockchip/camera/etc/camera_etc.mk)

# VIR or EXT
ifeq (true,$(filter true, $(BOARD_CAMERA_SUPPORT_VIR) $(BOARD_CAMERA_SUPPORT_EXT)))

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.external.xml

#EXT only
ifeq ($(BOARD_CAMERA_SUPPORT_EXT),true)
DEVICE_MANIFEST_FILE += device/rockchip/common/manifests/android.hardware.camera.provider@2.4-provider.external.xml
endif

#VIR only
ifeq ($(BOARD_CAMERA_SUPPORT_VIR),true)
DEVICE_MANIFEST_FILE += device/rockchip/common/manifests/android.hardware.camera.provider@2.4-provider.virtual.xml
endif

#both VIR and EXT
else ifneq (,$(filter true, $(BOARD_CAMERA_SUPPORT_VIR) $(BOARD_CAMERA_SUPPORT_EXT)))

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.external.xml

DEVICE_MANIFEST_FILE += device/rockchip/common/manifests/android.hardware.camera.provider@2.4-provider.external-virtual.xml

# legacy only
else
DEVICE_MANIFEST_FILE += device/rockchip/common/manifests/android.hardware.camera.provider@2.4-provider.legacy.xml
endif

#camera hal for structured light
ifeq ($(BOARD_CAMERA_SUPPORT_VIR),true)
$(call inherit-product-if-exists, hardware/rockchip/camera_vir/camera_etc.mk)

PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-virtual-service
endif

# Camera external
ifeq ($(BOARD_CAMERA_SUPPORT_EXT),true)

ifdef PRODUCT_USB_CAMERA_CONFIG
PRODUCT_COPY_FILES += \
    $(PRODUCT_USB_CAMERA_CONFIG):$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml
else
PRODUCT_COPY_FILES += \
    device/rockchip/common/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml
endif

PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-external-service
endif

# Camera Autofocus
ifeq ($(CAMERA_SUPPORT_AUTOFOCUS),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.autofocus.xml
endif

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml

# Camera HAL
PRODUCT_PACKAGES += \
    camera.$(TARGET_BOARD_HARDWARE) \
    camera.device@1.0-impl \
    camera.device@3.2-impl \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.metadata@3.2 \
    librkisp_aec \
    librkisp_af \
    librkisp_awb

ifeq ($(ROCKCHIP_USE_LAZY_HAL),true)
#if enable usb camera, can not use lazy mode
ifeq ($(BOARD_CAMERA_SUPPORT_EXT),true)
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-service
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.camera.enableLazyHal=true
ifeq ($(TARGET_ARCH), $(filter $(TARGET_ARCH), arm64))
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-service-lazy_64
else
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-service-lazy
endif
endif
else
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-service
endif

ifeq ($(CAMERA_SUPPORT_HDMI),true)
PRODUCT_PACKAGES += \
    rockchip.hardware.hdmi@1.0-service \
    rockchip.hardware.hdmi@1.0-impl
endif
