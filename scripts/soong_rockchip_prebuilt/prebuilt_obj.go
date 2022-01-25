package rockchip_prebuilts

import (
    "strconv"
    "strings"
    "android/soong/android"
)

var pctx = android.NewPackageContext("android/soon/rockchip_prebuilts")

func init() {
    pctx.Import("android/soong/android")

    android.RegisterModuleType("cc_rockchip_prebuilt_obj", RockchipPrebuiltObjectFactory)
    android.RegisterModuleType("cc_rockchip_prebuilt_binary", RockchipPrebuiltBinFactory)
}

type RockchipPrebuiltObjectProperties struct {
    // Source file of this prebuilt.
    Src *string `android:"path,arch_variant"`

    // optional subdirectory under which this file is installed into
    Sub_dir *string `android:"arch_variant"`

    // optional name for the installed file. If unspecified, name of the module is used as the file name
    Filename *string `android:"arch_variant"`

    // when set to true, and filename property is not set, the name for the installed file
    // is the same as the file name of the source file.
    Filename_from_src *bool `android:"arch_variant"`

    // Make this module available when building for ramdisk.
    Ramdisk_available *bool

    // Make this module available when building for vendor ramdisk.
    // On device without a dedicated recovery partition, the module is only
    // available after switching root into
    // /first_stage_ramdisk. To expose the module before switching root, install
    // the recovery variant instead.
    Vendor_ramdisk_available *bool

    // Make this module available when building for debug ramdisk.
    Debug_ramdisk_available *bool

    // Make this module available when building for recovery.
    Recovery_available *bool

    // Whether this module is directly installable to one of the partitions. Default: true.
    Installable *bool

    // Whether this module is optee.
    Optee *bool
    Npu *bool

    // Ignore the following properties because we want to keep compatible.
    Check_elf_files *bool
    Shared_libs []string `android:"arch_variant"`
    Strip stripAttributes
}

type stripAttributes struct {
	//Keep_symbols                 *bool
	//Keep_symbols_and_debug_frame *bool
	//Keep_symbols_list            []string `android:"arch_variant"`
	All                          *bool
	None                         *bool
}

type RockchipPrebuiltObjectModule interface {
    android.Module
    SubDir() string
    OutputFile() android.OutputPath
}

type RockchipPrebuiltObject struct {
    android.ModuleBase

    properties RockchipPrebuiltObjectProperties

    sourceFilePath android.Path
    outputFilePath android.OutputPath
    // The base install location, e.g. "etc" for cc_rockchip_prebuilt_obj, "usr/share" for prebuilt_usr_share.
    installDirBase string
    // The base install location when soc_specific property is set to true, e.g. "firmware" for prebuilt_firmware.
    socInstallDirBase      string
    installDirPath         android.InstallPath
    additionalDependencies *android.Paths
    addArchToPrefix *bool
}

func (p *RockchipPrebuiltObject) inRamdisk() bool {
    return p.ModuleBase.InRamdisk() || p.ModuleBase.InstallInRamdisk()
}

func (p *RockchipPrebuiltObject) onlyInRamdisk() bool {
    return p.ModuleBase.InstallInRamdisk()
}

func (p *RockchipPrebuiltObject) InstallInRamdisk() bool {
    return p.inRamdisk()
}

func (p *RockchipPrebuiltObject) inRecovery() bool {
    return p.ModuleBase.InRecovery() || p.ModuleBase.InstallInRecovery()
}

func (p *RockchipPrebuiltObject) onlyInRecovery() bool {
    return p.ModuleBase.InstallInRecovery()
}

func (p *RockchipPrebuiltObject) InstallInRecovery() bool {
    return p.inRecovery()
}

var _ android.ImageInterface = (*RockchipPrebuiltObject)(nil)

func (p *RockchipPrebuiltObject) ImageMutatorBegin(ctx android.BaseModuleContext) {}

func (p *RockchipPrebuiltObject) CoreVariantNeeded(ctx android.BaseModuleContext) bool {
    return !p.ModuleBase.InstallInRecovery() && !p.ModuleBase.InstallInRamdisk()
}

func (p *RockchipPrebuiltObject) RamdiskVariantNeeded(ctx android.BaseModuleContext) bool {
    return android.Bool(p.properties.Ramdisk_available) || p.ModuleBase.InstallInRamdisk()
}

func (p *RockchipPrebuiltObject) VendorRamdiskVariantNeeded(ctx android.BaseModuleContext) bool {
    return android.Bool(p.properties.Vendor_ramdisk_available) || p.ModuleBase.InstallInVendorRamdisk()
}

func (p *RockchipPrebuiltObject) DebugRamdiskVariantNeeded(ctx android.BaseModuleContext) bool {
    return android.Bool(p.properties.Debug_ramdisk_available) || p.ModuleBase.InstallInDebugRamdisk()
}

func (p *RockchipPrebuiltObject) RecoveryVariantNeeded(ctx android.BaseModuleContext) bool {
    return android.Bool(p.properties.Recovery_available) || p.ModuleBase.InstallInRecovery()
}

func (p *RockchipPrebuiltObject) ExtraImageVariations(ctx android.BaseModuleContext) []string {
    return nil
}

func (p *RockchipPrebuiltObject) SetImageVariation(ctx android.BaseModuleContext, variation string, module android.Module) {
}

func (p *RockchipPrebuiltObject) DepsMutator(ctx android.BottomUpMutatorContext) {
    if p.properties.Src == nil {
        var new_src string = p.ModuleBase.BaseModuleName()
        p.properties.Src = &new_src
    }
}

func (p *RockchipPrebuiltObject) SourceFilePath(ctx android.ModuleContext) android.Path {
    return android.PathForModuleSrc(ctx, android.String(p.properties.Src))
}

