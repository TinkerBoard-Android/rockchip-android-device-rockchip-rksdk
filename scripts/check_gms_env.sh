#!/bin/bash

declare -A dpi_aapt_map

dpi_aapt_map["ldpi"]="120"
dpi_aapt_map["140dpi"]="140"
dpi_aapt_map["mdpi"]="160"
dpi_aapt_map["180dpi"]="180"
dpi_aapt_map["200dpi"]="200"
dpi_aapt_map["tvdpi"]="213"
dpi_aapt_map["220dpi"]="220"
dpi_aapt_map["hdpi"]="240"
dpi_aapt_map["280dpi"]="280"
dpi_aapt_map["xhdpi"]="320"
dpi_aapt_map["360dpi"]="360"
dpi_aapt_map["400dpi"]="400"
dpi_aapt_map["420dpi"]="420"
dpi_aapt_map["xxhdpi"]="480"
dpi_aapt_map["560dpi"]="560"
dpi_aapt_map["xxxhdpi"]="640"

#IS_GO_BUILD=`get_build_var BUILD_WITH_GO_OPT`
KERNEL_PATH=`get_build_var PRODUCT_KERNEL_PATH`
if [[ $KERNEL_PATH =~ "kernel" ]] ; then
    log "kernel path: $KERNEL_PATH"
else
    KERNEL_PATH=kernel
    log "kernel path: $KERNEL_PATH"
fi

# $1 var
# $2 value
# $3 msg to display
# Color: red for failed, green for pass
assert_env_value() {
    RET=`get_build_var $1`
    if [ $2 = "$RET" ] ; then
        echo -e "\033[32m [Pass] \033[0m \t\"$1\" Check OK!"
    else
        echo -e "\033[31m [Failed] \033[0m \t$1 Check Failed! Expect \"$2\", But was \"$RET\""
        echo -e "\033[31m \"$3\" \033[0m"
    fi
}

# $1 config to be checked
# $2 file to be checked
# $3 msg to display
assert_config_in_file() {
    RET=`grep -c "$1" $2`
    if [ "1" = "$RET" ] ; then
        echo -e "\033[32m [Pass] \033[0m \t\"$1\" Check OK!"
    else
        echo -e "\033[31m [Failed] \033[0m \t\"$1\" Check Failed! Expect \"$1\""
        echo -e "\033[31m \"$3\" \033[0m"
    fi
}

# $1 value
# $2 string
assert_value_in_string() {
    if [[ "$2" =~ "$1" ]] ; then
        echo -e "\033[32m [Pass] \033[0m \t\"$1\" Check OK!"
    else
        echo -e "\033[31m [Failed] \033[0m \t\"$1\" Check Failed! Expect \"$1\" FOUND, But was NOT FOUND"
        echo -e "\033[31m \"$3\" \033[0m"
    fi
}

# $1 value
# $2 string
assert_value_not_in_string() {
    if [[ "$2" =~ "$1" ]] ; then
        echo -e "\033[31m [Failed] \033[0m \t\"$1\" Check Failed! Expect \"$1\" NOT FOUND, But was FOUND"
        echo -e "\033[31m \"$3\" \033[0m"
    else
        echo -e "\033[32m [Pass] \033[0m \t\"$1\" Check OK!"
    fi
}

log() {
    echo $1
}

check_GO_config() {
    assert_config_in_file "RGA2G" $KERNEL_PATH/drivers/video/rockchip/rga2/Kconfig
}

check_kernel_config() {
    assert_config_in_file "clang version" $KERNEL_PATH/.config "Kernel MUST be compiled with clang."
    assert_config_in_file "CONFIG_ANDROID_BINDERFS=y" $KERNEL_PATH/.config "Did you compile the kernel with android-11.config?"
    assert_config_in_file "# CONFIG_DEBUG_FS is not set" $KERNEL_PATH/.config "Did you compile the kernel with non_debuggable.config?"
}

