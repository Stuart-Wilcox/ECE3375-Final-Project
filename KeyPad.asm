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
;*******Timer Initialization**************
;Register offset from $40
TSCR1 	EQU $46							  ;Timer init
TSCR2 	EQU $4D							  ;Scale factor
TIOS 	EQU $40							  ;Compare set
TCTL1 	EQU $48							  ;Counter
TCTL2 	EQU $49
TFLG1 	EQU $4E							  ;Event
TIE 	EQU $4C
TSCNT	EQU $44
TC0 EQU $50	   							  ;Delay Timer
TC1	EQU $52	   							  ;Pin timer
TC4	EQU $58								  
PORTM	EQU $0250
DDRM	EQU $0252
DelayTime EQU !10000					  ;Delay time = 10ms
PinTime EQU !65536
;********Serial Initialization**************************************************
BPS9600: EQU    $34             ; 9600 baud, for SCI baud rate reg. low byte

RegBase: EQU	0
SCI0BDH: EQU    RegBase+$C8        ; SCI 0 baud rate register hi byte
SCI0BDL: EQU    RegBase+$C9        ; SCI 0 baud rate register low byte
SC0CR1:  EQU    RegBase+$CA        ; SCI 0 control register 1
SCI0CR2: EQU    RegBase+$CB        ; SCI 0 control register 2
SCI0SR1: EQU    RegBase+$CC        ; SCI 0 status register 1
SC0SR2:  EQU    RegBase+$CD        ; SCI 0 status register 2
SCI0DRH: EQU    RegBase+$CE        ; SCI 0 data register high byte
SCI0DRL: EQU    RegBase+$CF        ; SCI 0 data register low byte
;*********Variables*************************************************************

		ORG $1000
		
INPUT1: DB 1
INPUT2: DB 1
INPUT3: DB 1
INPUT4: DB 1
PinCount: DB 1
InputCount: DB 1
Stored_RFID_Data: DS 8

;***************Main Routine****************************************************
		ORG $400
		
		LDS #$4000					 ;Load stack pointer
		
		BSET DDRA,%00000000
		
		LDAA #BPS9600
		STAA SCI0BDL
		
		LDAA #$0C	   	   			  ;we need to initialize the perhipheral conditions regarding parity bits, data size, and stop bits 
		STAA SCI0CR2	  			  ;here we are setting parity bit to 1 (None),data size to 8 bits, and stop bits to 1
			  
			  			  		 	  ;we are expecting a data size of 128bytes, for the purpose of this project, the data size is reduced to 8 bytes
			  	  	  	  	  	  	  ;therefore we need to allocate 8 bytes of memory that is pre-allocated
		;Timer Stuff
		BSET TSCR1,%10010000		 ;Enable timer
		BSET TSCR2,%00000011		 ;Scale factor for timer
		BSET TIOS,%00000011			 ;Set delay timer(CH0),pin timer(CH1)to output compare
		BSET TCTL1,%00000000		 ;Disconnect delay and pin timers from external connection
		BSET TCTL2,%00000000
		
KEYINIT:
		BSET DDRB,$0F				 ;Init B0-3 to output, init B4-7 to input (Check if correct DDRB)
		BSET PUCR,$02				 ;Enable PORTB as pullup
		BRA CHECK_SW				 ;Go to main waiting state

Reset:	 LDAB PinCount				 ;Check pin counter
		 CMPB #!10					 ;If its ten, time is up for pin entry
		 BNE CHECK_SW
		 BRA CHECK_SW
		 
CHECK_SW:
		 BRCLR TFLG1,%00000010,Reset ;Check if timer has reached max value
		 
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
Timer:	   LDD TSCNT						 ;Set up timer
		   ADDD PinTime
		   STD TC1
		   LDAB PinCount					 ;increase pin counter 
		   INCB
		   STAB PinCount 
NoTimer:   CMPB #$04						 ;Check if four inputs have been entered
		   BEQ Compare						 ;Branch to compare subroutine
		   LBRA CHECK_SW

Compare:   PULA		   						 ;Get value from stack
		   CMPA PIN4   						 ;Check if pin is correct
		   BEQ Correct1		  				 ;Reset if not
		   LBRA CHECK_SW
Correct1:  PULA
		   CMPA PIN3
		   BEQ Correct2
		   LBRA CHECK_SW
Correct2:  PULA
		   CMPA PIN2
		   BEQ Correct3
		   LBRA CHECK_SW
Correct3:  PULA
		   CMPA PIN1
		   BEQ Correct4
		   LBRA CHECK_SW

Correct4:
		 LBRA CHECK_SW 
		 
		 
Delay: 	 LDD TSCNT    ;Current timer value
		 ADDD DelayTime
		 STD TC0	   ;Store time after 10ms delay
		 BRCLR TFLG1,%00000001,*   ;Spin until compare happens in timer channel 0								
		 RTS