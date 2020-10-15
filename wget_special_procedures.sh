#!/bin/sh
ptmp=/gpfs/dell1/ptmp/Ying.Lin
if [ ! -d $ptmp ]; then mkdir -p $ptmp; fi
cd $ptmp
# specify name of file saved, otherwise it'll be Special_Procedure.1 
# if the older file with the same name is already on disk. 
wget -N http://www2.pmb.ncep.noaa.gov/wiki/index.php/Special_Procedures \
  -O Special_Procedures
exit
