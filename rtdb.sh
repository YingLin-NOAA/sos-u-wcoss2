#!/bin/sh
# From Justin originally, 2020/07/14
# 2022/07/01: updated for wcoss2
# It runs /u/nco.sdm/rtdb, which prints out (tail) the last 10 lines of
# /lfs/h1/ops/para/com/dashboard/para/dashboard.${today}/model_ncep.realtime.dashboard.info.${today} 
# NOTE: need to kill/restart if shift crosses 00Z
nohup xterm -geometry 70x10+0+900 -sl 5000 -sb -bg orange -fg brown -e /u/nco.sdm/rtdb & 

