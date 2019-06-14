; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		for.asm
;		Purpose : 	For / Next structure
;		Date :		14th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									FOR instruction
;
; *******************************************************************************************

Command_FOR:	;; for
		nop
		lda 	(DCodePtr)					; look at first word
		and 	#(IDTypeMask+IDArrayMask)	; check to see if it is type $00 e.g. integer variable
		bne		_CFOBad
		jsr 	VariableFind 				; try to find variable
		bcs 	_CFOExists 					
		;
		ldy 	DCodePtr 					; Y is the address of the name
		lda 	#0 							; A = 0 because it's not an array.
		jsr 	VariableCreate 				; create it.
_CFOExists:
		pha 								; push variable address on stack
		lda 	#equalTokenID 				; check for = 
		jsr 	ExpectToken
		;
		jsr 	EvaluateInteger 			; this is the start value
		tyx 								; put high value in X
		ply 								; address in Y
		sta 	$0000,y
		stx 	$0002,y



_CFOBad:
		#error	"Bad FOR variable"