func (p *RockchipPrebuiltObject) InstallDirPath() android.InstallPath {
    return p.installDirPath
}

// This allows other derivative modules (e.g. cc_rockchip_prebuilt_obj_xml) to perform
// additional steps (like validating the src) before the file is installed.
func (p *RockchipPrebuiltObject) SetAdditionalDependencies(paths android.Paths) {
    p.additionalDependencies = &paths
}

func (p *RockchipPrebuiltObject) OutputFile() android.OutputPath {
    return p.outputFilePath
}

func (p *RockchipPrebuiltObject) SubDir() string {
    return android.String(p.properties.Sub_dir)
}

func (p *RockchipPrebuiltObject) Installable() bool {
    return p.properties.Installable == nil || android.Bool(p.properties.Installable)
}

func (p *RockchipPrebuiltObject) Optee() bool {
    return p.properties.Optee != nil && android.Bool(p.properties.Optee)
}

func (p *RockchipPrebuiltObject) Npu() bool {
    return p.properties.Npu != nil && android.Bool(p.properties.Npu)
}

func (p *RockchipPrebuiltObject) GenerateAndroidBuildActions(ctx android.ModuleContext) {
    var prefix string = ""
    if (p.Npu()) {
        prefix = strings.ToUpper(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"))
        if (!strings.EqualFold("rk356x", prefix) && !strings.EqualFold("rk3588", prefix)) {
            prefix = "RK356X"
        }
        prefix += "/Android/rknn_server/"
    }
    if (p.Optee()) {
        prefix = getOpteePrefix(ctx.AConfig().Getenv("TARGET_BOARD_PLATFORM"))
    }
    if (android.Bool(p.addArchToPrefix)) {
        if (strings.EqualFold(ctx.AConfig().DevicePrimaryArchType().String(),"arm64")) {
            prefix += "arm64/"
        } else {
            prefix += "arm/"
        }
    }
    p.sourceFilePath = android.PathForModuleSrc(ctx, prefix + android.String(p.properties.Src))
    filename := android.String(p.properties.Filename)
    filename_from_src := android.Bool(p.properties.Filename_from_src)
    if filename == "" {
        if filename_from_src {
            filename = p.sourceFilePath.Base()
        } else {
            filename = ctx.ModuleName()
        }
    } else if filename_from_src {
        ctx.PropertyErrorf("filename_from_src", "filename is set. filename_from_src can't be true")
        return
    }
    p.outputFilePath = android.PathForModuleOut(ctx, filename).OutputPath

    // If soc install dir was specified and SOC specific is set, set the installDirPath to the specified
    // socInstallDirBase.
    installBaseDir := p.installDirBase
    if ctx.SocSpecific() && p.socInstallDirBase != "" {
        installBaseDir = p.socInstallDirBase
    }
    p.installDirPath = android.PathForModuleInstall(ctx, installBaseDir, android.String(p.properties.Sub_dir))

    // This ensures that outputFilePath has the correct name for others to
    // use, as the source file may have a different name.
    ctx.Build(pctx, android.BuildParams{
        Rule:   android.Cp,
        Output: p.outputFilePath,
        Input:  p.sourceFilePath,
    })
}

func (p *RockchipPrebuiltObject) AndroidMkEntries() []android.AndroidMkEntries {
    nameSuffix := ""
    if p.inRamdisk() && !p.onlyInRamdisk() {
        nameSuffix = ".ramdisk"
    }
    if p.inRecovery() && !p.onlyInRecovery() {
        nameSuffix = ".recovery"
    }
    return []android.AndroidMkEntries{android.AndroidMkEntries{
        Class:      "ETC",
        SubName:    nameSuffix,
        OutputFile: android.OptionalPathForPath(p.outputFilePath),
        Required: p.properties.Shared_libs,
        ExtraEntries: []android.AndroidMkExtraEntriesFunc{
            func(ctx android.AndroidMkExtraEntriesContext, entries *android.AndroidMkEntries) {
                entries.SetString("LOCAL_MODULE_TAGS", "optional")
                entries.SetString("LOCAL_MODULE_PATH", p.installDirPath.ToMakePath().String())
                entries.SetString("LOCAL_INSTALLED_MODULE_STEM", p.outputFilePath.Base())
                entries.SetString("LOCAL_UNINSTALLABLE_MODULE", strconv.FormatBool(!p.Installable()))
                entries.SetString("LOCAL_SHARED_LIBRARIES", strconv.FormatBool(!p.Installable()))
                if p.additionalDependencies != nil {
                    entries.AddStrings("LOCAL_ADDITIONAL_DEPENDENCIES", p.additionalDependencies.Strings()...)
                }
            },
        },
    }}
}

func InitRockchipPrebuiltObjectModule(p *RockchipPrebuiltObject, dirBase string, addArch bool) {
    p.installDirBase = dirBase
    p.addArchToPrefix = &addArch
    p.AddProperties(&p.properties)
}

// cc_rockchip_prebuilt_obj is for a prebuilt artifact that is installed in
// <partition>/<sub_dir> directory.
func RockchipPrebuiltObjectFactory() android.Module {
    module := &RockchipPrebuiltObject{}
    InitRockchipPrebuiltObjectModule(module, "", false)
    // This module is device-only
    android.InitAndroidArchModule(module, android.DeviceSupported, android.MultilibFirst)
    return module
}

// cc_rockchip_prebuilt_binary is for a prebuilt artifact that is installed in
// <partition>/bin/<sub_dir> directory.
func RockchipPrebuiltBinFactory() android.Module {
    module := &RockchipPrebuiltObject{}
    InitRockchipPrebuiltObjectModule(module, "bin", true)
    // This module is device-only
    android.InitAndroidArchModule(module, android.DeviceSupported, android.MultilibFirst)
    return module
}

