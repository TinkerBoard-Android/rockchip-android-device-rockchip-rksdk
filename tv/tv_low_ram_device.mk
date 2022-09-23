ifneq ($(filter atv box, $(strip $(TARGET_BOARD_PLATFORM_PRODUCT))), )
PRODUCT_PROPERTY_OVERRIDES += \
    ro.mem_optimise.enable=true \
    ro.config.low_ram=true \
    ro.lmk.critical_upgrade=true \
    ro.lmk.upgrade_pressure=40 \
    ro.lmk.downgrade_pressure=60 \
    ro.lmk.kill_heaviest_task=false \
    ro.statsd.enable=true \
    pm.dexopt.downgrade_after_inactive_days=10 \
    pm.dexopt.shared=quicken \
    persist.traced.enable=1 \
    dalvik.vm.madvise-random=true \
    ro.lmk.medium=700
PRODUCT_COPY_FILES += \
    device/rockchip/common/lowmem_package_filter.xml:system/etc/lowmem_package_filter.xml
PRODUCT_SYSTEM_SERVER_COMPILER_FILTER := speed-profile
PRODUCT_ALWAYS_PREOPT_EXTRACTED_APK := true
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := true
PRODUCT_DEX_PREOPT_BOOT_IMAGE_PROFILE_LOCATION := frameworks/base/config/boot-image-profile.txt
#PRODUCT_PACKAGES += InProcessNetworkStack
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true
endif
