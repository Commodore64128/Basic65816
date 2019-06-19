@run

100 REM "Bomber"
105 a$ = "Outer"
106 x1=42
107 z = -1
110 rem
1107 print "Should be outer : ";a$,x1,z
1110 PROC start:print "Worked!"
1112 print "Should be outer : ";a$,x1,z
1114 PROC start:print "Worked!"
1116 print "Should be outer : ";a$,x1,z
1117 c$ = "!"
1120 end

11000 DEFPROC start
11001 local a$,x1,z
11002 print "In start"
11004 a$ = "Inner":x1 = 99:z = -1
11005 print "	Should be inner : ";a$,x1,z
11008 PROC submethod
11009 print "	Should be inner : ";a$,x1,z
11040 ENDPROC

11100 DEFPROC submethod
11105 local a$:a$ = "really inner"
11110 print "   		sub method",a$,x1,z
11120 endproc

