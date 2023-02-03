#!/bin/bash

# CFG start
CFG_COUNTRY=CN
CFG_PROVINE=Fujian
CFG_CITY=Fuzhou
CFG_COMPANY=Rockchip
CFG_EMAIL=gms@rock-chips.com
# CFG end

TARGET_KEY_PATH=device/rockchip/common/security
include_array=(media platform shared testkey)
TMP_KEYSET=.rktmp_keyset_dir

if [ -d $TMP_KEYSET ]; then
    echo "cleanning previous cache..."
    rm -rf $TMP_KEYSET
fi

mkdir $TMP_KEYSET
cd $TMP_KEYSET

count="${#include_array[@]}"
for idx in "${!include_array[@]}"; do
    ret="${include_array[$idx]}"
    rm ../$TARGET_KEY_PATH/$ret.*
    echo "Generating keyset for $ret ..."
    ../development/tools/make_key $ret \
        "/C=$CFG_COUNTRY/ST=$CFG_PROVINE/L=$CFG_CITY/O=$CFG_COMPANY/OU=$CFG_COMPANY/CN=$CFG_COMPANY/emailAddress=$CFG_EMAIL"
    openssl pkcs8 -inform DER -nocrypt -in $ret.pk8 -out $ret.pem
    mv $ret* ../$TARGET_KEY_PATH/
done

