; Used for Stepper Motor
PORTA			EQU $0000
DDRA			EQU $0002
PORTB			EQU $0001
DDRB			EQU $0003
PORTM			EQU $0250
DDRM			EQU $0252

; Used for Pot
ADTCTL2	   	  EQU	$122
ADTCTL4 	  EQU	$124
ADTCTL5		  EQU	$125
ADTSTAT0	  EQU	$126
ADT1DR1L	  EQU	$133
; Ignore DDRA and PORTA cuz already def.


                org $400
                lds #$4000
				
				
potInit:		LDAA #%11000000; Initialize ADTCTL2				
				STAA ADTCTL2
				; You should have one of these already, or something like it
				; A software delay is fine.
				ldx #!1000	; 1 ms delay set for A/D Converter.
				stx dtmr  	; Pushes our variable to duty cycle
				JSR Delay1MS
				
				LDAA #%11100101; Initialize ADTCTL4
				;8 bit res, 16AtoD clock periods, clock prescale factor
				STAA ADTCTL4
				
				JSR Delay1MS
				
				LDAA #$FF; Initialize DDRA
				STAA DDRA
				; Initialize A/D
				; Initialize port A for output
				; Initiate sample
				
				
				
				
				
stepperInit:	; Init. the stepper motor paramters				
					
				; Port B to outputs				
				ldaa #$FF
				staa DDRB
				; Port M to input
				clra
				staa DDRM
				ldx #!1750	; Default value for duty cycle
				stx dtmr  	; Pushes our variable to duty cycle
				
				
outer			; MODIFIED FOR A/D SHIT
	
				LDAA #%10000000
				; port 0 config
				STAA ADTCTL5

				BRCLR ADTSTAT0,%10000000,* 	; Spin on correct port 0 or 1 ($126) bit 7 to detect conversion complete
				LDAB ADT1DR1L; Read eight bit A/D data from ATD1DR1L
				;STAA PORTA; Display raw A/D data on the LED bank
				
				; STAB dtmr
				
cmpADval:		
				LDAA #$FF;corresponds to 11111111
				CMPB #!227
				BHS setTmr
	  
	  			LDAA #$7F;corresponds to 01111111
	  	   		CMPB #!199
				BHS setTmr
	  
	  			LDAA #$3F;corresponds to 00111111
				CMPB #!171
				BHS setTmr
	  
	  			LDAA #$1F; corresponds to 00011111
				CMPB #!143
				BHS setTmr
	  
	  			LDAA #$0F; corresponds to 00001111
				CMPB #!115
				BHS setTmr
	  
	  			LDAA #$07; corresponds to 00000111
				CMPB #!87
				BHS setTmr
	  
	  			LDAA #$03;corresponds to 00000011
				CMPB #!59
				BHS setTmr
	  
	  			LDAA #$01;corresponds to 00000001
				CMPB #!31
				BHS setTmr
	  
	  
	  			LDAA #$0
				BRA setTmr				
				
				
setTmr:			STAA dtmr
				
				

				
				; WE LEFT HERE
				
				
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
				jsr Delay
				pulx
				dec index
				bge inner
				lbra outer
       

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