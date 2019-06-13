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
	.word IllegalToken             & $FFFF ; token $3217 ","
	.word IllegalToken             & $FFFF ; token $3218 ";"
	.word IllegalToken             & $FFFF ; token $3219 ":"
	.word IllegalToken             & $FFFF ; token $321a "("
	.word IllegalToken             & $FFFF ; token $321b ")"
	.word IllegalToken             & $FFFF ; token $321c "'"
	.word IllegalToken             & $FFFF ; token $321d "to"
	.word IllegalToken             & $FFFF ; token $321e "step"
	.word Function_REM             & $FFFF ; token $3e1f "rem"
	.word Function_Let             & $FFFF ; token $3e20 "let"
	.word Function_ASSERT          & $FFFF ; token $3e21 "assert"
	.word Function_END             & $FFFF ; token $3e22 "end"
	.word Function_RUN             & $FFFF ; token $3e23 "run"
	.word Function_STOP            & $FFFF ; token $3e24 "stop"
	.word Function_CLEAR           & $FFFF ; token $3e25 "clear"
	.word Function_Dim             & $FFFF ; token $3e26 "dim"
	.word Function_COLLECT         & $FFFF ; token $3e27 "collect"
	.word Function_CLS             & $FFFF ; token $3e28 "cls"
	.word Function_PRINT           & $FFFF ; token $3e29 "print"
	.word Function_GOTO            & $FFFF ; token $3e2a "goto"
	.word Function_GOSUB           & $FFFF ; token $3e2b "gosub"
	.word Function_RETURN          & $FFFF ; token $3e2c "return"
	.word Function_ONGOTO          & $FFFF ; token $3e2d "on"
	.word Handler_ELSE             & $FFFF ; token $3e2e "else"
	.word Function_REPEAT          & $FFFF ; token $3c2f "repeat"
	.word Function_WHILE           & $FFFF ; token $3c30 "while"
	.word Function_IF              & $FFFF ; token $3c31 "if"
	.word IllegalToken             & $FFFF ; token $3c32 "for"
	.word Function_WEND            & $FFFF ; token $3a33 "wend"
	.word Function_UNTIL           & $FFFF ; token $3a34 "until"
	.word IllegalToken             & $FFFF ; token $3a35 "then"
	.word Handler_ENDIF            & $FFFF ; token $3a36 "endif"
	.word IllegalToken             & $FFFF ; token $3a37 "next"

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
	 .text $92,","        ; token $3217
	 .text $92,";"        ; token $3218
	 .text $92,":"        ; token $3219
	 .text $92,"("        ; token $321a
	 .text $92,")"        ; token $321b
	 .text $92,"'"        ; token $321c
	 .text $93,"to"       ; token $321d
	 .text $95,"step"     ; token $321e
	 .text $f4,"rem"      ; token $3e1f
	 .text $f4,"let"      ; token $3e20
	 .text $f7,"assert"   ; token $3e21
	 .text $f4,"end"      ; token $3e22
	 .text $f4,"run"      ; token $3e23
	 .text $f5,"stop"     ; token $3e24
	 .text $f6,"clear"    ; token $3e25
	 .text $f4,"dim"      ; token $3e26
	 .text $f8,"collect"  ; token $3e27
	 .text $f4,"cls"      ; token $3e28
	 .text $f6,"print"    ; token $3e29
	 .text $f5,"goto"     ; token $3e2a
	 .text $f6,"gosub"    ; token $3e2b
	 .text $f7,"return"   ; token $3e2c
	 .text $f3,"on"       ; token $3e2d
	 .text $f5,"else"     ; token $3e2e
	 .text $e7,"repeat"   ; token $3c2f
	 .text $e6,"while"    ; token $3c30
	 .text $e3,"if"       ; token $3c31
	 .text $e4,"for"      ; token $3c32
	 .text $d5,"wend"     ; token $3a33
	 .text $d6,"until"    ; token $3a34
	 .text $d5,"then"     ; token $3a35
	 .text $d6,"endif"    ; token $3a36
	 .text $d5,"next"     ; token $3a37
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
commaTokenID                     = $3217
semicolonTokenID                 = $3218
colonTokenID                     = $3219
lparenTokenID                    = $321a
rparenTokenID                    = $321b
squoteTokenID                    = $321c
toTokenID                        = $321d
stepTokenID                      = $321e
remTokenID                       = $3e1f
letTokenID                       = $3e20
assertTokenID                    = $3e21
endTokenID                       = $3e22
runTokenID                       = $3e23
stopTokenID                      = $3e24
clearTokenID                     = $3e25
dimTokenID                       = $3e26
collectTokenID                   = $3e27
clsTokenID                       = $3e28
printTokenID                     = $3e29
gotoTokenID                      = $3e2a
gosubTokenID                     = $3e2b
returnTokenID                    = $3e2c
onTokenID                        = $3e2d
elseTokenID                      = $3e2e
repeatTokenID                    = $3c2f
whileTokenID                     = $3c30
ifTokenID                        = $3c31
forTokenID                       = $3c32
wendTokenID                      = $3a33
untilTokenID                     = $3a34
thenTokenID                      = $3a35
endifTokenID                     = $3a36
nextTokenID                      = $3a37
