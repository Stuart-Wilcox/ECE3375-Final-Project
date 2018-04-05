

PORTA: 	equ $0000 ; port A data register
DDRA: 	equ $0002 ; port A data direction register
PUCR: 	equ $000C ; port A, B, E and K pullup control register


Init: 		  bset DDRA,$00 ; set port A to inputs
			  bset PUCR,$01 ; enable pullup devices for all port A inputs


CheckSw:   	  brclr PORTA,$01,CheckSw1 ; check to see if switch pressed

NoPress: 	  clra ; no press detected, return 0 in accumulator A
		 	  rts ; return

CheckSw1: 	  ldaa #!10 ; yes, switch press detected, now debounce
			  bsr Delay ; 10mS delay for debounce
			  brset PORTA,$01,NoPress ; if switch press not detected after debounce, return

CheckSw2: 	  brclr PORTA,$01,* ; wait here until switch release detected
			  ldaa #!10 ; 10mS delay for release of switch press
			  bsr Delay
			  brclr PORTA,$01,CheckSw2 ; if false release, wait for release
			  ldaa #1 ; switch released, return valid key press condition
			  rts

				
				
Delay10MS:    ldx #!10000	; This is a magic number.  Modify to change delay


DelayLoop:    dex			; time.
              bne DelayLoop
              rts


Delay:     	  jsr Delay10MS
              ldX 2,SP		 ; The decrement can't be done in place
              dex			 	 ; DEC 2,X is a one byte operation
              stX 2,SP		 ; That's why I use Y as a temp.
              beq DelayEnd                
              bra Delay

DelayEnd      rts  
				
