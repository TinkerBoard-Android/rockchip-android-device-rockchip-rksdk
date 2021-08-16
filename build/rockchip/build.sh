#!/bin/bash
usage()
{
   echo "USAGE: [-U] [-CK] [-A] [-p] [-o] [-u] [-v VERSION_NAME]  "
    echo "No ARGS means use default build option                  "
    echo "WHERE: -U = build uboot                                 "
    echo "       -C = build kernel with Clang                     "
    echo "       -K = build kernel                                "
    echo "       -A = build android                               "
    echo "       -p = will build packaging in IMAGE      "
    echo "       -o = build OTA package                           "
    echo "       -u = build update.img                            "
    echo "       -v = build android with 'user' or 'userdebug'    "
    echo "       -d = huild kernel dts name    "
    echo "       -V = build version    "
    echo "       -J = build jobs    "
    exit 1
}

source build/envsetup.sh >/dev/null
BUILD_UBOOT=false
BUILD_KERNEL_WITH_CLANG=false
BUILD_KERNEL=false
BUILD_ANDROID=false
BUILD_AB_IMAGE=false
BUILD_UPDATE_IMG=false
BUILD_OTA=false
BUILD_PACKING=false
BUILD_VARIANT=`get_build_var TARGET_BUILD_VARIANT`
KERNEL_DTS=""
BUILD_VERSION=""
BUILD_JOBS=16

# check pass argument
while getopts "UCKABpouv:d:V:J:" arg
do
    case $arg in
        U)
            echo "will build u-boot"
            BUILD_UBOOT=true
            ;;
        C)
            echo "will build kernel with Clang"
            BUILD_KERNEL=true
            BUILD_KERNEL_WITH_CLANG=true
            ;;
        K)
            echo "will build kernel"
            BUILD_KERNEL=true
            ;;
        A)
            echo "will build android"
            BUILD_ANDROID=true
            ;;
        B)
            echo "will build AB Image"
            BUILD_AB_IMAGE=true
            ;;
        p)
            echo "will build packaging in IMAGE"
            BUILD_PACKING=true
            ;;
        o)
            echo "will build ota package"
            BUILD_OTA=true
            ;;
        u)
            echo "will build update.img"
            BUILD_UPDATE_IMG=true
            ;;
        v)
            BUILD_VARIANT=$OPTARG
            ;;
        V)
            BUILD_VERSION=$OPTARG
            ;;
        d)
            KERNEL_DTS=$OPTARG
            ;;
        J)
            BUILD_JOBS=$OPTARG
            ;;
        ?)
            usage ;;
    esac
done

TARGET_PRODUCT=`get_build_var TARGET_PRODUCT`
TARGET_BOARD_PLATFORM=`get_build_var TARGET_BOARD_PLATFORM`

#set jdk version
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
export PATH=$ANDROID_BUILD_TOP/prebuilts/clang/host/linux-x86/clang-r416183b/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar

# source environment and chose target product
BUILD_NUMBER=`get_build_var BUILD_NUMBER`
BUILD_ID=`get_build_var BUILD_ID`
# only save the version code
SDK_VERSION=`get_build_var CURRENT_SDK_VERSION`
UBOOT_DEFCONFIG=`get_build_var PRODUCT_UBOOT_CONFIG`
KERNEL_VERSION=`get_build_var PRODUCT_KERNEL_VERSION`
KERNEL_ARCH=`get_build_var PRODUCT_KERNEL_ARCH`
KERNEL_DEFCONFIG=`get_build_var PRODUCT_KERNEL_CONFIG`
if [ "$KERNEL_DTS" = "" ] ; then
KERNEL_DTS=`get_build_var PRODUCT_KERNEL_DTS`
fi
LOCAL_KERNEL_PATH=kernel-$KERNEL_VERSION
echo "-------------------KERNEL_VERSION:$KERNEL_VERSION"
echo "-------------------KERNEL_DTS:$KERNEL_DTS"

if [ "$KERNEL_VERSION" = "5.10" ] ; then
echo "Force use clang and llvm to build kernel-$KERNEL_VERSION"
BUILD_KERNEL_WITH_CLANG=true
fi

