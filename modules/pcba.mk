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

# Include this makefile to support PCBA Test.
ifeq ($(strip $(TARGET_ROCKCHIP_PCBATEST)), true)
PRODUCT_PACKAGES += \
    pcba_core \
    bdt

PRODUCT_COPY_FILES += \
   $(TARGET_DEVICE_DIR)/bt_vendor.conf:$(PRODUCT_OUT)/$(TARGET_COPY_OUT_RECOVERY)/root/pcba/bt_vendor.conf \
   $(call find-copy-subdir-files,*,bootable/recovery/pcba_core/res,$(PRODUCT_OUT)/$(TARGET_COPY_OUT_RECOVERY)/root/pcba) \
   $(call find-copy-subdir-files,"*.ko",$(TOPDIR)$(PRODUCT_KERNEL_PATH)/drivers/net/wireless/rockchip_wlan,$(PRODUCT_OUT)/$(TARGET_COPY_OUT_RECOVERY)/root/pcba/lib/modules) \
    $(call find-copy-subdir-files,*,vendor/rockchip/common/wifi/firmware,$(PRODUCT_OUT)/$(TARGET_COPY_OUT_RECOVERY)/root/vendor/etc/firmware)
endif
