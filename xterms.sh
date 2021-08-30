#!/bin/ksh
#
# Pop up a bunch of xterms: 4 white for Dell, 1 lightgrey for Cray, and 
# 2 lightgoldenrod1 for Dev Dell.  This is greatly simplified version of lt.sh
VERSION="20210711"
#

#----------
#  Launch xterms
#----------
X_BG1="white"
X_BG2="lightgrey"
X_BG3="lightgoldenrod1"
X_FT="'Monospace' -fs 14" 
nohup  xterm -sl 5000 -sb  -bg ${X_BG1} -fa ${X_FT} &
sleep 1
nohup  xterm -sl 5000 -sb  -bg ${X_BG1} -fa ${X_FT} &
sleep 1
nohup  xterm -sl 5000 -sb  -bg ${X_BG1} -fa ${X_FT} &
sleep 1
nohup  xterm -sl 5000 -sb  -bg ${X_BG1} -fa ${X_FT} &
sleep 1
nohup  xterm -sl 5000 -sb  -bg ${X_BG2} -fa ${X_FT} &
sleep 1
nohup  xterm -sl 5000 -sb  -bg ${X_BG3} -fa ${X_FT} &
sleep 1
nohup  xterm -sl 5000 -sb  -bg ${X_BG3} -fa ${X_FT} &
sleep 1
~/sos/rtdb.sh

