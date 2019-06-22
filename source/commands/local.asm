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
		nop
		nop
		nop

_LPVFail:
		#error 	"Bad Local Command"

; *******************************************************************************************
;
;								Restore an element off the stack
;
; *******************************************************************************************

LocalRestore:
		nop

		