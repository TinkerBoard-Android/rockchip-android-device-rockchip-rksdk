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

ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 4)))

DTBO_APPEND_FIX := device/rockchip/$(TARGET_BOARD_PLATFORM)/dtbo_gki_fix.dts

# Enforce generic ramdisk allow list
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

TARGET_NO_KERNEL := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true

# Build recovery res to vendor-ramdisk
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true

# Build GSI avb keys to vendor-ramdisk
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

ifeq ($(BOARD_USES_AB_IMAGE),true)
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
else
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := false
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
