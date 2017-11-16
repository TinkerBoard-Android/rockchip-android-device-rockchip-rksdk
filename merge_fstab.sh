#!/bin/bash
TARGET_PRODUCT=$1
PRODUCT_OUT=$2

DEVICE_ROCKCHIP_PATH=device/rockchip
FSTAB_NAME=fstab.rk30board
FSTAB_COMMON=$DEVICE_ROCKCHIP_PATH/common/$FSTAB_NAME
FSTAB_PRODUCT=$DEVICE_ROCKCHIP_PATH/$TARGET_PRODUCT/fstab.$TARGET_PRODUCT
FASTB_UNION=$DEVICE_ROCKCHIP_PATH/$TARGET_PRODUCT/$FSTAB_NAME
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
