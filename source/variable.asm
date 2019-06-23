; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		variable.asm
;		Purpose : 	Expression Evaluation
;		Date :		7th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Attempt to locate the variable expression at the current code pointer. If it doesn't 
;		exist return an error.
;
;		Store the address of its data in DVariablePtr. Return this in YA with CS if it is
;		a string value, CC if it is an integer.
;
;		This is only used by the Expression function, should not be called directly.
;
; *******************************************************************************************

VariableAccessExpression:
		;
		;		find the variable. this also sets up the DHashPtr to point to the link.
		;
		lda 	(DCodePtr)					; get the first token, push on stack
		pha 
		jsr 	VariableFind 				; try to find the variables
		sta 	DVariablePtr 				; store the result in DVariablePtr
		bcc 	_VANError 					; not found, so report an error.
		;
		; 		apply subscripting if array.
		;
		pla 								; get and save that first token
		pha 								; we use it for typing.
		tay 								; put first token in Y.
		and 	#IDArrayMask 				; is it an array ?
		beq 	_VANNotArray
		;
		;		Subscript it. If you do this DVariablePtr points to record+4 - the high subscript
		;
		lda 	DVariablePtr 				; variable pointer into A
		jsr 	VariableSubscript			; index calculation
		sta 	DVariablePtr 				; and write it back.
		;
		;		Get value and type.
		;
_VANNotArray:
		pla 								; get the token back.
		and 	#IDTypeMask 				; this is the integer/string bit. $2000 if string, $0000 if int
		eor 	#IDTypeMask 				; now $0000 if string, $2000 if integer.
		beq 	_VANIsString 				; if zero, Y = 0 and just load the lower address with the variable (string)
		;
		;		Returning a number.
		;
		clc 								; returning a number, read high data word
		ldy 	#2
		lda 	(DVariablePtr),y
		tay 								; put A into Y (this is the high byte)
		lda 	(DVariablePtr)				; read the low data word
		rts
		;
		;		Returning a string.
		;
_VANIsString:
		ldy 	#0 							; load string into YA
		lda 	(DVariablePtr) 				
		bne 	_VANNotEmptyString
		lda 	#Block_NullString 			; if value is $0000 then return the empty string
		clc 								; which is always maintained.
		adc 	DBaseAddress
_VANNotEmptyString:		
		sec
		rts

_VANError:
		#error	"Variable unknown"

; *******************************************************************************************
;
;		Find a variable at codeptr. Identify the hash table and hash entry and store the 
;		address in DHashPtr. Search down the list looking for the variable ; if it exists,
;		return its data record address in A with CS, and skip the variable tokens.
;
;		If it doesn't exist, return CC and leave the token where it is.
;
; *******************************************************************************************

VariableFind:
		;
		; 		check it's an identifier token
		;
		lda 	(DCodePtr)					; look at the first token
		cmp 	#$C000 						; must be $C000-$FFFF, an identifier.
		bcc 	_VFError
		;
		;		check if it's a "fast variable" A-Z
		;
		cmp 	#$C01A+1					; C01A is identifier, no continuation Z
		bcs 	_VFSlowVariable 			; < this it is the fast variable A-Z
		;
		;		Fast Variable
		;
		and 	#$001F 						; now it is 1-26.
		dec 	a 							; now 0-25
		asl 	a 							; x 4 and clear carry
		asl 	a
		adc 	#Block_FastVariables 		; offset to fast variables
		adc 	DBaseAddress 				; now an actual address in A
		;
		inc 	DCodePtr 					; skip over the token (only one)
		inc 	DCodePtr
		sec 								; return with carry set.
		rts
		;
		;		Variable in the linked list. First identify which linked list.
		;
