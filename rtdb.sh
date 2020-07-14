#!/bin/sh
# From Justin originally, 2020/07/14
h1=`hostname | cut -c 1-1`
if [ $h1 = m ]; then
  host=mars
elif [ $h1 = v ]; then
  host=venus
else
  echo 'Host is neither Mars nor Venus, exit.' 
fi
nohup xterm -geometry 70x10+0+900 -sl 5000 -sb -bg orange -fg brown -e ssh $host 'export COMROOT=/gpfs/dell1/nco/ops/com; set term=xterm; export term; resize; cd /u/SDM/; ./rtdb \' &
exit

