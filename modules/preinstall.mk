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

# Include this makefile to support prebuild apps
ifneq ($(strip $(TARGET_PRODUCT)), )
    $(shell python device/rockchip/common/auto_generator.py $(TARGET_DEVICE_DIR) preinstall bundled_persist-app $(TARGET_ARCH))
    $(shell python device/rockchip/common/auto_generator.py $(TARGET_DEVICE_DIR) preinstall_del bundled_uninstall_back-app $(TARGET_ARCH))
    $(shell python device/rockchip/common/auto_generator.py $(TARGET_DEVICE_DIR) preinstall_del_forever bundled_uninstall_gone-app $(TARGET_ARCH))
    -include $(TARGET_DEVICE_DIR)/preinstall/preinstall.mk
    -include $(TARGET_DEVICE_DIR)/preinstall_del/preinstall.mk
    -include $(TARGET_DEVICE_DIR)/preinstall_del_forever/preinstall.mk
endif
