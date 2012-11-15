LOCAL_PATH := $(call my-dir)

include $(call all-makefiles-under,$(LOCAL_PATH))
#ifeq ($(strip $(BOARD_WITH_CALL_FUNCTION)), true)
#$(shell $(LOCAL_PATH)/../telephony.sh)
#$(info "config_voice_capable : true")
#$(info "config_sms_capable : true")
#else
#$(shell $(LOCAL_PATH)/../no_telephony.sh)
#$(info "config_voice_capable : false")
#$(info "config_sms_capable : false")
#endif
