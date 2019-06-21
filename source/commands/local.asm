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
;				Make the variable at (DCodePtr) local. Return data address in A.
;
; *******************************************************************************************

LocalProcessVariable:
		lda 	(DCodePtr)					; check it is an identifier and not an array
		cmp 	#$C000
		bcc 	_LPVFail
		and 	#IDArrayMask 
		bne 	_LPVFail
		;
		lda 	(DCodePtr) 					; save the type on the stack.
		pha
		;
		;		Try to find the variable, create it if it doesn't exist.
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
		tay 								; address in Y
		ldx 	DStack 						; stack pointer in X
		sta 	$02,x 						; offset 0 address
		lda 	$0000,y 					; offset 2 LSW
		sta 	$04,x
		lda 	$0002,y 					; offset 4 LSW
		sta 	$06,x				
		;
		lda 	#$0000 						; clear the old value
		sta 	$0000,y
		sta 	$0002,y
		;
		pla
		and 	#$C000+IDTypeMask 			; $C000 if number, $E000 if string.
		sta 	$08,x						; save offset 6
		cmp 	#$C000
		beq 	_LPVNotString
		;
		lda 	#0
		sta 	$0000,y 					; make it an empty string.
		sta 	$0002,y
_LPVNotString:
		txa
		clc
		adc 	#8
		sta 	DStack
		sec
		tya 								; return the data address.
		rts

_LPVFail:
		#error 	"Bad Local Command"

; *******************************************************************************************
;
;								Restore an element off the stack
;
; *******************************************************************************************

LocalRestore:
		lda 	DStack 						; unpick stack.
		sec
		sbc 	#8
		sta 	DStack
		tax
		lda 	$08,x 						; look at type.
		cmp 	#$C000 	
		beq 	_LRRestore					; skip if number.
		;
		lda 	$02,x 						; release the string that was there if any.
		tay 
		lda 	$0000,y
		jsr 	StringRelease
		;
_LRRestore:		
		lda 	$02,x 						; restore a string.
		tay
		lda 	$04,x
		sta 	$0000,y
		lda 	$06,x
		sta 	$0002,y
		rts
;
; Note: when a local variable is created, the string that was assigned to it is still marked used, and this
; is restored on ENDPROC.
;
; However, when creating the local variable it is reset to empty. The reason for this is if you allow the
; assignment to work it will deallocate the string (because it doesn't need it any more, not realising it is
; on the local stack)
;
; Additionally, when restoring the local stack, it is possible string memory has been allocated to it in 
; after a local string variable has declared. Thus when you release a local variable it should free any string
; allocated to it.
;