#!/bin/sh
# manually test scp speed to the other wcoss2 machine (dev to prod/prod to dev)
#
#set -x

# find the name of the 'other' machine:
here1=`hostname|cut -c 1-1`
if [ $here1 = 'c' ] 
then
  there1='d'
elif [ $here1 = 'd' ] 
then
  there1='c'
else
  echo Calice! Unrecognized hostname, EXIT
fi

stmpdir=/lfs/h1/nco/stmp/$USER
there=${there1}login

# scp_test_file is from Justin's test_file
# For simplicity's sake I'm assuming /lfs/h1/nco/stmp/$USER already exists, to
# save the hassel of using ssh to check for existence of the dir, then mkdir
# If this script complains about scp: 
#   /lfs/h1/nco/stmp/$USER/.: No such file or directory
# go to the other machine to mkdir.
scp ~/scp_test_file ${USER}@${there}:$stmpdir/.

