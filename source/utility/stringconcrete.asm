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
;
;		Strings are stored as a block of memory starting at the high memory pointer.
;		the first two bytes are size of the block, with bit 15 being set if this is 
; 		available for use.
;
; *******************************************************************************************
;
;							Reset the string permanent memory
;
; *******************************************************************************************

StringResetPermanent:
		lda 	DHighAddress				; the end of memory
		dec 	a 							; subtract 2 to add a null terminator.
		dec 	a
		tay
		pha
		lda 	#$0000
		sta 	$0000,y						; reset that link to next to $0000.
		pla
		ldy 	#Block_HighMemoryPtr		; save the high memory pointer, which is the start of the link
		sta 	(DBaseAddress),y
		rts

; *******************************************************************************************
;
;		On entry A contains the new string, and Y contains the address that contains the
; 		old string. Update that address with the new string, concreting in memory if
;		required.
;
; *******************************************************************************************

StringReassign:
		phx 								; save X.
		tyx 								; save the pointer to the current on X.
		pha 								; save the new string address on stack

		lda 	@w$0000,x 					; address of the old string in A
		ldy 	#Block_HighMemoryPtr 		; compare it against the high memory pointer
		cmp 	(DBaseAddress),y 			; if < this then we don't need to release it first.
		bcc 	_SRANoRelease
		;
		;		Release string from usage.
		;
		ldy 	@w$0000,x 					; the address of the old string
		dey 								; point to the link.
		dey
		lda 	@w$0000,y 					; and set the available bit.
		ora 	#$8000 						
		sta 	@w$0000,y
		;
		;		Search for a string of suitable length that's available.
		;
_SRANoRelease:		
		ply 								; restore and save the new string address
		phy
		lda 	$0000,y 					; get the length of this new string
		and 	#$00FF 						; mask it off.
		inc 	a 							; we want one more, for the length byte.
		sta 	DTemp5
		ldy 	#Block_HighMemoryPtr		; start position in Y		
		lda 	(DBaseAddress),y
		tay
		;
		;		Check blocks sequentially
		;
_SRACheckUnused:
		lda 	$0000,y 					; offset to next
		beq 	_SRAAllocate 				; if zero, nothing fits, so allocate a new chunk.
		bpl 	_SRACheckNext 				; if +ve then it is in use, so can't use that either.
		and 	#$7FFF 						; it's available, get the actual size.
		cmp 	DTemp5 						; compare against the required length
		bcc 	_SRACheckNext 				; too small.
		;
		sta 	$0000,y 					; it's okay - write back with the bit cleared.
		tya 								; A is the address of the link
		inc 	a 							; add 2, it's the data.
		inc 	a
		bra 	_SRACopyA 					; copy there.
		;	
_SRACheckNext:
		lda 	$0000,y 					; get offset , mask bit 15
		and 	#$7FFF
		sta 	DTemp5+2 					; save it
		tya 								; add to Y
		clc
		adc 	DTemp5+2						
		inc 	a 							; add 2 more for the link itself
		inc 	a
		tay
		bra 	_SRACheckUnused
		;
		;		Allocate a string of the required space.
		;
_SRAAllocate:
		ply 								; get the new string address back.
		phy 								; push it back on the stack.
		lda 	$0000,y 					; get its length
		and 	#$00FF 						; one more for the byte count.
		inc 	a
		jsr 	StringAllocateSpace 		; allocate A bytes from High Memory -> A
		;
		;		A points to the start of the allocated space, the target string address is on the stack.
		;
_SRACopyA:		
		sta 	@w$0000,x 					; save the address of the new string.
		stz 	@w$0002,x 					; zero the high byte.
		tax 								; where we are copying to.
		ply 								; where we're coming from.
		lda 	$0000,y 					; bytes to copy.
		and 	#$00FF 						; mask, add 1 for length byte.
		inc 	a
		sta 	DTemp5 						; save counter.
_SRACopy:
		sep 	#$20
		lda 	@w$0000,y 					; copy byte over
		sta 	@W$0000,x 
		rep 	#$20
		iny
		inx
		dec 	DTemp5 						; do it this many times.
		bne 	_SRACopy
		plx 								; restore X and exit.
		rts

StringAllocateSpace:
		phx									; save XY
		phy
		pha 								; save the length.
		inc 	a 							; two extra bytes, for the offset pointer.
		inc 	a
		eor 	#$FFFF 						; make it -ve
		sec 								; add 1 (2's complement)
		ldy 	#Block_HighMemoryPtr 		
		adc 	(DBaseAddress),y 	
		sta 	(DBaseAddress),y 			; A is the address of the new storage.
		tay 								; put in Y
		pla 								; restore the length
		sta 	$0000,y 					; store this as the "link"
		tya 								; get the address back
		inc 	a 							; skip over the link
		inc 	a
		ply									; restore YX and exit.
		plx
		rts





