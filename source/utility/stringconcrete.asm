; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		stringconcrete.asm
;		Purpose : 	Concrete strings into permanent storage.
;		Date :		19th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Strings are stored backwards in memory from the high memory pointer. The maximum
;		length of any string is stored in the immediately preceding byte.
;
; *******************************************************************************************
;
;							Reset the string permanent memory
;
; *******************************************************************************************

StringResetPermanent:
		lda 	DHighAddress				; the end of memory
		tay
		ldy 	#Block_HighMemoryPtr		; save the high memory pointer, which is the first link.
		sta 	(DBaseAddress),y
		rts

; *******************************************************************************************
;
;		On entry A contains the new string, and Y contains the address that contains the
; 		old string. Update that address with the new string, concreting in memory if
;		required.
;
; *******************************************************************************************

StringAssign:
		phx 								; save X
		tax 								; new string to X.
		;
		lda 	$0000,y 					; does the string have an address yet.
		beq 	_SAAllocate 				; if not , allocate space for it and copy the string.
		;
		;		Check to see if this string has memory allocated already.
		;
		phy
		lda 	$0000,y 					; compare calculate saved address - high memory pointer
		cmp 	(DBaseAddress),y
		tay 								; read the max available length of the old string
		dey  								; CC still contains first allocation check
		lda 	$0000,y
		ply 								; restore Y
		bcc 	_SAAllocate					; if < high memory pointer, first allocation.		
		;
		; 		Compare max length of old string (A) vs length of new string. If it fits
		;		copy it in.
		;
		and 	#$00FF 						; max length of old string
		sep 	#$20 						
		cmp 	@w$0000,x 					; compare against length of new string
		rep 	#$20
		bcs 	_SACopyString 				; just copy it in if old max length >= new
		;
		;		Is this the bottom-most string.
		;
		lda 	$0000,y 					; get the address of the string.
		dec 	a 							; if bottom, compare the previous byte address
		phy 								; which is the max length.
		ldy 	#Block_HighMemoryPtr
		eor 	(DBaseAddress),y
		ply
		ora 	#$0000 						; if not, then allocate memory.
		bne 	_SAAllocate
		;
		;		Restore the memory back. It will then be re-allocated.
		;
		phy
		lda 	$0000,y 					; address of old string
		tay 								; to Y
		dey 								; get maximum length.
		lda 	$0000,y 			
		and 	#$00FF
		inc 	a 							; add 2 (string,max)
		inc 	a
		ldy 	#Block_HighMemoryPtr 		; return memory back
		clc
		adc 	(DBaseAddress),y
		sta 	(DBaseAddress),y
		ply
		;
		;		Allocate memory for the string.
		;
_SAAllocate:
		lda 	@w$0000,x 					; get the length of the string
		and 	#$00FF
		clc 
		adc 	#8 							; allocate extra space if needed.
		cmp 	#255 						; can't be larger than this.
		bcc 	_SASizeOkay
		lda 	#255
_SASizeOkay:
		;
		;		Allocate A bytes of memory, at least for the new string
		;
		phy 								; push [string] on the stack.
		pha 								; push largest string size on the stack.
		inc 	a  							; one more for the string size byte
		inc 	a 							; one more for the maximum size byte
		;
		eor 	#$FFFF 						; subtract from the high memory pointer
		sec
		ldy 	#Block_HighMemoryPtr
		adc 	(DBaseAddress),y
		sta 	(DBaseAddress),y
		;
		ldy 	#Block_LowMemoryPtr 		; out of memory ? - if below the lowmemorypointer
		cmp 	(DBaseAddress),y
		bcc 	_SAMemory
		;
		tay 								; address of start of space in Y.
		pla 								; restore largest string size and save it
		sta 	@w$0000,y 					; doesn't matter it's a word.
		iny 								; Y now points to the first byte of the string we'll copy
		tya 								; in A now
		ply 								; Y is the address of the variable pointer.
		sta 	@w$0000,y 					; make that pointer the first byte
		;
		;		Copy the string at X to the string at [Y].
		;
_SACopyString		
		lda 	@w$0000,x 					; get length
		and 	#$00FF
		sta 	DTemp1 						; save it.
		lda 	@w$0000,y 					; Y now contains the actual address of the string
		tay 
_SACopyStringLoop:
		sep 	#$20
		lda 	@w$0000,x				
		sta 	@w$0000,y
		rep 	#$20
		inx
		iny
		dec 	DTemp1
		bpl 	_SACopyStringLoop
		plx 								; restore X
		rts

_SAMemory:		
		brl 	OutOfMemoryError


