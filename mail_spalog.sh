#/bin/sh
set -x
# Each day before shift mail first 50000 lines of SPAlog to self (to be opened
# in local emacs buffer for easier reference).  Also send a copy to emcrzdm/ftp
# in case outgoing email from wcoss is down.
wrkdir=/gpfs/dell1/stmp/Ying.Lin/mail.spalog
if [ -d $wrkdir ]
then
  rm -f $wrkdir/*
else
  mkdir -p $wrkdir
fi
cd $wrkdir
head -50000 /gpfs/dell1/nco/ops/com/logs/spalog > spalog50000.txt
Mail -a spalog50000.txt -s spalog50000 Ying.Lin@noaa.gov << EOF
1st 50,000 lines of spalog
EOF
#password-less scp to emcrzdm doesn't work.  
#scp spalog50000.txt wd22yl@emcrzdm:/home/ftp/emc/mmb/precip/.
