CUR_PATH := device/rockchip/common/oem_preset

HAVE_PRESET_CONTENT := $(shell test -d $(CUR_PATH)/pre_set && echo yes)
HAVE_PRESET_DEL_CONTENT := $(shell test -d $(CUR_PATH)/pre_set_del && echo yes)

ifeq ($(HAVE_PRESET_DEL_CONTENT), yes)
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(CUR_PATH)/pre_set_del,$(TARGET_COPY_OUT_OEM)/pre_set_del)

PRODUCT_PROPERTY_OVERRIDES += \
    ro.boot.copy_oem=true
endif

ifeq ($(HAVE_PRESET_CONTENT), yes)
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(CUR_PATH)/pre_set,$(TARGET_COPY_OUT_OEM)/pre_set)

PRODUCT_PROPERTY_OVERRIDES += \
    ro.boot.copy_oem=true
endif
