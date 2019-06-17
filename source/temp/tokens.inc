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
	.word Function_MID             & $FFFF ; token $3020 "mid$("
	.word Function_RIGHT           & $FFFF ; token $3021 "right$("
	.word Function_INSTR           & $FFFF ; token $3022 "instr("
	.word Function_Inkey           & $FFFF ; token $3023 "inkey("
	.word IllegalToken             & $FFFF ; token $3224 ","
	.word IllegalToken             & $FFFF ; token $3225 ";"
	.word IllegalToken             & $FFFF ; token $3226 ":"
	.word IllegalToken             & $FFFF ; token $3227 "("
	.word IllegalToken             & $FFFF ; token $3228 ")"
	.word IllegalToken             & $FFFF ; token $3229 "'"
	.word IllegalToken             & $FFFF ; token $382a "to"
	.word IllegalToken             & $FFFF ; token $382b "step"
	.word Function_REM             & $FFFF ; token $3e2c "rem"
	.word Function_Let             & $FFFF ; token $3e2d "let"
	.word Function_ASSERT          & $FFFF ; token $3e2e "assert"
	.word Function_END             & $FFFF ; token $3e2f "end"
	.word Function_RUN             & $FFFF ; token $3e30 "run"
	.word Function_STOP            & $FFFF ; token $3e31 "stop"
	.word Function_CLEAR           & $FFFF ; token $3e32 "clear"
	.word Function_Dim             & $FFFF ; token $3e33 "dim"
	.word Function_COLLECT         & $FFFF ; token $3e34 "collect"
	.word Function_CLS             & $FFFF ; token $3e35 "cls"
	.word Function_PRINT           & $FFFF ; token $3e36 "print"
	.word Function_GOTO            & $FFFF ; token $3e37 "goto"
	.word Function_GOSUB           & $FFFF ; token $3e38 "gosub"
	.word Function_RETURN          & $FFFF ; token $3e39 "return"
	.word Function_ONGOTO          & $FFFF ; token $3e3a "on"
	.word Handler_ELSE             & $FFFF ; token $3e3b "else"
	.word Command_POKE             & $FFFF ; token $3e3c "poke"
	.word Command_DOKE             & $FFFF ; token $3e3d "doke"
	.word Command_LOKE             & $FFFF ; token $3e3e "loke"
	.word Command_List             & $FFFF ; token $3e3f "list"
	.word Function_LINK            & $FFFF ; token $3e40 "link"
	.word Function_REPEAT          & $FFFF ; token $3c41 "repeat"
	.word Function_WHILE           & $FFFF ; token $3c42 "while"
	.word Function_IF              & $FFFF ; token $3c43 "if"
	.word Command_FOR              & $FFFF ; token $3c44 "for"
	.word Function_WEND            & $FFFF ; token $3a45 "wend"
	.word Function_UNTIL           & $FFFF ; token $3a46 "until"
	.word IllegalToken             & $FFFF ; token $3a47 "then"
	.word Handler_ENDIF            & $FFFF ; token $3a48 "endif"
	.word Command_NEXT             & $FFFF ; token $3a49 "next"

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
	 .text $85,"RND("     ; token $3011
	 .text $85,"SGN("     ; token $3012
	 .text $85,"ABS("     ; token $3013
	 .text $85,"LEN("     ; token $3014
	 .text $85,"VAL("     ; token $3015
	 .text $86,"STR$("    ; token $3016
	 .text $86,"CHR$("    ; token $3017
	 .text $85,"ASC("     ; token $3018
	 .text $85,"SPC("     ; token $3019
	 .text $86,"PEEK("    ; token $301a
	 .text $86,"DEEK("    ; token $301b
	 .text $86,"LEEK("    ; token $301c
	 .text $88,"LOWER$("  ; token $301d
	 .text $88,"UPPER$("  ; token $301e
	 .text $87,"LEFT$("   ; token $301f
	 .text $86,"MID$("    ; token $3020
	 .text $88,"RIGHT$("  ; token $3021
	 .text $87,"INSTR("   ; token $3022
	 .text $87,"INKEY("   ; token $3023
	 .text $92,","        ; token $3224
	 .text $92,";"        ; token $3225
	 .text $92,":"        ; token $3226
	 .text $92,"("        ; token $3227
	 .text $92,")"        ; token $3228
	 .text $92,"'"        ; token $3229
	 .text $c3,"TO"       ; token $382a
	 .text $c5,"STEP"     ; token $382b
	 .text $f4,"REM"      ; token $3e2c
	 .text $f4,"LET"      ; token $3e2d
	 .text $f7,"ASSERT"   ; token $3e2e
	 .text $f4,"END"      ; token $3e2f
	 .text $f4,"RUN"      ; token $3e30
	 .text $f5,"STOP"     ; token $3e31
	 .text $f6,"CLEAR"    ; token $3e32
	 .text $f4,"DIM"      ; token $3e33
	 .text $f8,"COLLECT"  ; token $3e34
	 .text $f4,"CLS"      ; token $3e35
	 .text $f6,"PRINT"    ; token $3e36
	 .text $f5,"GOTO"     ; token $3e37
	 .text $f6,"GOSUB"    ; token $3e38
	 .text $f7,"RETURN"   ; token $3e39
	 .text $f3,"ON"       ; token $3e3a
	 .text $f5,"ELSE"     ; token $3e3b
	 .text $f5,"POKE"     ; token $3e3c
	 .text $f5,"DOKE"     ; token $3e3d
	 .text $f5,"LOKE"     ; token $3e3e
	 .text $f5,"LIST"     ; token $3e3f
	 .text $f5,"LINK"     ; token $3e40
	 .text $e7,"REPEAT"   ; token $3c41
	 .text $e6,"WHILE"    ; token $3c42
	 .text $e3,"IF"       ; token $3c43
	 .text $e4,"FOR"      ; token $3c44
	 .text $d5,"WEND"     ; token $3a45
	 .text $d6,"UNTIL"    ; token $3a46
	 .text $d5,"THEN"     ; token $3a47
	 .text $d6,"ENDIF"    ; token $3a48
	 .text $d5,"NEXT"     ; token $3a49
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
instrlparenTokenID               = $3022
inkeylparenTokenID               = $3023
commaTokenID                     = $3224
semicolonTokenID                 = $3225
colonTokenID                     = $3226
lparenTokenID                    = $3227
rparenTokenID                    = $3228
squoteTokenID                    = $3229
toTokenID                        = $382a
stepTokenID                      = $382b
remTokenID                       = $3e2c
letTokenID                       = $3e2d
assertTokenID                    = $3e2e
endTokenID                       = $3e2f
runTokenID                       = $3e30
stopTokenID                      = $3e31
clearTokenID                     = $3e32
dimTokenID                       = $3e33
collectTokenID                   = $3e34
clsTokenID                       = $3e35
printTokenID                     = $3e36
gotoTokenID                      = $3e37
gosubTokenID                     = $3e38
returnTokenID                    = $3e39
onTokenID                        = $3e3a
elseTokenID                      = $3e3b
pokeTokenID                      = $3e3c
dokeTokenID                      = $3e3d
lokeTokenID                      = $3e3e
listTokenID                      = $3e3f
linkTokenID                      = $3e40
repeatTokenID                    = $3c41
whileTokenID                     = $3c42
ifTokenID                        = $3c43
forTokenID                       = $3c44
wendTokenID                      = $3a45
untilTokenID                     = $3a46
thenTokenID                      = $3a47
endifTokenID                     = $3a48
nextTokenID                      = $3a49
