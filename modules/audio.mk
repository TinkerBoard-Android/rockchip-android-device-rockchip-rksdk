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

RKSDK_PATH=device/rockchip/common

ifeq ($(strip $(BOARD_SUPPORT_MULTIAUDIO)), true)
    PRODUCT_COPY_FILES += \
        $(RKSDK_PATH)/audio_policy_configuration_multihal.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration_multihal.xml
else
    ifneq ($(filter car, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
        PRODUCT_COPY_FILES += \
            $(TARGET_DEVICE_DIR)/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
            $(TARGET_DEVICE_DIR)/audio/car_audio_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/car_audio_configuration.xml \
            $(TARGET_DEVICE_DIR)/audio/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
            $(TARGET_DEVICE_DIR)/audio/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml
    else
        PRODUCT_COPY_FILES += \
            $(RKSDK_PATH)/audio_policy_configuration_singlehal.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration_singlehal.xml
    endif
endif

ifeq ($(filter car, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
    PRODUCT_COPY_FILES += \
        $(RKSDK_PATH)/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml
endif


PRODUCT_COPY_FILES += \
    $(RKSDK_PATH)/audio_policy_volumes_drc.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes_drc.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml \
    frameworks/av/media/libeffects/data/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml

# For audio-recoard 
PRODUCT_PACKAGES += \
    libsrec_jni

# For tts test
PRODUCT_PACKAGES += \
    libwebrtc_audio_coding

#audio
$(call inherit-product-if-exists, hardware/rockchip/audio/tinyalsa_hal/codec_config/rk_audio.mk)
ifeq ($(strip $(BOARD_SUPPORT_MULTIAUDIO)), true)
PRODUCT_PACKAGES += \
    audio.ext_1.$(TARGET_BOARD_HARDWARE) \
    audio.ext_2.$(TARGET_BOARD_HARDWARE) \
    audio.ext_3.$(TARGET_BOARD_HARDWARE) \
    audio.ext_4.$(TARGET_BOARD_HARDWARE)
endif

# audio lib
PRODUCT_PACKAGES += \
    audio_policy.$(TARGET_BOARD_HARDWARE) \
    audio.primary.$(TARGET_BOARD_HARDWARE) \
    audio.alsa_usb.$(TARGET_BOARD_HARDWARE) \
    audio.r_submix.default \
    libaudioroute \
    audio.usb.default \
    audio.usbv2.default \
    libanr

ifeq ($(call math_gt_or_eq,$(ROCKCHIP_LUNCHING_API_LEVEL),33),true)
PRODUCT_PACKAGES += \
    android.hardware.audio.service \
    android.hardware.audio@7.1-impl
else
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-service \
    android.hardware.audio@7.0-impl
endif

PRODUCT_PACKAGES += \
    android.hardware.audio.effect@7.0-impl

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

#only box and atv using our audio policy(write by rockchip)
ifneq ($(filter atv, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
USE_CUSTOM_AUDIO_POLICY := 1
PRODUCT_PACKAGES += \
    libaudiopolicymanagercustom
endif

USE_XML_AUDIO_POLICY_CONF := 1
