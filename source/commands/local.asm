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
		;		Save token for typing, and find/create variable if required.
		;
		lda 	(DCodePtr) 					; get type
		pha 								; save on stack.
		jsr 	VariableFind 				; find a variable
		bcs 	_LPVFound
		jsr 	VariableCreate 				; create it if it doesn't exist.
_LPVFound:		
		tay 								; variable address in Y
		pla 								; get the type back
		and 	#IDTypeMask 				; identify it
		bne 	_LPVStringPush 				; if string, push that on the stack.
		;
		;		Push a number.
		;
		ldx 	DStack
		lda 	$0000,y 					; get LSW and write
		sta 	$02,x
		lda 	$0002,y 					; get MSW and write
		sta 	$04,x
		tya 								; write address.
		sta 	$06,x
		lda 	#$C000 						; write $C000 marker.
		sta 	$08,x
		;
		lda 	#$0000 						; clear the local variable to zero
		sta 	$0000,y
		sta 	$0002,y
		;
		txa 								; shift to top of stack.
		clc
		adc 	#8
		sta 	DStack
		rts
		;
		;		Push a string.
		;
_LPVStringPush:
		lda 	$0000,y 					; if uninitialised then leave it like that.
		beq		_LPVExit
		phy 								; save storage address on stack.
		sta 	DTemp1 						; address of physical string.
		ldx 	DStack 						; get stack.
		inx 								; point to free stack byte.
		inx 
		lda 	(DTemp1) 					; get length of string.
		and 	#$00FF
		tay 								; copy backwards
_LPVPushOut:
		lda 	(DTemp1),y 					; copy byte at a time. just do words :)
		sta 	$00,x
		inx
		dey
		bpl 	_LPVPushOut 				; push one extra because of length byte.
		;
		pla 								; write out the address of the storage.
		sta 	$00,x 						; (e.g. this address has the physical string address)
		lda 	#$E000 						; write $E000 out.
		sta 	$02,x
		inx
		inx
		stx 	DStack 						; save $E000 marker
_LPVExit:		
		rts

_LPVFail:
		#error 	"Bad Local Identifier"

; *******************************************************************************************
;
;							Restore all local variables off the stack.
;
; *******************************************************************************************

LocalRestore:
		ldx 	DStack 						; access basic stack.
		lda 	$00,x 						; read top word.
		cmp 	#$C000 						; $C000-$FFFF indicates stacked local/parameter
		beq 	_LRIntegerPull 				; $C000 unstack integer
		bcs 	_LRString 					; $C001-$FFFF unstack string
		rts
		;
		;		pull integer off stack.
		;
_LRIntegerPull:
		txa 								; pull 8 bytes off stack.
		sec
		sbc 	#8
		sta 	DStack
		tax 								; put in X
		;
		lda 	$06,x 						; get address to restore
		tay
		lda 	$02,x 						; restore MSW
		sta 	@w$0000,y
		lda 	$04,x 						; and LSW
		sta 	@w$0002,y
		bra 	LocalRestore 				; and try again.
		;
		;		pull string off stack.
		;
_LRString:
		dex									; access the address
		dex
		lda 	$00,x 						; the address of the storage address
		tay
		lda 	$0000,y 					; the actual storage address
		sta 	DTemp1 						; save so we can write to it.
		dex 								; length is the next byte.
		lda 	$00,x 						; so get the length
		and 	#$00FF 						; mask it off
		tay 								; count in Y
_LRRecover:
		lda 	$00,x 						; extract and write bytes
		sep 	#$20
		sta 	(DTemp1)
		rep 	#$20
		dex 								; stack backwards
		inc 	DTemp1 						; pointer forwards
		dey 								; do Y+1 times.
		bpl 	_LRRecover
		;
		dex 								; stack should now point to next token
		stx 	DStack
		bra 	LocalRestore 				; and try again.		