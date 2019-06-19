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
		sec 								; set up return string.
		beq 	_VANLoadLower 				; if zero, Y = 0 and just load the lower address with the variable (string)
		clc 								; returning a number, read high data word
		ldy 	#2
		lda 	(DVariablePtr),y
_VANLoadLower:
		tay 								; put A into Y (this is the high byte)
		lda 	(DVariablePtr)				; read the low data word
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
		; 		check it's an id token
		;
		lda 	(DCodePtr)					; look at the first token
		cmp 	#$C000 						; must be $C000-$FFFF, an identifier.
		bcc 	_VFError
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
		;		Figure out which hash table
		;
		lda 	(DCodePtr)					; get the token
		and 	#(IDTypeMask+IDArrayMask) 	; get the type bits out --tt ---- ---- ----
		xba 								; now this is 0000 0000 00tt 0000 e.g. tt x 16
		asl 	a 							; there are 32 entries per table, also clc
		adc 	#Block_HashTable 			; now its the correct has table offset
		adc 	DBaseAddress 				; now the actual address
		sta 	DTemp1
		;
		;		Figure out which hash entry.
		;
		lda 	(DCodePtr) 					; get the token - building the hash code.
		and 	#Block_HashMask 			; now a mask value.
		asl 	a 							; double (word entries) and clear carry
		adc 	DTemp1
		sta 	DHashTablePtr 				; save pointer for later
		sta 	DTemp1 						; save in DTemp1, which we will use to follow the chain.
		;
		;		Search the next element in the chain.
		;
_VFNext:
		lda 	(DTemp1) 					; normally the link, first time will be the header.
		beq 	_VFFail 					; if zero, then it's the end of the list.
		;
		sta 	DTemp1 						; this is the new variable record to check
		tay 								; read the address of the name at $0002,y
		lda 	$0002,y
		sta 	DTemp2 						; save in DTemp2
		ldy 	#0 							; start matching lists of tokens
_VFCompare:
		lda 	(DTemp2),y 					; see if they match
		cmp 	(DCodePtr),y
		bne 	_VFNext 					; if not, go to the next one.
		iny 								; advance token pointer
		iny 
		and 	#IDContMask 				; if continuation bit set, keep going (if they match)
		bne 	_VFCompare
		;
		;		Found it.
		;
		tya 								; this is the length of the word.
		clc 								; so we add it to the code pointer
		adc 	DCodePtr
		sta 	DCodePtr 					; now points to the following token.
		;
		lda 	DTemp1 						; this is the variable record
		clc 								; four on is the actual data
		adc 	#4 							; or it's the index for indexes.
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
;		Subscript an Array Entry. On entry A points to the max-subscript for the index 
;		(record +4 for arrays)
;
;		On exit A points to the respective data element which can be 2 or 4 bytes 
;		depending.
;
; *******************************************************************************************

VariableSubscript:
		pha		 							; save variable address on stack.
		jsr		EvaluateNextInteger 		; get the subscript
		jsr 	ExpectRightBracket 			; skip right bracket.
		cpy 	#0 							; msword must be zero
		bne 	_VANSubscript
		;
		cmp 	(DVariablePtr)				; the subscript is at +4, so check against that.
		beq 	_VANSubOkay 				; fail if subscript > high subscript
		bcs 	_VANSubscript 
_VANSubOkay:

		asl 	a 							; double lsword
		asl 	a 							; and again, also clears carry.
		sta 	DTemp1	 					; 4 x subscript in DTemp1

		pla 								; restore DVariablePtr
		inc 	a 							; add 2 to get it past the high subscript
		inc 	a
		adc 	DTemp1 						; add the subscript
		rts

_VANSubscript:
		#error 	"Bad Array Subscript"

; *******************************************************************************************
;
;								Create a new variable. 
;
;		*** VariableFind needs to have been called first so DHashPtr is set up ***
;
;		A contains the high index, or zero if the variable is a single item. 
;		Y is the address of the token that is the  name of the variable. 
;
;		On exit A contains the address of the data part of the record for non-arrays, 
;		or the largest index for arrays, e.g. the record address + 4
;
; *******************************************************************************************

VariableCreate:			
		pha 								; save count.
		;
		;		Get the word to fill the new variable with. For strings this the address of the NULL 
		;		string stored at Block_EmptyString.
		;
		lda 	$0000,y 					; get first token
		and 	#IDTypeMask 
		beq 	_VCIsInteger 				; if this is zero ... use zero.
		lda 	#Block_EmptyString 			; otherwise fill with this address.
		clc 								; which is guaranteed by have a 0 length.
		adc 	DBaseAddress
		;
_VCIsInteger:		
		sta 	DSignCount 					; this is temporary for this
		;
		;		Work out space to allocate.
		;
		pla 								; restore count
		pha 
		inc 	a 							; need 1 more element. If zero, you need one. If high index,size is one more.	
		asl 	a 							; 2 x # items.
		asl 	a 							; 4 x # items.
_VCNotSingle:
		sta 	DTemp1 						; save temporarily
		lda 	$0000,y 					; get first token.
		and 	#IDArrayMask 				; check array bit.
		beq 	_VCNotArray
		inc 	DTemp1 						; if set, add 2 to count, space stores the high index value.
		inc 	DTemp1
_VCNotArray:
		phy 								; save address of first token on stack.
		;
		;		Allocate space (in DTemp1) + 4
		;
		ldy 	#Block_LowMemoryPtr 		; get low memory
		lda 	(DBaseAddress),y 		
		sta 	DTemp2 						; save in DTemp2
		clc 								; add 4 for link and name words
		adc 	#4 
		adc 	DTemp1 						; add memory required. already calculate this.
		sta 	(DBaseAddress),y 			; update low memory
		;
		;		Clear the data space.	
		;
		ldy 	DTemp2 						; put the address back in Y
_VCErase:
		lda 	DSignCount 					; clear that word to empty string/zero.
		sta 	$0004,y 					; data from +4 onwards
		iny 						
		iny
		dec 	DTemp1 						; do it DTemp1 times.
		dec 	DTemp1 						; (this is the count of the data beyond link/name)
		bne 	_VCErase
		;
		;		Now set it up.
		;
		ldy 	DTemp2 						; Y is the variable address
		lda 	(DHashTablePtr)				; get the link to next.
		sta 	$0000,y 					; save at offset +0
		;
		lda 	#Block_ProgramStart 		; work out the program start
		clc
		adc 	DBaseAddress
		sta 	DTemp1
		;
		pla 								; restore the token address
		cmp 	DTemp1 						; if it is below the program start we need to clone it.
		bcs 	_VCDontClone 				; because the variable being created has its identifier
		jsr 	VCCloneIdentifier	 		; in the token workspace, done via the command line
_VCDontClone:		
		sta 	$0002,y 					; save at offset +2
		;
		pla 								; restore count and store (if nonzero)
		beq 	_VCNotArray2
		sta 	$0004,y
_VCNotArray2:		
		;
		tya 								; update the head link
		sta 	(DHashTablePtr)
		clc 								; advance pointer to the data bit.
		adc 	#4
		rts 								; and done.
		;
		;		Clone the identifier at A.
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

		