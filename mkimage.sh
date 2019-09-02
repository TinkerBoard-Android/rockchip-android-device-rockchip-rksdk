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
TARGET_ARCH_VARIANT=`get_build_var TARGET_ARCH_VARIANT`
TARGET_OUT_VENDOR=`get_build_var TARGET_OUT_VENDOR`
TARGET_BASE_PARAMETER_IMAGE=`get_build_var TARGET_BASE_PARAMETER_IMAGE`
HIGH_RELIABLE_RECOVERY_OTA=`get_build_var HIGH_RELIABLE_RECOVERY_OTA`
BOARD_AVB_ENABLE=`get_build_var BOARD_AVB_ENABLE`
BOARD_KERNEL_CMDLINE=`get_build_var BOARD_KERNEL_CMDLINE`
ROCKCHIP_RECOVERYIMAGE_CMDLINE_ARGS=`get_build_var ROCKCHIP_RECOVERYIMAGE_CMDLINE_ARGS`
BOARD_BOOTIMG_HEADER_VERSION=`get_build_var BOARD_BOOTIMG_HEADER_VERSION`
KERNEL_DEBUG=`get_build_var TARGET_PREBUILT_KERNEL`

echo TARGET_BOARD_PLATFORM=$TARGET_BOARD_PLATFORM
echo TARGET_PRODUCT=$TARGET_PRODUCT
echo TARGET_HARDWARE=$TARGET_HARDWARE
echo TARGET_BUILD_VARIANT=$TARGET_BUILD_VARIANT
echo BOARD_SYSTEMIMAGE_PARTITION_SIZE=$BOARD_SYSTEMIMAGE_PARTITION_SIZE
echo BOARD_USE_SPARSE_SYSTEM_IMAGE=$BOARD_USE_SPARSE_SYSTEM_IMAGE
echo TARGET_BASE_PARAMETER_IMAGE==$TARGET_BASE_PARAMETER_IMAGE
echo HIGH_RELIABLE_RECOVERY_OTA=$HIGH_RELIABLE_RECOVERY_OTA
echo BOARD_AVB_ENABLE=$BOARD_AVB_ENABLE
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

PARAMETER=${TARGET_DEVICE_DIR}/parameter.txt
FLASH_CONFIG_FILE=${TARGET_DEVICE_DIR}/config.cfg

KERNEL_SRC_PATH=`grep TARGET_PREBUILT_KERNEL ${BOARD_CONFIG} |grep "^\s*TARGET_PREBUILT_KERNEL *:= *[\w]*\s" |awk  '{print $3}'`

[ $(id -u) -eq 0 ] || FAKEROOT=fakeroot

BOOT_OTA="ota"

[ $TARGET != $BOOT_OTA -a $TARGET != "withoutkernel" ] && echo "unknow target[${TARGET}],exit!" && exit 0

    if [ ! -f $OUT/kernel ]
    then
	    echo "kernel image not fount![$OUT/kernel] "
        read -p "copy kernel from TARGET_PREBUILT_KERNEL[$KERNEL_SRC_PATH] (y/n) n to exit?"
        if [ "$REPLY" == "y" ]
        then
            [ -f $KERNEL_SRC_PATH ]  || \
                echo -n "fatal! TARGET_PREBUILT_KERNEL not eixit! " || \
                echo -n "check you configuration in [${BOARD_CONFIG}] " || exit 0

            cp ${KERNEL_SRC_PATH} $OUT/kernel

        else
            exit 0
        fi
    fi

echo "create dtbo.img.... "
if [ "$BOARD_AVB_ENABLE" = "true" ]; then
cp -a $OUT/dtbo.img $IMAGE_PATH/dtbo.img
else
echo -n "BOARD_AVB_ENABLE is false,use default dtbo.img"
cp -a $TARGET_DEVICE_DIR/dtbo.img $IMAGE_PATH/dtbo.img
fi
echo "done."

echo "create boot.img.... "
if [ "$BOARD_AVB_ENABLE" = "true" ]; then
cp -a $OUT/boot.img $IMAGE_PATH/boot.img
else
echo "BOARD_AVB_ENABLE is false, make boot.img from kernel."
    mkbootimg --kernel $KERNEL_DEBUG --second kernel/resource.img --os_version $PLATFORM_VERSION --header_version $BOARD_BOOTIMG_HEADER_VERSION --os_patch_level $PLATFORM_SECURITY_PATCH --cmdline "$BOARD_KERNEL_CMDLINE" --output $OUT/boot.img && \
    cp -a $OUT/boot.img $IMAGE_PATH/boot.img
fi
echo "done."

echo "create recovery.img.... "
if [ "$BOARD_AVB_ENABLE" = "true" ]; then
cp -a $OUT/recovery.img $IMAGE_PATH/recovery.img
else
echo "BOARD_AVB_ENABLE is false, make recovery.img from kernel && out."
    [ -d $OUT/recovery/root ] && \
    mkbootfs -d $OUT/system $OUT/recovery/root | minigzip > $OUT/ramdisk-recovery.img && \
    mkbootimg --kernel $KERNEL_DEBUG --ramdisk $OUT/ramdisk-recovery.img --second kernel/resource.img --os_version $PLATFORM_VERSION --header_version $BOARD_BOOTIMG_HEADER_VERSION --recovery_dtbo $TARGET_DEVICE_DIR/dtbo.img --os_patch_level $PLATFORM_SECURITY_PATCH --cmdline "$ROCKCHIP_RECOVERYIMAGE_CMDLINE_ARGS" --output $OUT/recovery.img && \
    cp -a $OUT/recovery.img $IMAGE_PATH/recovery.img
