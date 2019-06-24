; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		simpleunary.asm
;		Purpose : 	Simple unary functions.
;		Date :		6th July 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									len s => length
;
; *******************************************************************************************

Function_Len: ;; len(
		jsr 	ResetTypeInteger 			; returns an integer
		jsr 	EvaluateNextString 			; get the value you are absoluting
		jsr 	ExpectRightBracket 			; check )
		ldy 	EXSValueL+EXSNext,x 		; address of string.
		lda 	$0000,y 					; get the string length
		and 	#$00FF 						; as a byte
		sta 	EXSValueL+0,x 				; and return it
		stz 	EXSValueH+0,x 			
		rts

; *******************************************************************************************
;
;									abs s => absolute value
;
; *******************************************************************************************

Function_Abs: ;; abs( 
		jsr 	ResetTypeInteger 			; returns an integer
		jsr 	EvaluateNextInteger 		; get the value you are absoluting
		jsr 	ExpectRightBracket 			; check )
		lda 	EXSValueH+EXSNext,x 		; get sign of result from the upper word.
		bmi 	_FAbsNegative 				; negate it if negative
		sta 	EXSValueH+0,x 				; otherwise just copy it.
		lda 	EXSValueL+EXSNext,x
		sta 	EXSValueL+0,x
		rts		
_FAbsNegative:
		sec 								; copy 0 - 2nd stack => 1st stack.
		lda 	#0
		sbc 	EXSValueL+EXSNext,x
		sta 	EXSValueL+0,x		
		lda 	#0
		sbc 	EXSValueH+EXSNext,x
		sta 	EXSValueH+0,x		
		rts

; *******************************************************************************************
;
;										sign of number
;
; *******************************************************************************************

Function_Sgn: ;; sgn( 
		jsr 	ResetTypeInteger 			; returns integer
		jsr 	EvaluateNextInteger 		; get an integer
		jsr 	ExpectRightBracket 			; check )
		stz 	EXSValueL+0,x 				; zero the result
		stz 	EXSValueH+0,x
		lda 	EXSValueH+EXSNext,x 		; get sign of result from high bit of upper word.
		bmi 	_FSgnNegative 				; set to -1 if signed
		ora 	EXSValueL+EXSNext,x 		; exit if zero as we already reset it.
		beq 	_FSgnExit
		;
		inc 	EXSValueL+0,x 				; > 0 so make result 1 if positive and non-zero
_FSgnExit:		
		rts
		;
_FSgnNegative:
		lda 	#$FFFF 						; set the return value to -1 as negative.
		sta 	EXSValueL+0,x		
		sta 	EXSValueH+0,x		
		rts

; *******************************************************************************************
;
;										random integer
;
;										 (Galois LFSR)
; *******************************************************************************************

Function_Random: ;; rnd(
		jsr 	ExpectRightBracket 			; check )
		jsr 	ResetTypeInteger
		lda 	DRandom 					; check for non-zero 
		ora 	DRandom+2 					; they don't like these :)
		bne 	_Rnd_NotZero
		lda 	#$B5 						; initialise it to the same value. 
		sta 	DRandom 
		lda 	#$EA
		sta 	DRandom+2
_Rnd_NotZero:
		jsr 	_Rnd_Process 				; call randomiser twice
		sta 	EXSValueH+0,x
		jsr 	_Rnd_Process
		sta 	EXSValueL+0,x
		rts

_Rnd_Process:
		asl 	DRandom 					; shift right, exit 
		rol 	DRandom+2
		bcc 	_Rnd_Exit

		lda 	DRandom 					; taps effectively
		eor 	#$D454
		sta 	DRandom
		lda 	DRandom+2
		eor 	#$55D5
		sta 	DRandom+2
_Rnd_Exit:		
		lda 	DRandom
		eor 	DRandom+2
		rts

; *******************************************************************************************
;
;									chr$(<expr>)
;
; *******************************************************************************************

Function_Chr: ;; chr$(
		jsr 	ResetTypeString 			; returns a string
		jsr 	EvaluateNextInteger 		; get integer
		jsr 	ExpectRightBracket 			; check )
		cpy 	#0 							; must be 0-255
		bne 	_FCHBad 
		pha  								; save char # on stack
		lda 	#1 							; allocate a single character string
		jsr 	StringTempAllocate
		pla 								; restore character number
		jsr 	StringWriteCharacter 		; write it out.
		lda 	DStartTempString 			; return the string address
		sta 	EXSValueL+0,x 				; and return that.
		stz 	EXSValueH+0,x
		rts
_FCHBad:#error 	"Bad value for chr$()"

; *******************************************************************************************
;
;									asc(<expr>)
;
; *******************************************************************************************

Function_Asc: ;; asc(
		jsr 	ResetTypeInteger 			; returns an integer
		jsr 	EvaluateNextString 			; get string
		jsr 	ExpectRightBracket 			; check )
		tay 								; string address in Y
		lda 	$0000,y 					; check length non zero
		and 	#$00FF
		beq 	_FASBad 					; what does ASC("") do ? return 0 - error here.
		;
		lda 	$0001,y 					; get first char
		and 	#$00FF 						; mask it
		sta 	EXSValueL+0,x 				; and return that.
		stz 	EXSValueH+0,x
		rts
_FASBad:#error 	"Bad value for asc()"

; *******************************************************************************************
;
;										spc(expr)
;
; *******************************************************************************************

Function_SPC: ;; spc(
		jsr 	ResetTypeString 			; returns a string
		jsr 	EvaluateNextInteger 		; get integer, which is the length.
		jsr 	ExpectRightBracket 			; check )
		cpy 	#0 							; must be 0-255
		bne 	_FSPBad 
		pha 								; save length
		jsr 	StringTempAllocate 			; allocate character space
		ply 								; get count in Y
		beq 	_FSPExit 					; if zero, just empty string
_FSPCopy:
		lda 	#" "						; space character		
		jsr 	StringWriteCharacter 		; write it out.
		dey
		bne 	_FSPCopy	 				; do it Y times
_FSPExit:		
		lda 	DStartTempString 			; return that address
		sta 	EXSValueL+0,x
		stz 	EXSValueH+0,x
		rts
_FSPBad:#error 	"Bad value for spc()"


; *******************************************************************************************
;
;											INKEY()
;					
; *******************************************************************************************

Function_Inkey: ;; inkey(
		jsr 	ExpectRightBracket 			; check )
		jsr 	ResetTypeInteger
		jsr 	HWInkey 					; read current key
		sta 	EXSValueL+0,x
		stz 	EXSValueH+0,x
		rts
