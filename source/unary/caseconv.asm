; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		caseconv.asm
;		Purpose : 	Case Conversion
;		Date :		14th July 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;										Upper$(<string>)
;
; *******************************************************************************************

Function_UPPER:	;; upper$(
		jsr 	ResetTypeString 			; returns a string.
		jsr 	EvaluateNextString 			; evaluate a string.
		pha
		jsr 	ExpectRightBracket 			; close call.
		jsr		StringTempAllocate 			; allocate memory for it
		pla
		jsr 	StringCreateCopy 			; create a copy of it.
		;
		lda 	DStartTempString 			; A = start of temporary string.
		sta 	EXSValueL+0,x
		tay 								; address in Y
		stz 	EXSValueH+0,x
		;
		phx 								; save X
		lda 	(DStartTempString)			; get string length
		and 	#$00FF 						
		beq 	_FUPExit
		tax 								; put in X
_FUPLoop:
		iny 								; increment and load character
		lda 	$0000,y
		and 	#$00FF
		cmp 	#"a" 						; check range
		bcc 	_FUPNoChange
		cmp 	#"z"+1
		bcs 	_FUPNoChange
		sec 								; shift case
		sbc 	#32
		sep 	#$20 						; write back
		sta 	$0000,y
		rep 	#$20
_FUPNoChange:
		dex 								; do X times
		bne 	_FUPLoop			
_FUPExit:
		plx 								; restore X
		rts

; *******************************************************************************************
;
;										Lower$(<string>)
;
; *******************************************************************************************

Function_LOWER:	;; lower$(
		jsr 	ResetTypeString 			; returns a string.
		jsr 	EvaluateNextString 			; evaluate a string.
		pha
		jsr 	ExpectRightBracket 			; close call.
		jsr		StringTempAllocate 			; allocate memory for it
		pla
		;
		jsr 	StringCreateCopy 			; create a copy of it.
		lda 	DStartTempString 			; A = start of temporary string.
		sta 	EXSValueL+0,x
		tay 								; address in Y
		stz 	EXSValueH+0,x
		;
		phx 								; save X
		lda 	(DStartTempString)			; get string length
		and 	#$00FF 						
		beq 	_FLOExit
		tax 								; put in X
_FLOLoop:
		iny 								; increment and load character
		lda 	$0000,y
		and 	#$00FF
		cmp 	#"A" 						; check range
		bcc 	_FLONoChange
		cmp 	#"Z"+1
		bcs 	_FLONoChange
		clc 								; shift case
		adc 	#32
		sep 	#$20 						; write back
		sta 	$0000,y
		rep 	#$20
_FLONoChange:
		dex 								; do X times
		bne 	_FLOLoop			
_FLOExit:
		plx 								; restore X
		rts
