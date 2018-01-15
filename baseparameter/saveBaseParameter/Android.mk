LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_SHARED_LIBRARIES := \
    libcutils \
    liblog \
    libutils \

LOCAL_SRC_FILES:= \
        main.cpp \

LOCAL_MODULE:= saveBaseParameter
include $(BUILD_EXECUTABLE)
