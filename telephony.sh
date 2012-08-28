#!/bin/bash

  
sed -i 's/<bool name="config_voice_capable">false/<bool name="config_voice_capable">true/' device/rockchip/rk30sdk/overlay/frameworks/base/core/res/res/values/config.xml
sed -i 's/<bool name="config_sms_capable">false/<bool name="config_sms_capable">true/' device/rockchip/rk30sdk/overlay/frameworks/base/core/res/res/values/config.xml
 

