@run
100 	a1 = 99942
110 	b1 = 38
111 	s1$ = "Str#1"
112 	s2$ = "Str#2"
115 	print a1,b1,s1$,s2$
120 	proc test
130 	print a1,b1,s1$,s2$
140 	proc test
150 	print a1,b1,s1$,s2$
160 	end

1000 	defproc test
1005 	local a1,b1,s1$,s2$
1009 	print "In test#1 ",a1,b1,s1$,s2$
1010	a1 = 1999
1020 	b1 = 666
1021 	s1$ = "In1":s2$="Alternate String ....."
1024 	print "In test#2 ",a1,b1,s1$,s2$
1026 	proc sublevel
1028 	print "In test#3 ",a1,b1,s1$,s2$
1100 	endproc

1200 	defproc sublevel
1210 	local a1,b1
1220 	a1 = 1:b1 = 2
1230 	print "Sublevel",a1,b1,s1$,s2$
1240 	endproc


