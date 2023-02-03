# hdmi cec
BOARD_SHOW_HDMI_SETTING := true
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.hdmi.cec.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.hdmi.cec.xml \
	$(LOCAL_PATH)/../tv/permissions/privapp-permissions-tv-common.xml:system/etc/permissions/privapp-permissions-tv-common.xml

PRODUCT_PROPERTY_OVERRIDES += ro.hdmi.device_type=4
PRODUCT_PACKAGES += \
	hdmi_cec.$(TARGET_BOARD_PLATFORM)

# HDMI CEC HAL
PRODUCT_PACKAGES += \
	android.hardware.tv.cec@1.0-impl \
	android.hardware.tv.cec@1.0-service
DEVICE_MANIFEST_FILE += device/rockchip/common/manifests/android.hardware.cec@1.0-service.xml
