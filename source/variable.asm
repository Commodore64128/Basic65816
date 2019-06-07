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
;		exist create it - either as an integer, a null string or an 11 element array (0..10)
;		with those values.
;
;		Store the address of its data in DVariablePtr. Return this in YA with CS if it is
;		a string value, CC if it is an integer.
;
; *******************************************************************************************

VariableFindCreate:
		;
		;		find the variable. this also sets up the DHashPtr to point to the link.
		;
		jsr 	VariableFind
		bcs 	_VFCFound
		;
		; 		create it if it doesn't exist.
		;
		lda 	#10 						; if creating an array, then max subscript is 10
		jsr 	VariableCreate

_VFCFound:
		;
		; 		apply subscripting if array.
		;

		;
		;		Get value and type.
		;
		rts

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
		bcc 	_VFCError
		sec
		rts

_VFCError:
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

