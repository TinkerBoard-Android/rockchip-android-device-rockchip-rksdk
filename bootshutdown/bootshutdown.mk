CUR_PATH := device/rockchip/common/bootshutdown

HAVE_BOOT_RING := $(shell test -f $(CUR_PATH)/startup.wav && echo yes)
HAVE_SHUTDOWN_RING := $(shell test -f $(CUR_PATH)/shutdown.wav && echo yes)
HAVE_BOOT_ANIMATION := $(shell test -f $(CUR_PATH)/bootanimation.zip && echo yes)
HAVE_SHUTDOWN_ANIMATION := $(shell test -f $(CUR_PATH)/shutdownanimation.zip && echo yes)

ifeq ($(HAVE_BOOT_RING), yes)
PRODUCT_COPY_FILES += $(CUR_PATH)/startup.wav:system/media/audio/startup.wav
endif

ifeq ($(HAVE_SHUTDOWN_RING), yes)
PRODUCT_COPY_FILES += $(CUR_PATH)/startup.wav:system/media/audio/shutdown.wav
endif

ifeq ($(HAVE_BOOT_ANIMATION), yes)
PRODUCT_COPY_FILES += $(CUR_PATH)/startup.wav:system/media/bootanimation.zip
endif

ifeq ($(HAVE_SHUTDOWN_ANIMATION), yes)
PRODUCT_COPY_FILES += $(CUR_PATH)/startup.wav:system/media/shutdownanimation.zip
endif
