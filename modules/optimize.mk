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

# Include this makefile to support speed compile.
PRODUCT_DEXPREOPT_SPEED_APPS += \
    Camera2 \
    Contacts \
    DeskClock \
    DocumentsUI \
    ExactCalculator \
    Gallery2 \
    Settings \
    SoundRecorder

PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.boot-dex2oat-threads=4 \
    dalvik.vm.dex2oat-threads=4

# Task profile
PRODUCT_PACKAGES += vendor_cgroups.json

ifdef ROCKCHIP_OEM_CONFIG_FILE
PRODUCT_COPY_FILES += \
    $(ROCKCHIP_OEM_CONFIG_FILE):$(TARGET_COPY_OUT_VENDOR)/etc/cfg_rockchip_default.xml \
    $(ROCKCHIP_OEM_CONFIG_PACKAGES):$(TARGET_COPY_OUT_VENDOR)/etc/rockchip_forbid_packages.xml
endif
