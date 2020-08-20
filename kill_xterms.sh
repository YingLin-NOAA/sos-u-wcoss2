#!/bin/sh
# Kill off phantom xterm sesssions from 'failed' lt.sh
# 
set -x
# This script is named kill_xterms.sh, so w/o the 'grep -v' below the 
# process started by this script would be the first one killed. 
for pid in `ps | grep xterm | grep -v '_xterm' | awk '{ print $1 }'`
do
  kill -9 $pid
done
exit

