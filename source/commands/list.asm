; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		list.asm
;		Purpose : 	LIST / Detokenise
;		Date :		15th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

Command_List: 	;; list

	lda 	#255 							; create a buffer to use.
	jsr 	StringTempAllocate
	sta 	DListBuffer						; save buffer.
	stz 	DIndent 						; reset the indents
	stz 	DIndent2
	stz 	DTemp4+0 						; low number
	lda 	#$7FFF
	sta 	DTemp4+2 						; high number.
	;
	;		Decode command line
	;
	lda 	(DCodePtr)						; anything else ?
	beq 	_CLIList
	cmp 	#colonTokenID
	beq 	_CLIList
	cmp 	#commaTokenID 					; is it , something.
	beq 	_CLIComma	
	jsr 	EvaluateNextInteger 			; yes, first number
	cpy 	#0 
	bne 	_CLIError
	sta 	DTemp4+0 						; which becomes the first and the last :)
	sta 	DTemp4+2
	lda 	(DCodePtr) 						; , follows ?
	cmp 	#commaTokenID
	bne 	_CLIList
_CLIComma:	
	jsr 	ExpectComma 					; skip comma
	lda 	(DCodePtr)
	beq 	_CLIToEnd 						; if $0000 or :, then list to end.
	cmp 	#colonTokenID
	beq 	_CLIToEnd
	jsr 	EvaluateNextInteger 			; get end line.
	sta 	DTemp4+2
	cpy 	#0 								; if legal continue.
	beq 	_CLIList
_CLIError:
	brl 	SyntaxError

_CLIToEnd:
	lda 	#$7FFF
	sta 	DTemp4+2
_CLIList:
	;
	;		Start listing - scan the whole program to track structure, only output the
	;		lines we want.
	;
	lda 	#Block_ProgramStart 			; work out program start.
	clc
	adc 	DBaseAddress
	tay 									; put in Y
_CLINextLine:
	lda 	$0000,y 						; check end of program
	beq 	_CLIExit
	;
	jsr 	ScanIndent  					; scan for formatting.
	;
	lda 	$0002,y 						; get line number.
	cmp 	DTemp4+0 						; check if it is in range.
	bcc 	_CLIFollowLink 
	cmp 	DTemp4+2
	beq 	_CLIShowLine
	bcs 	_CLIFollowLink
_CLIShowLine:
	;
	lda 	DListBuffer
	jsr 	Detokenise 						; detokenise it
	phy
	tay 									; print buffer out
	jsr 	PrintBasicString
	jsr 	HWNewLine
	ply 									; get address
_CLIFollowLink:	
	tya 									; follow link
	clc
	adc 	$0000,y
	tay
	jsr 	HWCheckBreak 					; break key pressed.
	beq 	_CLINextLine
_CLIExit:
	stz 	DIndent 						; reset the indent
	rts


; *******************************************************************************************
;
;						Detokenise line at Y into buffer at A.
;
; *******************************************************************************************

Detokenise:
	pha
	phx
	phy
	sta 	DStartTempString 				; set the temp function pointers to this buffer
	inc 	a
	sta 	DCurrentTempString
	stz		DConstantShift
	lda 	#$0000 							; write zero, clearing the string size.
	sta 	(DStartTempString)
	;
	;		Encode the line number.
	;
	phy 									; save Y
	lda 	$0002,y 						; read the line number.
	ldy 	#$0000 							; the high byte is 0
	ldx 	#10 							; in BASE 10.
	jsr 	ConvertToStringAlreadyAllocated	; convert to string in situ.
	lda 	DIndent 						; work out indent, which is the smaller of this/last
	cmp 	DIndent2
	bcc 	_DTKSmaller
	lda 	DIndent2
_DTKSmaller:	
	asl 	a
	adc 	#6
	sta 	DTemp1
