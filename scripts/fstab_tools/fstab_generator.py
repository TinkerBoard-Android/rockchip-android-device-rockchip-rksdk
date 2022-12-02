#!/usr/bin/env python
import sys
import getopt
import os
from string import Template

usage = 'fstab_generator.py \
            -I <type: fstab/dts> \
            -i <fstab_template> \
            -p <block_prefix> \
            -d <dynamic_part_list> \
            -f <flags> \
            -c <chained_flags> \
            -s <sdmmc_device> \
            -o <output_file> \
            -a <append>'

def main(argv):
    ifile = ''
    prefix = ''
    flags = ''
    fstab_file = ''
    vbmeta_part = ''
    sdmmc_device = ''
    avbpub_key = ',avb_keys=/avb'
    type = 'fstab'
    part_list = ''
    chained_flags = ''
    append = ''
    str_append = ''
    dt_vbmeta = 'vbmeta {\n\
        compatible = "android,vbmeta";\n\
        parts = "vbmeta,boot,system,vendor,dtbo";\n\
    };'
    try:
        opts, args = getopt.getopt(argv, "hI:i:p:f:d:c:s:o:a:",
                                   ["IType","ifile","bprefix=",
                                    "flags=","dynamic_part_list",
                                    "chained_flags","sdevice=",
                                    "ofile=", "append="])
    except getopt.GetoptError:
        print (usage)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print (usage)
            sys.exit(2)
        elif opt in ("-I", "--IType"):
            type = arg;
        elif opt in ("-i", "--ifile"):
            ifile = arg;
        elif opt in ("-p", "--block_prefix"):
            prefix = arg;
        elif opt in ("-f", "--flags"):
            flags = arg;
        elif opt in ("-d", "--dynamic_part_list"):
            part_list = arg;
        elif opt in ("-c", "--chained_flags"):
            chained_flags = arg;
        elif opt in ("-s", "--sdmmc_device"):
            sdmmc_device = arg;
        elif opt in ("-o", "--ofile"):
            fstab_file = arg;
        elif opt in ("-a", "--append"):
            str_append = arg;
        else:
            print (usage)
            sys.exit(2)

    if prefix == 'none':
        prefix = ''
    if flags == 'none':
        flags = ''
    if chained_flags == 'none':
        chained_flags = ''
    if str_append == 'none':
        str_append = ''

    temp_addon_fstab = ''
    if part_list != 'none':
        temp_addon_fstab += '\n'
        list_partitions = part_list.split(',')
        for cur_part in list_partitions:
            temp_addon_fstab += '${_block_prefix}' + cur_part + ' /' + cur_part + ' ext4 ro,barrier=1 ${_flags},first_stage_mount\n'

    # add vbmeta parts name at here
    list_flags = list(flags);
    pos_avb = flags.find('avb')
    if pos_avb >= 0:
        list_flags.insert(pos_avb + 3, '=vbmeta')
    else:
        dt_vbmeta = ''
        avbpub_key = ''

    vbmeta_part = "".join(list_flags)

    file_fstab_in = open(ifile)
    template_fstab_in = file_fstab_in.read()

    if type == 'fstab':
        template_fstab_in += temp_addon_fstab

    if str_append != 'none':
        pos = str_append.find('file:')
        if pos == 0:
            # cat file
            append = open(str_append[pos + len('file:'):]).read()
        else:
            append = str_append
        template_fstab_in += append

    fstab_in_t = Template(template_fstab_in)

    if type == 'fstab':
        line = fstab_in_t.substitute(_block_prefix=prefix,_flags=flags,_flags_vbmeta=vbmeta_part,_flags_avbpubkey=avbpub_key,_flags_chained=chained_flags,_sdmmc_device=sdmmc_device)
    else:
        line = fstab_in_t.substitute(_boot_device=prefix,_vbmeta=dt_vbmeta,_flags=flags)

    if fstab_file != '':
        with open(fstab_file,"w") as f:
            f.write(line)
    else:
        print (line)

if __name__=="__main__":
    main(sys.argv[1:])
