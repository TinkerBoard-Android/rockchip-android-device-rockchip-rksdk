package rockchip_prebuilts

import (
    "android/soong/android"
    "android/soong/cc"
    "fmt"
    "strings"
)

func init() {
    fmt.Println("Rockchip conditional compile")
    android.RegisterModuleType("cc_rockchip_prebuilt_library_shared", RockchipPrebuiltLibsFactory)
    android.RegisterModuleType("cc_rockchip_prebuilt_binary", RockchipPrebuiltBinFactory)
}

func RockchipPrebuiltLibsFactory() (android.Module) {
    // Register rockchip_prebuilt_libs factory as PrebuiltSharedLibraryFactory
    module := cc.PrebuiltSharedLibraryFactory()

    // Add new props for rockchip conditional compile
    addon_props := &soongRockchipPrebuiltProperties{}
    module.AddProperties(addon_props)

    // Add Hook for PrebuiltSharedLibraryFactory
    android.AddLoadHook(module, AppendMultilibs)
    return module
}

func RockchipPrebuiltBinFactory() (android.Module) {
    // Register rockchip_prebuilt_binary factory as PrebuiltBinaryFactory
    module := cc.PrebuiltBinaryFactory()

    // Add new props for rockchip conditional compile
    addon_props := &soongRockchipPrebuiltProperties{}
    module.AddProperties(addon_props)

    // Add Hook for PrebuiltBinaryFactory
    android.AddLoadHook(module, ChangeSrcsPath)
    return module
}

/* *
 * For prebuilt binary and object
 * optee: true  --> srcs: v1(2)/arm(64)/$(name)
 * optee: false --> srcs: arm(64)/$(name)
 */
func ChangeSrcsPath(ctx android.LoadHookContext) {
    var prefix string = ""
    var module_name string = ctx.ModuleName()[9:]
    type props struct {
        Srcs []string
    }
    p := &props{}
    if (ctx.ContainsProperty("optee")) {
        if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3326")) {
            prefix = "v2/"
        } else {
            prefix = "v1/"
        }
    }
    if (strings.EqualFold(ctx.AConfig().DevicePrimaryArchType().String(),"arm64")) {
        prefix += "arm64/"
    } else {
        prefix += "arm/"
    }
    p.Srcs = append(p.Srcs, prefix + module_name)
    //fmt.Println("srcs: ", p.Srcs)
    ctx.AppendProperties(p)
}

type Ex_srcs struct {
    Srcs []string
}

type Ex_multilibType struct {
    Lib32 Ex_srcs
    Lib64 Ex_srcs
}

type soongRockchipPrebuiltProperties struct {
    Optee bool
}

func AppendMultilibs(ctx android.LoadHookContext) {
    if (strings.EqualFold(ctx.AConfig().DevicePrimaryArchType().String(),"arm64")) {
        type props struct {
            Compile_multilib *string
            Multilib Ex_multilibType
        }
        p := &props{}
        p.Compile_multilib = peferCompileMultilib(ctx)
        p.Multilib = configArm64Lib(ctx)
        ctx.AppendProperties(p)
    } else {
        type props struct {
            Compile_multilib *string
            Srcs []string
        }
        p := &props{}
        p.Compile_multilib = peferCompileMultilib(ctx)
        p.Srcs = configArmLib(ctx)
        ctx.AppendProperties(p)
    }
}

