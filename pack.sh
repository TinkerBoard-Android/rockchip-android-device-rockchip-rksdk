#!/usr/bin/perl
##############################################################
#		Auto Pack Android Code (without kernel)
#					author : Jerry (zhanghao@rock-chips.com)
#					version info :
#							2011-7-21 : create this shell
##############################################################
# parameters
@so_package=(
#	"hardware/rk29/libon2",
	"hardware/rk29/hwcomposer_rga",
	"hardware/rk29/libgralloc_ump",
#        "hardware/rk29/jpeghw",
        "hardware/rk29/libyuvtorgb",
);
@bin_package=(
#	"bootable/recovery",
);

$product="rk30sdk";
$devicepath="device/rockchip/rk30_common";
###############################################################
# don't change them below
$outpath="out/target/product";
@outLibPaths=(
	"obj/lib",
	"system/lib",
	"system/lib/hw"
);
@outBinPaths=(
	"system/bin",
	"system/xbin",
);
###############################################################
# TODO : check environment & parameters
-d "out" || die "Please make first!!";


# TODO : get so file from mk file.
foreach $path (@so_package)
{
	system("cd $path ; git checkout -f Android.mk ; cd -");
	system("grep LOCAL_MODULE[^_] $path -r >> _tmp");
	system("sed -i 's/\$(TARGET_BOARD_HARDWARE)/rk30board/g' _tmp");
}
# TODO : get bin file from mk file.
foreach $path (@bin_package)
{
	system("cd $path ; git checkout -f Android.mk ; cd -");
	system("grep LOCAL_MODULE[^_] $path -r >> _tmp_bin");
}

open(DAT,"_tmp")||die "$!";
-d "_tmp_bin" && (open(DAT_BIN,"_tmp_bin")||die "$!");
@files_so=<DAT>;
@files_bin=<DAT_BIN>;
system("rm _tmp -f");
system("rm _tmp_bin -f");

foreach $line (@files_so)
{
	$line =~ s/.*=//g;
	$line =~ s/^\s//g;
	$line =~ s/\s$//g;
	$line =~ s/$/\.so/;
}
foreach $line (@files_bin)
{
	$line =~ s/.*=//g;
	$line =~ s/^\s//g;
	$line =~ s/\s$//g;
	$line =~ s/$//;
}

#print "\n\nfiles_so = @files_so";
#print "\n\nfiles_bin = @files_bin";

# TODO : get so file path from out/
@sopaths=();
@binpaths=();
foreach $file (@files_so)
{
	foreach $outp (@outLibPaths)
	{
		if(-e "$outpath/$product/$outp/$file")
		{
			push (@sopaths,"$outpath/$product/$outp/$file\n");
		}
	}
}
foreach $file (@files_bin)
{
	foreach $outp (@outBinPaths)
	{
		if(-e "$outpath/$product/$outp/$file")
		{
			push (@binpaths,"$outpath/$product/$outp/$file\n");
		}
	}
}
#print "\n\nsopaths = @sopaths";
#print "\n\nbinpaths = @binpaths";

# TODO : copy these files to device folder and add mkfile
-d "$devicepath/proprietary/hardware" || system("mkdir $devicepath/proprietary/hardware -p");
-d "$devicepath/proprietary/bin" || system("mkdir $devicepath/proprietary/bin -p");
-d "$devicepath/common.mk" || system("rm $devicepath/common.mk");

open(MKFILE,">>$devicepath/common.mk") || die "$!";
print MKFILE "#Rockchip Hardware SO\n";
#print MKFILE "LOCAL_PATH := \$(call my-dir)\n";
print MKFILE "hardware := \$(LOCAL_PATH)/proprietary/hardware\n";
print MKFILE "PRODUCT_COPY_FILES +=\\\n";

foreach $file (@sopaths)
{
	chomp($file);
	-e $file || die "$!";
	$file=~s/$outpath\/$product\///g;
	$filename=$file;
	$filename=~s/.*\///g;
	print "-----".$path." : ".$file."\n";
	system ("cp $outpath/$product/$file $devicepath/proprietary/hardware/ -f");
	print MKFILE "\t\$(hardware)/$filename:$file\\\n";
}

print MKFILE "\n#Rockchip BIN\n";
print MKFILE "bin := \$(LOCAL_PATH)/proprietary/bin\n";
print MKFILE "PRODUCT_COPY_FILES +=\\\n";
foreach $file (@binpaths)
{
	chomp($file);
	-e $file || die "$!";
	$file=~s/$outpath\/$product\///g;
	$filename=$file;
	$filename=~s/.*\///g;
	print "-----".$path." : ".$file."\n";
	system ("cp $outpath/$product/$file $devicepath/proprietary/bin/ -f");
	print MKFILE "\t\$(bin)/$filename:$file\\\n";
}
close(MKFILE);

# TODO : delete paths
foreach $path (@so_package)
{
	system("find $path -name \"*.c\" -exec rm {} \\;");
	system("find $path -name \"*.cpp\" -exec rm {} \\;");
	system("find $path -name \"*.mk\" -exec rm {} \\;");
}
foreach $path (@bin_package)
{
	system("find $path -name \"*.c\" -exec rm {} \\;");
	system("find $path -name \"*.cpp\" -exec rm {} \\;");
	system("find $path -name \"*.mk\" -exec rm {} \\;");
}

###############################################################
# pack kernel
$kernelpath="kernel/";
-d "kernel" || die "no kernel found!";
chdir $kernelpath;
system("bash pack-kernel-rk30.sh");
chdir("../");

##############################################################n
# don't tar them below
@exclude=(
	".git",
	".repo",
#	"external/pretest",
);

###############################################################
foreach $path (@exclude)
{
	$path="--exclude=$path "; 
}

system("sed -i '\$a\$(call inherit-product, device/rockchip/rk30_common/common.mk)'  device/rockchip/$product/device.mk");
print "\nexclude = @exclude\n";
system(".repo/repo/repo manifest -r -o version-tag.xml");
system("mv out ../rkTmpOut");
system("mv kernel ../rkTmpKernel");
system("tar zxvf kernel.tar.gz kernel/");
system("mv kernel.tar* ../");
#system("mv device/rockchip/rk29sdk/asound-for-rt5625.conf device/rockchip/rk29sdk/asound-for-rt5625.conf.bak");
#system("mv device/rockchip/rk29sdk/asound-for-rt5625.conf.env device/rockchip/rk29sdk/asound-for-rt5625.conf");
system("tar -zcf ../jellybean.tar @exclude --exclude=device/rockchip/rk29sdk/asound-for-rt5625.conf.bak  ../jb");
#system("mv device/rockchip/rk29sdk/asound-for-rt5625.conf device/rockchip/rk29sdk/asound-for-rt5625.conf.env");
#system("mv device/rockchip/rk29sdk/asound-for-rt5625.conf.bak device/rockchip/rk29sdk/asound-for-rt5625.conf");
system("rm -r kernel");
system("mv ../rkTmpOut out");
system("mv ../rkTmpKernel kernel");
print "\n---pack done, see ../jellybean.tar file --\n"
