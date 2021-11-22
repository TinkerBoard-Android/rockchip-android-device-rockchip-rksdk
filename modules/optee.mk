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

#for enable optee support
ifeq ($(strip $(PRODUCT_HAVE_OPTEE)),true)

# Use keymint 1.0 to support app_attest_key
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.keystore.app_attest_key.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.keystore.app_attest_key.xml

PRODUCT_PACKAGES += \
    tee-supplicant \
    android.hardware.gatekeeper@1.0-service.optee \
    android.hardware.keymaster@4.0-service.optee \
    android.hardware.security.keymint-service.optee \
    android.hardware.weaver@1.0-service \
    android.hardware.weaver@1.0-impl

ifneq ($(filter rk3326 rk356x rk3588, $(strip $(TARGET_BOARD_PLATFORM))), )

PRODUCT_PACKAGES += \
    0b82bae5-0cd0-49a5-9521-516dba9c43ba.ta \
    258be795-f9ca-40e6-a869-9ce6886c5d5d.ta \
    481a57df-aec8-47ad-92f5-eb9fc24f64a6.ta

else

PRODUCT_PACKAGES += \
    0b82bae5-0cd0-49a5-9521516dba9c43ba.ta \
    258be795-f9ca-40e6-a8699ce6886c5d5d.ta \
    481a57df-aec8-47ad-92f5eb9fc24f64a6.ta

#Choose TEE storage type
#auto (storage type decide by storage chip emmc:rpmb nand:rkss)
#rpmb
#rkss
PRODUCT_PROPERTY_OVERRIDES += ro.tee.storage=rkss

endif

else

PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.0-service \
    android.hardware.gatekeeper@1.0-service.software

DEVICE_MANIFEST_FILE += device/rockchip/common/manifests/android.hardware.keymaster@4.0-service.xml

endif
