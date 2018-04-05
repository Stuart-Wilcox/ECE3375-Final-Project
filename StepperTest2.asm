
PORTA			EQU $0000
DDRA			EQU $0002

PORTB			EQU $0001
DDRB			EQU $0003

PORTM			EQU $0250
DDRM			EQU $0252

                org $400
                lds #$4000
				
				; Port B to outputs				
				ldaa #$FF
				staa DDRB
				; Port M to input
				clra
				staa DDRM
				ldx #!1750	; Default value for duty cycle
				stx dtmr  	; Pushes our variable to duty cycle
				
outer			ldab #3
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
				jsr Delay
				pulx
				dec index
				bge inner
				bra outer
       
Delay1MS:       ldx dtmr	; This is a magic number.  Modify to change delay
DelayLoop:      dex			; time.
                bne DelayLoop
                rts

Delay:          jsr Delay1MS
                ldX 2,SP		 ; The decrement can't be done in place
                dex			 ; DEC 2,X is a one byte operation
                stX 2,SP		 ; That's why I use Y as a temp.
                beq DelayEnd                
                bra Delay
DelayEnd        rts                        

cwArray: db $90,$60,$10,$40
ccwArray: db $40,$10,$60,$90

		 org $1000
index: 	 ds 1
ptr:	 ds 2
speed:	 ds 2
dtmr:	 ds 2