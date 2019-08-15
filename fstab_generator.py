#!/usr/bin/env python
import sys
import getopt
import os
from string import Template

templet = Template("${_block_prefix}system /system ext4 ro,barrier=1 ${_flags}\n\
${_block_prefix}vendor /vendor ext4 ro,barrier=1 ${_flags}\n\
/dev/block/by-name/metadata /metadata ext4 nodev,noatime,nosuid,errors=panic wait,formattable,first_stage_mount")

def main(argv):
    prefix = ''
    flags = ''
    fstab_file = ''
    try:
        opts, args = getopt.getopt(argv, "hp:f:o:", ["block_prefix=","flags=","ofile="])
    except getopt.GetoptError:
        print 'fstab_generator.py -p <block_prefix> -f <flags> -o <output_file>'
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print 'fstab_generator.py -p <block_prefix> -f <flags> -o <output_file>'
            sys.exit(2)
        elif opt in ("-p", "--block_prefix"):
            prefix = arg;
        elif opt in ("-f", "--flags"):
            flags = arg;
        elif opt in ("-o", "--ofile"):
            fstab_file = arg;
        else:
            print 'fstab_generator.py -p <block_prefix> -f <flags> -o <output_file>'
            sys.exit(2)

    #print 'prefix=' + prefix + ', flags=' + flags + ', fstab_file=' + fstab_file
    if prefix == 'none':
        prefix = ''

    fstab_file_content = templet.substitute(_block_prefix=prefix,_flags=flags)
    if fstab_file != '':
        with open(fstab_file,"w") as f:
            f.write(fstab_file_content)
    else:
        print fstab_file_content

if __name__=="__main__":
    main(sys.argv[1:])
