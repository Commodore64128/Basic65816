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
	.word Function_LOWER           & $FFFF ; token $301d "lower$("
	.word Function_UPPER           & $FFFF ; token $301e "upper$("
	.word IllegalToken             & $FFFF ; token $321f ","
	.word IllegalToken             & $FFFF ; token $3220 ";"
	.word IllegalToken             & $FFFF ; token $3221 ":"
	.word IllegalToken             & $FFFF ; token $3222 "("
	.word IllegalToken             & $FFFF ; token $3223 ")"
	.word IllegalToken             & $FFFF ; token $3224 "'"
	.word IllegalToken             & $FFFF ; token $3225 "to"
	.word IllegalToken             & $FFFF ; token $3226 "step"
	.word Function_REM             & $FFFF ; token $3e27 "rem"
	.word Function_Let             & $FFFF ; token $3e28 "let"
	.word Function_ASSERT          & $FFFF ; token $3e29 "assert"
	.word Function_END             & $FFFF ; token $3e2a "end"
	.word Function_RUN             & $FFFF ; token $3e2b "run"
	.word Function_STOP            & $FFFF ; token $3e2c "stop"
	.word Function_CLEAR           & $FFFF ; token $3e2d "clear"
	.word Function_Dim             & $FFFF ; token $3e2e "dim"
	.word Function_COLLECT         & $FFFF ; token $3e2f "collect"
	.word Function_CLS             & $FFFF ; token $3e30 "cls"
	.word Function_PRINT           & $FFFF ; token $3e31 "print"
	.word Function_GOTO            & $FFFF ; token $3e32 "goto"
	.word Function_GOSUB           & $FFFF ; token $3e33 "gosub"
	.word Function_RETURN          & $FFFF ; token $3e34 "return"
	.word Function_ONGOTO          & $FFFF ; token $3e35 "on"
	.word Handler_ELSE             & $FFFF ; token $3e36 "else"
	.word Command_POKE             & $FFFF ; token $3e37 "poke"
	.word Command_DOKE             & $FFFF ; token $3e38 "doke"
	.word Command_LOKE             & $FFFF ; token $3e39 "loke"
	.word Function_REPEAT          & $FFFF ; token $3c3a "repeat"
	.word Function_WHILE           & $FFFF ; token $3c3b "while"
	.word Function_IF              & $FFFF ; token $3c3c "if"
	.word Command_FOR              & $FFFF ; token $3c3d "for"
	.word Function_WEND            & $FFFF ; token $3a3e "wend"
	.word Function_UNTIL           & $FFFF ; token $3a3f "until"
	.word IllegalToken             & $FFFF ; token $3a40 "then"
	.word Handler_ENDIF            & $FFFF ; token $3a41 "endif"
	.word Command_NEXT             & $FFFF ; token $3a42 "next"

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
	 .text $88,"lower$("  ; token $301d
	 .text $88,"upper$("  ; token $301e
	 .text $92,","        ; token $321f
	 .text $92,";"        ; token $3220
	 .text $92,":"        ; token $3221
	 .text $92,"("        ; token $3222
	 .text $92,")"        ; token $3223
	 .text $92,"'"        ; token $3224
	 .text $93,"to"       ; token $3225
	 .text $95,"step"     ; token $3226
	 .text $f4,"rem"      ; token $3e27
	 .text $f4,"let"      ; token $3e28
	 .text $f7,"assert"   ; token $3e29
	 .text $f4,"end"      ; token $3e2a
	 .text $f4,"run"      ; token $3e2b
	 .text $f5,"stop"     ; token $3e2c
	 .text $f6,"clear"    ; token $3e2d
	 .text $f4,"dim"      ; token $3e2e
	 .text $f8,"collect"  ; token $3e2f
	 .text $f4,"cls"      ; token $3e30
	 .text $f6,"print"    ; token $3e31
	 .text $f5,"goto"     ; token $3e32
	 .text $f6,"gosub"    ; token $3e33
	 .text $f7,"return"   ; token $3e34
	 .text $f3,"on"       ; token $3e35
	 .text $f5,"else"     ; token $3e36
	 .text $f5,"poke"     ; token $3e37
	 .text $f5,"doke"     ; token $3e38
	 .text $f5,"loke"     ; token $3e39
	 .text $e7,"repeat"   ; token $3c3a
	 .text $e6,"while"    ; token $3c3b
	 .text $e3,"if"       ; token $3c3c
	 .text $e4,"for"      ; token $3c3d
	 .text $d5,"wend"     ; token $3a3e
	 .text $d6,"until"    ; token $3a3f
	 .text $d5,"then"     ; token $3a40
	 .text $d6,"endif"    ; token $3a41
	 .text $d5,"next"     ; token $3a42
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
lowerdollarlparenTokenID         = $301d
upperdollarlparenTokenID         = $301e
commaTokenID                     = $321f
semicolonTokenID                 = $3220
colonTokenID                     = $3221
lparenTokenID                    = $3222
rparenTokenID                    = $3223
squoteTokenID                    = $3224
toTokenID                        = $3225
stepTokenID                      = $3226
remTokenID                       = $3e27
letTokenID                       = $3e28
assertTokenID                    = $3e29
endTokenID                       = $3e2a
runTokenID                       = $3e2b
stopTokenID                      = $3e2c
clearTokenID                     = $3e2d
dimTokenID                       = $3e2e
collectTokenID                   = $3e2f
clsTokenID                       = $3e30
printTokenID                     = $3e31
gotoTokenID                      = $3e32
gosubTokenID                     = $3e33
returnTokenID                    = $3e34
onTokenID                        = $3e35
elseTokenID                      = $3e36
pokeTokenID                      = $3e37
dokeTokenID                      = $3e38
lokeTokenID                      = $3e39
repeatTokenID                    = $3c3a
whileTokenID                     = $3c3b
ifTokenID                        = $3c3c
forTokenID                       = $3c3d
wendTokenID                      = $3a3e
untilTokenID                     = $3a3f
thenTokenID                      = $3a40
endifTokenID                     = $3a41
nextTokenID                      = $3a42
