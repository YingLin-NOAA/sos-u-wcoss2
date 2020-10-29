#!/bin/sh
# check dump job's *.o file for DATACOUNT-deficiency RED reports
# Note that when a *_dump_alert fails, it's just an alert - its *.o* file
#   does not contain the type of reports that are deficient.  In the 
#   dump_alert's 'triggers' tab, find the job that triggers it - the e.g
#   jgdas_dump_post that's (usually?) right above the dump_alert in the
#   ecf_ui.  Run this script on that job's *.o file. 
# 
if [ $# -ne 1 ]; then
  echo This script needs ONE argument: /path/*.o\$pid.  Exit
else
  output_file=$1
  grep DATACOUNT-deficiency ${output_file} | grep RED | grep 'msg='
fi

exit

