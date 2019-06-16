1 a = 99:x = 42:y = 38:list 1,5
2 print "Before",a,x,y
3 link 65536+15*4096:rem "This is in the start.asm routine :)"
4 print "After",a,x,y


9 list 100,133:goto 170

11  for i = 1 to 9999
13  next i
20 	x = 0
50 	repeat
60 		print
70 	until x = 0
80 for i = 1 to 5
90	 a = i
95 next i
97 repeat
100	if (x & 1) = 0
110		print x,"Even",
112 	if x > 5
118			print ">5"
119 	else
120 		print "<=5"
129 	endif
130 	if x = 8 then print "It's eight !"
133 else
134 	print x,"odd",
135 	y = x
136 	repeat:print y;" ";:y = y-1:until y = 0:print
140	endif
150 x = x + 1
160 until x > 10
170 for i = 0 to 255
200 poke 983040+i+64*24,i
210 next i
11180 stop	