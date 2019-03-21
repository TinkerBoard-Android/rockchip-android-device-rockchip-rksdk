#!/bin/bash
set -e

. build/envsetup.sh >/dev/null && setpaths

export PATH=$ANDROID_BUILD_PATHS:$PATH
TARGET_PRODUCT=`get_build_var TARGET_PRODUCT`
TARGET_HARDWARE=`get_build_var TARGET_BOARD_HARDWARE`
TARGET_BOARD_PLATFORM=`get_build_var TARGET_BOARD_PLATFORM`
TARGET_DEVICE_DIR=`get_build_var TARGET_DEVICE_DIR`
PLATFORM_VERSION=`get_build_var PLATFORM_VERSION`
PLATFORM_SECURITY_PATCH=`get_build_var PLATFORM_SECURITY_PATCH`
TARGET_BUILD_VARIANT=`get_build_var TARGET_BUILD_VARIANT`
ROCKCHIP_RECOVERYIMAGE_CMDLINE_ARGS=`get_build_var ROCKCHIP_RECOVERYIMAGE_CMDLINE_ARGS`
BOARD_SYSTEMIMAGE_PARTITION_SIZE=`get_build_var BOARD_SYSTEMIMAGE_PARTITION_SIZE`
BOARD_USE_SPARSE_SYSTEM_IMAGE=`get_build_var BOARD_USE_SPARSE_SYSTEM_IMAGE`
TARGET_ARCH=`get_build_var TARGET_ARCH`
TARGET_OUT_VENDOR=`get_build_var TARGET_OUT_VENDOR`
TARGET_BASE_PARAMETER_IMAGE=`get_build_var TARGET_BASE_PARAMETER_IMAGE`
HIGH_RELIABLE_RECOVERY_OTA=`get_build_var HIGH_RELIABLE_RECOVERY_OTA`
BOARD_AVB_ENABLE=`get_build_var BOARD_AVB_ENABLE`
BOARD_USES_AB_IMAGE=`get_build_var BOARD_USES_AB_IMAGE`
BOARD_USES_RECOVERY_AS_BOOT=`get_build_var BOARD_USES_RECOVERY_AS_BOOT`

echo TARGET_BOARD_PLATFORM=$TARGET_BOARD_PLATFORM
echo TARGET_PRODUCT=$TARGET_PRODUCT
echo TARGET_HARDWARE=$TARGET_HARDWARE
echo TARGET_BUILD_VARIANT=$TARGET_BUILD_VARIANT
echo BOARD_SYSTEMIMAGE_PARTITION_SIZE=$BOARD_SYSTEMIMAGE_PARTITION_SIZE
echo BOARD_USE_SPARSE_SYSTEM_IMAGE=$BOARD_USE_SPARSE_SYSTEM_IMAGE
echo TARGET_BASE_PARAMETER_IMAGE==$TARGET_BASE_PARAMETER_IMAGE
echo HIGH_RELIABLE_RECOVERY_OTA=$HIGH_RELIABLE_RECOVERY_OTA
echo BOARD_AVB_ENABLE=$BOARD_AVB_ENABLE
echo BOARD_USES_AB_IMAGE=$BOARD_USES_AB_IMAGE
echo BOARD_USES_RECOVERY_AS_BOOT=$BOARD_USES_RECOVERY_AS_BOOT

TARGET="withoutkernel"
if [ "$1"x != ""x  ]; then
         TARGET=$1
fi

IMAGE_PATH=rockdev/Image-$TARGET_PRODUCT
UBOOT_PATH=u-boot
KERNEL_PATH=kernel
KERNEL_CONFIG=$KERNEL_PATH/.config
rm -rf $IMAGE_PATH
mkdir -p $IMAGE_PATH

FSTYPE=ext4
echo system filesysystem is $FSTYPE

BOARD_CONFIG=device/rockchip/common/device.mk

PARAMETER=${TARGET_DEVICE_DIR}/parameter_ab.txt

