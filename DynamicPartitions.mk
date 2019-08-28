# Enable dynamic partitions, Android Q must set this by default.
# Use the non-open-source parts, if they're present
# Android Q -> api_level 29, Pie or earlier should not include this makefile

PRODUCT_USE_DYNAMIC_PARTITIONS := true

BOARD_SUPER_PARTITION_GROUPS := rockchip_dynamic_partitions
BOARD_ROCKCHIP_DYNAMIC_PARTITIONS_SIZE ?= 3263168512
BOARD_ROCKCHIP_DYNAMIC_PARTITIONS_PARTITION_LIST := system vendor odm
BOARD_SYSTEMIMAGE_PARTITION_RESERVED_SIZE := 52428800
BOARD_VENDORIMAGE_PARTITION_RESERVED_SIZE := 52428800
BOARD_ODMIMAGE_PARTITION_RESERVED_SIZE := 52428800
