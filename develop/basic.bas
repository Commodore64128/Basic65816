100 CLS
110 screen = 15 * 65536 : width = 64 : height = 32
115 DIM pattern$(5 )
120 pattern$(0 )  = "FRRDFDFDRFD"
121 pattern$(1 )  = "FRRDFDFDLFD"
122 pattern$(2 )  = "FFRRDFDFDFD"
123 pattern$(3 )  = "DFDRFDRFD"
124 pattern$(4 )  = "FRRDFDRFDLFD"
125 pattern$(5 )  = "FRRDFDLFDRFD"
130 pattern$ = pattern$( RND(  )  % 6 )
150 PROC drawframe(7 )
160 FOR p = 0 TO 3
200 FOR dir = 0 TO 3
220 PROC piece(187 , pattern$(p )  , dir * 10 + 10 , 5 + p * 5 , dir )
230 NEXT dir
235 NEXT p
240 END
4990 DEFPROC piece(color , pattern$ , x1 , y1 , d1 )
5000 hit = 0
5040 FOR i = 1 TO  LEN( pattern$ )
5050 c$ =  UPPER$(  MID$( pattern$ , i , 1 )  )
5060 IF c$ = "L" THEN d1 =  ( d1 - 1 )  & 3
5070 IF c$ = "R" THEN d1 =  ( d1 + 1 )  & 3
5080 IF c$ = "F"
5090 IF d1 = 0 | d1 = 2 THEN x1 = x1 + d1 - 1
5100 IF d1 = 1 | d1 = 3 THEN y1 = y1 - d1 + 2
5110 ENDIF
5120 IF c$ = "D"
5125 addr = x1 + y1 * width + screen
5130 IF c >= 0
5140 POKE addr , color
5150 ELSE
5160 IF  PEEK( addr )  <> 32 UNTIL hit = 1
5180 ENDIF
5185 ENDIF
5190 NEXT i
5200 ENDPROC
5990 REM
5991 REM "Draw frame"
5992 REM
6000 DEFPROC drawframe(size )
6001 fwidth = size
6002 LOCAL i , y
6005 xframe = 4 : yframe = 4
6010 FOR y = yframe TO yframe + 20
6020 POKE screen + y * width + xframe , 127
6025 POKE screen + y * width + xframe + fwidth + 1 , 127
6030 NEXT y
6040 FOR i = 0 TO fwidth + 1
6050 POKE screen +  ( yframe + 20 )  * width + xframe + i , 127
6060 NEXT i
6070 ENDPROC
7000 DEFPROC gfx
7005 LOCAL i
7010 FOR i = 0 TO 255
7020 POKE 15 * 65536 + i , i
7030 NEXT i :  ENDPROC