#! /bin/bash -e
# Minimization
#    procedure : Hydrogen only -> Side Chain -> Whole structure
#    This script is written for CUDA amber

sysname=bfl # system name
source ~/.bashrc

if [ ! -e data ];then # data dir setting
    mkdir data
fi

parmtop=../0strct/${sysname}.prmtop # parmtop file
reference=../0strct/${sysname}.inpcrd # reference file
initial_strct=../0strct/${sysname}.inpcrd # intial structure

for sim_name in minH minSC minW;do

    echo "***** Minimization $sim_name *****"

    input=./${sim_name}.inp # input file
    restart=./data/${sim_name}.rst # restart file
    output=./data/${sim_name}.out # output file
    mdinfo=./mdinfo_${sim_name} # md information file

    job="$AMBERHOME/bin/pmemd.cuda -O \
    	       -p $parmtop \
	       -i $input \
	       -c $initial_strct \
	       -ref $reference \
	       -r $restart \
	       -o $output \
	       -inf $mdinfo"
    echo $job
    # execution job #
    eval time $job
    echo

    $AMBERHOME/bin/ambpdb -p $parmtop < $restart > ./data/${sim_name}.pdb 2> /dev/null

    initial_strct=$restart # updata initial structure for next job

    mv $mdinfo ./data/mdinfo_${sim_name} # mv mdinfo file
done


