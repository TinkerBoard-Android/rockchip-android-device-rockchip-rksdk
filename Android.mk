LOCAL_PATH := $(call my-dir)

$(shell mkdir -p $(TARGET_ROOT_OUT)/mnt/vendor/metadata)
$(shell mkdir -p $(TARGET_OUT_VENDOR)/odm/app)
$(shell mkdir -p $(TARGET_OUT_VENDOR)/odm/bin)
$(shell mkdir -p $(TARGET_OUT_VENDOR)/odm/etc)
$(shell mkdir -p $(TARGET_OUT_VENDOR)/odm/firmware)
$(shell mkdir -p $(TARGET_OUT_VENDOR)/odm/framework)
$(shell mkdir -p $(TARGET_OUT_VENDOR)/odm/lib)
$(shell mkdir -p $(TARGET_OUT_VENDOR)/odm/lib64)
$(shell mkdir -p $(TARGET_OUT_VENDOR)/odm/overlay)
$(shell mkdir -p $(TARGET_OUT_VENDOR)/odm/priv-app)

include $(call all-makefiles-under,$(LOCAL_PATH))
