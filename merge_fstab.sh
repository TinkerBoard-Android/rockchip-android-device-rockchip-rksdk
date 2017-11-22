#!/bin/bash

TARGET_PRODUCT=
PRODUCT_OUT=
TARGET_DEVICE_DIR=

# get pass argument
while getopts "p:o:d:" arg
do
    case $arg in
        p)
            TARGET_PRODUCT=$OPTARG
            ;;
        o)
            PRODUCT_OUT=$OPTARG
            ;;
        d)
            TARGET_DEVICE_DIR=$OPTARG
            ;;
    esac
done

# check arguments
if [[ -z $TARGET_PRODUCT || -z $PRODUCT_OUT || -z $TARGET_DEVICE_DIR ]];then
    echo "Missing some args, exit!" 1>&2
    echo "TARGET_PRODUCT=$TARGET_PRODUCT" 1>&2
    echo "PRODUCT_OUT=$PRODUCT_OUT" 1>&2
    echo "TARGET_DEVICE_DIR=$TARGET_DEVICE_DIR" 1>&2
    exit 1
fi

DEVICE_ROCKCHIP_PATH=device/rockchip
FSTAB_NAME=fstab.rk30board
FSTAB_COMMON=$DEVICE_ROCKCHIP_PATH/common/$FSTAB_NAME
FSTAB_PRODUCT=$TARGET_DEVICE_DIR/fstab.$TARGET_PRODUCT
FASTB_UNION=$TARGET_DEVICE_DIR/$FSTAB_NAME
FSTAB_OUT=$PRODUCT_OUT/$FSTAB_NAME
############################################################################################
#merge product's fstab to fstab.rk30board
############################################################################################
echo Merge $FSTAB_PRODUCT to $FSTAB_OUT

if [ -f $FASTB_UNION ]; then
    echo del existed temp file: $FASTB_UNION
    rm -rf $FASTB_UNION
fi

if [ -f $FSTAB_PRODUCT ]; then
    echo $FSTAB_PRODUCT is exist, merge it to fstab.union
    cat $FSTAB_COMMON $FSTAB_PRODUCT > $FASTB_UNION
else
    echo $FSTAB_PRODUCT is not exist, cat $FSTAB_COMMON to $FASTB_UNION
    cat $FSTAB_COMMON > $FASTB_UNION
fi

if [ -f $FASTB_UNION ]; then
    echo Success to Merge fstab!
fi
