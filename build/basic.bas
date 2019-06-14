10 rem "POKE LOKE DOKE test"
15 a$ = "Hello "+" World!"
17 print ">>";upper$(a$)+"..."+lower$(a$)
20 addr = 2 * 65536 + 4 * 4096
30 gosub 130
60 print
70 loke addr+2,-42
80 gosub 130
90 stop
100 rem "Display RAM"
130 for ix = 0 to 8
140 print str$(ix+addr,16),str$(peek(ix+addr),16)
150 next ix
160 return
