#!/bin/bash
set -e

. build/envsetup.sh >/dev/null && setpaths

export PATH=$ANDROID_BUILD_PATHS:$PATH

TARGET="withoutkernel"
if [ "$1"x != ""x  ]; then
         TARGET=$1
fi
rm -rf rockdev/Image
mkdir -p rockdev/Image

FSTYPE=`grep 'mtd@system' $OUT/root/init.rk30board.rc | head -n 1 | awk '{ print $2 }'`
if [ "$FSTYPE" = "" ]; then
       FSTYPE=`grep 'mtd@system' $OUT/root/init.rc | head -n 1 | awk '{ print $2 }'`
fi
echo system filesysystem is $FSTYPE

BOARD_CONFIG=device/rockchip/rk30sdk/device.mk

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

if [ $TARGET == $BOOT_OTA ]
then
	echo "make ota images... "
	echo -n "create boot.img with kernel... "
	[ -d $OUT/root ] && \
	mkbootfs $OUT/root | minigzip > $OUT/ramdisk.img && \
	mkbootimg --kernel $OUT/kernel --ramdisk $OUT/ramdisk.img --output $OUT/boot.img && \
	cp -a $OUT/boot.img rockdev/Image/
	echo "done."
else
	echo -n "create boot.img without kernel... "
	[ -d $OUT/root ] && \
	mkbootfs $OUT/root | minigzip > $OUT/ramdisk.img && \
	rkst/mkkrnlimg $OUT/ramdisk.img rockdev/Image/boot.img >/dev/null
	echo "done."
fi

	echo -n "create recovery.img with kernel... "
	[ -d $OUT/recovery/root ] && \
	mkbootfs $OUT/recovery/root | minigzip > $OUT/ramdisk-recovery.img && \
	mkbootimg --kernel $OUT/kernel --ramdisk $OUT/ramdisk-recovery.img --output $OUT/recovery.img && \
	cp -a $OUT/recovery.img rockdev/Image/
	echo "done."

	echo -n "create misc.img.... "
	cp -a rkst/Image/misc.img rockdev/Image/misc.img	    
	cp -a rkst/Image/misc_factory_test.img rockdev/Image/misc_factory_test.img	
	echo "done."

if [ -d $OUT/system ]
then
	echo -n "create system.img... "
	if [ "$FSTYPE" = "cramfs" ]
	then
		chmod -R 777 $OUT/system
		$FAKEROOT mkfs.cramfs $OUT/system rockdev/Image/system.img
	elif [ "$FSTYPE" = "squashfs" ]
	then
		chmod -R 777 $OUT/system
		mksquashfs $OUT/system rockdev/Image/system.img -all-root >/dev/null
	elif [ "$FSTYPE" = "ext3" ] || [ "$FSTYPE" = "ext4" ]
	then
		delta=5120
		num_blocks=`du -sk $OUT/system | tail -n1 | awk '{print $1;}'`
		num_blocks=$(($num_blocks + $delta))

		num_inodes=`find $OUT/system | wc -l`
		num_inodes=$(($num_inodes + 500))

		ok=0
		while [ "$ok" = "0" ]; do
			genext2fs -a -d $OUT/system -b $num_blocks -N $num_inodes -m 0 rockdev/Image/system.img >/dev/null 2>&1 && \
			tune2fs -j -L system -c -1 -i 0 rockdev/Image/system.img >/dev/null 2>&1 && \
			ok=1 || num_blocks=$(($num_blocks + $delta))
		done
		e2fsck -fy rockdev/Image/system.img >/dev/null 2>&1 || true

		delta=1024
		num_blocks=`resize2fs -P rockdev/Image/system.img 2>&1 | tail -n1 | awk '{print $7;}'`
		rm -f rockdev/Image/system.img
		ok=0
		while [ "$ok" = "0" ]; do
			genext2fs -a -d $OUT/system -b $num_blocks -N $num_inodes -m 0 rockdev/Image/system.img >/dev/null 2>&1 && \
			tune2fs -O dir_index,filetype,sparse_super -j -L system -c -1 -i 0 rockdev/Image/system.img >/dev/null 2>&1 && \
			ok=1 || num_blocks=$(($num_blocks + $delta))
		done
		e2fsck -fyD rockdev/Image/system.img >/dev/null 2>&1 || true
	else
		mkdir -p rockdev/Image/2k rockdev/Image/4k
		mkyaffs2image -c 2032 -s 16 -f $OUT/system rockdev/Image/2k/system.img
		mkyaffs2image -c 4080 -s 16 -f $OUT/system rockdev/Image/4k/system.img
	fi
	echo "done."
fi

chmod a+r -R rockdev/Image/
