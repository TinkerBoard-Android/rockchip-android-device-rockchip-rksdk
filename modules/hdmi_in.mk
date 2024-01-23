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
# TV Apps
PRODUCT_PACKAGES += \
    TvProvider \
    rkCamera2 \
    PartnerSupportSampleTvInput

# pcie
#PRODUCT_PACKAGES += \
    lib_rk_pcie_rc.vendor \
    lib_rk_pcie_ep.vendor

# JNI
PRODUCT_PACKAGES += \
    libmedia_tv_tuner

# Frameworks service
#PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.live_tv.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.live_tv.xml

# Build tv_input HAL
PRODUCT_PACKAGES += \
    android.hardware.tv.input-service.rockchip

PRODUCT_PROPERTY_OVERRIDES += \
    vendor.hwc.enable_sideband_stream_2_mode=1

PRODUCT_PRODUCT_PROPERTIES += \
    ro.tvinput.hdmiin.enable=true
