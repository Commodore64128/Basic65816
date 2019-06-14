; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		run.asm
;		Purpose : 	Run command.
;		Date :		8th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;								End the Program
;
; *******************************************************************************************

Function_END: ;; end
		cop 	#0

; *******************************************************************************************
;
;								Run the program
;
; *******************************************************************************************

Function_RUN: ;; run
		jsr 	Function_CLEAR 				; clear all variables.
		lda 	DBaseAddress 				; work out the first instruction.
		clc 
		adc 	#Block_ProgramStart 		; so run from here.
		;
		;		Run instruction at A.
		;
_FRun_NextLineNumber:
		tay 								; put in Y
		lda 	$0000,y 					; read the link token.
		beq 	Function_END 				; if zero, off the end of the program
		lda 	$0002,y 					; read the line number
		sta 	DLineNumber 				; and save it.

		tya 								; get address back
		clc 								; skip over the link/line number
		adc 	#4
		sta 	DCodePtr
		;
		;		Next instruction.
		;
_FRun_NextInstruction:
		ldy 	#Block_HighMemoryPtr 		; initialise temporary string below upper area
		lda 	(DBaseAddress),y 			; with enough memory to concrete a string above.
		sec
		sbc 	#256
		sta 	DTempStringPointer
		;
		lda 	(DCodePtr)					; what's next
		beq 	_FRun_EndInstruction		; if end of this line, then go to next line.
		cmp 	#colonTokenID 				; colon then skip
		beq 	_FRun_Colon

		tay 								; save in Y
		and 	#$E800 						; see if it is a keyword. 1111 1xxk kkkk kkkk e.g. types 11xx
		cmp 	#$2800 						; so it only runs 1100-1111 keywords.
		bne 	_FRun_TryLET 				; if not, try LET as a default.
		;
		tya 								; get token back
		and 	#$01FF 						; mask out keyword
		asl 	a 							; double it into X
		tax
		;
		inc 	DCodePtr 					; skip over token
		inc 	DCodePtr 	
		jsr 	(CommandJumpTable,x)		; and call that routine
		bra 	_FRun_NextInstruction 		; do the following instruction.
		;
		;		Skip over colon.
		;
_FRun_Colon:
		inc 	DCodePtr 					; skip over token
		inc 	DCodePtr 	
		bra 	_FRun_NextInstruction 		; do the following instruction.
		;
		;		Maybe we can do a LET , is there an identifier ?
		;
_FRun_TryLET:
		lda 	(DCodePtr) 					; look to see if it's an identifier.
		cmp 	#$C000
		bcc		_FRunSyntax
		jsr 	Function_LET 				; try as a LET.
		bra 	_FRun_NextInstruction 		; if we get away with it, go to next instruction.
_FRunSyntax:
		brl 	SyntaxError		
		;
		;		End of instruction. Go to next line.
		;
_FRun_EndInstruction:
		lda 	DCodePtr 					; address of terminating NULL.
		inc 	a 							; go to link for next line
		inc 	a
		bra 	_FRun_NextLineNumber

; *******************************************************************************************
;
;									Clear all variables
;
; *******************************************************************************************

Function_CLEAR: ;; clear
		jsr 	ClearVariablesPointersAndStacks
		rts

; *******************************************************************************************
;
;									  STOP (faux error)
;
; *******************************************************************************************

Function_STOP: ;; stop
		#error 	"Stop"
		
; *******************************************************************************************
;		
;											Resets
;
;	(i) 	Basic stack
;	(ii)	Pointer used for NULL string
;	(iii)	High memory pointer to top of memory
;	(iv)	Low memory pointer to end of program
;	(v)		Clear the Variable Hash Tables.
;
; *******************************************************************************************

ClearVariablesPointersAndStacks:		
		;
		;		Reset the BASIC stack, which has a zero on it for 'first pop' fail.
		;
		lda 	#BASStack
		sta 	DStack
		stz 	BASStack 					
		;
		;		Clear the value used to refer to an empty string.
		;
		ldy 	#Block_EmptyString 	
		lda 	#$0000
		sta 	(DBaseAddress),y
		;
		;		reset high pointer
		;	
		lda 	DHighAddress				; reset the end of memory pointer
		ldy 	#Block_HighMemoryPtr
		sta 	(DBaseAddress),y
		;
		;		reset low pointer
		;
		jsr 	FindCodeEnd 				; find where the program ends.
		tay 								; Y points to it.
		lda 	#$EEEE 						; put the marker in.
		sta 	$0002,y
		sta 	$0004,y
		tya 								; start of working memory up
		clc
		adc 	#6
		ldy 	#Block_LowMemoryPtr
		sta 	(DBaseAddress),y
		;
		; 		clear the hash table from $80-$1000
		;
		ldy 	#Block_HashTable 			
_FCLoop:
		lda 	#$0000
		sta 	(DBaseAddress),y
		iny
		iny
		cpy 	#Block_HashTable+Block_HashTableEntrySize*4*2
		bne 	_FCLoop
		rts

; *******************************************************************************************
;
;		Return in A the address of the $0000 offset/link at the end of the program.
;
; *******************************************************************************************

FindCodeEnd:
		lda 	#Block_ProgramStart 		; offset to program
		clc
		adc 	DBaseAddress 				; now an actual address
		tay 
_FCELoop:
		lda 	$0000,y 					; get link.
		beq 	_FCEExit
		tya 								; add offset
		clc
		adc 	$0000,y
		tay
		bra 	_FCELoop
_FCEExit:
		tya 								; return in A
		rts

