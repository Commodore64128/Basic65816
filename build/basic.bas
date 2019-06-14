5 x = 0
6 repeat
7 rem "If you change the last 10 to 16 it crashes"
10 print str$(x,16),str$(peek(x),16),str$(deek(x),16),str$(leek(x),10)
12 x = x + 1
15 until x = 16
20 stop