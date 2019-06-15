2 goto 4
3 for ix = 0 to 8:print "RAM";str$(ix+addr,16),str$(peek(ix+addr),16):next ix:end
4 list

10 rem "POKE LOKE DOKE test"
15 a$ = "Hello."+".World!"
17 print ">>";upper$(a$)+"..."+lower$(a$)

40 print "2  6 ["+mid$(a$,2,7)+"]"

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
