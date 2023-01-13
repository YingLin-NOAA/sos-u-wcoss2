#!/bin/sh
#
# check for connection time for each of the ncorzdm vm to see if one of them
# is slow.  See Holly email 2020/12/31.
#
echo -e "\n Check CP RZDM:"
for mem in 01 02 03 04 05 06 07 08
do
  machine=vm-lnx-rzdm${mem}.ncep.noaa.gov
  time ssh -q -o BatchMode=yes nwprod@${machine}
  echo above is for ssh to ${machine}
done

echo -e "\n Check BLDR RZDM:"
for mem in 01 02 03 04 05 06 07 08
do
  machine=vm-bldr-rzdm${mem}.ncep.noaa.gov
  time ssh -q -o BatchMode=yes nwprod@${machine}
  echo above is for ssh to ${machine}
done

exit
