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

#begin Add Rockchip BOX/ATV Apps
ifeq ($(TARGET_BOARD_PLATFORM_PRODUCT),box)
PRODUCT_PACKAGES := \
    RKUpdateService \
    RKDeviceTest \
    RKTvLauncher \
    PinyinIME \
    WifiDisplay \
    DLNA

ifneq ($(strip $(BUILD_WITH_GOOGLE_MARKET)), true)
    PRODUCT_PACKAGES += \
        Lightning
endif

ifeq ($(strip $(BOARD_HAS_STRESSTEST_APP)), true)
    PRODUCT_PACKAGES += \
        StressTest
endif

ifeq ($(BOARD_TV_LOW_MEMOPT), false)
    PRODUCT_PACKAGES += \
        ChangeLedStatus
endif
endif

# MediaCenter is required in BOX/ATV
PRODUCT_PACKAGES += \
    MediaCenter

#end Add Rockchip BOX/ATV Apps
