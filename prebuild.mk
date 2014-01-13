#DO CLEAN
ifdef PRODUCT_OUT
    $(shell rm -f $(PRODUCT_OUT)/root/default.prop)
    $(shell rm -rf $(PRODUCT_OUT)/system/preinstall)
    $(shell rm -rf $(PRODUCT_OUT)/system/preinstall_del)
endif
ifdef TARGET_OUT
    $(shell rm -f $(TARGET_OUT)/build.prop)
    $(shell rm -f $(TARGET_OUT)/manifest.xml)
endif

#GENERATE MANIFEST
$(shell test -d .repo && .repo/repo/repo manifest -r -o manifest.xml)

-include $(TARGET_DEVICE_DIR)/prebuild.mk

