; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		local.asm
;		Purpose : 	Handle Local Variables
;		Date :		19th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									LOCAL <Var list>
;
; *******************************************************************************************

Command_LOCAL:	;; local
		jsr 	LocalProcessVariable 		; make one variable 'local'
		bcc 	_CLOFail
		lda 	(DCodePtr) 					; look at next character
		cmp 	#commaTokenID 				; exit if not comma
		bne 	_CLOExit
		inc 	DCodePtr 					; skip comma and get next variable
		inc 	DCodePtr
		bra 	Command_Local
_CLOExit:
		rts
_CLOFail:
		#error 	"Bad Local Statement"

; *******************************************************************************************
;
;		Push variable at codePtr on the stack. If it doesn't exist create it. Return
;		variable address in A ; push value,address and local marker on the stack, 
; 		marker is $E000 for string and $C000 for an integer. Return CS.
;
;		Return CC on error.
;
; *******************************************************************************************

LocalProcessVariable:
		lda 	(DCodePtr)					; check it is an identifier and not an array
		cmp 	#$C000
		bcc 	_LPVFail
		and 	#IDArrayMask 
		bne 	_LPVFail
		lda 	(DCodePtr)
		and 	#$E000
		pha
		;
		;		Already exists ?
		;
		jsr 	VariableFind 				; try to find the variable
		bcs 	_LPVFound 					; if found, A points to the data.
		;
		;		If not, create it.
		;
		ldy 	DCodePtr 					; Y is the address of the name
		lda 	#0 							; A = 0 because it's just a single value.
		jsr 	VariableCreate 				; create it.
		;
_LPVSkipToken:
		lda 	(DCodePtr) 					; skip over the token
		inc 	DCodePtr
		inc 	DCodePtr
		and 	#IDContMask 				; if there is a continuation 
		bne 	_LPVSkipToken		
		;
_LPVFound:		
		;
		;		Put it on the stack.
		;
		tay 								; data pointer in Y
		ldx 	DStack
		;
		sta 	$02,x 						; offset 0 address
		lda 	$0000,y 					; offset 2 LSW
		sta 	$04,x
		lda 	$0002,y 					; offset 4 LSW
		sta 	$06,x
		pla 								; get the type header
		sta 	$08,x 						; update the BASIC stack.
		;
		;		Update the stack pointer.
		;
		txa
		clc
		adc 	#8
		sta 	DStack
		sec
		rts

_LPVFail:
		clc
		rts



