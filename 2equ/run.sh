#!/bin/bash -e
# Equilibration
#    procedure : Heating -> NVT -> NPT
#    This script is written for CUDA amber.

### output usage info. ###
if [ ! $# = 1 ];then
    echo 'Equilibration'
    echo 'USAGE ./run.sh [run number]'
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

EQU_DIR=$( pwd ) # equilibration dir : /home/kota/????/2equ/
SIM_DIR=$( dirname $EQU_DIR ) # simulation dir : /home/kota/????/

### Working dir setting ###
WORK_DIR=/work/${SYS_NAME}${RUN}_equ
mkdir $WORK_DIR
cd $WORK_DIR
cp ${SIM_DIR}/0strct/${SYS_NAME}.prmtop ./system.prmtop # parmtop file
cp ${SIM_DIR}/0strct/${SYS_NAME}.inpcrd ./reference.inpcrd # reference structure
cp ${SIM_DIR}/1min/data/minW.rst ./initial.rst # initial structure

### MD ###
for sim_name in heat nvt npt;do

    echo "***** Equilibration $sim_name *****"

    cp ${EQU_DIR}/${sim_name}.inp ./input.inp # MD input file
    mdinfo=${EQU_DIR}/mdinfo${RUN}_${sim_name} # MD information file

    # reference setting
    if [ $sim_name = 'heat' ];then # reference file is only used in Heating
	reference_line="-ref reference.inpcrd"
    else
	reference_line=''
    fi

    time $AMBERHOME/bin/pmemd.cuda -O \
    	       -p system.prmtop \
	       -i input.inp \
	       -c initial.rst \
	       $reference_line \
	       -r restart.rst \
	       -o output.out \
	       -x output.crd.nc \
	       -inf $mdinfo

    echo

    $AMBERHOME/bin/ambpdb -p system.prmtop < ./restart.rst > ./system.pdb 2> /dev/null

    mv output.out ${EQU_DIR}/data${RUN}/${sim_name}.out # mv output file
    mv output.crd.nc ${EQU_DIR}/data${RUN}/${sim_name}.crd.nc # mv output crd file
    mv $mdinfo ${EQU_DIR}/data${RUN}/mdinfo_${sim_name} # mv mdinfo file
    mv system.pdb ${EQU_DIR}/data${RUN}/${sim_name}.pdb # mv pdb file

    cp restart.rst ${EQU_DIR}/data${RUN}/${sim_name}.rst # copy restart file
    mv restart.rst initial.rst # left restart file in WORK_DIR for next simulation

done


### clean work dir ###
cd $EQU_DIR
rm -r $WORK_DIR