PACK_TOOL_DIR=RKTools/linux/Linux_Pack_Firmware
IMAGE_PATH=rockdev/Image-$TARGET_PRODUCT
export PROJECT_TOP=`gettop`

lunch $TARGET_PRODUCT-$BUILD_VARIANT

DATE=$(date  +%Y%m%d.%H%M)
STUB_PATH=Image/"$TARGET_PRODUCT"_"$BUILD_VARIANT"_"$KERNEL_DTS"_"$BUILD_VERSION"_"$DATE"
STUB_PATH="$(echo $STUB_PATH | tr '[:lower:]' '[:upper:]')"
export STUB_PATH=$PROJECT_TOP/$STUB_PATH
export STUB_PATCH_PATH=$STUB_PATH/PATCHES

# build uboot
if [ "$BUILD_UBOOT" = true ] ; then
echo "start build uboot"
cd u-boot && make clean &&  make mrproper &&  make distclean && ./make.sh $UBOOT_DEFCONFIG && cd -
if [ $? -eq 0 ]; then
    echo "Build uboot ok!"
else
    echo "Build uboot failed!"
    exit 1
fi
fi

if [ "$BUILD_KERNEL_WITH_CLANG" = true ] ; then
ADDON_ARGS="CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 LLVM_IAS=1"
fi

# build kernel
if [ "$BUILD_KERNEL" = true ] ; then
echo "Start build kernel"
cd $LOCAL_KERNEL_PATH && make clean && make $ADDON_ARGS ARCH=$KERNEL_ARCH $KERNEL_DEFCONFIG && make $ADDON_ARGS ARCH=$KERNEL_ARCH $KERNEL_DTS.img -j$BUILD_JOBS && cd -
if [ $? -eq 0 ]; then
    echo "Build kernel ok!"
else
    echo "Build kernel failed!"
    exit 1
fi

if [ "$KERNEL_ARCH" = "arm64" ]; then
    KERNEL_DEBUG=$LOCAL_KERNEL_PATH/arch/arm64/boot/Image
else
    KERNEL_DEBUG=$LOCAL_KERNEL_PATH/arch/arm/boot/zImage
fi
cp -rf $KERNEL_DEBUG $OUT/kernel
fi

echo "package resoure.img with charger images"
cd u-boot && ./scripts/pack_resource.sh ../$LOCAL_KERNEL_PATH/resource.img && cp resource.img ../$LOCAL_KERNEL_PATH/resource.img && cd -

# build android
if [ "$BUILD_ANDROID" = true ] ; then
    # build OTA
    if [ "$BUILD_OTA" = true ] ; then
        INTERNAL_OTA_PACKAGE_OBJ_TARGET=obj/PACKAGING/target_files_intermediates/$TARGET_PRODUCT-target_files-*.zip
        INTERNAL_OTA_PACKAGE_TARGET=$TARGET_PRODUCT-ota-*.zip
        if [ "$BUILD_AB_IMAGE" = true ] ; then
            echo "make ab image and generate ota package"
            make installclean
            make -j$BUILD_JOBS
            make dist -j$BUILD_JOBS
            ./mkimage_ab.sh ota
        else
            echo "generate ota package"
	    make installclean
	    make -j$BUILD_JOBS
	    make dist -j$BUILD_JOBS
            ./mkimage.sh ota
        fi
        cp $OUT/$INTERNAL_OTA_PACKAGE_TARGET $IMAGE_PATH/
        cp $OUT/$INTERNAL_OTA_PACKAGE_OBJ_TARGET $IMAGE_PATH/
    else # regular build without OTA
        echo "start build android"
        make installclean
        make -j$BUILD_JOBS
        # check the result of make
        if [ $? -eq 0 ]; then
            echo "Build android ok!"
        else
            echo "Build android failed!"
            exit 1
        fi
    fi
