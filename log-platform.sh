#!/bin/bash

# log platform characteristics

PLATFORM=`uname`

if [[ "$PLATFORM" == 'Linux' ]]; then
    uname -a > platform.txt
    free -h >> platform.txt
    cat /proc/cpuinfo | grep "model name" | sort -u >> platform.txt
    NCORES=`grep "^cpu cores" /proc/cpuinfo | sort -u | awk '{print $4}'`
    echo $NCORES physical CPU cores >> platform.txt

elif [[ "$PLATFORM" == 'Darwin' ]]; then
    uname -a > platform.txt
    sysctl machdep.cpu.brand_string >> platform.txt
    sysctl hw.physicalcpu >> platform.txt
    sysctl hw.memsize >> platform.txt
    sysctl hw.usermem >> platform.txt

else
    echo 'Unknown platform'

fi
