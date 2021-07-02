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

ifeq ($(strip $(BOARD_TWRP_ENABLE)), true)
	TW_THEME := landscape_hdpi
	TW_USE_TOOLBOX := true
	TW_EXTRA_LANGUAGES := true
	TW_DEFAULT_LANGUAGE := zh_CN
	DEVICE_RESOLUTION := 1280x720
	TW_NO_BATT_PERCENT := true
	TWRP_EVENT_LOGGING := false
	TARGET_RECOVERY_FORCE_PIXEL_FORMAT := RGB_565
	TW_NO_SCREEN_TIMEOUT := true
	TW_NO_SCREEN_BLANK := true
	TW_SCREEN_BLANK_ON_BOOT := false
	TW_IGNORE_MISC_WIPE_DATA := true
	TW_HAS_MTP := true
	TW_NO_USB_STORAGE := true
endif