_DTKPadLineNo:
	lda 	#32 							; pad out to 6+indent*2 characters.
	jsr 	StringWriteCharacter
	lda 	(DStartTempString)
	and 	#$00FF
	cmp 	DTemp1
	bne 	_DTKPadLineNo
	;
	pla 									; get pointer
	clc 									; point to start of line
	adc 	#4
	tay 									; put back in Y.
	;
	;		Main loop
	;
_DTKMainLoop:	
	lda 	$0000,y 						; look at first token.
	bne 	_DTKNotZero 					; if zero, return.
	;
	ply
	plx
	pla
	rts
	;
_DTKNotZero:
	cmp 	#$0100 							; is it a quoted string $0000-$00FF
	bcs 	_DTKNotString
	;
	;		Decode a quoted string
	;
	phy										; save token address on stack. 		
	iny 									; skip first token
	iny
	lda 	#34 							; write out opening quote
	jsr 	StringWriteCharacter
	tya 									; copy the string out.
	jsr 	StringCreateCopy 	
	lda 	#34 							; write out closing quote
	jsr 	StringWriteCharacter
	pla 									; get token, which is its own offset
	tay
	clc
	adc 	$0000,y
	tay
	bra 	_DTKMainLoop
	;
_DTKNotString:
	cmp 	#$2000							; if $1000-$1FFF then constant shift
	bcs 	_DTKNotShift
	;
	;		Handle constant shift.
	;
	and 	#$0FFF 							; store in shift
	sta 	DConstantShift
	iny 									; skip token.
	iny
	bra 	_DTKMainLoop
	;
_DTKNotShift:
	cmp 	#$4000 							; if $2000-$3FFF it's a token.
	bcs 	_DTKNotKeyword
	iny 									; skip over token
	iny
	jsr 	_DTKDecodeKeyword 				; decode it.
	bra 	_DTKMainLoop
_DTKNotKeyword:	
	cmp 	#$C000							; if $4000-$BFFF it's a (possibly shifted) constant.
	bcs 	_DTKIdentifier 					; if $C000-$CFFF it's an identifier.
	;
	;		Handle constant
	;
	phy 									; save pointer
	sec  									; shift it in the range 0-32767
	sbc 	#$4000
	asl 	a 								; shift it left, losing bit 15
	lsr 	DConstantShift 					; shift constant right into carry.
	ror 	a 								; rotate that into the constant value
	ldy 	DConstantShift 					; YA number
	ldx 	#10 							; output base.
	jsr 	ConvertToStringAlreadyAllocated	; convert to string in situ.
	stz 	DConstantShift
	ply 									; restore pointer
	iny 									; skip token.
	iny
	bra 	_DTKMainLoop
	;
	;		Handle identifier.
	;
_DTKIdentifier:
	pha 									; save token for typing at end
