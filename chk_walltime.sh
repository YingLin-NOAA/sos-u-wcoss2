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
    grep '\.walltime' ${output_file}
fi

exit

