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

ifeq ($(strip $(BOARD_USES_AB_IMAGE)), true)
PRODUCT_PACKAGES += \
    update_engine \
    update_verifier	\
    cppreopts.sh

PRODUCT_PACKAGES += \
    update_engine_sideload \
    sg_write_buffer \
    f2fs_io \
    check_f2fs

PRODUCT_PACKAGES += \
    update_engine_client

AB_OTA_PARTITIONS += \
    boot \
    system	\
    uboot	\
    vendor	\
    odm	\
    dtbo

ifneq ($(strip $(BOARD_ROCKCHIP_TRUST_MERGE_TO_UBOOT)),true)
AB_OTA_PARTITIONS += \
    trust
endif

ifeq ($(strip $(BOARD_AVB_ENABLE)),true)
AB_OTA_PARTITIONS += \
    vbmeta
endif

ifndef BOARD_USES_AB_LEGACY_RETROFIT
AB_OTA_PARTITIONS += \
    system_dlkm \
    system_ext \
    vendor_dlkm \
    odm_dlkm \
    product
endif

ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 3)))
AB_OTA_PARTITIONS += \
    resource \
    vendor_boot

ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 4)))
AB_OTA_PARTITIONS += \
    init_boot
endif

endif
# Boot control HAL
PRODUCT_PACKAGES += \
    android.hardware.boot@1.2-service \
    android.hardware.boot@1.2-impl-rockchip \
    android.hardware.boot@1.2-impl-rockchip.recovery

ifeq ($(strip $(BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE)),true)
ifeq ($(strip $(BOARD_ROCKCHIP_VIRTUAL_AB_COMPRESSION)),true)
ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 3)))
$(call inherit-product, \
    $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_with_xor.mk)
else
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_retrofit.mk)
endif
else
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
endif
endif

ifeq ($(strip $(BOARD_USES_VIRTUAL_AB_RETROFIT)),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota_retrofit.mk)
endif

PRODUCT_PACKAGES += \
  bootctrl.rk30board \
  bootctrl.rk30board.recovery

PRODUCT_PACKAGES_DEBUG += \
    bootctl

# A/B OTA dexopt package
PRODUCT_PACKAGES += otapreopt_script

# A/B OTA dexopt update_engine hookup
AB_OTA_POSTINSTALL_CONFIG += \
    RUN_POSTINSTALL_system=true \
    POSTINSTALL_PATH_system=system/bin/otapreopt_script \
    FILESYSTEM_TYPE_system=ext4 \
    POSTINSTALL_OPTIONAL_system=true
else
PRODUCT_PACKAGES += \
    applypatch
endif