_VFSlowVariable:
		;
		;		Figure out which hash table to use, there are four integer/string
		;		and single value/array.
		;
		lda 	(DCodePtr)					; get the token
		and 	#(IDTypeMask+IDArrayMask) 	; get the type bits out --tt ---- ---- ----
		xba 								; now this is 0000 0000 00tt 0000 e.g. tt x 16
		;
		asl 	a 							; 32 bytes (16 x 2 byteentries) per table, also clc
		adc 	#Block_HashTable 			; now its the correct has table offset
		adc 	DBaseAddress 				; now the actual address
		sta 	DTemp1 						; so this is the base of the hash table for the type
		;
		;		Figure out which hash entry.
		;
		lda 	(DCodePtr) 					; get the token - building the hash code.
		and 	#Block_HashMask 			; now a mask value, very simple but okay I think.
		asl 	a 							; double (word entries) and clear carry
		adc 	DTemp1 						; add to the base hash table
		sta 	DHashTablePtr 				; save pointer for later
		sta 	DTemp1 						; save in DTemp1, which we will use to follow the chain.
		;
		;		Search the next element in the chain, looking for a particular variable.
		;
_VFNext:
		lda 	(DTemp1) 					; normally the link, first time will be the header.
		beq 	_VFFail 					; if zero, then it's the end of the list.
		;
		;		Valid variable record, check if it's the one we want.
		;
		sta 	DTemp1 						; this is the new variable record to check
		tay 								; read the address of the name at $0002,y
		lda 	$0002,y
		sta 	DTemp2 						; save in DTemp2
		;
		;		Check the name of this record (DTemp2)  against the one we're finding (CodePtr)
		;
		ldy 	#0 							; start matching lists of tokens, we can do it in words
_VFCompare:
		lda 	(DTemp2),y 					; see if they match
		cmp 	(DCodePtr),y
		bne 	_VFNext 					; if not, go to the next one.
		iny 								; advance token pointer
		iny 
		and 	#IDContMask 				; if continuation bit set, keep going (if they match)
		bne 	_VFCompare
		;
		;		Found it - the token lists match.
		;
		tya 								; this is the length of the word.
		clc 								; so we add it to the code pointer
		adc 	DCodePtr
		sta 	DCodePtr 					; now points to the token after the identifier.
		;
		lda 	DTemp1 						; this is the variable record
		clc 								; four on is the actual data
		adc 	#4 							; or it's the reference for the data for arrays.
		;
		sec 								; return with CS indicating success
		rts
		;
_VFFail: 									; didn't find the variable
		clc
		rts

_VFError:
		#error 	"Missing variable"

; *******************************************************************************************
;
;	  Subscript an Array Entry. On entry A points to the link to the data, X is the level.
;
; *******************************************************************************************

VariableSubscript:
		;
		;		Get the address of the data block for the array.
		;
		phy 								; save Y
		tay 								; put the link pointer into Y
		lda 	$0000,y 					; read the link, this is the array data block.
		pha		 							; save array data block address on stack.
		;
		; 		Get the subscript and check it is 0-65535
		;
		jsr		EvaluateNextInteger 		; get the subscript
		jsr 	ExpectRightBracket 			; skip right bracket.
		cpy 	#0 							; msword must be zero
		bne 	_VANSubscript
		;
		;		Compare the subscript against the max index at the start of the memory block.
		;
		ply 								; start of array memory block.
		cmp 	$0000,y						; the max index is at the start, so check against that.
		beq 	_VANSubOkay 				; fail if subscript > high subscript
		bcs 	_VANSubscript 
_VANSubOkay:
		;
		;		Convert to a data address
		;
		asl 	a 							; double lsword
		asl 	a 							; and again, also clears carry.
		sta 	DTemp1	 					; 4 x subscript in DTemp1

		tya 								; restore the address of the array memory block.
		inc 	a 							; add 2 to get it past the high subscript
		inc 	a
		clc
		adc 	DTemp1 						; add the subscript x 4
		ply 								; restore Y
		rts

_VANSubscript:
		#error 	"Bad Array Subscript"

