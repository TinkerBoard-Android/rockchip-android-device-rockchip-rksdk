#!/system/bin/sh
log -t PackageManager "Start to clean up /system/preinstall_del/"
mount -o rw,remount -t ext4 /dev/block/mtdblock8 /system 
rm system/preinstall_del/*.*
mount -o ro,remount -t ext3 /dev/block/mtdblock8 /system 
