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

Command_Let: ;; let
		;
		;		Find the variable that we are assigning to.
		;
		lda 	(DCodePtr)					; get the first token, for typing.
		pha  								; save on stack for later.
		jsr 	VariableFind 				; find the variable
		sta 	DVariablePtr 				; save where it is.
		bcs 	_FLetFound 					; skip if found.
		;
		;		Couldn't find it, so create variable at this position
		;		We cannot create arrays automagically (well we do not, we could !)
		;
		pla 								; get and push the first token again.
		pha
		and 	#IDArrayMask 				; if it is an array, you can't autoinstantiate it, you have to DIM it.
		bne 	_FLError					; arrays, so this causes an error.
		;
		jsr 	VariableCreate 				; create it as a single variable.
		sta 	DVariablePtr 				; save the data address.
		;
_FLetFound:	
		;
		;		Check to see if there is indexing by examining the first token of the identifier.
		;		The first token is on the stack, the variable data address is in DVariablePtr
		;		This is the record+4 value, which is the data for non array types, and the
		;		array size for array types.
		;
		pla 								; get and save the first token.
		pha
		and 	#IDArrayMask				; is it an array ?
		beq 	_FLetNotArray
		;
		;		Do the indexing
		;
		ldx		#EXSBase 					; in LET, so do it from the base stack.
		lda 	DVariablePtr 				; variable pointer into A, first token in A
		jsr 	VariableSubscript			; index calculation
		sta 	DVariablePtr 				; and write it back.
		;		
_FLetNotArray: 
		;
		;		Restore the first token, and push the target address on the stack, then the token
		;
		ply 								; get the first token into Y
		lda 	DVariablePtr 				; save the target address on the stack.
		pha 
		phy 								; save the first token on the stack.
		;
		;		Now the first token (1st) and the variable address (2nd) is on the stack
		;		skip the =, evaluate the RHS and store the result.
		;
		lda 	#equalTokenID 				; check the = and skip it.
		cmp 	(DCodePtr)
		bne 	_FLetMissingEquals
		inc 	DCodePtr
		inc 	DCodePtr
		pla 								; restore the first token.
		and 	#IDTypeMask 				; check the type bit
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
		ply 								; get address we are overwriting in Y - this is the
											; address in the variable space pointing to the string.
		jsr 	StringAssign 				; assign the string in memory.
		rts

_FLetMissingEquals:
		#error 	"Missing ="
_FLError:	
		#error 	"Undefined array"
		