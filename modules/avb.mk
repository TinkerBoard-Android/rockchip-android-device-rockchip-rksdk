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

ifeq ($(strip $(BOARD_AVB_ENABLE)),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)
PRODUCT_PACKAGES += \
    t-gsi.avbpubkey
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml

BOARD_AVB_ALGORITHM ?= SHA256_RSA4096
BOARD_AVB_KEY_PATH ?= device/rockchip/common/avb_test_keys/testkey_atx_psk.pem

BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_ODM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_DTBO_ADD_HASH_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_BOOT_ADD_HASH_FOOTER_ARGS += --hash_algorithm sha256

# Dynamic partitions
ifeq ($(strip $(BOARD_SUPER_PARTITION_GROUPS)),rockchip_dynamic_partitions)
BOARD_AVB_SYSTEM_EXT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_VENDOR_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
BOARD_AVB_ODM_DLKM_ADD_HASHTREE_FOOTER_ARGS += --hash_algorithm sha256
endif

# Only set this when uboot enable security avb.
# BOARD_AVB_METADATA_BIN_PATH ?= device/rockchip/common/avb_test_keys/atx_metadata.bin

# Build vbmeta with public_key_metadata
# when BOARD_AVB_METADATA_BIN_PATH is set
ifdef BOARD_AVB_METADATA_BIN_PATH
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS := \
    --public_key_metadata $(BOARD_AVB_METADATA_BIN_PATH)
ifneq ($(strip $(BOARD_USES_AB_IMAGE)),true)
BOARD_AVB_RECOVERY_ADD_HASH_FOOTER_ARGS := \
    --public_key_metadata $(BOARD_AVB_METADATA_BIN_PATH)
endif #BOARD_USES_AB_IMAGE
endif #BOARD_AVB_METADATA_BIN_PATH

ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \>= 4)))
# Enable chained vbmeta for the boot image.
# The following can be absent, where the hash descriptor of the
# 'boot' partition will be stored then signed in vbmeta.img instead.
BOARD_AVB_BOOT_KEY_PATH := $(BOARD_AVB_KEY_PATH)
BOARD_AVB_BOOT_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_BOOT_ROLLBACK_INDEX ?= $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION ?= 2
BOARD_AVB_VENDOR_BOOT_ADD_HASH_FOOTER_ARGS += --hash_algorithm sha256
endif # Boot Header 4, for GKI

ifneq ($(strip $(BOARD_USES_AB_IMAGE)),true)
BOARD_AVB_RECOVERY_KEY_PATH := $(BOARD_AVB_KEY_PATH)
BOARD_AVB_RECOVERY_ALGORITHM := $(BOARD_AVB_ALGORITHM)
#BOARD_AVB_RECOVERY_KEY_PATH ?= external/avb/test/data/testkey_rsa4096.pem
#BOARD_AVB_RECOVERY_ALGORITHM ?= SHA256_RSA4096
ifdef BOARD_AVB_ROLLBACK_INDEX
BOARD_AVB_RECOVERY_ROLLBACK_INDEX ?= $(BOARD_AVB_ROLLBACK_INDEX)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION ?= 2
endif
endif # BOARD_USES_AB_IMAGE
endif # BOARD_AVB_ENABLE
