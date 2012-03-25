#include <dumpstate.h>

void dumpstate_board()
{
    dump_file("clocks", "/proc/clocks");
    dump_file("rk29xxnand", "/proc/rk29xxnand");
    dump_file("vpu mem", "/proc/vpu_mem");
    dump_file("vpu service", "/proc/vpu_service");
};
