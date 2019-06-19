; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		stringtemp.asm
;		Purpose : 	String Temporary Utilities
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
		pha
		lda 	DTempStringPointer 			; needs resetting ?
		bne 	_STANoReset

		phy 								; reset the temp string pointer.
		ldy 	#Block_HighMemoryPtr
		lda 	(DBaseAddress),y
		sta 	DTempStringPointer
		ply

_STANoReset:
		pla 								; get length.
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
		inc 	DCurrentTempString 			; increment write pointer
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

