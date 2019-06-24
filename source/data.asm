
; ********************************************************************************
; ********************************************************************************
;
;		Name: 		data.asm
;		Purpose:	Data Description for Basic
;		Date:		6th June 2019
;		Author:		Paul Robson (paul@robsons.org.uk)
;
; ********************************************************************************
; ********************************************************************************

;
;	Direct Page requires 4 pages for data as shown below.
;
DirectPage = $F000 		

;	+000 .. +07F 		General variables
;	+080 .. +1FF 		BASIC stack
;	+200 .. +27F 		Expression Stack.
; 	+260 .. +3FF 		CPU Stack.


; ********************************************************************************
;
;								This is the Zero Page Data
;
; ********************************************************************************

DPBaseAddress = $00 						; Base address used for direct page.
											; (e.g. variables start at DP+nn)

DPageNumber = DPBaseAddress+0 				; page number of workspace area (upper 8 bits of address)
DBaseAddress = DPBaseAddress+2 				; low memory for workspace area
DHighAddress = DPBaseAddress+4 				; high memory for workspace area

DCodePtr = DPBaseAddress+6 					; address of code - current token.

DTempStringPointer = DPBaseAddress + 8	 	; memory allocated to temp string pointer, going down.

DStartTempString = DPBaseAddress + 10 		; start of current temporary string

DCurrentTempString = DPBaseAddress + 12 	; current position in temporary string.

DConstantShift = DPBaseAddress + 14 		; constant shift store.

DVariablePtr = DPBaseAddress + 16			; address of found variable.

DHashTablePtr = DPBaseAddress + 18 			; address of hash entry of searched variable.

DLineNumber = DPBaseAddress + 20 			; current line number.

DSignCount = DPBaseAddress + 22				; Sign count in division.

DCursor = DPBaseAddress + 24 				; cursor (for external routines, not used by BASIC)

DStack = DPBaseAddress + 26					; BASIC stack pointer.

DIndent = DPBaseAddress + 28 				; indent for LIST

DIndent2 = DPBaseAddress + 30 				; previous indent.

DListBuffer = DPBaseAddress + 32 			; list buffer address.

DStack65816 = DPBaseAddress + 34 			; 65816 Stack pointer.

; ********************************************************************************

DLongVars = DPBaseAddress + $40 			; 4 byte variables.

DTemp1 = DLongVars + 0 						; general temporary variables.
DTemp2 = DLongVars + 4
DTemp3 = DLongVars + 8 	
DTemp4 = DLongVars + 12 	
DTemp5 = DLongVars + 16	

DRandom = DLongVars + 20 					; random seed


; ********************************************************************************
;
;								Parameter Buffer area
;
; ********************************************************************************

PRMBuffer = $80							 	; buffer for parameter values.

; ********************************************************************************
;
;									BASIC stack.
;
; ********************************************************************************

BASStack = $C0 								; start of Basic stack.

; ********************************************************************************
;
;			Expression Stack. There are three entries, low and high word
;			and combined type/precedence word.
;
; ********************************************************************************

EXSValueL = 0 								; Low word
EXSValueH = 2  								; High word
EXSPrecType = 4								; Precedence level / type is in bit 15, 1 = string.
EXSNext = 6 								; offset to next level.

; ********************************************************************************
;
;								65816 Stack Starts Here.
;
; ********************************************************************************

CPUStack = $400-2 							; CPU Stack initial value.

