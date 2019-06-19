; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		stringconcrete.asm
;		Purpose : 	Concrete strings into permanent storage.
;		Date :		19th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;							Reset the string permanent memory
;
; *******************************************************************************************

StringResetPermanent:
		lda 	DHighAddress				; reset the end of memory pointer
		ldy 	#Block_HighMemoryPtr
		sta 	(DBaseAddress),y
		rts

; *******************************************************************************************
;
;						Make String at A concrete, return new string in A
;
; *******************************************************************************************

StringMakeConcrete:
		ldy 	#Block_LowMemoryPtr 		; compare the address against low memory.
		cmp 	(DBaseAddress),y 			; if the address is < this, then it doesn't need concreting.
		bcc 	_SMCExit
		;
		sta 	DTemp1 						; source 
		lda 	(DTemp1)					; get length
		and 	#$00FF
		bne 	_SMCNonZero 				; if not "" skip.
		;
		lda 	#Block_EmptyString 			; empty string, return the null pointer in low memory
		clc 								; this reference is used for all empty strings.
		adc 	DBaseAddress
_SMCExit:		
		rts
		;
		;		String is not empty, so allocate high memory for it.
		;
_SMCNonZero:
		pha 								; save on stack.
		;
		eor 	#$FFFF 						; 2's complement with carry clear, allocate one more.
		clc
		ldy 	#Block_HighMemoryPtr 		; add to the high pointer to create space
		adc 	(DBaseAddress),y
		sta 	(DBaseAddress),y
		sta 	DTemp2 						; target
		;
		ply 								; get length copy from here until Y goes -ve
		sep 	#$20 						; 8 bit mode.
_SMCLoop:
		lda 	(DTemp1),y 					; copy from source to target
		sta 	(DTemp2),y
		dey 								; Y+1 times.
		bpl 	_SMCLoop
		rep 	#$20 						; 16 bit mode.
		lda 	DTemp2 						; return new string address.
		rts
