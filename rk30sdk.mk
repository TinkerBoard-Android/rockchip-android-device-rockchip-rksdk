# The rockchip rk30sdk board
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

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
