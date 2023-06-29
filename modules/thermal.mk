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

# Include this makefile to support HARDWARE_PROPERTIES_SERVICE.
# Set BOARD_ROCKCHIP_THERMAL := true to build thermal HAL support.
ifeq ($(BOARD_ROCKCHIP_THERMAL),true)
PRODUCT_PACKAGES += \
    android.hardware.thermal-service.rockchip

BOARD_SEPOLICY_DIRS += hardware/rockchip/thermal/sepolicy
endif
