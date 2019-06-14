; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		dim.asm
;		Purpose : 	Assignment Statement
;		Date :		11th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

Function_Dim: ;; dim
		lda 	(DCodePtr)					; get the first token, for typing.
		and 	#IDArrayMask 				; is it an array ?
		beq		_FDIMNotArray 				; no, error.
		jsr 	VariableFind 				; try to find it.
		bcs 	_FDIMExists 				; if it does, that's an error.
		;
		lda 	DCodePtr 					; push the variable identifier address on the stack
		pha
		lda 	DHashTablePtr 				; push the hash value on the stack as well, as evaluateinteger might change it
		pha
_FDIMSkip:
		lda 	(DCodePtr)					; skip over the token.
		inc 	DCodePtr
		inc 	DCodePtr
		and 	#IDContMask
		bne 	_FDIMSkip 
		;
		jsr 	EvaluateInteger 			; evaluate the size
		jsr 	ExpectRightBracket 			; check the ) following.
		;
		cpy 	#0 							; if MSWord is non zero, obviously it's a non starter.
		bne 	_FDIMSize
		cmp 	#0 							; need at least one element.
		beq 	_FDIMSize
		;
		ply 								; restore HashTablePtr
		sty 	DHashTablePtr
		;
		ply 								; so now A is the high index, Y points to the token
		jsr 	VariableCreate 				; create the variable.
		;
		lda 	(DCodePtr)					; look at next character
		cmp 	#commaTokenID 				; if not a comma, exit
		bne 	_FDIMExit
		inc 	DCodePtr 					; skip comma
		inc 	DCodePtr
		bra 	Function_DIM 				; and do another 
_FDIMExit:		
		rts

_FDIMNotArray:
		#error 	"Bad DIM"
_FDIMExists:
		#error 	"Cannot Redimension"
_FDIMSize:
		#error 	"DIM too large"
		