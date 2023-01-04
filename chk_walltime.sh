#!/bin/sh
# check job *.o file for wall time used/allocated 
# Arguments:
#   Job output file (required)

if [ $# -eq 0 ]; then
  echo This script needs argument: /path/*.o\$pid.  Exit
  exit
else
  output_file=$1

  # check for walltime used:
    grep -a '\.walltime' ${output_file}

  # print the first and last match of UTC - start/ending time of job:
    grep -a UTC ${output_file} | sed -n '1p;$p' 
fi

exit

