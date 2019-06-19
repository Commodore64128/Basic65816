@run
100 REM "Bomber"
105 a$ = "Outer":x1 = 42:z = 44
107 print "Should be outer : ";a$,x1,z
110 PROC start:print "Worked!"
112 print "Should be outer : ";a$,x1,z
114 PROC start:print "Worked!"
116 print "Should be outer : ";a$,x1,z
120 end

1000 DEFPROC start
1001 local a$,x1,z
1002 print "In start"
1004 a$ = "Inner":x1 = 99:z = -1
1005 print "	Should be inner : ";a$,x1,z
1008 PROC submethod
1009 print "	Should be inner : ";a$,x1,z
1040 ENDPROC

1100 DEFPROC submethod
1105 local a$:a$ = "really inner"
1110 print "   		sub method",a$,x1,z
1120 endproc

