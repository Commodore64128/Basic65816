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
	.word Function_Random          & $FFFF ; token $3011 "rnd()"
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
	.word Function_REM             & $FFFF ; token $3e1d "rem"
	.word Function_Let             & $FFFF ; token $3e1e "let"
	.word Function_ASSERT          & $FFFF ; token $3e1f "assert"
	.word Function_END             & $FFFF ; token $3e20 "end"
	.word Function_RUN             & $FFFF ; token $3e21 "run"
	.word Function_STOP            & $FFFF ; token $3e22 "stop"
	.word Function_CLEAR           & $FFFF ; token $3e23 "clear"
	.word Function_Dim             & $FFFF ; token $3e24 "dim"
	.word Function_COLLECT         & $FFFF ; token $3e25 "collect"
	.word Function_CLS             & $FFFF ; token $3e26 "cls"
	.word Function_PRINT           & $FFFF ; token $3e27 "print"
	.word Function_GOTO            & $FFFF ; token $3e28 "goto"
	.word Function_GOSUB           & $FFFF ; token $3e29 "gosub"
	.word Function_RETURN          & $FFFF ; token $3e2a "return"
	.word Function_ONGOTO          & $FFFF ; token $3e2b "on"
	.word Handler_ELSE             & $FFFF ; token $3e2c "else"
	.word Function_REPEAT          & $FFFF ; token $3c2d "repeat"
	.word IllegalToken             & $FFFF ; token $3c2e "while"
	.word Function_IF              & $FFFF ; token $3c2f "if"
	.word IllegalToken             & $FFFF ; token $3a30 "wend"
	.word Function_UNTIL           & $FFFF ; token $3a31 "until"
	.word IllegalToken             & $FFFF ; token $3a32 "then"
	.word Handler_ENDIF            & $FFFF ; token $3a33 "endif"

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
	 .text $86,"rnd()"    ; token $3011
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
	 .text $f4,"rem"      ; token $3e1d
	 .text $f4,"let"      ; token $3e1e
	 .text $f7,"assert"   ; token $3e1f
	 .text $f4,"end"      ; token $3e20
	 .text $f4,"run"      ; token $3e21
	 .text $f5,"stop"     ; token $3e22
	 .text $f6,"clear"    ; token $3e23
	 .text $f4,"dim"      ; token $3e24
	 .text $f8,"collect"  ; token $3e25
	 .text $f4,"cls"      ; token $3e26
	 .text $f6,"print"    ; token $3e27
	 .text $f5,"goto"     ; token $3e28
	 .text $f6,"gosub"    ; token $3e29
	 .text $f7,"return"   ; token $3e2a
	 .text $f3,"on"       ; token $3e2b
	 .text $f5,"else"     ; token $3e2c
	 .text $e7,"repeat"   ; token $3c2d
	 .text $e6,"while"    ; token $3c2e
	 .text $e3,"if"       ; token $3c2f
	 .text $d5,"wend"     ; token $3a30
	 .text $d6,"until"    ; token $3a31
	 .text $d5,"then"     ; token $3a32
	 .text $d6,"endif"    ; token $3a33
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
rndlparenrparenTokenID           = $3011
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
remTokenID                       = $3e1d
letTokenID                       = $3e1e
assertTokenID                    = $3e1f
endTokenID                       = $3e20
runTokenID                       = $3e21
stopTokenID                      = $3e22
clearTokenID                     = $3e23
dimTokenID                       = $3e24
collectTokenID                   = $3e25
clsTokenID                       = $3e26
printTokenID                     = $3e27
gotoTokenID                      = $3e28
gosubTokenID                     = $3e29
returnTokenID                    = $3e2a
onTokenID                        = $3e2b
elseTokenID                      = $3e2c
repeatTokenID                    = $3c2d
whileTokenID                     = $3c2e
ifTokenID                        = $3c2f
wendTokenID                      = $3a30
untilTokenID                     = $3a31
thenTokenID                      = $3a32
endifTokenID                     = $3a33
