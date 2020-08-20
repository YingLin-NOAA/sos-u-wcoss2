#!/bin/sh
# run Nitin's "watch for ensemble files to arrive at dcom" in a script.
# 
# watch --interval=30 "ls -l /gpfs/dell1/nco/ops/dcom/prod/20200816/wgrbbul/ecmwf/DCE081600* | wc -l"
# 
# 
if [ $# -gt 0 ]
then
  pattern=$1
  if [ $# -eq 2 ] 
  then
    num_norm=$2
  fi
else
  echo This script needs at least one argument.  Exit
  exit
fi

if [ -z "$num_norm" ];
then
  watch --interval=30 "ls -l ${pattern}* | wc -l"
else
  watch --interval=30 "ls -l ${pattern}* | wc -l; echo out of $num_norm"
fi

exit