else # repack v2 boot
    echo "Repacking header 2 boot..."
    BOOT_CMDLINE=`get_build_var BOARD_KERNEL_CMDLINE`
    SECURITY_LEVEL=`get_build_var PLATFORM_SECURITY_PATCH`
    mkbootfs -d $OUT/system $OUT/ramdisk | minigzip > $OUT/ramdisk.img
    mkbootimg --kernel $OUT/kernel --ramdisk $OUT/ramdisk.img --dtb $OUT/dtb.img --cmdline "$BOOT_CMDLINE" --os_version 12 --os_patch_level $SECURITY_LEVEL --second $LOCAL_KERNEL_PATH/resource.img --header_version 2 --output $OUT/boot.img
fi

if [ "$BUILD_OTA" != true ] ; then
	# mkimage.sh
	echo "make and copy android images"
	./mkimage.sh
	if [ $? -eq 0 ]; then
		echo "Make image ok!"
	else
		echo "Make image failed!"
		exit 1
	fi
fi

if [ "$BUILD_UPDATE_IMG" = true ] ; then
    mkdir -p $PACK_TOOL_DIR/rockdev/Image/
    cp -f $IMAGE_PATH/* $PACK_TOOL_DIR/rockdev/Image/

    echo "Make update.img"
    if [[ $TARGET_PRODUCT =~ "PX30" ]]; then
	cd $PACK_TOOL_DIR/rockdev && ./mkupdate.sh px30 Image
    elif [[ $TARGET_PRODUCT =~ "rk356x_box" ]]; then
	if [ "$BUILD_AB_IMAGE" = true ] ; then
		cd $PACK_TOOL_DIR/rockdev && ./mkupdate_ab_$TARGET_PRODUCT.sh
	else
		cd $PACK_TOOL_DIR/rockdev && ./mkupdate_$TARGET_PRODUCT.sh
	fi
    else
		cd $PACK_TOOL_DIR/rockdev && ./mkupdate.sh $TARGET_BOARD_PLATFORM Image
    fi

    if [ $? -eq 0 ]; then
        echo "Make update image ok!"
    else
        echo "Make update image failed!"
        exit 1
    fi
    cd -
    mv $PACK_TOOL_DIR/rockdev/update.img $IMAGE_PATH/ -f
    rm $PACK_TOOL_DIR/rockdev/Image -rf
fi

if [ "$BUILD_PACKING" = true ] ; then
echo "make and copy packaging in IMAGE "

mkdir -p $STUB_PATH
mkdir -p $STUB_PATH/IMAGES/
cp $IMAGE_PATH/* $STUB_PATH/IMAGES/

#Generate patches

.repo/repo/repo forall  -c "$PROJECT_TOP/device/rockchip/common/gen_patches_body.sh"
.repo/repo/repo manifest -r -o out/commit_id.xml
#Copy stubs
cp out/commit_id.xml $STUB_PATH/manifest_${DATE}.xml

mkdir -p $STUB_PATCH_PATH/kernel
cp $LOCAL_KERNEL_PATH/.config $STUB_PATCH_PATH/kernel
cp $LOCAL_KERNEL_PATH/vmlinux $STUB_PATCH_PATH/kernel

cp build.sh $STUB_PATH/build.sh
#Save build command info
echo "Build as $LOCAL_KERNEL_PATH"                                                                   >> $STUB_PATH/build_cmd_info.txt
echo "uboot:   ./make.sh $UBOOT_DEFCONFIG"                                                           >> $STUB_PATH/build_cmd_info.txt
echo "kernel:  make ARCH=$KERNEL_ARCH $KERNEL_DEFCONFIG && make ARCH=$KERNEL_ARCH $KERNEL_DTS.img"   >> $STUB_PATH/build_cmd_info.txt
echo "android: lunch $TARGET_PRODUCT-$BUILD_VARIANT && make installclean && make"                    >> $STUB_PATH/build_cmd_info.txt
echo "version: $SDK_VERSION"                                                                         >> $STUB_PATH/build_cmd_info.txt
echo "finger:  $BUILD_ID/$BUILD_NUMBER/$BUILD_VARIANT"                                               >> $STUB_PATH/build_cmd_info.txt
fi
