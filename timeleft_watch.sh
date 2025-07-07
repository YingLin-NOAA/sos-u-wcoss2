#!/bin/sh
# 'watch' how much time is left for a job.  Enter one or more jobid(s) as
#  argument.
#
if [ $# -eq 0 ]
then
  echo Needs at least one argument as jobID
  exit
else
  args=("$@")
fi

watch --interval 90 "echo ${args[@]}; qstat -f ${args[@]} | grep -e 'Job Id' -e 'Job_Name' -e 'walltime'"

