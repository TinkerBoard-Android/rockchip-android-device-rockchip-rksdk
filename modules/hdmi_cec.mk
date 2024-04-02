# hdmi cec
BOARD_SHOW_HDMI_SETTING := true
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.hdmi.cec.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.hdmi.cec.xml \
	$(LOCAL_PATH)/../tv/permissions/privapp-permissions-tv-common.xml:system/etc/permissions/privapp-permissions-tv-common.xml

PRODUCT_PROPERTY_OVERRIDES += ro.hdmi.device_type=$(BOARD_HDMI_CEC_TYPE)
PRODUCT_PACKAGES += \
    hdmi_connection.rk30board \
	hdmi_cec.rk30board

# HDMI CEC AIDL
PRODUCT_PACKAGES += \
    android.hardware.tv.hdmi.connection-service \
	android.hardware.tv.hdmi.cec-service

ifneq ($(filter 0, $(strip $(BOARD_HDMI_CEC_TYPE))), )
    HDMI_PORT_TYPE := in
else
    HDMI_PORT_TYPE := out
endif
