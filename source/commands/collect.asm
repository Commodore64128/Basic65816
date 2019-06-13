; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		collect.asm
;		Purpose : 	Run command.
;		Date :		11th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								Garbage Collect String Heap
;
; *******************************************************************************************

Function_COLLECT: ;; collect

		lda 	DHighAddress 				; DTemp2 is the highest value the pointer can be - must be < this.
		sta 	DTemp2

		ldy 	#Block_HighMemoryPtr 		; DTemp2+2 is the smallest value that the pointer can be.
		lda 	(DBaseAddress),y 			; this starts off at the start of the current string area.
		sta 	DTemp2+2

		lda 	DHighAddress 				; reset the current string area
		sta 	(DBaseAddress),y
		;
		;		Main loop. Look for the highest string between DTemp2+2 (low) and DTemp2 (high)
		;		
_FCNextPass:
		lda 	DTemp2+2					; lowest permission allowable
		sta 	DTemp1 						; and goes up as you scan through. Must be >= this.

		stz 	DSignCount 					; DSignCount is the address of the string reference, so (DStringPtr)
											; should give the same value as is stored in DTemp1. Zero = not found.
		;
		; 		The first set of links is the string variable table.
		;
		lda 	#Block_HashTable+Block_HashTableEntrySize*2*2
		clc 
		adc 	DBaseAddress
		tay 								; put in Y
		ldx 	#16 						; there are 16 to do.
_FCO1:
		jsr  	COLLECTScanVariable 		; scan that one.
		iny 	 							; go to next pointer
		iny 	
		dex 	
		bne 	_FCO1 						; until done all 16.
		;
		; 		The second set of links is the string array table.
		;
		ldx 	#16 						; there are 16 to do.
_FCO2:
		jsr  	COLLECTScanArray 			; scan that one.
		iny 	 							; go to next pointer
		iny
		dex 	
		bne 	_FCO2 						; until done all 16.
		;
		;		Finished scanning strings.
		;
		lda 	DSignCount 					; get the string pointer.
		beq		_FCExit 					; if finished then exit.
		;
		;		Found a string, so move it to the top.
		;
		pha 								; save the target address
		lda 	(DSignCount)				; the address of the string text is the highest next time round.
		sta 	DTemp2 						; store in DTemp2

		jsr 	StringMakeConcrete 			; make the string concrete.
		ply 								; restore the string.
		sta 	$0000,y 					; update the pointer.

		bra		_FCNextPass	 	
_FCExit:
		rts

COLLECTScanVariable:
		phx 								; save XY
		phy 
_CSVLoop:		
		lda 	$0000,y 					; read link.		
		beq 	_CSVExit
		tay 								; put new address into Y
		clc 								; which is four on.
		adc 	#4
		jsr 	COLLECTCheck
		bra 	_CSVLoop
_CSVExit:		
		ply
		plx
		rts

COLLECTScanArray:
		phx 								; save XY
		phy 
_CSALoop:		
		lda 	$0000,y 					; read link.
		beq 	_CSAExit
		tay 								; put new address in Y
		lda 	$0004,y 					; array max subscript in X
		tax
		inx									; +1 as one more data element.
		tya 								; point A to first element, at +6
		clc
		adc 	#6
_CSADoAllStrings:
		jsr 	COLLECTCheck 				; collect check the first.
		inc 	a 							; advance the pointer.
		inc 	a
		inc 	a
		inc 	a
		dex
		bne 	_CSADoAllStrings 			; until all strings are done.
		bra 	_CSALoop
_CSAExit:		
		ply
		plx
		rts


COLLECTCheck:
		sta 	DTemp1+2 					; save address here.
		lda 	(DTemp1+2) 					; get the actual string address
		cmp 	DTemp1						; if <= DTemp1 then exit
		bcc 	_COCExit 					
		cmp 	DTemp2 						; if >= DTemp2 then exit.
		bcs 	_COCExit

		sta 	DTemp1 						; save the best score in DTemp1
		lda 	DTemp1+2 					; and copy the address to DSignCount
		sta 	DSignCount

_COCExit: 									; restore pointer and exit
		lda 	DTemp1+2
		rts
		rts