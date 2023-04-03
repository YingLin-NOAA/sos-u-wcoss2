#!/bin/sh
# if no argument, ring terminal bell
# if arg1 is sos1/sos2/sos3 then sound the 'boing' on lw-sos*
if [ $# -eq 0 ]; then
  echo -en "\007"
else
  arg1=$1
  if [[ $arg1 = sos1 || $arg1 = sos2 || $arg1 = sos3 ]]
  then
    ssh wx11yl@nco-lw-$arg1 "/usr/bin/aplay ~wx11yl/sounds/boing.au"
  fi
fi

