#!/bin/bash
TARGET_ARCH=$1
TARGET_OUT_VENDOR=$2
echo "---- make wifi ko  ----"
echo "TARGET_ARCH = $TARGET_ARCH"

#make -C kernel ARCH=$TARGET_ARCH  modules -j8

mkdir -p $TARGET_OUT_VENDOR/lib/modules/wifi

find kernel/drivers/net/wireless/rockchip_wlan/*  -name "*.ko" | \
xargs -n1 -i cp {} $TARGET_OUT_VENDOR/lib/modules/wifi/
echo "Install wifi ko to $TARGET_OUT_VENDOR/lib/modules/wifi/"
