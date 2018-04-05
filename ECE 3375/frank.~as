PORTA EQU $0000
DDRA EQU $0002
PORTB EQU $0001
DDRB EQU $0003
PUCR EQU $0003
PORTM EQU $0250
DDRM EQU $0252

	 ORG $400
	 LDS #$4000

KEYINIT:
  LDAA #$0F
  STAA DDRB

  LDAA #$02
  STAA PUCR

  CLRA
  STAA DDRM

  BRA CHECK_SW

CHECK_SW:
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

CHECK_SW1:
  JSR Delay
  BRA DRIVE_STEPPER
CHECK_SW1_CONT:
  BRSET PORTB,$F0,CHECK_SW
CHECK_SW2:
  LDAA PORTB
  BRSET PORTB,$F0,*
  JSR Delay
  BRSET PORTB,$F0,CHECK_SW2

DRIVE_STEPPER:
outer   LDAB #3
      STAB index
      LDAA PORTM
      ANDA #1
      BEQ CW
      LDY #cwArray
      BRA assignPtr
CW:   LDY #ccwArray

assignPtr:  
			STY ptr
            LDAB PORTM
            ANDB #2
            ADDB #2
            CLRA
            STD speed

inner       LDY ptr
            LDAB index
            LDAA PORTB
            ANDA #$0F
            ORAA B,Y
            STAA PORTB
            LDX speed
            PSHX
            JSR Delay
            PULX
            DEC index
            BGE inner
            BRA CHECK_SW1_CONT


Delay1MS:       LDX #!1750	; This is a magic number.  Modify to change delay
DelayLoop:      DEX			; time.
                BNE DelayLoop
                RTS

Delay:          JSR Delay1MS
                LDX 2,SP		 ; The decrement can't be done in place
                DEX			 ; DEC 2,X is a one byte operation
                STX 2,SP		 ; That's why I use Y as a temp.
                BEQ DelayEnd
                BRA Delay
DelayEnd        RTS

cwArray: db $90,$60,$10,$40
ccwArray: db $40,$10,$60,$90

    org $1000
index: 	 ds 1
ptr:	 ds 2
speed:	 ds 2