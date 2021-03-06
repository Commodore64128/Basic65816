; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		for.asm
;		Purpose : 	For / Next structure
;		Date :		14th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;									FOR instruction
;
; *******************************************************************************************

Command_FOR:	;; for
		;
		;		Get the FOR variable, which must be a non array integer. Create if required.
		;
		lda 	(DCodePtr)					; look at first word
		and 	#(IDTypeMask+IDArrayMask)	; check to see if it is type $00 e.g. integer variable
		bne		_CFOBad
		jsr 	VariableFind 				; try to find variable
		bcs 	_CFOExists 					
		;
		jsr 	VariableCreate				; create it and skip token.
		;
		;		Now have the variable used as the index in A
		;
_CFOExists:
		pha 								; push variable address on stack
		lda 	#equalTokenID 				; check for = 
		jsr 	ExpectToken
		;
		;		Get the start value and initialise the index variable
		;
		jsr 	EvaluateInteger 			; this is the start value
		tyx 								; put high value in X
		ply 								; address of for variable in Y
		sta 	$0000,y 					; copy into variable
		txa
		sta 	$0002,y
		;
		;		Skip TO keyword
		;
		lda 	#toTokenID 					; expect the TO
		jsr 	ExpectToken
		;
		;		Save information on the stack for the loop - evaluating the square bracket
		;		part of FOR I = 1 TO [9 STEP 3] each time round.
		;
		ldx 	DStack 						; get the stack.
		lda 	DCodePtr 					; save code ptr at +2 (after "TO")
		sta 	$02,x 						
		lda 	DLineNumber 				; save line number at +4
		sta 	$04,x
		tya 								; save variable address at +6
		sta 	$06,x
		lda 	#forTokenID 				; save for token at +8
		sta 	$08,x
		;
		txa 								; add 8 to stack position
		clc
		adc 	#8
		sta 	DStack
		;
		;		We do not execute this here FOR I = 1 TO [22 STEP 3] it is just skipped over.
		;		We could check it this time and not execute the FOR but most BASICs do not do this.
		;
		;		Skip over <n> [STEP <n>] for now.
		;
		jsr 	EvaluateInteger 			; the end value, which we don't want this time.
		lda 	(DCodePtr)
		cmp 	#stepTokenID 				; if STEP x is present.
		bne 	_CFONoStep
		lda 	#stepTokenID 				; skip STEP
		jsr 	ExpectToken 
		jsr 	EvaluateInteger 			; and whatever the step is, throw away this time.
		;
_CFONoStep:
		rts

_CFOBad:
		#error	"Bad FOR variable"

; *******************************************************************************************
;
;										NEXT <var>
;
; *******************************************************************************************

Command_NEXT: ;; next
		;
		;		Check that the last thing was a FOR.
		;
		ldx 	DStack 						; look at TOS
		lda 	$00,x 		
		cmp 	#forTokenID 				; if not FOR then error
		beq 	_CNXOk
		#error 	"Next without For"
_CNXOk:				
		;
		;		If identifier present (optional) then check it is the same as 
		;	 	the one on the stack.
		;
		lda 	(DCodePtr)					; if there's an identifier here.
		cmp 	#$C000 						; e.g. NEXT <var>
		bcc 	_CNXNoVariable
		;
		jsr 	VariableFind 				; get address of variable.
		bcc 	_CNXNextVar 				; not found variable, it's an error.
		ldx 	DStack 						; point X to variable address
		dex
		dex 
		cmp 	$00,x 						; same variable as the found one.
		beq 	_CNXNoVariable 				; then continue
_CNXNextVar:
		#error 	"Bad NEXT variable"
		;
		; 		Do the actual NEXT code, wind the loop back so we are executing the
		;		FOR I = 1 TO [9 STEP 2] bit - the bit in square brackets.
		;
_CNXNoVariable:
		lda 	DCodePtr 					; save the following position on the stack in case we are done.
		pha
		lda 	DStack 						; subtract 8 from stack
		sec
		sbc 	#8
		sta 	DStack 
		tax 								; X points to the stack.
		;
		lda 	$02,x 						; put the old pointer in the pointer (e.g. after TO)
		sta 	DCodePtr
		;
		;		Now evaluate <target> and optional STEP <step>
		;
		jsr 	EvaluateInteger 			; this is the target constant 
		phy 								; save the target on the stack
		pha
		;
		;		Figure out the STEP, which defaults to 1.
		;
		lda 	#1 							; set DTemp1 (the count) to 1
		sta 	DTemp1
		stz 	DTemp1+2
		lda 	(DCodePtr)					; does a STEP follow.
		cmp 	#stepTokenID
		bne 	_CNXNoStep 
		;
		inc 	DCodePtr 					; skip over the step token.
		inc 	DCodePtr 
		jsr 	EvaluateInteger 			; work out the step.
		sta 	DTemp1 						; and save in DTemp1
		sty 	DTemp1+2
		;
		;		Now calculate the new 32 bit index value
		;
_CNXNoStep:
		pla 								; save the Target in DTemp2
		sta 	DTemp2
		pla 	
		sta 	DTemp2+2		
		;
		ldx 	DStack 						; get the stack
		lda 	$06,x 						; address of the FOR variable into Y
		tay
		;
		; 		Add the step (DTemp1) to the target (at $0000,y)
		;
		clc
		lda 	$0000,y 					
		adc 	DTemp1
		sta 	$0000,y
		lda 	$0002,y
		adc 	DTemp1+2
		sta 	$0002,y
		;
		; 	 	now calculate Target - Index Value
		;
		sec
		lda 	DTemp2
		sbc 	$0000,y
		sta 	DTemp2
		lda 	DTemp2+2
		sbc 	$0002,y
		sta 	DTemp2+2

		ora 	DTemp2 						; if zero (Target = Result)
		beq 	_CNXLoopAgain 				; then loop again, as we have to be past the target.

		lda 	DTemp2+2 					; if sign(target-counter) == sign(step)
		eor 	DTemp1+2
		bpl		_CNXLoopAgain 				; we aren't there yet, so loop again.
		;
		;		Exit the FOR loop
		;
		pla 								; restore the original DCodePtr as we are exiting the structure
		sta 	DCodePtr
		rts
		;
		;		Go round again, i.e. NEXT has decided we need to execute the body again.
		;
_CNXLoopAgain:		
		pla 								; throw the original DCodePtr as we're going back.
		clc
		lda 	DStack 						; fix the stack back so we can loop round again.
		tax
		adc 	#8
		sta 	DStack
		lda		$04,x 						; because we've jumped to the top, get the line number
		sta 	DLineNumber 				; and make that right again.
		rts

