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

VariableFindCreate:
		nop
		;
		;		find the variable. this also sets up the DHashPtr to point to the link.
		;
		lda 	(DCodePtr)					; get the first token, push on stack
		pha 
		jsr 	VariableFind 				; try to find the variable
		sta 	DVariablePtr 				; store the result in DVariablePtr
		bcc 	_VFCError
		;
		; 		apply subscripting if array.
		;


_VFCNotArray:
		;
		;		Get value and type.
		;
		pla 								; get the token back.
		and 	#$2000 						; this is the integer/string bit. $2000 if string, $0000 if int
		eor 	#$2000 						; now $0000 if string, $2000 if integer.
		sec 								; set up return string.
		beq 	_VFCLoadLower 				; if zero, Y = 0 and just load the lower address with CS
		clc 								; returning a number, read high data word
		ldy 	#2
		lda 	(DVariablePtr),y
_VFCLoadLower:
		tay 								; put A into Y (this is the high byte)
		lda 	(DVariablePtr)				; read the low data word
		rts

_VFCError:
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
		bcs 	_VFCSlowVariable 			; < this it is the fast variable A-Z
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
_VFCSlowVariable:
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
_VLNext:
		lda 	(DTemp1) 					; normally the link, first time will be the header.
		beq 	_VLFail 					; if zero, then it's the end of the list.
		sta 	DTemp1 						; this is the new variable record to check
		tay 								; read the address of the name at $0002,y
		lda 	$0002,y
		sta 	DTemp2 						; save in DTemp2
		ldy 	#0 							; start matching lists of tokens
_VLCompare:
		lda 	(DTemp2),y 					; see if they match
		cmp 	(DCodePtr),y
		bne 	_VLNext 					; if not, go to the next one.
		iny 								; advance token pointer
		iny 
		and 	#$0800 						; if continuation bit set, keep going
		bne 	_VLCompare
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
_VLFail:
		clc
		rts

_VFError:
		#error 	"Missing variable"

; *******************************************************************************************
;
;		Create a variable at codeptr. It does not check to see if it exists, so this needs
;		to be run in conjunction with VariableFind.
;
;		Uses the DHashPtr set in VariableFind to create a new record, with array max 
;		subscript in A. (ignored for non array values) and initialises those values.
;
;		Returns the address of the variable data record in A.
;
; *******************************************************************************************

VariableCreate:
		rts

