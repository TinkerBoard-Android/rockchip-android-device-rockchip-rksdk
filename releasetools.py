# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Emit commands needed for Rockchip devices during OTA installation
(installing the RK30xxLoader.bin)."""

import common
import re


def FullOTA_Assertions(info):
  AddBootloaderAssertion(info, info.input_zip)


def IncrementalOTA_Assertions(info):
  AddBootloaderAssertion(info, info.target_zip)


def AddBootloaderAssertion(info, input_zip):
  android_info = input_zip.read("OTA/android-info.txt")
  m = re.search(r"require\s+version-bootloader\s*=\s*(\S+)", android_info)
  if m:
    bootloaders = m.group(1).split("|")
    if "*" not in bootloaders:
      info.script.AssertSomeBootloader(*bootloaders)
    info.metadata["pre-bootloader"] = m.group(1)

def Install_Parameter(info):
  try:
    parameter_bin = info.input_zip.read("PARAMETER/parameter");
  except KeyError:
    print "warning: no parameter in input target_files; not flashing parameter"
    return
    
  print "find parameter, should add to package"
  common.ZipWriteStr(info.output_zip, "parameter", parameter_bin)
  info.script.Print("start update parameter...")
  info.script.WriteRawParameterImage("/parameter", "parameter")
  info.script.Print("end update parameter")

def InstallRKLoader(loader_bin, input_zip, info):
  common.ZipWriteStr(info.output_zip, "RKLoader.img", loader_bin)
  info.script.Print("Writing rk loader bin...")
  info.script.WriteRawImage("/misc", "RKLoader.img")


def FullOTA_InstallEnd(info):
  try:
    loader_bin = info.input_zip.read("LOADER/RKLoader.img")
  except KeyError:
    print "warning: no rk loader bin in input target_files; not flashing loader"
    print "clear misc command"
    info.script.ClearMiscCommand()
    return

  InstallRKLoader(loader_bin, info.input_zip, info)


def IncrementalOTA_InstallEnd(info):
  try:
    target_loader = info.target_zip.read("LOADER/RKLoader.img")
  except KeyError:
    print "warning: rk loader bin missing from target; not flashing loader"
    print "clear misc command"
    info.script.ClearMiscCommand()
    return

  try:
    source_loader = info.source_zip.read("LOADER/RKLoader.img")
  except KeyError:
    source_loader = None

  if source_loader == target_loader:
    print "RK loader bin unchanged; skipping"
    return

  InstallRKLoader(target_loader, info.target_zip, info)
