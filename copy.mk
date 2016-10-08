define all-files-under
$(patsubst ./%,%, \
  $(shell cd $(1) ; \
          find -L . -type f) \
 )
endef

define copy-file
$(eval PRODUCT_COPY_FILES += \
    $(2)/$(3):$(1)/$(3))
endef

define copy-files-under
    $(foreach f, $(call all-files-under,$(2)), \
	    $(call copy-file,$(1),$(2),$(f))
    )
endef

DEVICE_PATH=device/rockchip/common

#$(eval $(call copy-files-under,root,$(DEVICE_PATH)/rootdir))
$(eval $(call copy-files-under,system,$(DEVICE_PATH)/systemdir))
