@run
100 a$ = "":b$ = ""
110 for i = 1 to 14
120 	a$ = a$ + chr$((rnd() & 15)+65)
125 	b$ = b$ + "."
130 next i
140 print a$
150 print b$



