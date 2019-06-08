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
		bcc 	_VANError
		;
		; 		apply subscripting if array.
		;
		pla 								; get and save that first token
		pha
		tay 								; put first token in Y.
		and 	#$1000 						; is it an array ?
		beq 	_VANNotArray
		;
		;		Subscript it. If you do this DVariablePtr points to record+4 - the high subscript
		;
		lda 	DVariablePtr 				; variable pointer into A,first token is in Y
		jsr 	VariableSubscript			; index calculation
		sta 	DVariablePtr 				; and write it back.
		;
		;		Get value and type.
		;
_VANNotArray:
		pla 								; get the token back.
		and 	#$2000 						; this is the integer/string bit. $2000 if string, $0000 if int
		eor 	#$2000 						; now $0000 if string, $2000 if integer.
		sec 								; set up return string.
		beq 	_VANLoadLower 				; if zero, Y = 0 and just load the lower address with CS
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
		adc 	DBaseAddress 				; now an actual address
		inc 	DCodePtr 					; skip over the token
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
		and 	#$3000 						; get the type bits out --xx ---- ---- ----
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
		and 	#$0800 						; if continuation bit set, keep going
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
_VFFail:
		clc
		rts

_VFError:
		#error 	"Missing variable"

; *******************************************************************************************
;
;		Subscript an Array Entry. On entry Y is the first token of the array name (for 
;		typing) and A points to the max-subscript for the index (record +4 for arrays)
;
;		On exit A points to the respective data element which can be 2 or 4 bytes 
;		depending.
;
; *******************************************************************************************

VariableSubscript:
		phy 								; save token on stack
		pha		 							; save variable address on stack.
		jsr		EvaluateNextInteger 		; get the subscript
		jsr 	ExpectRightBracket 			; skip right bracket.
		cpy 	#0 							; msword must be zero
		bne 	_VANSubscript
		cmp 	(DVariablePtr)				; the subscript is at +4, so check against that.
		beq 	_VANSubOkay 				; fail if subscript > high subscript
		bcs 	_VANSubscript
_VANSubOkay:
		asl 	a 							; double lsword
		sta 	DTemp1	 					; 2 x subscript in DTemp1

		pla 								; restore DVariablePtr
		sta 	DVariablePtr

		pla 								; get and save that first token
		and 	#$2000 						; is it a string ?
		bne 	_VANNotString  				; if not, i.e. it is an integeer
		asl 	DTemp1 						; double subscript again (32 bit word)
_VANNotString
		lda 	DVariablePtr 				; variable address
		clc 								; add 2 to get it past the high subscript
		adc 	#2
		adc 	DTemp1 						; add the subscript
		rts

_VANSubscript:
		#error 	"Bad Array Subscript"


