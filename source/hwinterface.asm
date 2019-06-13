; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		hwinterface.asm
;		Purpose : 	I/O Interface to fake emulated hardware (not part of BASIC)
;		Date :		12th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

HWCursorCharacter = $01

sWidth = 64
sHeight = 32

; *******************************************************************************************
;
;								Clear screen and home cursor
;
; *******************************************************************************************

HWClearScreen:
		pha
		phx
		ldx 	#sWidth*sHeight-2
_CS0:	lda 	#$2020
		sta 	$F0000,x
		dex
		bpl 	_CS0
		stz 	DCursor
		lda 	#$2000+HWCursorCharacter
		sta 	$F0000
		plx
		pla
		rts
		
; *******************************************************************************************
;
;			Output a single character (in A). This is an actual visible character
;			as all character values 0-255 can be in a string.
;
; *******************************************************************************************

HWPrintChar:
		pha
		phx
		ldx 	DCursor
		sep 	#$20
		sta 	$F0000,x
		rep 	#$20
		inx
		txa
		and 	#(sWidth*sHeight-1)
		sta 	DCursor
		tax
		lda 	#HWCursorCharacter
		sep 	#$20
		sta 	$F0000,x
		rep 	#$20
		plx
		pla
		rts

; *******************************************************************************************
;
;								Print a new line and TAB (share code)
;
; *******************************************************************************************

HWNewLine:
		pha
		phx
		ldx 	#sWidth-1
HWMoveCursor:
		lda 	#32
		jsr 	HWPrintChar
		txa
		and 	DCursor
		bne 	HWMoveCursor
		plx
		pla
		rts
		
HWTab:	pha 
		phx
		ldx 	#7
		bra 	HWMoveCursor		
