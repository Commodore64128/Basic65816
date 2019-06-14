;
;	Vector Jump table
;
CommandJumpTable:
	.word IllegalToken & $FFFF ; for the $0000 token.
	.word Binary_And               & $FFFF ; token $2001 "&"
	.word Binary_Or                & $FFFF ; token $2002 "|"
	.word Binary_Xor               & $FFFF ; token $2003 "^"
	.word Binary_Less              & $FFFF ; token $2204 "<"
	.word Binary_Greater           & $FFFF ; token $2205 ">"
	.word Binary_Equals            & $FFFF ; token $2206 "="
	.word Binary_LessEqual         & $FFFF ; token $2207 "<="
	.word Binary_GreaterEqual      & $FFFF ; token $2208 ">="
	.word Binary_NotEquals         & $FFFF ; token $2209 "<>"
	.word Binary_Add               & $FFFF ; token $240a "+"
	.word Binary_Subtract          & $FFFF ; token $240b "-"
	.word Binary_Multiply          & $FFFF ; token $260c "*"
	.word Binary_Divide            & $FFFF ; token $260d "/"
	.word Binary_Modulus           & $FFFF ; token $260e "%"
	.word Binary_ShiftRight        & $FFFF ; token $260f ">>"
	.word Binary_ShiftLeft         & $FFFF ; token $2610 "<<"
	.word Function_Random          & $FFFF ; token $3011 "rnd("
	.word Function_Sgn             & $FFFF ; token $3012 "sgn("
	.word Function_Abs             & $FFFF ; token $3013 "abs("
	.word Function_Len             & $FFFF ; token $3014 "len("
	.word Function_VAL             & $FFFF ; token $3015 "val("
	.word Function_Str             & $FFFF ; token $3016 "str$("
	.word Function_Chr             & $FFFF ; token $3017 "chr$("
	.word Function_Asc             & $FFFF ; token $3018 "asc("
	.word Function_SPC             & $FFFF ; token $3019 "spc("
	.word Function_Peek            & $FFFF ; token $301a "peek("
	.word Function_Deek            & $FFFF ; token $301b "deek("
	.word Function_Leek            & $FFFF ; token $301c "leek("
	.word IllegalToken             & $FFFF ; token $321d ","
	.word IllegalToken             & $FFFF ; token $321e ";"
	.word IllegalToken             & $FFFF ; token $321f ":"
	.word IllegalToken             & $FFFF ; token $3220 "("
	.word IllegalToken             & $FFFF ; token $3221 ")"
	.word IllegalToken             & $FFFF ; token $3222 "'"
	.word IllegalToken             & $FFFF ; token $3223 "to"
	.word IllegalToken             & $FFFF ; token $3224 "step"
	.word Function_REM             & $FFFF ; token $3e25 "rem"
	.word Function_Let             & $FFFF ; token $3e26 "let"
	.word Function_ASSERT          & $FFFF ; token $3e27 "assert"
	.word Function_END             & $FFFF ; token $3e28 "end"
	.word Function_RUN             & $FFFF ; token $3e29 "run"
	.word Function_STOP            & $FFFF ; token $3e2a "stop"
	.word Function_CLEAR           & $FFFF ; token $3e2b "clear"
	.word Function_Dim             & $FFFF ; token $3e2c "dim"
	.word Function_COLLECT         & $FFFF ; token $3e2d "collect"
	.word Function_CLS             & $FFFF ; token $3e2e "cls"
	.word Function_PRINT           & $FFFF ; token $3e2f "print"
	.word Function_GOTO            & $FFFF ; token $3e30 "goto"
	.word Function_GOSUB           & $FFFF ; token $3e31 "gosub"
	.word Function_RETURN          & $FFFF ; token $3e32 "return"
	.word Function_ONGOTO          & $FFFF ; token $3e33 "on"
	.word Handler_ELSE             & $FFFF ; token $3e34 "else"
	.word Function_REPEAT          & $FFFF ; token $3c35 "repeat"
	.word Function_WHILE           & $FFFF ; token $3c36 "while"
	.word Function_IF              & $FFFF ; token $3c37 "if"
	.word Command_FOR              & $FFFF ; token $3c38 "for"
	.word Function_WEND            & $FFFF ; token $3a39 "wend"
	.word Function_UNTIL           & $FFFF ; token $3a3a "until"
	.word IllegalToken             & $FFFF ; token $3a3b "then"
	.word Handler_ENDIF            & $FFFF ; token $3a3c "endif"
	.word Command_NEXT             & $FFFF ; token $3a3d "next"

