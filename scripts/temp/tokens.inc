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
	.word Function_LEFT            & $FFFF ; token $301f "left$("
	.word IllegalToken             & $FFFF ; token $3020 "mid$("
	.word Function_RIGHT           & $FFFF ; token $3021 "right$("
	.word IllegalToken             & $FFFF ; token $3222 ","
	.word IllegalToken             & $FFFF ; token $3223 ";"
	.word IllegalToken             & $FFFF ; token $3224 ":"
	.word IllegalToken             & $FFFF ; token $3225 "("
	.word IllegalToken             & $FFFF ; token $3226 ")"
	.word IllegalToken             & $FFFF ; token $3227 "'"
	.word IllegalToken             & $FFFF ; token $3228 "to"
	.word IllegalToken             & $FFFF ; token $3229 "step"
	.word Function_REM             & $FFFF ; token $3e2a "rem"
	.word Function_Let             & $FFFF ; token $3e2b "let"
	.word Function_ASSERT          & $FFFF ; token $3e2c "assert"
	.word Function_END             & $FFFF ; token $3e2d "end"
	.word Function_RUN             & $FFFF ; token $3e2e "run"
	.word Function_STOP            & $FFFF ; token $3e2f "stop"
	.word Function_CLEAR           & $FFFF ; token $3e30 "clear"
	.word Function_Dim             & $FFFF ; token $3e31 "dim"
	.word Function_COLLECT         & $FFFF ; token $3e32 "collect"
	.word Function_CLS             & $FFFF ; token $3e33 "cls"
	.word Function_PRINT           & $FFFF ; token $3e34 "print"
	.word Function_GOTO            & $FFFF ; token $3e35 "goto"
	.word Function_GOSUB           & $FFFF ; token $3e36 "gosub"
	.word Function_RETURN          & $FFFF ; token $3e37 "return"
	.word Function_ONGOTO          & $FFFF ; token $3e38 "on"
	.word Handler_ELSE             & $FFFF ; token $3e39 "else"
	.word Command_POKE             & $FFFF ; token $3e3a "poke"
	.word Command_DOKE             & $FFFF ; token $3e3b "doke"
	.word Command_LOKE             & $FFFF ; token $3e3c "loke"
	.word Function_REPEAT          & $FFFF ; token $3c3d "repeat"
	.word Function_WHILE           & $FFFF ; token $3c3e "while"
	.word Function_IF              & $FFFF ; token $3c3f "if"
	.word Command_FOR              & $FFFF ; token $3c40 "for"
	.word Function_WEND            & $FFFF ; token $3a41 "wend"
	.word Function_UNTIL           & $FFFF ; token $3a42 "until"
	.word IllegalToken             & $FFFF ; token $3a43 "then"
	.word Handler_ENDIF            & $FFFF ; token $3a44 "endif"
	.word Command_NEXT             & $FFFF ; token $3a45 "next"

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
	 .text $87,"left$("   ; token $301f
	 .text $86,"mid$("    ; token $3020
	 .text $88,"right$("  ; token $3021
	 .text $92,","        ; token $3222
	 .text $92,";"        ; token $3223
	 .text $92,":"        ; token $3224
	 .text $92,"("        ; token $3225
	 .text $92,")"        ; token $3226
	 .text $92,"'"        ; token $3227
	 .text $93,"to"       ; token $3228
	 .text $95,"step"     ; token $3229
	 .text $f4,"rem"      ; token $3e2a
	 .text $f4,"let"      ; token $3e2b
	 .text $f7,"assert"   ; token $3e2c
	 .text $f4,"end"      ; token $3e2d
	 .text $f4,"run"      ; token $3e2e
	 .text $f5,"stop"     ; token $3e2f
	 .text $f6,"clear"    ; token $3e30
	 .text $f4,"dim"      ; token $3e31
	 .text $f8,"collect"  ; token $3e32
	 .text $f4,"cls"      ; token $3e33
	 .text $f6,"print"    ; token $3e34
	 .text $f5,"goto"     ; token $3e35
	 .text $f6,"gosub"    ; token $3e36
	 .text $f7,"return"   ; token $3e37
	 .text $f3,"on"       ; token $3e38
	 .text $f5,"else"     ; token $3e39
	 .text $f5,"poke"     ; token $3e3a
	 .text $f5,"doke"     ; token $3e3b
	 .text $f5,"loke"     ; token $3e3c
	 .text $e7,"repeat"   ; token $3c3d
	 .text $e6,"while"    ; token $3c3e
	 .text $e3,"if"       ; token $3c3f
	 .text $e4,"for"      ; token $3c40
	 .text $d5,"wend"     ; token $3a41
	 .text $d6,"until"    ; token $3a42
	 .text $d5,"then"     ; token $3a43
	 .text $d6,"endif"    ; token $3a44
	 .text $d5,"next"     ; token $3a45
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
leftdollarlparenTokenID          = $301f
middollarlparenTokenID           = $3020
rightdollarlparenTokenID         = $3021
commaTokenID                     = $3222
semicolonTokenID                 = $3223
colonTokenID                     = $3224
lparenTokenID                    = $3225
rparenTokenID                    = $3226
squoteTokenID                    = $3227
toTokenID                        = $3228
stepTokenID                      = $3229
remTokenID                       = $3e2a
letTokenID                       = $3e2b
assertTokenID                    = $3e2c
endTokenID                       = $3e2d
runTokenID                       = $3e2e
stopTokenID                      = $3e2f
clearTokenID                     = $3e30
dimTokenID                       = $3e31
collectTokenID                   = $3e32
clsTokenID                       = $3e33
printTokenID                     = $3e34
gotoTokenID                      = $3e35
gosubTokenID                     = $3e36
returnTokenID                    = $3e37
onTokenID                        = $3e38
elseTokenID                      = $3e39
pokeTokenID                      = $3e3a
dokeTokenID                      = $3e3b
lokeTokenID                      = $3e3c
repeatTokenID                    = $3c3d
whileTokenID                     = $3c3e
ifTokenID                        = $3c3f
forTokenID                       = $3c40
wendTokenID                      = $3a41
untilTokenID                     = $3a42
thenTokenID                      = $3a43
endifTokenID                     = $3a44
nextTokenID                      = $3a45
