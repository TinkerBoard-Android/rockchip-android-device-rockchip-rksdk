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

# OMX/Camera omx-plugin vpu libion_rockchip_ext
PRODUCT_PACKAGES += \
    libgralloc_priv_omx

# Rockit player service
PRODUCT_PACKAGES += \
    rockchip.hardware.rockit.hw@1.0-service \
    librockit_hw_client@1.0

# Codec2
PRODUCT_PACKAGES += \
    android.hardware.media.c2@1.1-service \
    libcodec2_rk_component

# Use C2 to obtain surface
PRODUCT_PROPERTY_OVERRIDES += \
    debug.stagefright.c2inputsurface=-1 \
    debug.stagefright.ccodec=4
