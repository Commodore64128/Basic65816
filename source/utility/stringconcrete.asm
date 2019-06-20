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
		dec 	a 							; at the top of memory.
		tay
		pha
		lda 	#$0000
		sta 	$0000,y						; reset that link to next to $0000.
		pla
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

StringReassign:
		phx 								; save X
		tyx 								; save the pointer to the current value into X.
		;
		;		We don't need the old string any more, we're replacing it.
		;
		tay 								; put address of the new string in Y
		lda 	@w$0000,x					; address of the old string in A
		jsr 	StringRelease 				; release the old string
		;
		;		If the new string is empty, we can store the standard NULL value there.
		;
		lda 	@w$0000,y 					; get length
		and 	#$00FF 						; mask it off.
		bne 	_SRAContent
		brl 	_SRAEmpty 					; if zero, return empty address.
_SRAContent:
		phy 								; save the new string address on stack
		;
		;		Search for a string of suitable length that's available. Work out how long
		; 		we need this string space to be.
		;
		ply 								; restore and save the new string address
		phy
		lda 	$0000,y 					; get the length of this new string
		and 	#$00FF 						; mask it off.
		inc 	a 							; we want one more, for the length byte.
		sta 	DTemp5 						; the length required is stored in DTemp5.
		;
		;		Work down the string chain looking for strings that aren't used.
		;
		ldy 	#Block_HighMemoryPtr		; start position in Y		
		lda 	(DBaseAddress),y 			
		tay
		;
		;		Check blocks sequentially ; this is the search for unused blocks loop.
		;
_SRACheckUnused:
		lda 	$0000,y 					; this is the offset/size to the next (actually offset is 2 more)
		beq 	_SRAAllocate 				; if zero, nothing fits, so allocate a new chunk.
		;
		bpl 	_SRACheckNext 				; if +ve then it is in use, so can't use that either.
		;
		and 	#$7FFF 						; it's available, get the actual size of this bhunk.
		cmp 	DTemp5 						; compare against the required length
		bcc 	_SRACheckNext 				; too small, go and look at the next block.
		;
		;		We've found a block we can use for the new string.
		;
		sta 	$0000,y 					; it's okay - write back with bit 15 cleared.
		tya 								; A is the address of the link
		inc 	a 							; add 2, to make this the address of the data space associated
		inc 	a 							; with it.
		bra 	_SRACopyA 					; go and copy it there.
		;	
		;		Try the next string block.
		;
_SRACheckNext:
		lda 	$0000,y 					; get offset , mask bit 15 out, this is the size of the block.
		and 	#$7FFF
		sta 	DTemp5+2 					; save it in temporary space.
		tya 								; add to the offset to the current address
		clc
		adc 	DTemp5+2						
		inc 	a 							; add 2 more for the link itself, the link is 2 less than the offset.
		inc 	a
		tay 								; put it in Y, go check that one.
		bra 	_SRACheckUnused
		;
		;		Allocate a string of the required space - couldn't find one in the string list.
		;
_SRAAllocate:
		ply 								; get the new string address back.
		phy 								; push it back on the stack.
		lda 	$0000,y 					; get its length
		and 	#$00FF 						; one more for the byte count.
		inc 	a
		clc  								; make it bigger than needed ; this allows a bit of
		adc 	#4 							; space for expansion.
		bcc 	_SRANoCarry 				; can't do more than this.
		lda 	#255
_SRANoCarry:		
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
		sep 	#$20
_SRACopy:
		lda 	@w$0000,y 					; copy byte over
		sta 	@W$0000,x 
		iny
		inx
		dec 	DTemp5 						; do it this many times.
		bne 	_SRACopy
		rep 	#$20
		plx 								; restore X and exit.
		rts
		;
		;		Set up to point to empty string.
		;		
_SRAEmpty:
		lda 	#Block_EmptyString 			; otherwise fill with this address.
		clc 								; which is guaranteed by have a 0 length.
		adc 	DBaseAddress
		sta 	@w$0000,x
		stz 	@w$0002,x
		plx
		rts		

; *******************************************************************************************
;
;								Allocate space for strings
;
; *******************************************************************************************

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

; *******************************************************************************************
;
;						Attempt to release the string at address A
;
; *******************************************************************************************

StringRelease:		
		phy									; save Y
		ldy 	#Block_HighMemoryPtr 		; compare it against the high memory pointer
		cmp 	(DBaseAddress),y 			; if < this then we don't need to release it 
		bcc 	_SASNoRelease
		;
		;		Release string from usage.
		;
		tay 								; the address of the old string
		dey 								; point to the link.
		dey
		lda 	@w$0000,y 					; and set the available bit.
		ora 	#$8000 						
		sta 	@w$0000,y
_SASNoRelease:	
		ply
		rts



