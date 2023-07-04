#
# Copyright 2022 Rockchip Limited
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

# Health hardware impl
PRODUCT_PACKAGES += \
    android.hardware.health-service.rockchip \
    android.hardware.health-service.rockchip_recovery

# Charger resource
PRODUCT_PACKAGES += \
    charger_res_images_rockchip

# Allows healthd to boot directly from charger mode rather than initiating a reboot.
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.enable_boot_charger_mode=0

