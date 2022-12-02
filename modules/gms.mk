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

# Flash Lock Status reporting,
# GTS: com.google.android.gts.persistentdata.
# PersistentDataHostTest#testTestGetFlashLockState
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.oem_unlock_supported=1

# Add for function frp
ifeq ($(strip $(BUILD_WITH_GOOGLE_MARKET)), true)
  ifeq ($(strip $(BUILD_WITH_GOOGLE_FRP)), true)
    PRODUCT_PROPERTY_OVERRIDES += \
      ro.frp.pst=/dev/block/by-name/frp
  endif
  ifeq ($(strip $(TARGET_BUILD_VARIANT)), user)
    ifneq ($(strip $(BUILD_WITH_GOOGLE_GMS_EXPRESS)),true)
      $(warning ****************************************)
      $(error Please note that all your apps MUST be able to get permissions, Otherwise android cannot boot!)
      $(warning After confirming your apps, please remove the above error line!)
      $(warning ****************************************)
    endif
    # Enforce privapp-permissions whitelist only for user build.
    PRODUCT_PROPERTY_OVERRIDES += \
      ro.control_privapp_permissions=enforce
  endif
  $(warning Please set client id with your own MADA ID!)
  TARGET_SYSTEM_PROP += vendor/rockchip/common/gms/gms.prop
  MAINLINE_INCLUDE_WIFI_MODULE := false
  TMP_GMS_VAR := gms
  TMP_MAINLINE_VAR := mainline_modules
  ifeq ($(strip $(BUILD_WITH_GO_OPT)),true)
    TMP_GMS_VAR := $(TMP_GMS_VAR)_go
    # Mainline partner build config - low RAM
    TMP_MAINLINE_VAR := $(TMP_MAINLINE_VAR)_low_ram
    OVERRIDE_TARGET_FLATTEN_APEX := true
    PRODUCT_PROPERTY_OVERRIDES += ro.apex.updatable=false
    # 2G A Go
    #TMP_GMS_VAR := $(TMP_GMS_VAR)_2gb
  else
    PRODUCT_PACKAGES += RockchipTetheringConfigOverlay
    PRODUCT_PACKAGES += RockchipNetworkStackConfigOverlay
  endif
  ifeq ($(strip $(BUILD_WITH_EEA)),true)
    BUILD_WITH_GOOGLE_MARKET_ALL := true
    TMP_GMS_VAR := $(TMP_GMS_VAR)_eea_$(BUILD_WITH_EEA_TYPE)
  endif
  ifneq ($(strip $(BUILD_WITH_GOOGLE_MARKET_ALL)), true)
    TMP_GMS_VAR := $(TMP_GMS_VAR)-mandatory
  endif # BUILD_WITH_GOOGLE_MARKET_ALL
  PRODUCT_PACKAGE_OVERLAYS += vendor/rockchip/common/gms/gms_overlay
  $(call inherit-product, vendor/partner_gms/products/$(TMP_GMS_VAR).mk)
  $(call inherit-product, vendor/partner_modules/build/$(TMP_MAINLINE_VAR).mk)
  # add this for zerotouch warpper.
  #$(call inherit-product, vendor/rockchip/common/gms/zerotouch.mk)
endif

#GOOGLE EXPRESS PLUS CONFIGURATION
ifeq ($(strip $(BUILD_WITH_GOOGLE_GMS_EXPRESS)),true)
PRODUCT_COPY_FILES += \
    vendor/rockchip/common/gms-express.xml:system/etc/sysconfig/gms-express.xml
endif

# GTVS
ifeq ($(strip $(PRODUCT_USE_PREBUILT_GTVS)), yes)
  $(call inherit-product-if-exists, vendor/google_gtvs/gms.mk.sample)
  $(call inherit-product-if-exists, vendor/google_gtvs/mainline_modules_atv.mk.sample)
  $(call inherit-product-if-exists, vendor/widevine/widevine.mk)
endif

ifneq ($(filter true yes, $(BUILD_WITH_GOOGLE_MARKET) $(PRODUCT_USE_PREBUILT_GTVS)),)
  PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.opengles.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level-2020-03-01.xml
  ifeq ($(strip $(TARGET_ARCH)), arm64)
    ifneq ($(strip $(BUILD_WITH_GO_OPT)), true)
      ifeq (,$(filter rk356x rk3588, $(TARGET_BOARD_PLATFORM)))
        # for swiftshader, vulkan v1.1 test.
        PRODUCT_PACKAGES += \
          vulkan.pastel
        PRODUCT_PROPERTY_OVERRIDES += \
          ro.hardware.vulkan=pastel
      endif

      PRODUCT_PROPERTY_OVERRIDES += \
        ro.cpuvulkan.version=4202496

      PRODUCT_COPY_FILES += \
        frameworks/native/data/etc/android.hardware.vulkan.version-1_1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version-1_1.xml \
        frameworks/native/data/etc/android.hardware.vulkan.level-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level-0.xml \
        frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute-0.xml \
        frameworks/native/data/etc/android.software.vulkan.deqp.level-2021-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml
    endif
  endif
endif
