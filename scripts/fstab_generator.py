#!/usr/bin/env python
import sys
import getopt
import os
from string import Template

usage = 'fstab_generator.py -p <block_prefix> -f <flags> -o <output_file>'

def main(argv):
    ifile = ''
    plist = 'system,vendor'
    prefix = ''
    flags = ''
    fstab_file = ''
    try:
        opts, args = getopt.getopt(argv, "hi:p:f:o:", ["ifile","bprefix=","flags=","ofile="])
    except getopt.GetoptError:
        print usage
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print usage
            sys.exit(2)
        elif opt in ("-i", "--ifile"):
            ifile = arg;
        elif opt in ("-p", "--block_prefix"):
            prefix = arg;
        elif opt in ("-f", "--flags"):
            flags = arg;
        elif opt in ("-o", "--ofile"):
            fstab_file = arg;
        else:
            print usage
            sys.exit(2)

    if prefix == 'none':
        prefix = ''

    file_fstab_in = open(ifile)
    template_fstab_in = file_fstab_in.read()
    fstab_in_t = Template(template_fstab_in)

    line = fstab_in_t.substitute(_block_prefix=prefix,_flags=flags)

    if fstab_file != '':
        with open(fstab_file,"w") as f:
            f.write(line)
    else:
        print line

if __name__=="__main__":
    main(sys.argv[1:])
