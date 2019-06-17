; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		basic.asm
;		Purpose : 	Basic start up
;		Date :		6th June 2019
;		Author : 	paul@robsons.org.uk
;
;		Note : 		There are currently two pieces of self modifying code.
;					(i) the branch to the binary token handler routine in expression.asm
;					(ii) the branch to the LINK address.
;
; *******************************************************************************************
; *******************************************************************************************

StartOfBasicCode:

		.include "temp/block.inc"					; block addresses/offsets.
		.include "temp/tokens.inc"					; tokens include file (generated)
		.include "data.asm" 						; data definition.
		.include "expression.asm" 					; expression evaluation
		.include "variable.asm"						; variable management
		.include "utility/utility.asm"				; utility stuff.
		.include "utility/stringutils.asm"			; string utility stuff.
		.include "utility/tokeniser.asm"			; ASCII -> Tokens converter

		.include "binary/arithmetic.asm"			; binary operators
		.include "binary/bitwise.asm"
		.include "binary/comparison.asm"
		.include "binary/divide.asm"
		.include "binary/multiply.asm"

		.include "unary/simpleunary.asm" 			; unary functions.
		.include "unary/string.asm" 				; (left$,right$,mid$)
		.include "unary/memread.asm"				; (peek, deek, leek)
		.include "unary/val.asm"					
		.include "unary/str.asm"
		.include "unary/instr.asm"
		.include "unary/caseconv.asm"				; (upper$,lower$)
		
		.include "commands/let.asm" 				; assignment
		.include "commands/list.asm"				; list / detokenising code.
		.include "commands/print.asm"				; print.
		.include "commands/if.asm"					; conditional execution.
		.include "commands/for.asm"					; loops
		.include "commands/transfer.asm"			; goto/gosub/return on x goto/gosub
		.include "commands/repeat.asm"				; repeat .. until
		.include "commands/while.asm"				; while .. wend
		.include "commands/run.asm" 				; run / end / clear / stop etc.
		.include "commands/dim.asm"					; array dimension
		.include "commands/collect.asm"				; garbage collection code.
		.include "commands/memwrite.asm" 			; write to memory.
		.include "commands/miscellany.asm"			; all other commands

		.include "utility/hwinterface.asm"			; display code.

IDTypeMask = $2000 									; bit masks in identifier.
IDArrayMask = $1000
IDContMask = $0800

UnaryFunction = 8 									; Unary function Token Type ID.
TokenShift = 9										; Token shift to reach precedence.

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
		jsr 	HWClearScreen 						; clear screen		
		and 	#$00FF 								; make page number 24 bit
		sta 	DPageNumber 						; save page, base, high in RAM.
		stx		DBaseAddress
		sty 	DHighAddress

		tsx 										; save the current SP. 										
		stx 	DStack65816 			
		xba 										; put the page number (goes in the DBR) in B
		pha 										; then copy it into B.
		plb
		plb 

		jsr 	ClearVariablesPointersAndStacks		; clear all variables etc.

		
		ldy 	#Block_BootFlag 					; if boot flag zero, warm start
		lda 	(DBaseAddress),y
		beq 	WarmStart
		;
		dec 	a 									; decrement zero.
		sta 	(DBaseAddress),y
		bra 	ExecuteTokenBuffer 					; execute contents of token buffer.

; *******************************************************************************************
;
;									Warm Start (print Ready.)
;
; *******************************************************************************************

WarmStart:
		ldx 	#BasicPrompt & $FFFF
		jsr 	PrintROMMessage

; *******************************************************************************************
;
;			Next command, reset CPU stack, get command, tokenise and do it.
;
; *******************************************************************************************

NextCommand:		
		ldx 	DStack65816 						; reset the CPU stack
		txs
		ldy 	#Block_BootFlag 					; if the boot flag is non-zero 
		lda 	(DBaseAddress),y
		bne 	ExitEmulator
		nop				
w1:		bra 	w1

ExecuteTokenBuffer:		
		jmp 	RUNExecuteTokenBuffer 				; execute the token buffer

ExitEmulator:
		cop 	#0

BasicPrompt:
		.text 	"Ready.",13,0

