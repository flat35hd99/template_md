#! /bin/bash

files=()
for smp in 0 1 2 3 4 5 6 7 8 9
do
    dir_name=data${smp}
    cd $dir_name
    pwd
    for traj in 0 1 2 3 4 5 6 7 8 9
    do
	filename=ec${traj}.dat
	if [ -e $filename ]; then
	    ../minus.py ${filename}
	    #files+=("../${dir_name}/${filename}")
	else
	    continue
	fi
    done
    cd ../
done

#echo ${files[*]}


