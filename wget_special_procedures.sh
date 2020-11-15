#!/bin/sh
ptmp=/gpfs/dell1/ptmp/Ying.Lin
if [ ! -d $ptmp ]; then mkdir -p $ptmp; fi
cd $ptmp
# specify name of file saved, otherwise it'll be Special_Procedure.1 
# if the older file with the same name is already on disk. 
# Note that with '-O', the downloaded file already carry the time stamp in the
# original file on www2 (-N - timestamping - does nothing in combination with
# -O.  Per https://www.gnu.org/software/wget/manual/wget.html the downloaded 
# file should bear the time stamp at the time wget is run, but that does not
# seem to be the case.

wget http://www2.pmb.ncep.noaa.gov/wiki/index.php/Special_Procedures \
  -O Special_Procedures
exit
