#!/bin/sh
#
# Find the active ecflow server
# As of 2022/09/21, /lfs/h1/ops/prod/config/active.ecflow seems to show the
# 'active ecflow server' that was valid at the last 'orderly' ecflow server 
# switch, not when it was part of the emergency prod switch. 
ecfserver=`ssh cecflow01 "grep 'edit ECF_LOGHOST'  /tfs/ops/prod/com/ecflow/ecf.check | awk '{print $3'}" | tail -1 | cut -d "'" -f 2`
echo $ecfserver 

