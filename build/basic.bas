@run
100 REM "Bomber"
110 PROC start:print "Worked!"
111 PROC start:print "Worked!"
120 end

1000 DEFPROC start
1002 print "In start"
1005 PROC submethod
1010 ENDPROC

1100 DEFPROC submethod
1110 print "   sub method"
1120 endproc

