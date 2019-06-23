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
		;		Check to see not redimensioning an array that already exists.
		;
		jsr 	VariableFind 				; try to find it.
		bcs 	_FDIMExists 				; if it does, that's an error.
		;
		;		Create the array, which will have no elements at this point, and
		;		push its data address on the stack.
		;
		jsr 	VariableCreate 				; create the empty variable.
		pha 								; save array address on the stack.
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
		;		Create an array data part and store a reference to it in the data structure.
		;
		jsr 	DIMCreateArrayBlock 		; create and return empty array, size A+1.
		ply 								; this is where it goes.
		sta 	$0000,y 					; pointer to first array level block.
		;
		;		If followed by a comma, go round again (e.g. dim a(3),b(4) and so on)
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
		

; *******************************************************************************************
;
;				Create an empty array of size A+1, and return address.
;		
; *******************************************************************************************

DIMCreateArrayBlock:	
		;
		; 		Work out size in bytes from size in elements.
		;	
		pha 								; save max index for later.
		inc 	a 							; work out size + 1 x 4
		asl 	a 							; array(7) has 8 elements indexed from zero.
		bcs 	_DCABFail
		asl 	a
		bcs 	_DCABFail
		clc 								; 2 for size word, the first word is the max index.
		adc 	#2
		bcs 	_DCABFail
		sta 	DTemp1 						; save this total size.
		;
		;		Allocate memory
		;
		ldy 	#Block_LowMemoryPtr 		; add to pointer.
		lda 	(DBaseAddress),y 			
		pha 								; save return address
		clc
		adc 	DTemp1
		sta 	(DBaseAddress),y
		;
		;		Check out of memory - have we crossed the high pointer coming down.
		;
		ldy 	#Block_HighMemoryPtr
		cmp 	(DBaseAddress),y
		bcs 	_DCABFail
		;
		;		Clear the whole structure to zeros.
		;
		ldx 	DTemp1
		ply
		phy
_DCABClear:
		lda 	#0
		sta 	$0000,y
		iny
		iny
		dex
		dex 	
		bne 	_DCABClear
		;
		ply 								; restore start address
		pla 								; restore high index
		sta 	$0000,y 					; save high index
		tya 								; return in A.
		rts

_DCABFail:
		brl 	OutOfMemoryError
		