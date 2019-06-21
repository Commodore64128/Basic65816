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
		;
		;		Check that we are dimensioning an array
		;
		lda 	(DCodePtr)					; get the first token, for typing.
		and 	#IDArrayMask 				; is it an array ?
		beq		_FDIMNotArray 				; no, error.
		;
		;		Check to see not redimensioning an array
		;
		jsr 	VariableFind 				; try to find it.
		bcs 	_FDIMExists 				; if it does, that's an error.
		;
		;		Push the address of the identifier token, and its hash pointer on the stack.
		;
		lda 	DCodePtr 					; push the variable identifier address on the stack
		pha
		lda 	DHashTablePtr 				; push the hash value on the stack as well, as evaluateinteger might change it
		pha
		;
		;		Skip over the token, so we can calculate the array size
		;
_FDIMSkip:
		lda 	(DCodePtr)					; skip over the token, so we can evaluate the array size.
		inc 	DCodePtr
		inc 	DCodePtr
		and 	#IDContMask
		bne 	_FDIMSkip 
		;
		;		Get and validate the array size
		;
		jsr 	EvaluateInteger 			; evaluate the size
		jsr 	ExpectRightBracket 			; check the ) following.
		;
		cpy 	#0 							; if MSWord is non zero, obviously it's a non starter.
		bne 	_FDIMSize
		cmp 	#0 							; need at least one element.
		beq 	_FDIMSize
		;
		;		Restore the hash pointer and the identifier token address
		;
		ply 								; restore HashTablePtr for the array variable.
		sty 	DHashTablePtr
		ply 								; restore DCodePtr to point to the identifier.
		sty 	DCodePtr 				
		;
		;		Now create the array
		;
		jsr 	VariableCreateNew 			; create the variable.
		;
		;		Skip over tokens until gone past the right bracket.
		;
_FDIMFindRight:
		lda 	(DCodePtr)
		inc 	DCodePtr
		inc 	DCodePtr
		cmp 	#rParenTokenID
		bne 	_FDIMFindRight		
		;
		;		If followed by a comma, go round again.
		;
		lda 	(DCodePtr)					; look at next character
		cmp 	#commaTokenID 				; if not a comma, exit
		bne 	_FDIMExit
		inc 	DCodePtr 					; skip comma
		inc 	DCodePtr
		bra 	Function_DIM 				; and do another 
_FDIMExit:		
		rts

		;
		;		Error Messages.
		;
_FDIMNotArray:
		#error 	"Bad DIM"
_FDIMExists:
		#error 	"Cannot Redimension"
_FDIMSize:
		#error 	"DIM too large"
		