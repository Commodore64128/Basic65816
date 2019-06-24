; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		string.asm
;		Purpose : 	String split routines
;		Date :		15th July 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									left$(string$,n)
;
; *******************************************************************************************

Function_LEFT: 	;; left$(
		jsr 	ResetTypeString 			; returns a string.
		jsr 	EvaluateNextString 			; get the value you are absoluting
		pha 								; save string on stack.
		jsr 	ExpectComma 				; get count
		jsr 	EvaluateNextInteger
		cpy 	#0 							; can't be high
		bne 	FNStringParameter
		sta 	DTemp1 						; save count.
		jsr 	ExpectRightBracket
		;
		ply 								; Y points to string.
		lda 	$0000,y 					; get length of string
		and 	#$00FF 						
		beq 	FNStringEmpty 				; return empty if zero length anyway.
		cmp 	DTemp1 						; compare current vs required length
		beq 	FNStringY 					; return string in Y if current len = required len.
		bcc 	FNStringY 					; if current < required return whole thing.
		;
		iny 								; take from here - start of string
		bra 	FNDTemp1Characters

; *******************************************************************************************
;
;									right$(string$,n)
;
; *******************************************************************************************

Function_RIGHT: 	;; right$(
		jsr 	ResetTypeString 			; returns a string.
		jsr 	EvaluateNextString 			; get the value you are absoluting
		pha 								; save string on stack.
		jsr 	ExpectComma 				; get count
		jsr 	EvaluateNextInteger
		cpy 	#0 							; can't be high
		bne 	FNStringParameter
		sta 	DTemp1 						; save count.
		jsr 	ExpectRightBracket
		;
		ply 								; Y points to string.
		lda 	$0000,y 					; get length of string
		and 	#$00FF 						
		beq 	FNStringEmpty 				; return empty if zero length anyway.
		cmp 	DTemp1 						; compare current vs required length
		beq 	FNStringY 					; return string in Y if current len = required len.
		bcc 	FNStringY 					; if current < required return whole thing.
		;
		sec 								; current-required is the number to skip
		sbc 	DTemp1 
		sta 	DTemp1+2
		tya
		clc
		adc 	DTemp1+2
		tay
		iny 								; +1 for the count.
		;
		bra 	FNDTemp1Characters

; *******************************************************************************************
;
;									Generic support stuff
;
; *******************************************************************************************

		;
		;		Output DTemp1 characters to a string, starting from Y
		;
FNDTemp1Characters:		
		lda 	DTemp1 						; we need this big a string.
		beq 	FNStringEmpty 				; if zero, return empty string.
		jsr 	StringTempAllocate
		pha 								; save the address
_FND1Loop:
		lda 	$0000,y 					; character to copy		
		jsr 	StringWriteCharacter 		
		iny
		dec 	DTemp1 						; DTemp1 times
		bne 	_FND1Loop
		ply 								; string address in Y
		bra 	FNStringY
		;
		;		Return empty string.
		;
FNStringEmpty:
		lda 	#0 							; return an empty string.
		jsr 	StringTempAllocate 			; put address of it in Y
		tay
		;
		;		Return string whose address is in Y.
		; 
FNStringY:
		tya
		sta 	EXSValueL+0,x
		stz 	EXSValueH+EXSNext,x
		rts

FNStringParameter:
		#error 	"Bad String Operation"

; *******************************************************************************************
;
;									mid$(string$,n[,n1])
;
; *******************************************************************************************

Function_MID: 	;; mid$(
		jsr 	ResetTypeString 			; returns a string.
		jsr 	EvaluateNextString 			; get the value you are absoluting
		pha 								; save string on stack.
		jsr 	ExpectComma 				; get offset (n)
		jsr 	EvaluateNextInteger
		cpy 	#0 							; can't be high
		bne 	FNStringParameter
		cmp 	#0
		beq 	FNStringParameter 			; or zero
		pha 								; save start position on stack.
		lda 	#255 						; default third parameter is 255 e.g. whole string
		sta 	DTemp1
		lda 	(DCodePtr) 					; is there a comma
		cmp 	#commaTokenID
		bne 	_FMINoThird
		inc 	DCodePtr 					; skip the comma
		inc 	DCodePtr
		jsr 	EvaluateNextInteger 		; how many to do (n1)
		cpy 	#0 							; can't be high
		bne 	FNStringParameter
		sta 	DTemp1 						; save in DTemp1 (characters to count)
_FMINoThird:
		jsr 	ExpectRightBracket
		pla 								; get offset position
		sta 	DTemp2 							
		ply 								; get address of string in Y
		;
		lda		$0000,y 					; get length
		and 	#$00FF
		cmp 	DTemp2 						; check length of string vs offset position 				
		bcc 	FNStringEmpty 				; if length <= offset position then return ""
		;
		sec 								; calculate number of characters left after
		sbc 	DTemp2 						; offset
		inc 	a 							; there is one more because of index starts at 1.
		cmp 	DTemp1 						; available -- chars required.
		bcs 	_FMISufficient
		sta 	DTemp1 						; if available < chars required, only copy those
_FMISufficient:
		tya 								; get address
		clc
		adc 	DTemp2 						; add the offset, the extra 1 (index) skips length
		tay 								; put in Y
		brl 	FNDTemp1Characters			; and copy them.
