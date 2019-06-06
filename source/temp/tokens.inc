;
;	Vector Jump table
;
CommandJumpTable:
	.word IllegalToken & $FFFF ; for the $0000 token.
	.word Binary_And               & $FFFF ; token $4001 "and"
	.word Binary_Or                & $FFFF ; token $4002 "or"
	.word Binary_Xor               & $FFFF ; token $4003 "xor"
	.word Binary_Less              & $FFFF ; token $4404 "<"
	.word Binary_Greater           & $FFFF ; token $4405 ">"
	.word Binary_Equals            & $FFFF ; token $4406 "="
	.word Binary_LessEqual         & $FFFF ; token $4407 "<="
	.word Binary_GreaterEqual      & $FFFF ; token $4408 ">="
	.word Binary_NotEquals         & $FFFF ; token $4409 "<>"
	.word Binary_Add               & $FFFF ; token $480a "+"
	.word Binary_Subtract          & $FFFF ; token $480b "-"
	.word Binary_Multiply          & $FFFF ; token $4c0c "*"
	.word Binary_Divide            & $FFFF ; token $4c0d "/"
	.word Binary_Modulus           & $FFFF ; token $4c0e "mod"
	.word Binary_ShiftRight        & $FFFF ; token $4c0f ">>"
	.word Binary_ShiftLeft         & $FFFF ; token $4c10 "<<"
	.word Function_Random          & $FFFF ; token $6011 "rnd()"
	.word Function_Sgn             & $FFFF ; token $6012 "sgn("
	.word Function_Abs             & $FFFF ; token $6013 "abs("
	.word Function_Len             & $FFFF ; token $6014 "len("
	.word IllegalToken             & $FFFF ; token $6415 ","
	.word IllegalToken             & $FFFF ; token $6416 ";"
	.word IllegalToken             & $FFFF ; token $6417 ":"
	.word IllegalToken             & $FFFF ; token $6418 "("
	.word IllegalToken             & $FFFF ; token $6419 ")"
	.word IllegalToken             & $FFFF ; token $7c1a "let"
	.word IllegalToken             & $FFFF ; token $781b "while"
	.word IllegalToken             & $FFFF ; token $741c "wend"

;
;	Token text table. Byte is typeID[7:4] length[3:0]
;
TokenText:
	 .text $04,"and"      ; token $4001
	 .text $03,"or"       ; token $4002
	 .text $04,"xor"      ; token $4003
	 .text $12,"<"        ; token $4404
	 .text $12,">"        ; token $4405
	 .text $12,"="        ; token $4406
	 .text $13,"<="       ; token $4407
	 .text $13,">="       ; token $4408
	 .text $13,"<>"       ; token $4409
	 .text $22,"+"        ; token $480a
	 .text $22,"-"        ; token $480b
	 .text $32,"*"        ; token $4c0c
	 .text $32,"/"        ; token $4c0d
	 .text $34,"mod"      ; token $4c0e
	 .text $33,">>"       ; token $4c0f
	 .text $33,"<<"       ; token $4c10
	 .text $86,"rnd()"    ; token $6011
	 .text $85,"sgn("     ; token $6012
	 .text $85,"abs("     ; token $6013
	 .text $85,"len("     ; token $6014
	 .text $92,","        ; token $6415
	 .text $92,";"        ; token $6416
	 .text $92,":"        ; token $6417
	 .text $92,"("        ; token $6418
	 .text $92,")"        ; token $6419
	 .text $f4,"let"      ; token $7c1a
	 .text $e6,"while"    ; token $781b
	 .text $d5,"wend"     ; token $741c
	.byte $00

;
;	Constants
;
andTokenID                       = $4001
orTokenID                        = $4002
xorTokenID                       = $4003
lessTokenID                      = $4404
greaterTokenID                   = $4405
equalTokenID                     = $4406
lessequalTokenID                 = $4407
greaterequalTokenID              = $4408
lessgreaterTokenID               = $4409
plusTokenID                      = $480a
minusTokenID                     = $480b
starTokenID                      = $4c0c
slashTokenID                     = $4c0d
modTokenID                       = $4c0e
greatergreaterTokenID            = $4c0f
lesslessTokenID                  = $4c10
rndlparenrparenTokenID           = $6011
sgnlparenTokenID                 = $6012
abslparenTokenID                 = $6013
lenlparenTokenID                 = $6014
commaTokenID                     = $6415
semicolonTokenID                 = $6416
colonTokenID                     = $6417
lparenTokenID                    = $6418
rparenTokenID                    = $6419
letTokenID                       = $7c1a
whileTokenID                     = $781b
wendTokenID                      = $741c