// Change the lib path, chose lib/lib64
func peferCompileMultilib(ctx android.LoadHookContext) (*string) {
    /*fmt.Println("TARGET_PRODUCT:", ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"))
    fmt.Println("TARGET_ARCH:", ctx.AConfig().DevicePrimaryArchType().String())
    fmt.Println("MODULE NAME:", ctx.ModuleName()[9:]) // Skip 'prebuilt_'
    fmt.Println("isOptee:", ctx.ContainsProperty("optee"))*/

    var compile_multilib string
    target_arch := ctx.AConfig().DevicePrimaryArchType().String()
    if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3126c")) {
        compile_multilib = "32"
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk322x")) {
        compile_multilib = "32"
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3326")) {
        if (strings.EqualFold(target_arch,"arm64")) {
            compile_multilib = "both"
        } else {
            compile_multilib = "32"
        }
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3328")) {
        if (strings.EqualFold(target_arch,"arm64")) {
            compile_multilib = "both"
        } else {
            compile_multilib = "32"
        }
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3368")) {
        if (strings.EqualFold(target_arch,"arm64")) {
            compile_multilib = "both"
        } else {
            compile_multilib = "32"
        }
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3399")) {
        if (strings.EqualFold(target_arch,"arm64")) {
            compile_multilib = "both"
        } else {
            compile_multilib = "32"
        }
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3399pro")) {
        if (strings.EqualFold(target_arch,"arm64")) {
            compile_multilib = "both"
        } else {
            compile_multilib = "32"
        }
    } else {
        compile_multilib = "32"
    }
    //fmt.Println("compile_multilib:", compile_multilib)
    return &compile_multilib
}

func configArm64Lib(ctx android.LoadHookContext) (Ex_multilibType) {
    var srcs []string
    var module_name string = ctx.ModuleName()[9:] + ".so"
    var multilib Ex_multilibType
    var prefix64 string
    var prefix32 string
    if (ctx.ContainsProperty("optee")) {
        if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3326")) {
            prefix64 = "v2/arm64/"
            prefix32 = "v2/arm/"
        } else {
            prefix64 = "v1/arm64/"
            prefix32 = "v1/arm/"
        }
    } else {
        prefix64 = "arm64/"
        prefix32 = "arm/"
    }
    if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3126c")) {
        multilib.Lib32.Srcs = append(srcs, prefix32 + module_name)
        multilib.Lib64.Srcs = append(srcs, prefix64 + module_name)
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3326")) {
        multilib.Lib32.Srcs = append(srcs, prefix32 + module_name)
        multilib.Lib64.Srcs = append(srcs, prefix64 + module_name)
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3328")) {
        multilib.Lib32.Srcs = append(srcs, prefix32 + module_name)
        multilib.Lib64.Srcs = append(srcs, prefix64 + module_name)
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3368")) {
        multilib.Lib32.Srcs = append(srcs, prefix32 + module_name)
        multilib.Lib64.Srcs = append(srcs, prefix64 + module_name)
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3399")) {
        multilib.Lib32.Srcs = append(srcs, prefix32 + module_name)
        multilib.Lib64.Srcs = append(srcs, prefix64 + module_name)
    } else {
        multilib.Lib32.Srcs = append(srcs, prefix32 + module_name)
        multilib.Lib64.Srcs = append(srcs, prefix64 + module_name)
    }
    //fmt.Println("multilib.lib32.srcs:", multilib.Lib32.Srcs )
    //fmt.Println("multilib.lib64.srcs:", multilib.Lib64.Srcs)
    return multilib
}

func configArmLib(ctx android.LoadHookContext) ([]string) {
    var srcs []string
    //fmt.Println("TARGET_PRODUCT:", ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"))
    var prefix string
    var module_name string = ctx.ModuleName()[9:] + ".so"
    if (ctx.ContainsProperty("optee")) {
        if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3326")) {
            prefix = "v2/arm/"
        } else {
            prefix = "v1/arm/"
        }
    } else {
        prefix = "arm/"
    }
    if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3126c")) {
        srcs = append(srcs, prefix + module_name)
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk322x")) {
        srcs = append(srcs, prefix + module_name)
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3326")) {
        srcs = append(srcs, prefix + module_name)
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3328")) {
        srcs = append(srcs, prefix + module_name)
    }else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3368")) {
        srcs = append(srcs, prefix + module_name)
    } else if (strings.EqualFold(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"),"rk3399")) {
        srcs = append(srcs, prefix + module_name)
    } else {
        srcs = append(srcs, prefix + module_name)
    }
    //fmt.Println("srcs:", srcs)
    return srcs
}
