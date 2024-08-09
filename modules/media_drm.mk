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

# DRM service opt-in
PRODUCT_VENDOR_PROPERTIES += drm.service.enabled=true

ifeq ($(ROCKCHIP_USE_LAZY_HAL),true)
PRODUCT_PACKAGES += \
    android.hardware.cas-service.example-lazy

# Media Drm clearkey
$(call inherit-product, frameworks/av/drm/mediadrm/plugins/clearkey/service-lazy.mk)
else
PRODUCT_PACKAGES += \
    com.android.hardware.cas

# Media Drm clearkey
$(call inherit-product, frameworks/av/drm/mediadrm/plugins/clearkey/service.mk)
endif

ifneq ($(strip $(BOARD_WIDEVINE_OEMCRYPTO_LEVEL)), )
PRODUCT_PACKAGES += \
    move_widevine_data.sh
ifeq ($(ROCKCHIP_USE_LAZY_HAL),true)
PRODUCT_PACKAGES += \
    com.google.android.widevine.lazy
else
PRODUCT_PACKAGES += \
    com.google.android.widevine.nonupdatable
endif
ifeq ($(BOARD_WIDEVINE_OEMCRYPTO_LEVEL), 1)
    PRODUCT_VENDOR_LINKER_CONFIG_FRAGMENTS += \
        vendor/widevine/libwvdrmengine/apex/device/linker.config.json
    PRODUCT_PACKAGES += \
        liboemcrypto
    ifneq ($(filter rk312x rk322x rk3288 rk3328 rk322xh rk3368 rk3399 rk3399pro, $(strip $(TARGET_BOARD_PLATFORM))), )
        PRODUCT_PACKAGES += \
            c11fe8ac-b997-48cf-a28de2a55e5240ef.ta
    else
        PRODUCT_PACKAGES += \
            c11fe8ac-b997-48cf-a28d-e2a55e5240ef.ta
    endif
endif # Widevine L1
endif
