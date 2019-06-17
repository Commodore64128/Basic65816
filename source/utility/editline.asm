; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		editline.asm
;		Purpose : 	Add or Remove line from the program
;		Date :		17th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									Delete Line Number A.
;
; *******************************************************************************************

LineDelete:
		tax 	 							; this is the one we're looking for ....		
		lda 	DBaseAddress 				; work the start position
		clc
		adc 	#Block_ProgramStart
		tay
		;
		;		Search for the line to delete
		;
_LDLoop:
		lda 	$0000,y 					; look at the link
		beq 	_LDExit						; exit if zero ; line does not exist
		txa 								; found a match
		cmp 	$0002,y
		beq		_LDFound
		;
		tya 								; follow the link.
		clc
		adc 	$0000,y
		tay
		bra 	_LDLoop
		;
_LDFound:
		sty 	DTemp1 						; copy to DTemp1
		tya 								; follow link to next.
		clc 
		adc 	$0000,y
		sta 	DTemp2 						; copy from DTemp2
		;
		jsr 	FindCodeEnd 				; find the end of the code.
		sec 	
		sbc 	DTemp2 						; copy count
		inc 	a 							; copy the $0000 trailer (e.g. the last link/offset)
		inc 	a
		tax
		;
		ldy 	#0 							; block copy memory down.
_LDCopy:lda 	(DTemp2),y
		sta 	(DTemp1),y
		iny
		iny		
		dex
		dex
		bne 	_LDCopy
_LDExit:		
		rts

; *******************************************************************************************
;
;							Insert code at Y in Line Number at A
;
; *******************************************************************************************

LineInsert:
		sty 	DTemp1 						; save code in DTemp1
		sta 	DTemp2 						; save Line # in DTemp2
		;
		; 		Find out how long the tokenised code is.
		;
		ldy 	#0
_LIFindLength:
		lda 	(DTemp1),y 					; examine token
		cmp 	#$0000 						; if $0000 then found the end
		beq 	_LIFindEnd
		cmp 	#$0100 						; if < $0100 then just skip it
		bcc 	_LIQString
		iny 								; otherwise just skip it.
		iny
		bra 	_LIFindLength

_LIQString:		
		tya 								; skip quoted strings
		clc
		adc 	(DTemp1),y
		tay
		bra 	_LIFindLength
		;
_LIFindEnd:
		tya 								; the tokens in the line
		clc
		adc 	#6 							; add 6. One for the ending zero, one for line, one for offset.
		sta 	DTemp3 						; save this in DTemp3
		;
		;		Find where the line is to be inserted.
		;
		lda 	#Block_ProgramStart
		clc
		adc 	DBaseAddress
		tay
_LIFindInsertPoint:
		lda 	$0000,y						; if offset is zero, end, so insert here.
		beq		_LIFoundInsertPoint
		lda 	$0002,y 					; if line number here > line number required insert here.
		cmp 	DTemp2
		bcs 	_LIFoundInsertPoint
		tya 								; if < go to the next line.
		clc
		adc 	$0000,y
		tay
		bra 	_LIFindInsertPoint
		;
_LIFoundInsertPoint:
		sty 	DTemp5 						; save in DTemp5		
		;
		;		Work out the copy addresses ; we start from end => end + size and work back
		;		opening up space.
		;
		jsr 	FindCodeEnd 				; get the end of the code.
		sta 	DTemp4 						; save in DTemp4
		clc
		adc 	DTemp3
		sta 	DTemp4+2 					; copying it to DTemp4 + length.
		;
		;		Now copy to make space.
		;
_LICopyMove:
		lda 	(DTemp4) 					; copy the word
		sta 	(DTemp4+2)
		;
		lda 	DTemp4 						; reached the insert point
		cmp 	DTemp5 
		beq 	_LICopyMoveOver
		dec 	DTemp4 						; shift all pointers.
		dec 	DTemp4
		dec 	DTemp4+2 		
		dec 	DTemp4+2
		bra 	_LICopyMove
		;
		;		Now copy the new line in in - offset and line # first.
		;
_LICopyMoveOver:		
		lda 	DTemp3 						; copy the length in, this is the offset
		sta 	(DTemp5)
		ldy 	#2
		lda 	DTemp2 						; copy the line number in.
		sta 	(DTemp5),y
		;
		; 		Now copy the tokens in.
		;
		ldy 	#4
_LICopyTokens:
		lda 	(DTemp1) 					; copy token over.
		sta 	(DTemp5),y
		iny
		iny
		inc 	DTemp1
		inc 	DTemp1
		dec 	DTemp3 						; count - 4 times.
		dec 	DTemp3
		lda 	DTemp3
		cmp 	#4
		bne 	_LICopyTokens
		rts
