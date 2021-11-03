#! /bin/bash

files=()
num_file=0

for ((run=0; run<10; run++));do # RUN number
    run_dir=../data${run}
    if [ ! -e $run_dir ]; then
	continue
    fi
    for ((smp=0; smp<10; smp++));do # sampling number
	ec_file=${run_dir}/ec${smp}.dat
	if [ -e $ec_file ] ; then
	    files+=("${ec_file}")
	    (( num_file++ ))
	else
	    continue
	fi
    done
done

echo "${num_file} files found."
echo

sleep 0.5

./average_side.py ${files[*]}
