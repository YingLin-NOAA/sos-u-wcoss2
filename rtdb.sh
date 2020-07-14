nohup xterm -geometry 120x10+0+900 -sl 5000 -sb -bg orange -fg brown -e ssh venus 'export COMROOT=/gpfs/dell1/nco/ops/com; set term=xterm; export term; resize; cd /u/SDM/; ./rtdb \'
