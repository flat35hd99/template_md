#!/bin/bash -e
# Sampling
#    5ns NPT simulation
#    extract 10 structures.
#    This script is written for CUDA amber.

### output usage info. ###
if [ ! $# = 1 ];then
    echo 'Sampling'
    echo 'USAGE ./smp.sh [run number]'
    exit
fi

SYS_NAME=bfl # system name
RUN=$( printf %02d $1 ) # run number

### PATH setting ###
source ~/.bashrc

### data dir setting ###
if [ ! -e data${RUN}/sampling ];then
    mkdir data${RUN}/sampling
fi

SMP_DIR=$( pwd ) # sampling dir : /home/kota/????/3smp/
SIM_DIR=$( dirname $SMP_DIR ) # simulation dir : /home/kota/????/

### working dir setting ###
WORK_DIR=/work/${SYS_NAME}${RUN}_smp
mkdir $WORK_DIR
cd $WORK_DIR
cp ${SIM_DIR}/0strct/${SYS_NAME}.prmtop ./system.prmtop # parmtop file
cp ${SMP_DIR}/smp.inp ./input.inp # MD input file
cp ${SMP_DIR}/data${RUN}/pre-smp.rst ./initial.rst # initial structure file

echo "*****Sampling : ${SMP} (5ns)*****"

mdinfo=${SMP_DIR}/mdinfo${RUN}_smp # MD information file

### MD ###
time $AMBERHOME/bin/pmemd.cuda  -O \
       -p system.prmtop \
       -i input.inp \
       -c initial.rst \
       -r smp.rst \
       -o smp.out \
       -x smp.crd.nc \
       -inf $mdinfo

$AMBERHOME/bin/ambpdb -p system.prmtop < smp.rst > smp.pdb 2> /dev/null

### move data ###
mv smp.rst_* ${SMP_DIR}/data${RUN}/sampling/ # extracted restart files
mv smp.{crd.nc,rst,out,pdb} ${SMP_DIR}/data${RUN}/ # {crd,restart,output,pdb} file
mv $mdinfo ${SMP_DIR}/data${RUN}/mdinfo_smp # MD information file

### clean work dir ###
cd $SMP_DIR
rm -r $WORK_DIR

