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

PRODUCT_FS_COMPRESSION := 1

#BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := f2fs
#BOARD_SYSTEMIMAGE_FILE_SYSTEM_COMPRESS := true
#BOARD_SYSTEMIMAGE_F2FS_SLOAD_COMPRESS_FLAGS := -r -L 4

TARGET_RECOVERY_FSTAB := device/rockchip/common/scripts/fstab_tools/recovery_compression.fstab
PRODUCT_FSTAB_TEMPLATE := device/rockchip/common/scripts/fstab_tools/fstab_compression.in
#BOARD_USERDATAIMAGE_PARTITION_SIZE := 8589934592
#BOARD_USERDATAIMAGE_PARTITION_SIZE := 26145193984
#PRODUCT_FSTAB_TEMPLATE := device/rockchip/rk356x/rk3566_s/fstab_userdata.in
PRODUCT_KERNEL_CONFIG += f2fs_compression.config
# Tracking flags for f2fs compressed
PRODUCT_COPY_FILES += \
    vendor/rockchip/common/gms/features/com.google.android.feature.COMPRESSED_F2FS.xml:system/etc/sysconfig/com.google.android.feature.COMPRESSED_F2FS.xml
