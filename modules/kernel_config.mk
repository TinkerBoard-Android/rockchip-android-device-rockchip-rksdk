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

ifeq ($(BOARD_BUILD_GKI),true)
PRODUCT_KERNEL_CONFIG := gki_defconfig rockchip_gki.config
else # Regular build
PRODUCT_KERNEL_CONFIG := rockchip_defconfig
ifeq ($(BUILD_WITH_GO_OPT), true)
PRODUCT_KERNEL_CONFIG += android-13-go.config
else
PRODUCT_KERNEL_CONFIG += android-13.config
endif

ifeq ($(TARGET_BUILD_VARIANT), user)
PRODUCT_KERNEL_CONFIG += non_debuggable.config
endif
endif
