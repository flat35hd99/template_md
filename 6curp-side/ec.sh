#!/bin/bash -e
# Energy Conductivity

### output usage info. ###
if [ ! $# = 2 ];then
    echo 'Energy Conductivity'
    echo 'USAGE ./ec.sh [run number (0~)] [sampling number (0~9)]'
    exit
fi

RUN=$( printf %02d $1 ) # run number
SMP=${2} # sampling number (sampling simulation number)
NPROC=8  # number of processor uning MPI

### PATH settings ###
source ~/.bashrc

echo "==========info=========="
echo "run,smp : ${RUN},${SMP}"
echo "========================"

### EC ###
echo "EC"
time mpirun -nq $NPROC $CURP_HOME/bin/cal-tc \
    --frame-range 1 5000 1 --average-shift 1 \
    --dt 0.01 \
    -a ./data${RUN}/acf${SMP}.nc \
    -o ./data${RUN}/ec${SMP}.dat \
    ./data${RUN}/flux${SMP}.nc > ./ec${RUN}_${SMP}.log
echo

### move data ###
mv ec${RUN}_${SMP}.log ./data${RUN}/ec${SMP}.log # logfile