check_widevine() {
    log "Checking widevine..."
    assert_env_value BOARD_WIDEVINE_OEMCRYPTO_LEVEL 3 "GMS builds require a widevine level of at least L3."
}

check_EEA_type() {
    log "Checking EEA..."
    assert_env_value BUILD_WITH_EEA "" "If you do not have an EEA license, you should not enable EEA."
}

check_GMS_BUNDLE() {
    log "Checking base var..."
    assert_env_value BUILD_WITH_GOOGLE_MARKET true "Core var should be enabled."
    assert_env_value BUILD_WITH_GOOGLE_MARKET_ALL false "WIFI-Only device should not enable this Var."
    assert_env_value BUILD_WITH_GOOGLE_GMS_EXPRESS true "We recommend that you use GMS Express."
    assert_env_value PRODUCT_HAVE_RKAPPS false "Do not enable this on user build."
    assert_env_value BUILD_WITH_GOOGLE_FRP true "Frp MUST be enabled."
}

check_OPTEE() {
    log "Checking Optee..."
    assert_env_value PRODUCT_HAVE_OPTEE true "Optee MUST be enabled."
}

check_AB_AVB() {
    log "Checking avb..."
    assert_env_value BOARD_AVB_ENABLE true "AVB MUST be enabled."
    assert_env_value BOARD_USES_AB_IMAGE true "Android 11+ MUST enable A/B update."
    assert_env_value BOARD_ROCKCHIP_VIRTUAL_AB_ENABLE true "Android 11+ MUST enable virtual A/B update."
}

check_Uboot() {
    assert_config_in_file "CONFIG_ANDROID_AB=y" u-boot/.config "Android 11+ MUST enable A/B update."
    assert_config_in_file "CONFIG_ANDROID_WRITE_KEYBOX=y" u-boot/.config "Attestation key MUST be enabled."
    assert_config_in_file "CONFIG_ANDROID_KEYMASTER_CA=y" u-boot/.config "Keymaster in uboot MUST be enabled."
    assert_config_in_file "CONFIG_OPTEE_CLIENT=y" u-boot/.config "Optee MUST be enabled."
    assert_config_in_file "CONFIG_OPTEE_ALWAYS_USE_SECURITY_PARTITION=y" u-boot/.config "Security partition MUST be enabled."
}

check_SELINUX() {
    log "Checking SELinux..."
    assert_env_value BOARD_SELINUX_ENFORCING true "SELinux MUST be enabled."
    TMP_CMDLINE=`get_build_var BOARD_KERNEL_CMDLINE`
    assert_value_not_in_string "androidboot.selinux=permissive" "$TMP_CMDLINE" "androidboot.selinux=permissive MUST NOT in cmdline, check BOARD_KERNEL_CMDLINE."
}

check_AAPT_CONFIG() {
    log "Checking aapt and dpi config..."
    AAPT_PERF=`get_build_var PRODUCT_AAPT_PREF_CONFIG`
    RET_AAPT_LIST=`grep -r PRODUCT_AAPT_CONFIG device/rockchip/common/device.mk`
    assert_value_in_string $AAPT_PERF $RET_AAPT_LIST "$AAPT_PERF not in PRODUCT_AAPT_CONFIG list, please add $AAPT_PERF to list."
    TMP_DPI="ro.sf.lcd_density=${dpi_aapt_map["$AAPT_PERF"]}"
    define_api=`grep ro.sf.lcd_density $OUT/vendor/build.prop`
    assert_value_in_string $TMP_DPI $define_api "ro.sf.lcd_density MUST correspond to PRODUCT_AAPT_PREF_CONFIG, please set property to $TMP_DPI or change PRODUCT_AAPT_PREF_CONFIG"
}

check_Uboot
check_kernel_config
check_widevine
#check_EEA_type
check_GMS_BUNDLE
check_OPTEE
check_AB_AVB
check_SELINUX
check_AAPT_CONFIG
