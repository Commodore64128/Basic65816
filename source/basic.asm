; *******************************************************************************************c; *******************************************************************************************
;
;		Name : 		basic.asm
;		Purpose : 	Basic start up
;		Date :		6th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

StartOfBasicCode:

		.include "temp/block.inc"					; block addresses/offsets.
		.include "temp/tokens.inc"					; tokens include file (generated)
		.include "data.asm" 						; data definition.
		.include "expression.asm" 					; expression evaluation
		.include "utility.asm"						; utility stuff.
		.include "stringutils.asm"					; string utility stuff.
		
		.include "binary/arithmetic.asm"			; binary operators
		.include "binary/bitwise.asm"
		.include "binary/comparison.asm"
		.include "binary/divide.asm"
		.include "binary/multiply.asm"
		.include "unary/simpleunary.asm" 			; unary functions.

error	.macro
		jsr 	ErrorHandler 						; call error routine
		.text 	\1,$00 								; with this message
		.endm

; *******************************************************************************************
;
;							Enter BASIC / switch to new instance
;
;	A 	should be set to the page number (e.g. the upper 8 bits)
;	X 	is the base address of the BASIC workspace (lower 16 bits)
;	Y 	is the end address of the BASIC workspace (lower 16 bits)
;
;	Assumes S and DP are set. DP memory is used but not saved on instance switching.
;
; *******************************************************************************************

SwitchBasicInstance:
		rep 	#$30 								; 16 bit A:X mode.
		and 	#$00FF 								; make page number 24 bit
		sta 	DPageNumber 						; save page, base, high in RAM.
		stx		DBaseAddress
		sty 	DHighAddress

		xba 										; put the page number (goes in the DBR) in B
		pha 										; then copy it into B.
		plb
		plb 

		ldy 	#Block_HighMemoryPtr 				; initialise temporary string below upper area
		lda 	(DBaseAddress),y 					; with enough memory to concrete a string above.
		sec
		sbc 	#256
		sta 	DTempStringPointer

		lda 	#$4104
		sta 	DCodePtr
		nop
		jsr 	Evaluate
		nop
		cop 	#2
