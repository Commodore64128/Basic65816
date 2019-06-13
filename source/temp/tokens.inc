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
	.word Function_Let             & $FFFF ; token $3e1d "let"
	.word Function_ASSERT          & $FFFF ; token $3e1e "assert"
	.word Function_END             & $FFFF ; token $3e1f "end"
	.word Function_RUN             & $FFFF ; token $3e20 "run"
	.word Function_CLEAR           & $FFFF ; token $3e21 "clear"
	.word Function_Dim             & $FFFF ; token $3e22 "dim"
	.word Function_COLLECT         & $FFFF ; token $3e23 "collect"
	.word Function_CLS             & $FFFF ; token $3e24 "cls"
	.word Function_PRINT           & $FFFF ; token $3e25 "print"
	.word Function_GOTO            & $FFFF ; token $3e26 "goto"
	.word Function_GOSUB           & $FFFF ; token $3e27 "gosub"
	.word Function_RETURN          & $FFFF ; token $3e28 "return"
	.word IllegalToken             & $FFFF ; token $3e29 "on"
	.word Function_REPEAT          & $FFFF ; token $3c2a "repeat"
	.word Function_UNTIL           & $FFFF ; token $3a2b "until"

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
	 .text $f4,"let"      ; token $3e1d
	 .text $f7,"assert"   ; token $3e1e
	 .text $f4,"end"      ; token $3e1f
	 .text $f4,"run"      ; token $3e20
	 .text $f6,"clear"    ; token $3e21
	 .text $f4,"dim"      ; token $3e22
	 .text $f8,"collect"  ; token $3e23
	 .text $f4,"cls"      ; token $3e24
	 .text $f6,"print"    ; token $3e25
	 .text $f5,"goto"     ; token $3e26
	 .text $f6,"gosub"    ; token $3e27
	 .text $f7,"return"   ; token $3e28
	 .text $f3,"on"       ; token $3e29
	 .text $e7,"repeat"   ; token $3c2a
	 .text $d6,"until"    ; token $3a2b
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
letTokenID                       = $3e1d
assertTokenID                    = $3e1e
endTokenID                       = $3e1f
runTokenID                       = $3e20
clearTokenID                     = $3e21
dimTokenID                       = $3e22
collectTokenID                   = $3e23
clsTokenID                       = $3e24
printTokenID                     = $3e25
gotoTokenID                      = $3e26
gosubTokenID                     = $3e27
returnTokenID                    = $3e28
onTokenID                        = $3e29
repeatTokenID                    = $3c2a
untilTokenID                     = $3a2b
