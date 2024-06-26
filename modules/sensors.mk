#
# Copyright 2024 Rockchip Limited
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

# Sensor configurations
$(call soong_config_set,sensor_rockchip,gravity,$(BOARD_GRAVITY_SENSOR_SUPPORT))
$(call soong_config_set,sensor_rockchip,compass,$(BOARD_COMPASS_SENSOR_SUPPORT))
$(call soong_config_set,sensor_rockchip,gyroscope,$(BOARD_GYROSCOPE_SENSOR_SUPPORT))
$(call soong_config_set,sensor_rockchip,proximity,$(BOARD_PROXIMITY_SENSOR_SUPPORT))
$(call soong_config_set,sensor_rockchip,light,$(BOARD_LIGHT_SENSOR_SUPPORT))
$(call soong_config_set,sensor_rockchip,pressure,$(BOARD_PRESSURE_SENSOR_SUPPORT))
$(call soong_config_set,sensor_rockchip,temperature,$(BOARD_TEMPERATURE_SENSOR_SUPPORT))

ifeq ($(BOARD_COMPASS_SENSOR_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml
endif
ifeq ($(BOARD_GYROSCOPE_SENSOR_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml
endif

ifeq ($(BOARD_PROXIMITY_SENSOR_SUPPORT),true)
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml
endif

ifeq ($(BOARD_LIGHT_SENSOR_SUPPORT),true)
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml
endif

# Android 14+ use sensor AIDL
ifeq ($(call math_gt_or_eq,$(ROCKCHIP_LUNCHING_API_LEVEL),34),true)
# Sensor AIDL
PRODUCT_PACKAGES += \
    com.rockchip.hardware.sensors
else
# Sensor HAL
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-service \
    android.hardware.sensors@1.0-impl \
    sensors.$(TARGET_BOARD_HARDWARE)
endif
