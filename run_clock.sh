#!/bin/sh
xterm -geometry 30x3+0+900 -bg black -fg green -fb *-fix-*-*-*-18-* -e clock.sh
exit
# When running the script I get xterm: cannot load font '*-fix-*-*-*-18-*'.  
# When running the line as command line input there's no complaint about the
# font, though '24' seems to produce the same size text as '18' (and other 
# font sizes don't work)
