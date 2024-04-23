#! /vendor/bin/sh

#########################################
### init.insmod.cfg format:           ###
### --------------------------------- ###
### [insmod|setprop] [path|prop name] ###
### ...                               ###
#########################################

cfg_gki_file="/vendor/etc/init.insmod_gki.cfg"

if [ -f $cfg_gki_file ]; then
  while IFS=" " read -r action name
  do
    case $action in
      "insmod")
        if [ -f $name ]; then
          insmod $name
        fi
        ;;
      "setprop") setprop $name 1 ;;
    esac
  done < $cfg_gki_file
fi

system_modules="/system_dlkm/lib/modules/modules.load"
if [ -f $system_modules ]; then
  while IFS= read -r name
  do
	if [ -f /system_dlkm/lib/modules/$name ]; then
          insmod /system_dlkm/lib/modules/$name
        fi
  done < $system_modules
fi

vendor_modules="/vendor_dlkm/lib/modules/modules.load"
if [ -f $vendor_modules ]; then
  while IFS= read -r name
  do
	if [ -f /vendor_dlkm/lib/modules/$name ]; then
          insmod /vendor_dlkm/lib/modules/$name
        fi
  done < $vendor_modules
fi

cfg_post_file="/vendor/etc/init.insmod_post.cfg"
if [ -f $cfg_post_file ]; then

  while IFS=" " read -r action name
  do
    case $action in
      "insmod")
        if [ -f $name ]; then
          insmod $name
        fi
        ;;
      "setprop") setprop $name 1 ;;
    esac
  done < $cfg_post_file
fi

if [[ -e "/vendor/etc/init.insmod_charger.cfg" && "$(getprop ro.boot.mode)" == "charger" ]]; then
  cfg_file="/vendor/etc/init.insmod_charger.cfg"
else
  cfg_file="/vendor/etc/init.insmod.cfg"
fi

if [ -f $cfg_file ]; then
  while IFS=" " read -r action name
  do
    case $action in
      "insmod")
        if [ -f $name ]; then
          insmod $name
        fi
        ;;
      "setprop") setprop $name 1 ;;
    esac
  done < $cfg_file
fi

# set property even if there is no insmod config
# as property value "1" is expected in early-boot trigger
setprop vendor.all.modules.ready 1
