CUR_PATH := device/rockchip/common/rootservice
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.rootservice=1

PRODUCT_COPY_FILES += \
    $(CUR_PATH)/bin/rootservice:/vendor/bin/rootservice \
    $(CUR_PATH)/bin/rootsudaemon.sh:/vendor/bin/rootsudaemon.sh \
    $(CUR_PATH)/$(TARGET_ARCH)/xbin/daemonsu:/system/xbin/daemonsu \
    $(CUR_PATH)/$(TARGET_ARCH)/xbin/su:/system/xbin/su \
    $(CUR_PATH)/$(TARGET_ARCH)/xbin/supolicy:/system/xbin/supolicy

ifeq ($(strip $(TARGET_ARCH)), arm64)
PRODUCT_COPY_FILES += \
    $(CUR_PATH)/$(TARGET_ARCH)/lib64/libsupol.so:/system/lib64/libsupol.so
else
PRODUCT_COPY_FILES += \
    $(CUR_PATH)/$(TARGET_ARCH)/lib/libsupol.so:/system/lib/libsupol.so
endif
