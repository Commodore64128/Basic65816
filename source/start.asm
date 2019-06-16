; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		start.asm
;		Purpose : 	Test bed for BASIC
;		Date :		6th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

	* = 0
		clc											; switch into 65816 16 bit mode.
		xce	
		rep 	#$30 									
		.al	
		.xl
		ldx 	#DirectPage+CPUStack 				; 65816 Stack
		txs
		lda 	#DirectPage 						; set Direct Page.
		tcd
		lda 	#CodeSpace >> 16 					; put the page number in A ($2)
		ldx 	#CodeSpace & $FFFF 					; and the base address in X ($4000)
		ldy 	#CodeEndSpace & $FFFF				; and the end address in Y ($C000)
	
		jmp 	SwitchBasicInstance

;
;			The BASIC Rom image.
;
		* = $10000
		.include "basic.asm" 						; this is the BASIC image

;
;		Routines for automatic testing.
;
		.include "utility/testing.asm"													
		
;
;		Demo BASIC instance.
;
		*=$24000 									; actual BASIC block goes here, demo at 02:4000
CodeSpace:
		.binary "temp/basic.bin"
CodeEndSpace:

