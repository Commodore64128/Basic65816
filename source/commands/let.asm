; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		let.asm
;		Purpose : 	Assignment Statement
;		Date :		8th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

Function_Let: ;; let
		lda 	(DCodePtr)					; get the first token, for typing.
		pha 
		jsr 	VariableFind 				; find the variable
		sta 	DVariablePtr 				; save where it is.
		bcs 	_FLetFound 					; skip if found.
		;
		;		Couldn't find it, so create variable at this position
		;
		pla 								; get and push the first token again.
		pha
		and 	#$1000 						; if it is an array, you can't autoinstantiate
		bne 	_FLError					; arrays, so this causes an error.
		;
		ldy 	DCodePtr 					; Y is the address of the name
		lda 	#1 							; A = 1 indicates we want one data element only, simple value.
		jsr 	VariableCreate 				; create it.
		sta 	DVariablePtr 				; save the data address.
		;
_FLSkipToken:
		lda 	(DCodePtr) 					; skip over the token
		inc 	DCodePtr
		inc 	DCodePtr
		and 	#$0800 						; if there is a continuation 
		bne 	_FLSkipToken
_FLetFound:	
		;
		;		Check to see if there is indexing by examining the first token.
		;		The first token is on the stack, the variable data address is in DVariablePtr
		;		This is the record+4 value, which is the data for non array types, and the
		;		array size for array types.
		;
		pla 								; get and save the first token.
		pha
		tay 								; put it in Y
		and 	#$1000						; is it an array ?
		beq 	_FLetNotArray
		;
		;		Do the indexing
		;
		lda 	DVariablePtr 				; variable pointer into A, first token in A
		jsr 	VariableSubscript			; index calculation
		sta 	DVariablePtr 				; and write it back.
		;		
_FLetNotArray: 
		ply 								; get the first token into Y
		lda 	DVariablePtr 				; save the target address on the stack.
		pha 
		phy 								; save the first token on the stack.
		;
		;		Now the first token (1st) and the variable address (2nd) is on the stack
		;		skip the =, evaluate the RHS and store the result.
		;
		lda 	#equalTokenID 				; check the = and skip it.
		jsr 	ExpectToken
		pla 								; restore the first token.
		and 	#$2000 						; check the type bit
		bne 	_FLetString 				; skip if string.
		;
		;		Integer Assignment
		;
		jsr 	EvaluateInteger 			; get an integer
		ply 								; get address in Y
		lda 	EXSValueL+0,x				; get the low word.
		sta 	$0000,y 					; save in variable low.
		lda 	EXSValueH+0,x 				; get the high word.
		sta 	$0002,y 					; save that
		rts 
		;
		;		String assignment
		;
_FLetString:
		jsr 	EvaluateString 				; get a string.
		lda 	EXSValueL+0,x				; get the low word, the address
		jsr 	StringMakeConcrete 			; make a copy of it in permanent store.
		ply 								; get address		
		sta 	$0000,y 					; save in variable low.
		rts

_FLError:	
		#error 	"Undefined array"