;
;	Token text table. Byte is typeID[7:4] length[3:0]
;
TokenText:
	 .text $02,"&"        ; token $2001
	 .text $02,"|"        ; token $2002
	 .text $02,"^"        ; token $2003
	 .text $12,"<"        ; token $2204
	 .text $12,">"        ; token $2205
	 .text $12,"="        ; token $2206
	 .text $13,"<="       ; token $2207
	 .text $13,">="       ; token $2208
	 .text $13,"<>"       ; token $2209
	 .text $22,"+"        ; token $240a
	 .text $22,"-"        ; token $240b
	 .text $32,"*"        ; token $260c
	 .text $32,"/"        ; token $260d
	 .text $32,"%"        ; token $260e
	 .text $33,">>"       ; token $260f
	 .text $33,"<<"       ; token $2610
	 .text $85,"rnd("     ; token $3011
	 .text $85,"sgn("     ; token $3012
	 .text $85,"abs("     ; token $3013
	 .text $85,"len("     ; token $3014
	 .text $85,"val("     ; token $3015
	 .text $86,"str$("    ; token $3016
	 .text $86,"chr$("    ; token $3017
	 .text $85,"asc("     ; token $3018
	 .text $85,"spc("     ; token $3019
	 .text $86,"peek("    ; token $301a
	 .text $86,"deek("    ; token $301b
	 .text $86,"leek("    ; token $301c
	 .text $92,","        ; token $321d
	 .text $92,";"        ; token $321e
	 .text $92,":"        ; token $321f
	 .text $92,"("        ; token $3220
	 .text $92,")"        ; token $3221
	 .text $92,"'"        ; token $3222
	 .text $93,"to"       ; token $3223
	 .text $95,"step"     ; token $3224
	 .text $f4,"rem"      ; token $3e25
	 .text $f4,"let"      ; token $3e26
	 .text $f7,"assert"   ; token $3e27
	 .text $f4,"end"      ; token $3e28
	 .text $f4,"run"      ; token $3e29
	 .text $f5,"stop"     ; token $3e2a
	 .text $f6,"clear"    ; token $3e2b
	 .text $f4,"dim"      ; token $3e2c
	 .text $f8,"collect"  ; token $3e2d
	 .text $f4,"cls"      ; token $3e2e
	 .text $f6,"print"    ; token $3e2f
	 .text $f5,"goto"     ; token $3e30
	 .text $f6,"gosub"    ; token $3e31
	 .text $f7,"return"   ; token $3e32
	 .text $f3,"on"       ; token $3e33
	 .text $f5,"else"     ; token $3e34
	 .text $e7,"repeat"   ; token $3c35
	 .text $e6,"while"    ; token $3c36
	 .text $e3,"if"       ; token $3c37
	 .text $e4,"for"      ; token $3c38
	 .text $d5,"wend"     ; token $3a39
	 .text $d6,"until"    ; token $3a3a
	 .text $d5,"then"     ; token $3a3b
	 .text $d6,"endif"    ; token $3a3c
	 .text $d5,"next"     ; token $3a3d
	.byte $00

;
;	Constants
;
ampersandTokenID                 = $2001
barTokenID                       = $2002
hatTokenID                       = $2003
lessTokenID                      = $2204
greaterTokenID                   = $2205
equalTokenID                     = $2206
lessequalTokenID                 = $2207
greaterequalTokenID              = $2208
lessgreaterTokenID               = $2209
plusTokenID                      = $240a
minusTokenID                     = $240b
starTokenID                      = $260c
slashTokenID                     = $260d
percentTokenID                   = $260e
greatergreaterTokenID            = $260f
lesslessTokenID                  = $2610
rndlparenTokenID                 = $3011
sgnlparenTokenID                 = $3012
abslparenTokenID                 = $3013
lenlparenTokenID                 = $3014
vallparenTokenID                 = $3015
strdollarlparenTokenID           = $3016
chrdollarlparenTokenID           = $3017
asclparenTokenID                 = $3018
spclparenTokenID                 = $3019
peeklparenTokenID                = $301a
deeklparenTokenID                = $301b
leeklparenTokenID                = $301c
commaTokenID                     = $321d
semicolonTokenID                 = $321e
colonTokenID                     = $321f
lparenTokenID                    = $3220
rparenTokenID                    = $3221
squoteTokenID                    = $3222
toTokenID                        = $3223
stepTokenID                      = $3224
remTokenID                       = $3e25
letTokenID                       = $3e26
assertTokenID                    = $3e27
endTokenID                       = $3e28
runTokenID                       = $3e29
stopTokenID                      = $3e2a
clearTokenID                     = $3e2b
dimTokenID                       = $3e2c
collectTokenID                   = $3e2d
clsTokenID                       = $3e2e
printTokenID                     = $3e2f
gotoTokenID                      = $3e30
gosubTokenID                     = $3e31
returnTokenID                    = $3e32
onTokenID                        = $3e33
elseTokenID                      = $3e34
repeatTokenID                    = $3c35
whileTokenID                     = $3c36
ifTokenID                        = $3c37
forTokenID                       = $3c38
wendTokenID                      = $3a39
untilTokenID                     = $3a3a
thenTokenID                      = $3a3b
endifTokenID                     = $3a3c
nextTokenID                      = $3a3d
