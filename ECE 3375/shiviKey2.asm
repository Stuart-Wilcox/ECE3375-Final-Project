;******Keypad Initialization*********
PORTB: EQU $01 		;Init PORTB
DDRB: EQU $03  		;Init PORTB init
PUCR: EQU $000C		;Pull up control register

PORTA: EQU 0
DDRA: EQU 2

;Correct Pin
PIN1: EQU %11101110	  ;Key 1
PIN2: EQU %11101101	  ;Key 2
PIN3: EQU %11101011	  ;Key 3
PIN4: EQU %11011110	  ;Key 4

; WE GONNA ADD SUM MOR

;************************************

;*********Variables*************************************************************

		ORG $1000
		
INPUT1: DB 1
INPUT2: DB 1
INPUT3: DB 1
INPUT4: DB 1
PinCount: DB 1
InputCount: DB 1
;******************************************************************************



KEYINIT:
		BSET DDRB,$0F				 ;Init B0-3 to output, init B4-7 to input (Check if correct DDRB)
		BSET PUCR,$02				 ;Enable PORTB as pullup
		JSR HRESET					 ;Hard reset system
		BRA CHECK_SW				 ;Go to main waiting state
		
Reset:	 LDAB PinCount				 ;Check pin counter
		 CMPB #!10					 ;If its ten, time is up for pin entry
		 BNE CHECK_SW
		 JSR HReset	 				 ;Hard reset
		 BRA CHECK_SW
		 
CHECK_SW:
		 ;BRCLR TFLG1,%00000010,Reset ;Check if timer has reached max value
		 
		 CLRB
		 
		 ;First Row
		 LDAA #%00001110
		 STAA PORTB
		 BRCLR PORTB,%00010000,CHECK_SW1
		 BRCLR PORTB,%00100000,CHECK_SW1
		 BRCLR PORTB,%01000000,CHECK_SW1
		 BRCLR PORTB,%10000000,CHECK_SW1
		 
		 ;Second Row
		 LDAA #%00001101
		 STAA PORTB
		 BRCLR PORTB,%00010000,CHECK_SW1
		 BRCLR PORTB,%00100000,CHECK_SW1
		 BRCLR PORTB,%01000000,CHECK_SW1
		 BRCLR PORTB,%10000000,CHECK_SW1
		 
		 ;Third Row
		 LDAA #%00001011
		 STAA PORTB
		 BRCLR PORTB,%00010000,CHECK_SW1
		 BRCLR PORTB,%00100000,CHECK_SW1
		 BRCLR PORTB,%01000000,CHECK_SW1
		 BRCLR PORTB,%10000000,CHECK_SW1
		 
		 ;Fourth Row
		 LDAA #%00000111
		 STAA PORTB
		 BRCLR PORTB,%00010000,CHECK_SW1
		 BRCLR PORTB,%00100000,CHECK_SW1
		 BRCLR PORTB,%01000000,CHECK_SW1
		 BRCLR PORTB,%10000000,CHECK_SW1
		 
		 BRA CHECK_SW
		 
CHECK_SW1: JSR Delay
		   BRSET PORTB,$F0,CHECK_SW		 ;Check if not pressed
CHECK_SW2: LDAA PORTB						 ;Load read value into acc A
		   BRSET PORTB,$F0,*				 ;Check for switch release
		   PSHA	 							 ;Store read value temporarily on stack
		   JSR Delay						 ;delay for release
		   PULA								 ;Pull value off stack
		   BRSET PORTB,$F0,CHECK_SW2		 ;if false release
		   LDAB InputCount
		   INCB  							 ;Add one to input counter
		   STAB InputCount
		   PSHA	 							 ;Push input on stack
		   CMPB #$01						 ;Check if first input
		   BNE NoTimer						 ;If not, nothing needs to be done

NoTimer:   CMPB #$04						 ;Check if four inputs have been entered
		   BEQ Compare						 ;Branch to compare subroutine
		   LBRA CHECK_SW

Compare:   PULA		   						 ;Get value from stack
		   CMPA PIN4   						 ;Check if pin is correct
		   BEQ Correct1		  				 ;Reset if not
		   JSR HReset
		   LBRA CHECK_SW
Correct1:  PULA
		   CMPA PIN3
		   BEQ Correct2
		   JSR HReset
		   LBRA CHECK_SW
Correct2:  PULA
		   CMPA PIN2
		   BEQ Correct3
		   JSR HReset
		   LBRA CHECK_SW
Correct3:  PULA
		   CMPA PIN1
		   BEQ Correct4
		   JSR HReset
		   LBRA CHECK_SW
Correct4:  BRA RFID		

RFID: 	   STAA PORTA


Delay1MS:       ldx #!1000	; This is a magic number.  Modify to change delay


DelayLoop:      dex			; time.
                bne DelayLoop
                rts


Delay:          jsr Delay1MS
                ldX 2,SP		 ; The decrement can't be done in place
                dex			 ; DEC 2,X is a one byte operation
                stX 2,SP		 ; That's why I use Y as a temp.
                beq DelayEnd                
                bra Delay
				
DelayEnd: 		rts
		 
		 
HReset:	 CLRB
		 STAB PinCount
		 STAB InputCount
		 LDS #$4000
		 STAB INPUT1
		 STAB INPUT2
		 STAB INPUT3
		 STAB INPUT4
		 JSR Flash	 				 ;Flash lights
		 RTS
		 
		 
Flash:	 LDAA #%11111111
		 LDAB #!5