# Get the long list of APNs
PRODUCT_COPY_FILES += device/rockchip/common/phone/etc/apns-full-conf.xml:system/etc/apns-conf.xml
PRODUCT_COPY_FILES += device/rockchip/common/phone/etc/spn-conf.xml:system/etc/spn-conf.xml
# The rockchip rk30sdk board
include device/rockchip/rk30sdk/BoardConfig.mk
$(call inherit-product, device/rockchip/rk30sdk/device.mk)

PRODUCT_BRAND := rk30sdk
PRODUCT_DEVICE := rk30sdk
PRODUCT_NAME := rk30sdk
PRODUCT_MODEL := rk30sdk
PRODUCT_MANUFACTURER := rockchip


PRODUCT_PROPERTY_OVERRIDES += \
			ro.product.version = 1.0.0 \
			ro.product.ota.host = www.rockchip.com:2300
