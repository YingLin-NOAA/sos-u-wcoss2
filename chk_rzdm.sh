#!/bin/sh
#
# check for connection time for each of the ncorzdm vm to see if one of them
# is slow.  See Holly email 2020/12/31.
#
for mem in 01 02 03 04 05 06 07 08
do
  machine=vm-lnx-rzdm${mem}.ncep.noaa.gov
  time ssh -q -o BatchMode=yes nwprod@${machine}
  echo above was for ssh to ${machine}
done
exit
