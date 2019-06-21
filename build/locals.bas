@run
100 dim a1$(3)
110 print "("+a1$(2)+")"

1000 	a1$ = "Outer"
1010	n1 = 42
1020 	print 	"Outer",n1,a1$
1024 	for i = 1 to 100
1030 	PROC Inner1
1040 	print 	"Outer",n1,a1$
1045  	next i
1050 	PROC Inner1
1060 	print 	"Outer",n1,a1$
1070 	end
1080 	rem
2000   	defproc inner1
2010 	local n1,a1$
2015 	n1 = 99:a1$ = "Inner1.."
2020 	print 	"Inner1",n1,a1$
2030 	proc inner2
2035 	print 	"Inner1",n1,a1$
2040 endproc
2050 rem
3000 defproc inner2
3010 local n1,a1$
3020 n1 = -1:a$ = "INNER 2 !"
3030 print "inner2",n1,a$
3040 endproc