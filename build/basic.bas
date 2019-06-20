@run
1000 	PROC Make:a$ = z$
1010 	PROC Make:b$ = z$
1020 	PROC Make:c$ = z$
1030 	PROC Make:d$ = z$
1040 	PROC Make:e$ = z$
1050 	PROC Make:f$ = z$
1060 	Print a$,b$,c$,d$,e$,f$
1070	for i = 1 to 2000
1071 	PROC Make:a$ = z$
1072 	PROC Make:b$ = z$
1073 	PROC Make:c$ = z$
1074 	PROC Make:d$ = z$
1075 	PROC Make:e$ = z$
1076 	PROC Make:f$ = z$
1077    if i % 20 = 0 then print i
1078 	PROC fiddle
1080 	next 
1090 	Print a$,b$,c$,d$,e$,f$
2900 	end
10000   DEFPROC fiddle
10010 	LOCAL a$,b$
11071 	PROC Make:a$ = z$
11072 	PROC Make:b$ = z$
11073 	PROC Make:c$ = z$
11074 	PROC Make:a$ = z$
11075 	PROC Make:b$ = z$
11076 	PROC Make:c$ = z$
11079 	ENDPROC

21100	DEFPROC Make
21110 	z$ = ""
21120  	c = (rnd() & 15)+2
21130 	while c > 0
21140 		z$ = z$ + chr$((rnd() & 15)+97)
21150 		c = c - 1
21160 	wend
21170 endproc