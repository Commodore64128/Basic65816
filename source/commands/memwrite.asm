; *******************************************************************************************
; *******************************************************************************************
;
;		Name : 		memwrite.asm
;		Purpose : 	Poke Doke Loke commands
;		Date :		14th June 2019
;		Author : 	paul@robsons.org.uk
;
; *******************************************************************************************
; *******************************************************************************************

; *******************************************************************************************
;
;											POKE
;
; *******************************************************************************************

Command_POKE:	;; poke
		jsr 	EvaluateInteger 			; address
		pha	 								; save on stack
		phy
		jsr 	ExpectComma 				; comma seperator.
		jsr 	EvaluateInteger 			; data

		plx 								; pull address and store in DTemp1
		stx 	DTemp1+2
		plx 	
		stx 	DTemp1+0

		sep 	#$20 						; byte mode
		sta 	[DTemp1]					; write it
		rep 	#$20 						; word mode
		rts

; *******************************************************************************************
;
;											DOKE
;
; *******************************************************************************************

Command_DOKE:	;; doke
		jsr 	EvaluateInteger 			; address
		pha	 								; save on stack
		phy
		jsr 	ExpectComma 				; comma seperator.
		jsr 	EvaluateInteger 			; data

		plx 								; pull address and store in DTemp1
		stx 	DTemp1+2
		plx 	
		stx 	DTemp1+0

		sta 	[DTemp1]					; write it
		rts

; *******************************************************************************************
;
;											LOKE
;
; *******************************************************************************************

Command_LOKE:	;; loke
		jsr 	EvaluateInteger 			; address
		pha	 								; save on stack
		phy
		jsr 	ExpectComma 				; comma seperator.
		jsr 	EvaluateInteger 			; data

		plx 								; pull address and store in DTemp1
		stx 	DTemp1+2
		plx 	
		stx 	DTemp1+0

		sta 	[DTemp1]					; write it (low)
		tya
		ldy 	#2
		sta 	[DTemp1],y 					; write it (high)
		rts

