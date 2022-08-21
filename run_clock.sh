#!/bin/sh
# nohup xterm -geometry 70x10+0+900 -bg beige -e /u/ying.lin/sos/clock.sh & 
if [ $# -eq 0 ];
then 
  xclock -digital -update 1 -face 'arial black-20:bold' -geom 400x50 &
else
  if [ $1 = 'big' ];
  then
    xclock -digital -update 1 -face 'arial black-40:bold' -geom 750x100 &
  elif [ $1 = 'dev' ];  # In case we want to dev clock against prod clock
  then
    # xclock with yellow background
    xclock -digital -update 1 -face 'arial black-20:bold' -bg yellow -geom 400x50 &
  else
    echo 'Unknow optional argument'
  fi
fi

