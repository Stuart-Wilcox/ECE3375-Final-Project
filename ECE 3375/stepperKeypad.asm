; Used for Stepper Motor
PORTA			EQU $0000
DDRA			EQU $0002
PORTB			EQU $0001
DDRB			EQU $0003
PORTM			EQU $0250
DDRM			EQU $0252


                org $400
                lds #$4000
							
				
				
stepperInit:	; Init. the stepper motor paramters				
					
				; Port B to outputs				
				ldaa #$FF
				staa DDRB
				; Port M to input
				clra
				staa DDRM
				ldx #!1750	; Default value for duty cycle
				stx dtmr  	; Pushes our variable to duty cycle

keypadInit: 	ldaa #$0F
				staa $03 ; Set port B for in[7..4], out[3..0]
				ldaa #$FF 
				staa $02  ; Set port A for output only
				
				
outer			
	  			LDAA #$0
				STAA dtmr
				
				
				; Regular stuff for stepper

	 			ldab #3
				stab index
				ldaa PORTM
				ANDA #1	  ; check direction bit
				BEQ	 CW
				ldy #cwArray
				BRA assignPtr
				

CW:				ldy #ccwArray


assignPtr:		STY ptr				
				LDAB PORTM
				ANDB #2
				ADDB #2
				clra
				STD speed


inner			ldy ptr
				ldab index
				LDAA PORTB
				ANDA #$0F
				ORaA B,Y
				staa PORTB
				ldx speed
				pshx
				jsr StepperDelay
				pulx
				dec index
				bge inner
				lbra ReScan
       

StepperDelay1MS:       ldx dtmr	; This is a magic number.  Modify to change delay


StepperDelayLoop:      dex			; time.
                bne StepperDelayLoop
                rts


StepperDelay:          jsr StepperDelay1MS
                ldX 2,SP		 ; The decrement can't be done in place
                dex			 ; DEC 2,X is a one byte operation
                stX 2,SP		 ; That's why I use Y as a temp.
                beq StepperDelayEnd                
                bra StepperDelay

StepperDelayEnd        rts                        


cwArray: db $90,$60,$10,$40
ccwArray: db $40,$10,$60,$90

		 org $1000
index: 	 ds 1
ptr:	 ds 2
speed:	 ds 2
dtmr:	 ds 2


;*************************KEYPAD************

				
ReScan:			des	 ; Create room on the stack for the return value
				jsr ScanOnce  ; Do one scan of the keypad
				pula		  ; Get the return value
				cmpa #$FF	  ; Invalid return value
				beq ReScan
				psha	  	  ; Store the current return value
				ldy #!50  	  ; 50 ms debounce delay
				pshy
				jsr Delay
				ins		 	  ; Only clean up one byte, since we need RValue
				jsr ScanOnce  ; Do another scan
				pula		  ; Get the return value
				pulb		  ; Get the previous return value
				cba			  ; Are they the same?
				bne ReScan	  ; If not, do nothing
				staa $0		  ; Else, write to the LED bank.
				lbra outer
				
										
ScanOnce:       clrb
top:            ldx #OutputMasks	; This lookup table contains the
                ldaa b,x			; single-zero outputs for the
                staa $1				; columns
				jsr Delay1MS		; Wait so the output can settle
                ldaa $1				; Read the input
                lsra 				; Shift right four times.  The rows
                lsra				; are in the high order bits
                lsra
                lsra
                anda #$0F			; Input $F means no key pressed
                cmpa #$0F			; Input anything else means keypressed
                beq next_test		; On $F, move to the next column
                ldx #ColAddr		; On not-$F, load the current column
                ldy b,x				; look-up table
                ldaa a,y; At this point, A contains the solution
				tsx
                staa 2,x  	 	  	; Write the answer to the stack
				rts	 				; and return
next_test:      incb				; We need to increment twice so B will 
                incb				; properly index the row and column tables
                cmpb #8				; When B reaches 8, we're done
                blt top
                ldaa #$FF			; If B reached 8, return $FF to indicate
				tsx	 				; no key pressed
				staa 2,x
				rts                

; OK.  Valid values are single zeros, so that's 7, B, D, E.  Others fault                
ColOne:         db  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$0A,$FF,$FF,$FF,$07,$FF,$04,$01,$FF
ColTwo:         db  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$FF,$FF,$FF,$08,$FF,$05,$02,$FF
ColThree:       db  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$0B,$FF,$FF,$FF,$09,$FF,$06,$03,$FF
ColFour:        db  $FF,$FF,$FF,$FF,$FF,$FF,$FF,$0C,$FF,$FF,$FF,$0D,$FF,$0E,$0F,$FF

ColAddr:        dw  ColOne,ColTwo,ColThree,ColFour

; Output mask must be padded, so we can step by 2s through the ColAddr array
OutputMasks:    db $E,$FF,$D,$Ff,$B,$FF,$7,$FF

Delay1MS:       ldx #!200	; This is a magic number.  Modify to change delay
DelayLoop:      dex			; time.
                bne DelayLoop
                rts

Delay:          tsx
                ldy 2,x		 ; The decrement can't be done in place.
                dey	   		 ; DEC 2,X is a one byte operation
                sty 2,x		 ; That's why I use Y as a temp.
                beq DelayEnd
                jsr Delay1MS
                bra Delay
DelayEnd        rts                        

