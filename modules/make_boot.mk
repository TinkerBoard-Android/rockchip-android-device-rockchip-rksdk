#
# Copyright 2021 Rockchip Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ROCKCHIP_ANDROID_BOOT_CMDLINE ?= androidboot.console=ttyFIQ0 androidboot.wificountrycode=CN
ROCKCHIP_ANDROID_BOOT_CMDLINE += androidboot.hardware=$(TARGET_BOARD_HARDWARE)
ROCKCHIP_ANDROID_BOOT_CMDLINE += androidboot.boot_devices=$(PRODUCT_BOOT_DEVICE)

BOARD_KERNEL_CMDLINE := console=ttyFIQ0 firmware_class.path=/vendor/etc/firmware init=/init rootwait ro
BOARD_KERNEL_CMDLINE += loop.max_part=7
BOARD_KERNEL_CMDLINE += printk.devkmsg=on

ifeq ($(BOARD_BUILD_GKI),true)
# When GKI enable, pass param to usb through cmdline
# ref:Documentation/admin-guide/kernel-parameters.txt
BOARD_KERNEL_CMDLINE += usbcore.autosuspend=-1
BOARD_KERNEL_CMDLINE += usbcore.quirks=325d:6410:k,21c4:0cd1:k,0951:1666:k,058f:6387:e
BOARD_KERNEL_CMDLINE += usb-storage.quirks=174c:x55aa:f,152d:0583:f,0bc2:2321:u,05e3:0749:mr
endif

# If pKvm is not enabled, disable kvm, which reduces the memory on the GKI by 16MiB.
ifneq ($(BOARD_ROCKCHIP_PKVM),true)
BOARD_KERNEL_CMDLINE += kvm-arm.mode=none
endif

ifneq ($(BOARD_SELINUX_ENFORCING), true)
ROCKCHIP_ANDROID_BOOT_CMDLINE += androidboot.selinux=permissive
endif

ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \<= 3)))
BOARD_KERNEL_CMDLINE += $(ROCKCHIP_ANDROID_BOOT_CMDLINE)
else # Boot header 4 requires bootconfig
BOARD_BOOTCONFIG := $(ROCKCHIP_ANDROID_BOOT_CMDLINE)
BOARD_KERNEL_CMDLINE += 8250.nr_uarts=10
endif

# For Header V2, set resource.img as second.
# For Header V3, add vendor_boot and resource.
ifeq (1,$(strip $(shell expr $(BOARD_BOOT_HEADER_VERSION) \<= 2)))
BOARD_MKBOOTIMG_ARGS += --second $(TARGET_PREBUILT_RESOURCE)
endif
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
# Always use header v2 for recovery image,
# - header v4 is using bootconfig, always override cmdline in recovery;
# - header v3+ is used for virtual A/B and GKI;
# - header v2 used for the device with recovery;
ifneq ($(BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE), true)
ifneq ($(BOARD_USES_AB_IMAGE), true)
BOARD_RECOVERY_MKBOOTIMG_ARGS ?= --second $(TARGET_PREBUILT_RESOURCE) \
    --header_version 2 \
    --cmdline "$(BOARD_KERNEL_CMDLINE) $(ROCKCHIP_ANDROID_BOOT_CMDLINE)"
ifeq ($(BOARD_AVB_ENABLE), true)
BOARD_USES_FULL_RECOVERY_IMAGE := true
endif
endif
endif

BOARD_INCLUDE_RECOVERY_DTBO ?= true
BOARD_INCLUDE_DTB_IN_BOOTIMG ?= true
