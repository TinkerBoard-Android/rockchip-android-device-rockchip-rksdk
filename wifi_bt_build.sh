#!/bin/bash

source ../../../build/envsetup.sh

croot

echo "---- make installclean ----"
make installclean

echo "---- mmm ----"
mmm external/wpa_supplicant_8/ -B
mmm external/bluetooth/bluedroid/ -B
mmm device/common/bluetooth/libbt/ -B
mmm hardware/libhardware_legacy/ -B
mmm system/netd/ -B
touch frameworks/base/wifi/java/android/net/wifi/*
touch frameworks/base/wifi_old/java/android/net/wifi/*
touch frameworks/base/core/jni/android_net_wifi_WifiNative_old.cpp
touch frameworks/base/core/jni/android_net_wifi_WifiNative.cpp
mmm frameworks/base/

echo "---- make -j4 ----"
make -j4

