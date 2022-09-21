#!/bin/ksh
#
VERSION="20220111"

# This script is a greatly simplified version of lt.sh.  It 
# pops up a number of xterms. It takes 0, 1, or 2 arguments

#   No argument: 
#     5 LightCyan1 for prod
#     1 Cornsilk1 for Dev 
#     1 light gray for edit text files (ng) while on loaner win GFE
#   1 argument (n1): n1 xterms
#   3 argument (n1, n2, n3): n1/n2/n3 xterms
# RTDB: no special provision for restarting it in this script since it is easy
#   to start it manually.  Note that RTDB should be restarted after 00Z during
#   an evening/night shift.  

#

#----------
#  Launch xterms
#----------
X_BG1="LightCyan1"
X_BG2="Cornsilk1"
X_BG3="Grey89"
X_FT="'Monospace' -fs 14" 

if [ $# -eq 0 ]
then 
  n1=5
  n2=1
  n3=1
  rtdb=Y
  clock=Y
elif [ $# -eq 1 ]
then
  n1=$1
  n2=0
  rtdb=N
  clock=N
elif [ $# -eq 2 ]
then
  n1=$1
  n2=$2
  rtdb=N
  clock=N
elif [ $# -eq 3 ]
then
  n1=$1
  n2=$2
  n3=$3
  rtdb=N
  clock=N
else
  print "Number of arguments need to be between 0-3"
  exit
fi

n=1
while [ $n -le $n1 ]
do 
  nohup  xterm -sl 5000 -sb  -bg ${X_BG1} -fa ${X_FT} &
  sleep 1
  let n=n+1
done 

n=1
while [ $n -le $n2 ]
do 
  nohup  xterm -sl 5000 -sb  -bg ${X_BG2} -fa ${X_FT} &
  sleep 1
  let n=n+1
done

# 3rd type of terminal is for notes editing, no need when using non-loaner GFE:
n=1
while [ $n -le $n3 ]
do 
#  nohup  xterm -sl 5000 -sb  -bg ${X_BG3} -fa ${X_FT} &
#  sleep 1
  let n=n+1
done

if [ $rtdb = 'Y' ]
then
  ~/sos/rtdb.sh
fi

if [ $clock = 'Y' ]
then
  ~/sos/run_clock.sh
fi
