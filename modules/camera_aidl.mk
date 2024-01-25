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

# Camera profiles
$(call inherit-product-if-exists, hardware/rockchip/camera/Config/rk32xx_camera.mk)
$(call inherit-product-if-exists, hardware/rockchip/camera/Config/user.mk)
$(call inherit-product-if-exists, hardware/rockchip/camera/etc/camera_etc.mk)

# EXT
# Camera external
ifeq ($(BOARD_CAMERA_SUPPORT_EXT),true)

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.camera.external.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.external.xml

ifdef PRODUCT_USB_CAMERA_CONFIG
PRODUCT_COPY_FILES += \
    $(PRODUCT_USB_CAMERA_CONFIG):$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml
else #PRODUCT_USB_CAMERA_CONFIG
PRODUCT_COPY_FILES += \
    device/rockchip/common/external_camera_config.xml:$(TARGET_COPY_OUT_VENDOR)/etc/external_camera_config.xml
endif #PRODUCT_USB_CAMERA_CONFIG

#use aidl
PRODUCT_PACKAGES += \
    android.hardware.camera.provider-V1-external-impl-rk \
    android.hardware.camera.provider-V1-external-service-rk \

endif #BOARD_CAMERA_SUPPORT_EXT

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

#use aidl
PRODUCT_PACKAGES += \
    android.hardware.camera.provider-V1-service

ifeq ($(CAMERA_SUPPORT_HDMI),true)
PRODUCT_PACKAGES += \
    android.hardware.camera.provider-V1-hdmi-service \
    rockchip.hardware.hdmi@1.0-service \
    rockchip.hardware.hdmi@1.0-impl
endif #CAMERA_SUPPORT_HDMI

ifeq ($(CAMERA_SUPPORT_VIRTUAL),true)
PRODUCT_PACKAGES += \
    android.hardware.camera.provider-V1-virtual-service \
    libdata_bridge \
    rockchip.hardware.hdmi@1.0-service \
    rockchip.hardware.hdmi@1.0-impl
$(call inherit-product-if-exists, hardware/rockchip/camera_aidl/etc/camera_etc.mk)
endif #CAMERA_SUPPORT_VIRTUAL

#enable eptz
ifeq ($(PRODUCT_HAVE_EPTZ),true)
PRODUCT_VENDOR_PROPERTIES += vendor.camera.eptz.mode=1
endif