KERNEL_SRC_PATH=`grep TARGET_PREBUILT_KERNEL ${BOARD_CONFIG} |grep "^\s*TARGET_PREBUILT_KERNEL *:= *[\w]*\s" |awk  '{print $3}'`

[ $(id -u) -eq 0 ] || FAKEROOT=fakeroot

BOOT_OTA="ota"

echo -n "create system.img boot.img uboot.img trust.img oem.img vendor.img dtbo.img vbmeta.img..."
cp -rf  $OUT/obj/PACKAGING/target_files_intermediates/*-target_files*/IMAGES/*.img  $IMAGE_PATH/
echo "done."


if [ "$BOARD_AVB_ENABLE" = "true" ]; then
echo -n "done!"
else
echo -n "BOARD_AVB_ENABLE is false,use default vbmeta.img..."
cp -a device/rockchip/common/vbmeta.img $IMAGE_PATH/vbmeta.img
fi
echo "done."


echo -n "create misc.img.... "
cp -a rkst/Image/misc.img $IMAGE_PATH/misc.img
cp -a rkst/Image/pcba_small_misc.img $IMAGE_PATH/pcba_small_misc.img
cp -a rkst/Image/pcba_whole_misc.img $IMAGE_PATH/pcba_whole_misc.img
echo "done."


if [ -f $UBOOT_PATH/*_loader_*.bin ]
then
        echo -n "create loader..."
        cp -a $UBOOT_PATH/*_loader_*.bin $IMAGE_PATH/MiniLoaderAll.bin
        echo "done."
else
	if [ -f $UBOOT_PATH/*loader*.bin ]; then
		echo -n "create loader..."
		cp -a $UBOOT_PATH/*loader*.bin $IMAGE_PATH/MiniLoaderAll.bin
		echo "done."
	elif [ "$TARGET_PRODUCT" == "px3" -a -f $UBOOT_PATH/RKPX3Loader_miniall.bin ]; then
        echo -n "create loader..."
        cp -a $UBOOT_PATH/RKPX3Loader_miniall.bin $IMAGE_PATH/MiniLoaderAll.bin
        echo "done."
	else
        echo "$UBOOT_PATH/*MiniLoaderAll_*.bin not fount! Please make it from $UBOOT_PATH first!"
	fi
fi

if [ -f $KERNEL_PATH/resource.img ]
then
        echo -n "create resource.img..."
        cp -a $KERNEL_PATH/resource.img $IMAGE_PATH/resource.img
        echo "done."
else
        echo "$KERNEL_PATH/resource.img not fount!"
fi

if [ -f $KERNEL_PATH/kernel.img ]
then
        echo -n "create kernel.img..."
        cp -a $KERNEL_PATH/kernel.img $IMAGE_PATH/kernel.img
        echo "done."
else
        echo "$KERNEL_PATH/kernel.img not fount!"
fi

if [ "$BOARD_USES_AB_IMAGE" = "true" ]; then
	echo "BOARD_USES_AB_IMAGE is true... "
	if [ -f ${TARGET_DEVICE_DIR}/parameter_ab.txt ]; then
		cp -a ${TARGET_DEVICE_DIR}/parameter_ab.txt $IMAGE_PATH/parameter.txt
		echo "done."
  else
		echo "${TARGET_DEVICE_DIR}/parameter_ab.txt not fount! Please make it from ${TARGET_DEVICE_DIR} first!"
  fi
fi

if [ "$TARGET_BASE_PARAMETER_IMAGE"x != ""x ]
then
    if [ -f $TARGET_BASE_PARAMETER_IMAGE ]
    then
        echo -n "create baseparameter..."
        cp -a $TARGET_BASE_PARAMETER_IMAGE $IMAGE_PATH/baseparameter.img
        echo "done."
    else
        echo "$TARGET_BASE_PARAMETER_IMAGE not fount!"
    fi
fi

chmod a+r -R $IMAGE_PATH/
