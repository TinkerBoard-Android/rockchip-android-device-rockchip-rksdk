LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_SHARED_LIBRARIES := \
    libcutils \
    liblog \
    libdrm \
    libutils \

LOCAL_SRC_FILES:= \
        main.cpp \

LOCAL_C_INCLUDES += external/libdrm/include/drm
LOCAL_C_INCLUDES += external/libdrm/
LOCAL_MODULE:= saveBaseParameter
include $(BUILD_EXECUTABLE)
