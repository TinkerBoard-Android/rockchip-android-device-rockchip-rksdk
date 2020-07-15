## Prebuilt modules written by Rockchip.
Example:

- Shared libaries
```Android.bp
cc_rockchip_prebuilt_library_shared {
    name: "libteec",
    strip: {
        none: true,
    },
    check_elf_files: false,
    vendor: true,
    optee: true,
}
```
Libs would be built:
    optee: true -> v1(or v2 only for RK3326)/arm(64)/$(name).so
    optee: false -> arm(64)/$(name).so
Libs would be placed:
    system(vendor)/lib(64)/$(name).so


- Binaries
```Android.bp
cc_rockchip_prebuilt_binary {
    name: "tee-supplicant",
    strip: {
        none: true,
    },
    check_elf_files: false,
    vendor: true,
    optee: true,
}
```
Binaries would be built:
    optee: true -> v1(or v2 only for RK3326)/arm(64)/$(name)
    optee: false -> arm(64)/$(name)
Binaries would be placed:
    system(vendor)/bin/$(name)

- Other files
```Android.bp
cc_rockchip_prebuilt_obj {
    name: "1.ta",
    src: "1.ta", // Will be set to $(name) if not set
    vendor: true,
    optee: true,
    sub_dir: "lib/optee_armtz",
}
```
Objects would be copy from:
    optee: true -> v1(or v2 only for RK3326)/ta/$(name) or $(src)
    optee: false -> $(name) or $(src)
Objects would be placed:
    system(vendor, recovery or ramdisk)/$(sub_dir)/$(name)
