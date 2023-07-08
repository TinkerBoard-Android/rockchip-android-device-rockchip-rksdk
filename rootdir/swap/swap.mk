#
# Copyright 2023 Rockchip Limited
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

PRODUCT_PACKAGES += \
    fstab_swap.ext256 \
    fstab_swap.ext512 \
    fstab_swap.ext1024 \
    fstab_swap.ext2048 \
    fstab_swap.ext4096 \
    fstab_swap.extnone

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.ext_ram?=none
