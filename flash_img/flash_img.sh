#!/system/bin/sh
log -t flash_img "dd.sh flash_img"
if=$(getprop persist.vendor.flash_if_path)
of=$(getprop persist.vendor.flash_of_path)
log -t flash_img "if=$if,of=$of"
RESULT=$(dd if=$if of=$of 2>&1)
log -t flash_img "$RESULT"
setprop sys.retaildemo.enabled 0