; *******************************************************************************************
;
;								Create a new variable. 
;
;		*** VariableFind needs to have been called first so DHashPtr is set up ***
;
;		DCodePtr points to the token.
;
;		On exit A contains the address of the data part of the record (e.g. at +4)
;		
;
; *******************************************************************************************

VariableCreate:			
		;
		;		Allocate space - 8 bytes always.
		;
		ldy 	#Block_LowMemoryPtr 		; get low memory
		lda 	(DBaseAddress),y 		
		pha 								; save it
		clc 
		adc 	#8 
		sta 	(DBaseAddress),y 			; update low memory
		;
		;		Check we are okay on memory.
		;
		ldy 	#Block_HighMemoryPtr 		; check allocation.
		cmp 	(DBaseAddress),y
		bcs 	_VCOutOfMemory
		ply 								; restore new variable address to Y.
		;
		;		Clear the data space.	
		;
		lda 	#$0000 						; clear that word to empty string/zero.
		sta 	$0004,y 					; data from +4..+7 is zeroed.
		sta 	$0006,y
		;
		;		Now set it up, put the original hash first link as this record's link
		; 		e.g. insert it into the front of the linked list.
		;
		lda 	(DHashTablePtr)				; get the link to next.
		sta 	$0000,y 					; save at offset +0
		;
		;		Set up the token. If the token is in the tokenised space used for typed in
		; 		commands (e.g. we've typed a3 = 42 at the keyboard) that token needs to be
		; 		copied, because the reference will disappear.
		;
		lda 	#Block_ProgramStart 		; work out the program start
		clc 								; in DTemp1. 
		adc 	DBaseAddress
		sta 	DTemp1
		;
		;		If the token address is < program start it's in the token buffer and needs
		;		duplicating.
		;
		lda 	DCodePtr 					; get the address of the token.
		cmp 	DTemp1 						; if it is below the program start we need to clone it.
		bcs 	_VCDontClone 				; because the variable being created has its identifier
		jsr 	VCCloneIdentifier	 		; in the token workspace, done via the command line
_VCDontClone:		
		;
		;		Update the token address word in the new variable record.
		;
		sta 	$0002,y 					; save at offset +2
		;
		;		The record is now complete, so put it in the head of the hash table linked list.
		;
		tya 								; update the head link
		sta 	(DHashTablePtr)
		clc 								; advance pointer to the data part.
		adc 	#4
		pha 								; save on stack.
		;
		;		Consume the identifier token
		;
_VCSkipToken:
		lda 	(DCodePtr) 					; skip over the token
		inc 	DCodePtr
		inc 	DCodePtr
		and 	#IDContMask 				; if there is a continuation 
		bne 	_VCSkipToken
		pla 								; restore data address
		rts 								; and done.
		;
_VCOutOfMemory:
		brl 	OutOfMemoryError
		;
		;		Clone the identifier at A. Used when we can't use a program token to name
		;		a new variable, because we did it at the keyboard. This will hardly ever 
		;		be used :)
		;
VCCloneIdentifier:
		phx 								; save XY
		phy
		tax 								; identifier address in Y.
		ldy 	#Block_LowMemoryPtr		 	; get low memory address, this will be the new identifier.
		lda 	(DBaseAddress),y
		pha
_VCCloneLoop:
		ldy 	#Block_LowMemoryPtr 		; get low memory
		lda 	(DBaseAddress),y
		pha 								; save on stack
		inc 	a 							; space for one token.
		inc 	a		
		sta 	(DBaseAddress),y 			
		ply 								; address of word in Y
		lda 	@w$0000,x 					; read the token
		sta 	$0000,y 					; copy it into that new byte.
		inx 								; advance the token pointer
		inx
		and 	#IDContMask 				; continuation ?
		bne 	_VCCloneLoop
		;
		pla 								; restore start address
		ply 								; and the others
		plx
		rts

