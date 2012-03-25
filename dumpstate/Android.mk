LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

LOCAL_C_INCLUDES := frameworks/base/cmds/dumpstate

LOCAL_SRC_FILES := dumpstate.c

LOCAL_MODULE := libdumpstate.$(TARGET_BOARD_PLATFORM)

LOCAL_MODULE_TAGS := optional

include $(BUILD_STATIC_LIBRARY)
