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

# build with go optimization
ifeq ($(strip $(BUILD_WITH_GO_OPT)),true)
ifeq ($(strip $(TARGET_ARCH)), arm64)
$(call inherit-product, build/target/product/go_defaults_512.mk)
$(call inherit-product, device/rockchip/common/build/rockchip/AndroidGo512.mk)
else
$(call inherit-product, build/target/product/go_defaults.mk)
# only set zygote 32 for arm devices
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.zygote=zygote32
endif
$(call inherit-product, device/rockchip/common/build/rockchip/AndroidGoCommon.mk)
$(call inherit-product, frameworks/native/build/tablet-7in-hdpi-1024-dalvik-heap.mk)

# Enable lazy service to save memory
ROCKCHIP_USE_LAZY_HAL := true

# Copy features to device
PRODUCT_COPY_FILES += \
    device/rockchip/common/permissions/android.hardware.ram.low.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.ram.low.xml

# Disable surfaceflinger prime_shader cache to improve post boot memory.
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += service.sf.prime_shader_cache=0

# remove the llkd process
PRODUCT_PROPERTY_OVERRIDES += ro.llk.enable=false

# Overlay configs
DEVICE_PACKAGE_OVERLAYS += device/rockchip/common/overlay_go

# Enable DM file pre-opting to reduce first boot time
PRODUCT_DEX_PREOPT_GENERATE_DM_FILES := true
PRODUCT_DEX_PREOPT_DEFAULT_COMPILER_FILTER := verify
# Save space but slow down device.
# DONT_UNCOMPRESS_PRIV_APPS_DEXS := true
# Config jemalloc for low memory
MALLOC_SVELTE := true

# Reduces GC frequency of foreground apps by 50%
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.foreground-heap-growth-multiplier=2.0 \
    ro.zram.mark_idle_delay_mins=60
endif
