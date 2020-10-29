#!/bin/sh
# 'watch' how much time is left for a job.  Job ID is the argument.
#
if [ $# -eq 0 ]
then
  echo Needs argument jobID
  exit
else
  jobid=$1
fi
watch --interval 60 bjobs -o TIME_LEFT $jobid

