#!/bin/bash
# Put Justin's manual rsync to hera into a script (2020/08/05)
h1=`hostname | cut -c 1-1`
if [ $h1 = m ]
then
  HOST=MARS
elif [ $h1 = v ]
then
  HOST=VENUS
else
  echo I do not yet recognize this host.  Exit without rsynching.
  exit
fi
sudo -u nwprod rsync --timeout=30 -ravzz -e '/opt/bin/ssh -F /u/nwprod/.ossh/ssh_config.hera -o NoneSwitch=yes' --progress --stats /gpfs/dell4/nco/ops/com/canned/4GB dtn-hera.fairmont.rdhpcs.noaa.gov:/scratch1/NCEPDEV/rstprod/ptmp/canned_transfer_${HOST}_p35 
