#
# Copyright 2024 Rockchip Limited
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

PRODUCT_PACKAGES := android.hardware.biometrics.face-service.optee

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.biometrics.face.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.biometrics.face.xml
ifneq ($(filter rk312x rk322x rk3288 rk3328 rk322xh rk3368 rk3399 rk3399pro, $(strip $(TARGET_BOARD_PLATFORM))), )
PRODUCT_PACKAGES += \
    d181d366-1ad1-11ee-be560242ac120002.ta
else
PRODUCT_PACKAGES += \
    d181d366-1ad1-11ee-be56-0242ac120002.ta
endif

BOARD_SEPOLICY_DIRS += \
     hardware/rockchip/face/sepolicy

include hardware/rockchip/face/rockiva/rockiva.mk
