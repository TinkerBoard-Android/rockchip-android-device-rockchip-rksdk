CUR_PATH := device/rockchip/common/rootservice
PRODUCT_PROPERTY_OVERRIDES += \
    persist.vendor.rootservice=1

PRODUCT_COPY_FILES += \
    $(CUR_PATH)/bin/rootservice:/vendor/bin/rootservice \
    $(CUR_PATH)/bin/rootsudaemon.sh:/vendor/bin/rootsudaemon.sh \
    $(CUR_PATH)/xbin/daemonsu:/system/xbin/daemonsu \
    $(CUR_PATH)/xbin/su:/system/xbin/su \
    $(CUR_PATH)/xbin/supolicy:/system/xbin/supolicy \
    $(CUR_PATH)/lib/libsupol.so:/system/lib/libsupol.so
