10 rem "POKE LOKE DOKE test"
15 a$ = "Hello "+" World!"
17 print ">>";upper$(a$)+"..."+lower$(a$)
20 print "4  [";left$(a$,4);"]"
21 print "20 [";left$(a$,20);"]"
22 print "0  [";left$(a$,0);"]"

30 print "4  [";right$(a$,4);"]"
31 print "20 [";right$(a$,20);"]"
32 print "0  [";right$(a$,0);"]"

100 stop

125 addr = 2 * 65536 + 4 * 4096
130 gosub 130
160 print
170 loke addr+2,-42
180 gosub 230
190 stop
200 rem "Display RAM"
230 for ix = 0 to 8
240 print str$(ix+addr,16),str$(peek(ix+addr),16)
250 next ix
260 return
