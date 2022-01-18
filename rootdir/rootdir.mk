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

ROCKCHIP_ROOT_DIR_PATH := device/rockchip/common/rootdir

PRODUCT_COPY_FILES += \
    $(ROCKCHIP_ROOT_DIR_PATH)/init.rockchip.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.rockchip.rc \
    $(ROCKCHIP_ROOT_DIR_PATH)/init.mount_all_early.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.mount_all.rc \
    $(ROCKCHIP_ROOT_DIR_PATH)/init.tune_io.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.tune_io.rc \
    $(ROCKCHIP_ROOT_DIR_PATH)/init.insmod.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/init.insmod.cfg \
    $(ROCKCHIP_ROOT_DIR_PATH)/init.insmod.sh:$(TARGET_COPY_OUT_VENDOR)/bin/init.insmod.sh \
    $(ROCKCHIP_ROOT_DIR_PATH)/init.rk30board.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.$(TARGET_BOARD_HARDWARE).rc \
    $(ROCKCHIP_ROOT_DIR_PATH)/init.rk30board.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.$(TARGET_BOARD_HARDWARE).usb.rc \
    $(ROCKCHIP_ROOT_DIR_PATH)/init.recovery.rk30board.rc:recovery/root/init.recovery.$(TARGET_BOARD_HARDWARE).rc \
    $(ROCKCHIP_ROOT_DIR_PATH)/ueventd.rockchip.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \

PRODUCT_COPY_FILES += \
    $(ROCKCHIP_ROOT_DIR_PATH)/init.system.rc:$(TARGET_COPY_OUT_SYSTEM)/etc/init/init.rockchip.rc

# Default env for test.
ifneq (,$(filter userdebug eng,$(TARGET_BUILD_VARIANT)))
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    persist.dbg.keep_debugfs_mounted=1
endif