fi
echo "done."

echo -n "create system.img.... "
python device/rockchip/common/sparse_tool.py $OUT/system.img
mv $OUT/system.img.out $OUT/system.img
cp -f $OUT/system.img $IMAGE_PATH/system.img
#cp -f $OUT/system.img $IMAGE_PATH/system.img
echo "done."

echo -n "create vbmeta.img.... "
if [ "$BOARD_AVB_ENABLE" = "true" ]; then
cp -a $OUT/vbmeta.img $IMAGE_PATH/vbmeta.img
else
echo -n "BOARD_AVB_ENABLE is false,use default vbmeta.img"
cp -a device/rockchip/common/vbmeta.img $IMAGE_PATH/vbmeta.img
fi
echo "done."

echo -n "create vendor.img..."
python device/rockchip/common/sparse_tool.py $OUT/vendor.img
mv $OUT/vendor.img.out $OUT/vendor.img
cp -a $OUT/vendor.img $IMAGE_PATH/vendor.img
echo "done."

echo -n "create oem.img..."
python device/rockchip/common/sparse_tool.py $OUT/oem.img
mv $OUT/oem.img.out $OUT/oem.img
cp -f $OUT/oem.img $IMAGE_PATH/oem.img
echo "done."

	echo -n "create misc.img.... "
	cp -a rkst/Image/misc.img $IMAGE_PATH/misc.img
	cp -a rkst/Image/pcba_small_misc.img $IMAGE_PATH/pcba_small_misc.img
	cp -a rkst/Image/pcba_whole_misc.img $IMAGE_PATH/pcba_whole_misc.img
	echo "done."

if [ -f $UBOOT_PATH/uboot.img ]
then
	echo -n "create uboot.img..."
	cp -a $UBOOT_PATH/uboot.img $IMAGE_PATH/uboot.img
	echo "done."
else
	echo "$UBOOT_PATH/uboot.img not fount! Please make it from $UBOOT_PATH first!"
fi

if [ -f $UBOOT_PATH/trust_nand.img ]
then
        echo -n "create trust.img..."
        cp -a $UBOOT_PATH/trust_nand.img $IMAGE_PATH/trust.img
        echo "done."
elif [ -f $UBOOT_PATH/trust_with_ta.img ]
then
        echo -n "create trust.img..."
        cp -a $UBOOT_PATH/trust_with_ta.img $IMAGE_PATH/trust.img
        echo "done."
elif [ -f $UBOOT_PATH/trust.img ]
then
        echo -n "create trust.img..."
        cp -a $UBOOT_PATH/trust.img $IMAGE_PATH/trust.img
        echo "done."

else    
        echo "$UBOOT_PATH/trust.img not fount! Please make it from $UBOOT_PATH first!"
fi

if [ "$HIGH_RELIABLE_RECOVERY_OTA" = "true" ]; then
	if [ -f $UBOOT_PATH/uboot_ro.img ]
	then
		echo -n "HIGH_RELIABLE_RECOVERY_OTA is true. create uboot_ro.img..."
		cp -a $UBOOT_PATH/uboot_ro.img $IMAGE_PATH/uboot_ro.img
		cp -a $IMAGE_PATH/trust.img $IMAGE_PATH/trust_ro.img
		echo "done."
	else
		echo "$UBOOT_PATH/uboot_ro.img not fount! Please make it from $UBOOT_PATH first!"
	fi
fi

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

if [ -f $FLASH_CONFIG_FILE ]
then
    echo -n "create config.cfg..."
    cp -a $FLASH_CONFIG_FILE $IMAGE_PATH/config.cfg
    echo "done."
else
    echo "$FLASH_CONFIG_FILE not fount!"
fi

if [ -f $PARAMETER ]
then
				if [ "$HIGH_RELIABLE_RECOVERY_OTA" = "true" ]; then
	        echo -n "create parameter...HIGH_RELIABLE_RECOVERY_OTA is ture. "
	        echo -n "create parameter from hrr..."
	        if [ -f $PARAMETER ]; then
						cp -a ${TARGET_DEVICE_DIR}/parameter_hrr.txt $IMAGE_PATH/parameter.txt
						echo "done."
	        else
						echo "${TARGET_DEVICE_DIR}/parameter_hrr.txt not fount! Please make it from ${TARGET_DEVICE_DIR} first!"
	        fi
	      else
					echo -n "create parameter..."
	        cp -a $PARAMETER $IMAGE_PATH/parameter.txt
	        echo "done."
	      fi
else
        echo "$PARAMETER not fount!"
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

if [ $TARGET == $BOOT_OTA ]
then
echo -n "create system.img boot.img oem.img vendor.img dtbo.img vbmeta.img for OTA..."
cp -rf  $OUT/obj/PACKAGING/target_files_intermediates/*-target_files*/IMAGES/*.img  $IMAGE_PATH/
rm -rf  $IMAGE_PATH/cache.img
rm -rf  $IMAGE_PATH/recovery-two-step.img
echo "done."
fi

chmod a+r -R $IMAGE_PATH/
