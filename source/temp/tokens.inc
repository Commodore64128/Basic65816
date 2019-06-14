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
	.word IllegalToken             & $FFFF ; token $3219 ","
	.word IllegalToken             & $FFFF ; token $321a ";"
	.word IllegalToken             & $FFFF ; token $321b ":"
	.word IllegalToken             & $FFFF ; token $321c "("
	.word IllegalToken             & $FFFF ; token $321d ")"
	.word IllegalToken             & $FFFF ; token $321e "'"
	.word IllegalToken             & $FFFF ; token $321f "to"
	.word IllegalToken             & $FFFF ; token $3220 "step"
	.word Function_REM             & $FFFF ; token $3e21 "rem"
	.word Function_Let             & $FFFF ; token $3e22 "let"
	.word Function_ASSERT          & $FFFF ; token $3e23 "assert"
	.word Function_END             & $FFFF ; token $3e24 "end"
	.word Function_RUN             & $FFFF ; token $3e25 "run"
	.word Function_STOP            & $FFFF ; token $3e26 "stop"
	.word Function_CLEAR           & $FFFF ; token $3e27 "clear"
	.word Function_Dim             & $FFFF ; token $3e28 "dim"
	.word Function_COLLECT         & $FFFF ; token $3e29 "collect"
	.word Function_CLS             & $FFFF ; token $3e2a "cls"
	.word Function_PRINT           & $FFFF ; token $3e2b "print"
	.word Function_GOTO            & $FFFF ; token $3e2c "goto"
	.word Function_GOSUB           & $FFFF ; token $3e2d "gosub"
	.word Function_RETURN          & $FFFF ; token $3e2e "return"
	.word Function_ONGOTO          & $FFFF ; token $3e2f "on"
	.word Handler_ELSE             & $FFFF ; token $3e30 "else"
	.word Function_REPEAT          & $FFFF ; token $3c31 "repeat"
	.word Function_WHILE           & $FFFF ; token $3c32 "while"
	.word Function_IF              & $FFFF ; token $3c33 "if"
	.word IllegalToken             & $FFFF ; token $3c34 "for"
	.word Function_WEND            & $FFFF ; token $3a35 "wend"
	.word Function_UNTIL           & $FFFF ; token $3a36 "until"
	.word IllegalToken             & $FFFF ; token $3a37 "then"
	.word Handler_ENDIF            & $FFFF ; token $3a38 "endif"
	.word IllegalToken             & $FFFF ; token $3a39 "next"

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
	 .text $92,","        ; token $3219
	 .text $92,";"        ; token $321a
	 .text $92,":"        ; token $321b
	 .text $92,"("        ; token $321c
	 .text $92,")"        ; token $321d
	 .text $92,"'"        ; token $321e
	 .text $93,"to"       ; token $321f
	 .text $95,"step"     ; token $3220
	 .text $f4,"rem"      ; token $3e21
	 .text $f4,"let"      ; token $3e22
	 .text $f7,"assert"   ; token $3e23
	 .text $f4,"end"      ; token $3e24
	 .text $f4,"run"      ; token $3e25
	 .text $f5,"stop"     ; token $3e26
	 .text $f6,"clear"    ; token $3e27
	 .text $f4,"dim"      ; token $3e28
	 .text $f8,"collect"  ; token $3e29
	 .text $f4,"cls"      ; token $3e2a
	 .text $f6,"print"    ; token $3e2b
	 .text $f5,"goto"     ; token $3e2c
	 .text $f6,"gosub"    ; token $3e2d
	 .text $f7,"return"   ; token $3e2e
	 .text $f3,"on"       ; token $3e2f
	 .text $f5,"else"     ; token $3e30
	 .text $e7,"repeat"   ; token $3c31
	 .text $e6,"while"    ; token $3c32
	 .text $e3,"if"       ; token $3c33
	 .text $e4,"for"      ; token $3c34
	 .text $d5,"wend"     ; token $3a35
	 .text $d6,"until"    ; token $3a36
	 .text $d5,"then"     ; token $3a37
	 .text $d6,"endif"    ; token $3a38
	 .text $d5,"next"     ; token $3a39
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
commaTokenID                     = $3219
semicolonTokenID                 = $321a
colonTokenID                     = $321b
lparenTokenID                    = $321c
rparenTokenID                    = $321d
squoteTokenID                    = $321e
toTokenID                        = $321f
stepTokenID                      = $3220
remTokenID                       = $3e21
letTokenID                       = $3e22
assertTokenID                    = $3e23
endTokenID                       = $3e24
runTokenID                       = $3e25
stopTokenID                      = $3e26
clearTokenID                     = $3e27
dimTokenID                       = $3e28
collectTokenID                   = $3e29
clsTokenID                       = $3e2a
printTokenID                     = $3e2b
gotoTokenID                      = $3e2c
gosubTokenID                     = $3e2d
returnTokenID                    = $3e2e
onTokenID                        = $3e2f
elseTokenID                      = $3e30
repeatTokenID                    = $3c31
whileTokenID                     = $3c32
ifTokenID                        = $3c33
forTokenID                       = $3c34
wendTokenID                      = $3a35
untilTokenID                     = $3a36
thenTokenID                      = $3a37
endifTokenID                     = $3a38
nextTokenID                      = $3a39
