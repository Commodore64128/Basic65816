@run
102 dim d$(3)
103 print d$(2)
105 a$ = "Outer"
107 print a$
108 PROC Demo
109 print a$
110 x1 = 1:z = -11

1107 print "Should be outer : ";a$,x1,z
1110 PROC start:print "Worked 1!"
1112 print "Should be outer : ";a$,x1,z
1114 PROC start:print "Worked 2!"
1116 print "Should be outer : ";a$,x1,z
1117 c$ = "!"
1119 print c$c$c$
1120 end

11000 DEFPROC start
11001 local a$,x1,z
11002 print "In start",a$
11004 a$ = "Inner":x1 = 99:z = -1
11005 print "	Should be inner : ";a$,x1,z
11008 PROC submethod
11009 print "	Should be inner : ";a$,x1,z
11040 ENDPROC

11100 DEFPROC submethod
11105 local a$:a$ = "really inner":local x1
11110 print "   		sub method",a$,x1,z
11120 endproc

12000 DEFPROC Demo
12005 local a$:a$ = "In routine"
12010 print a$
12012 PROC Demo2
12015 print a$
12020 endproc

13000 DEFPROC Demo2
13005 local a$:print "(";a$;")":a$ = "????":print "(";a$;")"
13010 ENDPROC
