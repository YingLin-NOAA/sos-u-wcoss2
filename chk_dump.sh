#!/bin/sh
# check dump job's *.o file for DATACOUNT-deficiency RED reports
# Note that when a *_dump_alert fails, it's just an alert - its *.o* file
#   does not contain the type of reports that are deficient.  In the 
#   dump_alert's 'triggers' tab, find the job that triggers it - the e.g
#   jgdas_dump_post that's (usually?) right above the dump_alert in the
#   ecf_ui.  Run this script on that job's *.o file. 
# 
# History: 
#   Created: 2020/10/29 YL
#   Revision:
#     2021/08/30: with Windows GFE, copy/paste is difficult from xterm to
#     chat and from xterm to PuTTY window. Solution: extract the deficiency
#     statement between the single quotes ('...') and pipe that to 
#     /stmp/.../dumpout
#
if [ $# -ne 1 ]; then
  echo This script needs ONE argument: /path/*.o\$pid.  Exit
else
  output_file=$1
fi

stmpdir=/lfs/h1/nco/stmp/$USER
if [ ! -d $stmpdir ]
then
  mkdir -p $stmpdir
fi

grep DATACOUNT-deficiency ${output_file} | grep RED | grep 'msg=' | tee $stmpdir/dump.tmp

cd $stmpdir
if [ -e dumpout ]; then rm -f dumpout; fi

cat dump.tmp | while read s
do
  s=${s#*"'"}; s=${s%"'"*}
  echo $s >> dumpout
done
  
exit



