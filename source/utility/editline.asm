; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		editline.asm
;		Purpose : 	Add or Remove line from the program
;		Date :		6th June 2019
;		Author : 	paul@robsons.org.uk
;
;		Note : 		There are currently two pieces of self modifying code.
;					(i) the branch to the binary token handler routine in expression.asm
;					(ii) the branch to the LINK address.
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
_LDLoop:
		lda 	$0000,y 					; look at the link
		beq 	_LDExit						; exit if zero.
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
		tya
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

LineInsert:
		nop		