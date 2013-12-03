#!/bin/bash

source ../../../build/envsetup.sh

croot

echo "---- make installclean ----"
make installclean

echo "---- make -j4 ----"
make -j4

echo "---- mmm ----"
mmm external/wpa_supplicant_8/ -B
mmm device/common/bluetooth/libbt/ -B
mmm hardware/libhardware_legacy/ -B
mmm system/netd/ -B
mmm frameworks/base/ -B
