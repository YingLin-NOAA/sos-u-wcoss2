#!/bin/sh
if [ $# -eq 0 ]
then
  echo Needs argument jobID
  exit
else
  jobid=$1
fi
bjobs -o TIME_LEFT $jobid

