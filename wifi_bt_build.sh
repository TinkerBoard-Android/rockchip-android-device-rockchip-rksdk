#!/bin/bash

source ../../../build/envsetup.sh

croot

echo "---- make installclean ----"
make installclean

echo "---- mmm ----"
mmm external/bluetooth/bluedroid/ -B -j4
mmm device/common/bluetooth/libbt/ -B -j4
mmm hardware/libhardware_legacy/ -B -j4
mmm system/netd/ -B -j4
mmm frameworks/base/core/jni/ -B -j4
mmm frameworks/base/core/res -B -j4
mmm frameworks/base/ -B -j4

echo "---- make -j4 ----"
make -j4

mmm external/wpa_supplicant_8/ -B -j4
