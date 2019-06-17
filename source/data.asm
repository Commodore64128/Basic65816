
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

DTemp1 = DPBaseAddress + 8 					; *** LONG *** Temporary value
DTemp2 = DPBaseAddress + 12 				; *** LONG *** Temporary value

DRandom = DPBaseAddress + 16 				; *** LONG *** Random Seed

DSignCount = DPBaseAddress + 20 			; Sign count in division.

DTempStringPointer = DPBaseAddress + 22 	; memory allocated to temp string pointer, going down.
DStartTempString = DPBaseAddress + 24 		; start of current temporary string
DCurrentTempString = DPBaseAddress + 26 	; current position in temporary string.

DConstantShift = DPBaseAddress + 28 		; constant shift store.

DVariablePtr = DPBaseAddress + 30 			; address of found variable.

DHashTablePtr = DPBaseAddress + 32 			; address of hash entry of searched variable.

DLineNumber = DPBaseAddress + 34 			; current line number.

DTemp3 = DPBaseAddress + 36 				; *** LONG *** Temporary Value.

DCursor = DPBaseAddress + 40 				; cursor (for external routines, not used by BASIC)

DStack = DPBaseAddress + 42 				; BASIC stack pointer.

DIndent = DPBaseAddress + 44 				; indent for LIST
DIndent2 = DPBaseAddress + 46 				; previous indent.
DListBuffer = DPBaseAddress + 48 			; list buffer address.

DTemp4 = DPBaseAddress + 50 				; *** LONG *** Temporary Value

DTemp5 = DPBaseAddress + 54 				; *** LONG *** Temporary Value

DStack65816 = DPBaseAddress + 58 			; 65816 Stack pointer.

; ********************************************************************************
;
;									BASIC stack.
;
; ********************************************************************************

BASStack = $80 								; start of Basic stack.
BASStackSize = $180 						; maximum size of BASIC stack.

; ********************************************************************************
;
;			Expression Stack. There are three entries, low and high word
;			and combined type/precedence word.
;
; ********************************************************************************

EXSBase = $200 								; Initial value of X at lowest stack level.

EXSStackElements = 16 						; depth of stack.

											; offsets from stack base (each stack element = 2 bytes)
EXSValueL = 0 								; Low word
EXSValueH = EXSStackElements*2  			; High word
EXSPrecType = EXSStackElements*2*2			; Precedence level / type is in bit 15, 1 = string.

; ********************************************************************************
;
;								65816 Stack Starts Here.
;
; ********************************************************************************

CPUStack = EXSBase+$200-2 					; CPU Stack initial value.

