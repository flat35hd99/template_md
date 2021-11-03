#!/bin/bash -e
# Pre-Sampling
#    50ns NPT simulation
#    This script is written for CUDA amber.

### output usage info. ###
if [ ! $# = 1 ];then
    echo 'Pre-Sampling'
    echo 'USAGE ./pre-smp.sh [run number]'
    exit
fi

SYS_NAME=bfl # system name
RUN=$( printf %02d $1 ) # run number

### PATH setting ###
source ~/.bashrc

### data dir setting ###
if [ ! -e data${RUN} ];then
    mkdir data${RUN}
fi

SMP_DIR=$( pwd ) # sampling dir : /home/kota/????/3smp/
SIM_DIR=$( dirname $SMP_DIR ) # simulation dir : /home/kota/????/

### working dir setting ###
work_dir=/work/${SYS_NAME}${RUN}_pre-smp
mkdir $work_dir
cd $work_dir
cp ${SIM_DIR}/0strct/${SYS_NAME}.prmtop ./system.prmtop # parmtop file
cp ${SIM_DIR}/2equ/data${RUN}/npt.rst ./initial.rst # initial structure
cp ${SMP_DIR}/pre-smp.inp ./input.inp # MD input file

echo "*****Pre-Sampling (50ns)*****"

mdinfo=${SMP_DIR}/mdinfo${RUN}_pre-smp # MD information file

### MD ###
time $AMBERHOME/bin/pmemd.cuda  -O \
    -p system.prmtop \
    -i input.inp \
    -c initial.rst \
    -r pre-smp.rst \
    -o pre-smp.out \
    -x pre-smp.crd.nc \
    -inf $mdinfo

$AMBERHOME/bin/ambpdb -p system.prmtop < pre-smp.rst > pre-smp.pdb 2> /dev/null

### move data ###
mv pre-smp.{crd.nc,rst,out,pdb} ${SMP_DIR}/data${RUN}/ # {crd,restart,ouput,pdb} file
mv $mdinfo ${SMP_DIR}/data${RUN}/mdinfo_pre-smp # MD information file

### clean work dir ###
cd $SMP_DIR
rm -r $work_dir
