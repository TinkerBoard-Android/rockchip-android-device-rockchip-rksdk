#GENERATE MANIFEST
$(shell test -d .repo && .repo/repo/repo manifest -r -o commit_id.xml)

-include $(TARGET_DEVICE_DIR)/prebuild.mk

