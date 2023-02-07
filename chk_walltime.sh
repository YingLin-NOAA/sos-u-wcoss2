#!/bin/sh
# check job *.o file for wall time used/allocated 
# Arguments:
#   Job output file (required)

if [ $# -eq 0 ]; then
  echo This script needs argument: /path/*.o\$pid.  Exit
  exit
else
  output_file=$1
  wrkdir=/lfs/h1/nco/stmp/$USER/chkw
  if [ -d $wrkdir ]
  then
    rm -f $wrkdir/*
  else
    mkdir -p $wrkdir
  fi
  cd $wrkdir

  # check for walltime used:
  grep -a '\.walltime' ${output_file} | tee grep1.out
  if [ -s grep1.out ]
  then 
    walltime=`head -1 grep1.out | awk '{print $3}'`
  else
    walltime="00:00:00"
  fi
#  echo 'walltime =' $walltime 

  # print the first and last match of UTC - start/ending time of job:
  #  grep -a UTC ${output_file} | sed -n '1p;$p'

  grep stime ${output_file} | tee stime.out
  if [ -s stime.out ]; then
    # use sed to remove leading blank space from string:
    stime=`awk -F"=" '{print $2}' stime.out | sed 's/^ *//g'`
  else
    stime=' '
  fi 

  grep mtime ${output_file} | tee mtime.out
  if [ -s mtime.out ]; then
    mtime=`awk -F"=" '{print $2}' mtime.out | sed 's/^ *//g'`
  else
    mtime=' '
  fi 
fi

python /u/ying.lin/sos/timediff_pbs.py "$stime" "$mtime"
exit

