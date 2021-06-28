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
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml

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

ifneq ($(strip $(BOARD_USES_AB_IMAGE)),true)
BOARD_AVB_RECOVERY_KEY_PATH := $(BOARD_AVB_KEY_PATH)
BOARD_AVB_RECOVERY_ALGORITHM := $(BOARD_AVB_ALGORITHM)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
ifdef BOARD_AVB_ROLLBACK_INDEX
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := $(BOARD_AVB_ROLLBACK_INDEX)
endif
endif #BOARD_USES_AB_IMAGE
endif # BOARD_AVB_ENABLE
