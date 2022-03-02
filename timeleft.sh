#!/bin/sh
if [ $# -eq 0 ]
then
  echo Needs argument jobID
  exit
else
  jobid=$1
fi
qstat -f $jobid | grep walltime

