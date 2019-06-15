; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		str.asm
;		Purpose : 	Integer to String.
;		Date :		11th July 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									str$(number,base)
;
; *******************************************************************************************

Function_Str: 	;; str$(
		jsr 	ResetTypeString 			; returns a string.
		jsr 	EvaluateNextInteger 		; get the value you are absoluting
		pha 								; save YA on the stack
		phy
		jsr 	VALGetBase 					; process , base (shared with STR$()) 	
		sta 	DSignCount		
		ply 								; YA is the number
		pla				
		phx
		ldx 	DSignCount 					; X is the base.
		jsr 	ConvertToString 			; convert it to a string.
		plx 								; restore X
		sta 	EXSValueL+0,x 				; save the result 
		stz 	EXSValueH+0,x
		rts

; *******************************************************************************************
;
;			Convert YA to string in base X, returns a string in temporary memory.
;
; *******************************************************************************************

ConvertToString:
		pha
		lda 	#34 						; enough space for Base 2.
		jsr 	StringTempAllocate 			; allocate space for return string.
		pla
ConvertToStringAlreadyAllocated:		
		phx 								; save X (base)
		sta 	DTemp3 						; save number in DTemp3
		sty 	DTemp3+2
		stx 	DSignCount 					; save base in DSignCount.

		lda 	DTemp3+2 					; is number -ve.
		bpl 	_CTSNotNegative
		lda 	#"-"						; output a minus character to the new string
		jsr 	CTSOutputA
		sec 								; negate DTemp3 which is the number
		lda 	#0 
		sbc 	DTemp3
		sta 	DTemp3
		lda 	#0 
		sbc 	DTemp3+2
		sta 	DTemp3+2
_CTSNotNegative:
		lda 	#1 							; push 32-bit 1 on stack, which is the first subtractor.
		pha
		lda 	#0
		pha
		lda 	DSignCount 					; reset DTemp1, the subtractor to the base value
		sta 	DTemp1
		stz 	DTemp1+2
		;
		;		Scale up subtractor (DTemp1), so it is more than the number (DTemp3)
		;
_CTSMultiplySubtractor:
		sec 								; check number vs subtractor
		lda 	DTemp3
		sbc 	DTemp1
		lda 	DTemp3+2
		sbc 	DTemp1+2
		bcc		_CTSScaledUp 				; if >= then scaled up.
		;
		lda 	DTemp1 						; push subtractor on the stack
		pha
		lda 	DTemp1+2
		pha	
		;
		lda 	DSignCount 					; multiply subtractor by base
		jsr 	MultiplyTemp1ByA 
		bcs 	_CTSScaledUp 				; if overflow, start subtracting.
		bra 	_CTSMultiplySubtractor 		; otherwise try the next x base.
		;
		;		Subtractor now >= number. Top of the pop-and-subtract loop.
		;
_CTSScaledUp:
		ply 								; YA contains the previous divider.
		pla
		cpy 	#0 							; has that divider reached one yet ?
		bne 	_CTSHasDigit
		cmp 	#1 							; if so, then we've just got that digit left.
		beq 	_CTSExit
_CTSHasDigit:
		sta 	DTemp2 						; save in DTemp2
		sty 	DTemp2+2
		ldx 	#0 							; this is the count.
_CTSSubLoop:		
		sec 								; subtract subtractor from number
		lda 	DTemp3
		sbc 	DTemp2
		tay 								; intermediate in Y
		lda 	DTemp3+2
		sbc 	DTemp2+2
		bcc 	_CTSFinishedSubtracting 	; if number < subtractor then completed this one.
		sta 	DTemp3+2 					; output the number to DTemp3.
		sty 	DTemp3 		
		inx 								; one more subtraction
		bra 	_CTSSubLoop 				; try it again.
		;
_CTSFinishedSubtracting:
		txa 								; convert to ASCII.
		jsr 	CTSOutputHexDigit 			; write that out.
		bra 	_CTSScaledUp 				; go pop the next subtactor and do that.
		;
_CTSExit:
		lda 	DTemp3 						; output last digit
		jsr 	CTSOutputHexDigit
		lda 	DStartTempString 			; return string address.
		plx 								; restore X.
		rts
		;
		;		Output one digit to the string.
		;
CTSOutputHexDigit:
		cmp 	#10 						; 0-9 are 48-56
		bcc 	_CTSNotLetter
		clc
		adc 	#65-58+32 					; shift for bases > 10
_CTSNotLetter:		
		clc 
		adc 	#48 
CTSOutputA:
		phy 								; save Y, set Y to current pointer
		ldy 	DCurrentTempString
		sta 	$0000,y 					; write out, with a following zero.
		sep 	#$20 						; save in 8 bit mode.
		lda 	(DStartTempString)			; increment character count.
		inc 	a
		sta 	(DStartTempString)
		rep 	#$20
		inc 	DCurrentTempString 			; advance the pointer.
		ply 								; restore Y and exit.
		rts

