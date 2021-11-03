#!/bin/bash -e
# Energy Flow (side chain)

### output usage info. ###
if [ ! $# = 2 ];then 
    echo 'Energy Flow (side chain)'
    echo 'USAGE ./flux.sh [run number (0~)] [sampling number (0~9)]'
    exit
fi

SYS_NAME=bfl # system name
RUN=$( printf %02d $1 ) # run number
SMP=${2} # sampling number (sampling simulation number)
NPROC=8  # number of processor uning MPI

FLX_DIR=$( pwd ) # flux dir : /home/kota/????/5curp
SIM_DIR=$( dirname $FLX_DIR ) # simulatio dir : /home/kota/????

### PATH setting ###
source ~/.bashrc

### data dir setting ###
DATA_DIR=data${RUN}
if [ ! -e $DATA_DIR ];then
   mkdir -p ./$DATA_DIR
fi

### work dir setting ###
WORK_DIR=/work/${SYS_NAME}${RUN}_ef-s${SMP}
mkdir $WORK_DIR
cd $WORK_DIR
cp ${SIM_DIR}/0strct/strip.prmtop ./ # parmtop file
cp ${FLX_DIR}/eflow.cfg ./ # eflow configuration file
cp ${FLX_DIR}/atomgroup/atomgroup.dat atomgroup.dat # atom group file (for side chain EF)
cp ${SIM_DIR}/4nve/data${RUN}/stripped${SMP}.crd.nc cc.crd.nc # crd file
cp ${SIM_DIR}/4nve/data${RUN}/adjusted${SMP}.vel.nc vv.vel.nc # vel file


echo "===============info==============="
echo "run,smp,trj : ${RUN},${SMP},${TRJ}"
echo "=================================="

### group file ###
${FLX_DIR}/modify_gpair.py ${SIM_DIR}/5curp/data${RUN}/gpair${SMP}.dat 1 104 105 > ./gpair.dat

logfile=${FLX_DIR}/eflow${RUN}_${SMP}.log

### EF calculation ###
echo "EF"
time mpirun -n $NPROC \
    $CURP_HOME/bin/curp eflow.cfg > $logfile
echo

### move data ###
mv flux_grp.nc ${FLX_DIR}/${DATA_DIR}/flux${SMP}.nc # flux file
mv gpair.dat ${FLX_DIR}/${DATA_DIR}/gpair${SMP}.dat # gpair file
mv $logfile ${FLX_DIR}/${DATA_DIR}/eflow${SMP}.log # log file

### clean work dir ###
cd $FLX_DIR
rm -r $WORK_DIR

