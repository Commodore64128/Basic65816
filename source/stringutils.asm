; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		stringutils.asm
;		Purpose : 	String Utilities
;		Date :		6th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;		Allocate temporary storage for string of length A, return address in A.
;
; *******************************************************************************************

StringTempAllocate:
		and 	#$00FF 						; check it's a byte size
		eor 	#$FFFF 						; 2's complement add to temporary pointer.
		clc 								; this adds one, for the length.
		adc 	DTempStringPointer
		sta 	DTempStringPointer
		;
		pha 								; save start address
		lda 	#$0000
		sep 	#$20 						; zero the length of this new string.
		sta		(DTempStringPointer)
		rep 	#$20
		pla 								; restore start address
		sta 	DStartTempString 			; start of new temporary string.
		sta 	DCurrentTempString 			; save current temporary string
		inc 	DCurrentTempString 			; step over length byte.
		rts

; *******************************************************************************************
;
;								Write A to current temp string
;
; *******************************************************************************************

StringWriteCharacter:
		sep 	#$20						; 8 bit mode
		sta 	(DCurrentTempString) 		; save character
		lda 	(DStartTempString) 			; bump length
		inc 	a
		sta 	(DStartTempString)
		rep 	#$20						; 16 bit mode
		rts	

; *******************************************************************************************
;
;			  Copy String at A to the most recently allocated temporary storage.
;
; *******************************************************************************************

StringCreateCopy:
		tay 								; put pointer to string in Y
		lda 	$0000,y 					; read the first byte, the length.
		and 	#$00FF 						; mask out the length byte.
		beq 	_SCCExit 					; do nothing if length zero (the length byte is reset when allocated)
		phx 								; save X and put the character count in X
		tax
_SCCCopy:
		iny 								; advance and read (first time skips length)
		sep 	#$20 						; switch to 8 bit mode.
		lda 	$0000,y
		sta 	(DCurrentTempString) 		; write into target
		lda 	(DStartTempString)			; one more character
		inc 	a
		sta 	(DStartTempString)
		rep 	#$20 						; switch back to 16 bit mode
		inc 	DCurrentTempString 			; bump target pointer
		dex 								; do X times
		bne 	_SCCCopy
		plx
_SCCExit:
		rts

; *******************************************************************************************
;
;						Make String at A concrete, return new string in A
;
; *******************************************************************************************

StringMakeConcrete:
		ldy 	#Block_LowMemoryPtr 		; compare the address against low memory.
		cmp 	(DBaseAddress),y 			; if the address is < this, then it doesn't need concreting.
		bcc 	_SMCExit
		;
		sta 	DTemp1 						; source 
		lda 	(DTemp1)					; get length
		and 	#$00FF
		bne 	_SMCNonZero 				; if not "" skip.
		;
		lda 	#Block_EmptyString 			; empty string, return the null pointer in low memory
		clc 								; this reference is used for all empty strings.
		adc 	DBaseAddress
_SMCExit:		
		rts
		;
		;		String is not empty, so allocate high memory for it.
		;
_SMCNonZero:
		pha 								; save on stack.
		;
		eor 	#$FFFF 						; 2's complement with carry clear, allocate one more.
		clc
		ldy 	#Block_HighMemoryPtr 		; add to the high pointer to create space
		adc 	(DBaseAddress),y
		sta 	(DBaseAddress),y
		sta 	DTemp2 						; target
		;
		ply 								; get length copy from here until Y goes -ve
		sep 	#$20 						; 8 bit mode.
_SMCLoop:
		lda 	(DTemp1),y 					; copy from source to target
		sta 	(DTemp2),y
		dey 								; Y+1 times.
		bpl 	_SMCLoop
		rep 	#$20 						; 16 bit mode.
		lda 	DTemp2 						; return new string address.
		rts
