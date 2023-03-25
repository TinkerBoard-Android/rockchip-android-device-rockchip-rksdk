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

# https://source.android.com/devices/bootloader/partitions/generic-boot#boot-images-contents
ifeq ($(BOARD_BUILD_GKI),true)
# BOARD_BOOT_HEADER_VERSION is set to 4 due to BOARD_BUILD_GKI being set.
BOARD_BOOT_HEADER_VERSION := 4

# init_boot partition size is recommended to be 8MB, it can be larger.
# When this variable is set, init_boot.img will be built with the generic
# ramdisk, and that ramdisk will no longer be included in boot.img.
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)
PRODUCT_BUILD_INIT_BOOT_IMAGE := true
#BOARD_BUILD_GKI_BOOT_IMAGE_WITHOUT_RAMDISK := true
DTBO_APPEND_FIX := device/rockchip/$(TARGET_BOARD_PLATFORM)/dtbo_gki_fix.dts

# Enforce generic ramdisk allow list
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Build prebuilt boot image
# PRODUCT_BUILD_BOOT_IMAGE := true
TARGET_NO_KERNEL := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true
# Android 13+ required LZ4 ramdisk
BOARD_RAMDISK_USE_LZ4 := true
# Build GSI avb keys to vendor-ramdisk
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

ifeq ($(BOARD_USES_AB_IMAGE),true)
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
# Build recovery res to vendor-ramdisk
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
else
PRODUCT_BUILD_RECOVERY_IMAGE := true
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE :=
endif

# BOARD_COPY_BOOT_IMAGE_TO_TARGET_FILES := 

# GKI APEX
PRODUCT_PACKAGES += com.android.gki.kmi_5_10_android12_1

# Tools
PRODUCT_PACKAGES += \
    linker.vendor_ramdisk \
    resize2fs.vendor_ramdisk \
    tune2fs.vendor_ramdisk

# Build all KOs
$(call inherit-product, mkcombinedroot/modular_kernel.mk)
endif
