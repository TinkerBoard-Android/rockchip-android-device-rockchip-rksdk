#!/bin/bash

TARGET_PRODUCT=
TARGET_DEVICE_DIR=

# get pass argument
while getopts "p:d:" arg
do
    case $arg in
        p)
            TARGET_PRODUCT=$OPTARG
            ;;
        d)
            TARGET_DEVICE_DIR=$OPTARG
            ;;
    esac
done

# check arguments
if [[ -z $TARGET_PRODUCT || -z $TARGET_DEVICE_DIR ]];then
    echo "Missing some args, exit!" 1>&2
    echo "TARGET_PRODUCT=$TARGET_PRODUCT" 1>&2
    echo "TARGET_DEVICE_DIR=$TARGET_DEVICE_DIR" 1>&2
    exit 1
fi

DEVICE_ROCKCHIP_PATH=device/rockchip
FSTAB_NAME=fstab.rk30board
if [ -f $TARGET_DEVICE_DIR/$FSTAB_NAME ]; then
FSTAB_COMMON=$TARGET_DEVICE_DIR/$FSTAB_NAME
else
FSTAB_COMMON=$DEVICE_ROCKCHIP_PATH/common/$FSTAB_NAME
fi
FSTAB_PRODUCT=$TARGET_DEVICE_DIR/fstab.$TARGET_PRODUCT
FASTB_UNION=$OUT/root/$FSTAB_NAME
############################################################################################
#merge product's fstab to fstab.rk30board
############################################################################################

if [ -f $FASTB_UNION ]; then
    #echo del existed temp file: $FASTB_UNION 1>&2
    rm -rf $FASTB_UNION
fi

if [ -f $FSTAB_PRODUCT ]; then
    #echo $FSTAB_PRODUCT is exist, merge it to fstab.union 1>&2
    cat $FSTAB_COMMON $FSTAB_PRODUCT > $FASTB_UNION
else
    #echo $FSTAB_PRODUCT is not exist, cat $FSTAB_COMMON to $FASTB_UNION 1>&2
    cat $FSTAB_COMMON > $FASTB_UNION
fi

#if [ -f $FASTB_UNION ]; then
#   echo Success to Merge fstab! 1>&2
#fi

