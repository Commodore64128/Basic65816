1000 REM "Tetris"
1001 screen = 15 * 65536 : sw = 64 : sh = 32
1002 CLS
1010 pattern$ = "DFDFDRFD"
1011 FOR dir = 0 TO 3
1012 x =  ( dir + 1 )  * 10 : y = 10
1020 GOSUB 2000
1021 NEXT
1030 END
2000 c = 143 :  GOTO 2020
2010 c = 32
2020 x1 = x : y1 = y : d1 = dir
2025 hit = 0
2030 FOR i = 1 TO  LEN( pattern$ )
2040 c$ =  MID$( pattern$ , i , 1 )
2050 IF c$ = "L" THEN d1 =  ( d1 - 1 )  & 3
2060 IF c$ = "R" THEN d1 =  ( d1 + 1 )  & 3
2070 IF c$ = "F"
2081 IF d1 = 0 THEN x1 = x1 + 1
2082 IF d1 = 1 THEN y1 = y1 + 1
2083 IF d1 = 2 THEN x1 = x1 - 1
2084 IF d1 = 3 THEN y1 = y1 - 1
2085 ENDIF
2090 IF c$ = "D"
2091 saddr = screen + x1 + y1 * sw
2092 IF  PEEK( saddr )  = 32
2093 POKE saddr , c
2095 ELSE
2097 hit = 1
2098 ENDIF
2100 ENDIF
2200 NEXT i
2210 RETURN