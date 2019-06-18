100 REM "Bomber"
101 screen = 15 * 65536 : width = 64 : height = 32
102 CLS
103 PRINT  :  PRINT  :  PRINT
110 GOSUB 1000
111 score = 0 :  GOSUB 1200
120 plane = screen + width :  GOSUB 1300
989 REM
990 REM "Draw the game outline"
991 REM
1000 FOR x = 0 TO width - 1
1010 bottom = screen +  ( height - 1 )  * width + x
1020 POKE bottom , 207
1030 bh =  RND(  )  and 7
1040 IF bh <> 0
1050 FOR i = 1 TO bh
1060 POKE bottom - i * width , 16
1070 NEXT i
1080 ENDIF
1100 NEXT x
1110 RETURN
1190 REM
1191 REM "Update the score"
1192 REM
1200 a$ =  RIGHT$( "00000" +  STR$( score )  , 5 )
1210 FOR i = 1 TO 5
1220 POKE screen + i ,  ASC(  MID$( a$ , i , 1 )  )
1230 NEXT i
1240 RETURN
1291 REM
1292 REM "Move the Plane"
1293 REM
1300 POKE plane , 32 :  POKE plane + 1 , 32
1310 plane = plane + 1
1320 IF  PEEK( plane )  <> 32 THEN  END
1330 POKE plane , 215 :  POKE plane + 1 , 210
1340 RETURN