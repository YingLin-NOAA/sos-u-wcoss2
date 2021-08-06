#!/bin/sh
VERSION=20210804

  #=======================================================================#
  #                                                                       #
  #  Purpose: find the latest failures from ecflog (tail)                 #
  #                                                                       #
  #  The active ecflow server name is extracted from                      #
  #    /ecf/rundir/switch_ecflow.log                                      #
  #  Author:   Ying Lin                                                   #
  #  Revison History                                                      #
  #    04 Aug 2021 - created out of frustration with copy/paste on        #
  #      Windows10 GFE.  Running the ecflog monitoring script from        #
  #      a PuTTY wcoss session becaue it is very difficult to copy from   #
  #      x-window to gChat, but copying info from ecf ui to x-terms is    #
  #      much easier than to PuTTY terminal.  
  #                                                                       #
  #=======================================================================#

#---------------------------------
#  Which ecflow log?  
#---------------------------------
ecfserver=`tail -1 /ecf/rundir/switch_ecflow.log | awk '{print $5}'`
LOGDIR=/ecf/rundir
ECFLOG=$LOGDIR/ecf.$ecfserver.log

egrep -v 'MSG.*MSG|-alter change label|:ecfprod|:nwprod' $ECFLOG | \
  egrep 'aborted.*reason' | tail  
  
exit
