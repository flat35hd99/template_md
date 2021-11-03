#!/bin/bash -e
# NVE simulation
#    1ns NVE simulation (0.1ns * 10section)
#    MD simulation is performed by pmemd.MPI

### output usage info. ###
if [ ! $# = 2 ];then # USAGE
    echo 'NVE simulation'
    echo 'USAGE ./nve.sh [run number (0~)] [sampling number (0~9)]'
    exit
fi

SYS_NAME=bfl # system name
RUN=$( printf %02d $1 ) # run number
SMP=$2 # sampling number (sampling simulation number)
NPROC=8 # number of processor uning MPI

NVE_DIR=$( pwd ) # nve dir : /home/kota/????/4nve
SIM_DIR=$( dirname $NVE_DIR ) # simulation dir : /home/kota/????

### PATH settings ###
source ~/.bashrc
# This CURP is for stripping and adjusting.
export CURP_HOME=/home/kota/opt/curp-v1.0-dev

### data dir setting ###
DATA_DIR=data${RUN}/smp${SMP}
if [ ! -e $DATA_DIR ];then
   mkdir -p ./$DATA_DIR
fi

### work dir setting ###
WORK_DIR=/work/${SYS_NAME}${RUN}_nve${SMP}
mkdir $WORK_DIR
cd $WORK_DIR
cp ${SIM_DIR}/0strct/${SYS_NAME}.prmtop ./system.prmtop # system parmtop file
cp ${SIM_DIR}/0strct/mask.pdb ./ # mask file ( for water stripping )
cp ${SIM_DIR}/0strct/strip.prmtop ./ # water stripped parmtop file
cp ${NVE_DIR}/nve.inp ./ # MD input file

# restart file
trj_num=$(( (SMP+1) * 250000))
restart_file=smp.rst_${trj_num}
cp ${SIM_DIR}/3smp/data${RUN}/sampling/$restart_file ./initial.rst

echo "===============info==============="
echo "run,smp : ${RUN},${SMP}"
echo "rst file: ${restart_file}"
echo "=================================="

### NVE ###
# 1ns = 100ps * 10-section (100ps per 1-section)
for (( sec=0; sec<10; sec++ ));do

    mdinfo=${NVE_DIR}/mdinfo${RUN}_${SMP}${sec} # md information

    ### MD simulation ###
    echo "MD : section ${sec}"
    time mpirun -nq $NPROC $AMBERHOME/bin/pmemd.MPI -O \
	 -p system.prmtop \
	 -i nve.inp \
	 -c initial.rst \
	 -r nve.rst \
	 -o nve.out \
	 -x nve.crd.nc \
	 -v nve.vel.nc \
	 -inf $mdinfo
    echo

    ### stripping crd ###
    echo "stripping crd : section ${sec}"
    time $CURP_HOME/bin/conv-trj -crd \
	 -p system.prmtop   -pf amber \
	 -i nve.crd.nc -if netcdf --irange 1 -1 1 \
	 -o stripped.crd.nc -of netcdf --orange 1 -1 1 \
	 mask -m mask.pdb > /dev/null
    echo

    #################################################
    # Setting for vel stripping and adjusting.      #
    #  1. include restart file at stripping or not. #
    #  2. start point of adjusting output.          #
    #################################################
    if [ $sec = 0 ];then
	rst_line=''
	first=5
    else
	rst_line='-i initial.rst -if restart --irange 1 -1 1'
	first=1
    fi

    ### stripping vel ###
    echo "stripping vel : section ${sec}"
    time $CURP_HOME/bin/conv-trj -vel \
	 -p system.prmtop   -pf amber \
	 ${rst_line} \
	 -i nve.vel.nc -if netcdf --irange 1 -1 1 \
	 -o stripped.vel.nc -of netcdf --orange 1 -1 1 \
	 mask -m mask.pdb > /dev/null
    echo

    ### adjusting vel ###
    echo "adjusting vel : section ${sec}"
    time $CURP_HOME/bin/conv-trj -vel \
	 -p strip.prmtop -pf amber \
	 -i stripped.vel.nc -if netcdf --irange 1 -1 1 \
	 -o adjusted.vel.nc -of netcdf --orange ${first} -1 5 \
	 adjust-vel > /dev/null
    echo

    ### move data ###
    mv nve.out ${NVE_DIR}/${DATA_DIR}/nve${sec}.out # MD output file
    mv $mdinfo ${NVE_DIR}/${DATA_DIR}/mdinfo_${sec} # MD information file
    # nve rst file is left on WORK_DIR for next section. #
    cp nve.rst ${NVE_DIR}/${DATA_DIR}/nve${sec}.rst # copy rst file in data_dir
    mv nve.rst ./initial.rst # rename

    mv stripped.crd.nc ./stripped${sec}.crd.nc # rename
    mv adjusted.vel.nc ./adjusted${sec}.vel.nc # rename

    ### remove large volume file ###
    rm nve.crd.nc
    rm nve.vel.nc
    rm stripped.vel.nc

    echo "   section ${sec} is completed."
    echo "----------------------------------"
done

### Union crd ###
echo "Union crd"
time $CURP_HOME/bin/conv-trj -crd \
     -p strip.prmtop   -pf amber \
     -i stripped0.crd.nc -if netcdf --irange 1 -1 1 \
     -i stripped1.crd.nc -if netcdf --irange 1 -1 1 \
     -i stripped2.crd.nc -if netcdf --irange 1 -1 1 \
     -i stripped3.crd.nc -if netcdf --irange 1 -1 1 \
     -i stripped4.crd.nc -if netcdf --irange 1 -1 1 \
     -i stripped5.crd.nc -if netcdf --irange 1 -1 1 \
     -i stripped6.crd.nc -if netcdf --irange 1 -1 1 \
     -i stripped7.crd.nc -if netcdf --irange 1 -1 1 \
     -i stripped8.crd.nc -if netcdf --irange 1 -1 1 \
     -i stripped9.crd.nc -if netcdf --irange 1 -1 1 \
     -o stripped.crd.nc -of netcdf --orange 1 -1 1 \
     convert-only > /dev/null
echo

### Union vel ###
echo "Union vel"
time $CURP_HOME/bin/conv-trj -vel \
     -p strip.prmtop   -pf amber \
     -i adjusted0.vel.nc -if netcdf --irange 1 -1 1 \
     -i adjusted1.vel.nc -if netcdf --irange 1 -1 1 \
     -i adjusted2.vel.nc -if netcdf --irange 1 -1 1 \
     -i adjusted3.vel.nc -if netcdf --irange 1 -1 1 \
     -i adjusted4.vel.nc -if netcdf --irange 1 -1 1 \
     -i adjusted5.vel.nc -if netcdf --irange 1 -1 1 \
     -i adjusted6.vel.nc -if netcdf --irange 1 -1 1 \
     -i adjusted7.vel.nc -if netcdf --irange 1 -1 1 \
     -i adjusted8.vel.nc -if netcdf --irange 1 -1 1 \
     -i adjusted9.vel.nc -if netcdf --irange 1 -1 1 \
     -o adjusted.vel.nc -of netcdf --orange 1 -1 1 \
     convert-only > /dev/null
echo

### move trj data ###
mv stripped.crd.nc ${NVE_DIR}/data${RUN}/stripped${SMP}.crd.nc # crd file
mv adjusted.vel.nc ${NVE_DIR}/data${RUN}/adjusted${SMP}.vel.nc # vel file
	
### clean work dir ###
cd $NVE_DIR
rm -r $WORK_DIR