_DTKILoop:
	lda 	$0000,y 						; get token
	jsr 	_DTKIDecodeToken 				; decode it.
	lda 	$0000,y 						; get the token again
	iny 									; skip it
	iny
	and 	#IDContMask 					; continuation ?
	bne 	_DTKILoop

	pla 									; add $( as required.
	pha 									; comes from the first token.
	and 	#IDTypeMask
	beq 	_DTKINotString
	lda 	#"$"
	jsr 	StringWriteCharacter
_DTKINotString:
	pla
	and 	#IDArrayMask
	beq 	_DTKINotArray
	lda 	#"("
	jsr 	StringWriteCharacter
_DTKINotArray:
	brl 	_DTKMainLoop 
;
;		Decode token A into alphanumerics.
;
_DTKIDecodeToken:
	phy
	and		#$07FF 							; mask off the identifier bit.
	ldy 	#-1 							; first, divide by 45 getting remainder.
_DTKIDivide:
	sec
	sbc 	#45
	iny	
	bcs 	_DTKIDivide
	adc 	#45
	jsr 	_DTKIOutA 						; output low.
	tya 		
	jsr 	_DTKIOutA 						; output high
	ply
	rts

_DTKIOutA:
	ora 	#$0000 							; exit if 0
	beq 	_DTKIOutExit
	cmp 	#27 							; skip if A-Z
	bcc 	_DTKIOutAlpha
	sec  									; adjust for 0-9
	sbc 	#$4B
_DTKIOutAlpha:
	clc										; adjust for A-Z
	adc 	#96
	jsr 	StringWriteCharacter
_DTKIOutExit:
	rts
;
;		Decode Keyword A
;
_DTKDecodeKeyword:
	pha
	phx
	phy
	;
	;		Decide if it is keyword, keyword + or keyword -, which need formatting.
	;
	tay 									; save token ID in Y
	and 	#$1800 							; is it a keyword
	eor 	#$1800 							; now zero if it is.
	pha 									; save this flag on a stack
	phy 									; save the token ID

	cmp 	#0 								; check if spacing perhaps required.
	bne 	_DTKNotSpecial1

	ldy 	DCurrentTempString 				; what was the last character out ?
	dey
	lda 	$0000,y
	and 	#$00FF
	cmp 	#" " 							; if space or colon, not needed/
	beq 	_DTKNotSpecial1
	cmp 	#":"
	beq 	_DTKNotSpecial1
	lda 	#" "							; output space otherwise.
	jsr 	StringWriteCharacter
_DTKNotSpecial1:

	pla
	and 	#$01FF 							; this is the keyword number.
	tay 									; into Y.
	ldx 	#0 								; offset into the ROM table, token text
_DTKDWorkThrough:
	dey 									; reached the token (tokens start at 1 in text table)
	beq 	_DTKDFound
	stx 	DTemp1
	lda 	TokenText,x 					; read the type/skip byte.
	and 	#$000F 							; bytes to skip
	clc
	adc 	DTemp1
	tax
	bra 	_DTKDWorkThrough
	;
_DTKDFound:	
	
	lda 	TokenText,x 					; get skip
	and 	#$000F 					 		; length is skip -1
	dec 	a
	tay 									; put in Y
_DTKOut:
	lda 	TokenText+1,x 					; output it.
	and 	#$00FF
;	cmp 	#"A"
;	bcc 	_DTKNotLC
;	cmp 	#"Z"+1
;	bcs 	_DTKNotLC
;	clc
;	adc 	#32
_DTKNotLC:
	jsr 	StringWriteCharacter
	inx
	dey
	bne 	_DTKOut

	pla 									; trailing space.
	bne 	_DTKNotSpecial2
	lda 	#" "
	jsr 	StringWriteCharacter
_DTKNotSpecial2:

	ply
	plx
	pla
	rts

; *******************************************************************************************
;
;		  At the line beginning with Y, scan it for keywords+ keywords- adjust DIndent
;
; *******************************************************************************************

ScanIndent:
	pha
	phy
	lda 	DIndent  						; save the old indentation
	sta 	DIndent2
	tya
	clc 									; point to code.
	adc 	#4
	tay
_SILoop:
	lda 	$0000,y 						; get token
	beq 	_SIExit
	cmp 	#$0100							; is it a string ?
	bcs 	_SICheckKeyword
	tya 									; skip string.
	clc
	adc 	$0000,y
	tay
	bra 	_SILoop
_SICheckKeyword: 							; check if keyword
	and 	#$E000
	cmp 	#$2000
	beq 	_SIFoundKeyword
_SIAdvance:
	iny 									; if not, loop round.
	iny
	bra 	_SILoop
	;
_SIFoundKeyword:
	lda 	$0000,y 						; get keyword
	and 	#15<<9							; extract type
	cmp 	#14<<9
	beq 	_SIKeyPlus
	cmp 	#13<<9 							; and adjust DIndent appropriately.
	bne 	_SIAdvance
	dec 	DIndent
	bpl 	_SIAdvance
	stz 	DIndent
	bra 	_SIAdvance
_SIKeyPlus:
	inc 	DIndent
	bra 	_SIAdvance

_SIExit:	
	ply
	pla
	rts