;	SwitchSounds.asm
;	8 switches for the 8 notes in an octave
;	2 buttons move up and down octaves
;	Only play a tone when one switch is up (handled by VHDL)
;	0x40-0x4F reserved

ORG 0

	; Sine wave
	
	; Measure 1
	; G3 triplet
	LOADI	3				; 3	
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit2			; G
	OUT		Output			; R channel
	OUT		Hex0
	CALL	Delay_Triplet
	; C4 and E3 triplet
	LOADI	0
	OUT		Output			; Reset R channel

	LOADI	1				; L channel
	SHIFT	15
	AND		Bit15
	STORE	Channel
	LOADI	4				; 4		
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit6			; C
	OUT		Hex0
	ADD		Channel
	OUT		Output
	LOADI	3				; 3	
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit4			; E
	OUT		Output			; R channel
	CALL	Delay_Triplet
	; E4 and G3 triplet
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	4				; 4		
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit4			; E
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	3				; 3	
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit2			; G
	OUT		Output			; R channel
	CALL	Delay_Triplet
	; G4 and E3 triplet
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	4				; 4
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit2			; G
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	3				; 3
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit4			; E
	OUT		Output			; R channel
	CALL	Delay_Triplet
	; C5 and G3 triplet
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	5				; 5
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit6			; C
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	3				; 3
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit2			; G
	OUT		Output			; R channel
	CALL	Delay_Triplet
	; E5 and C4 triplet
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	5				; 5
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit4			; E
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	4				; 4
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit6			; C
	OUT		Output			; R channel
	CALL	Delay_Triplet
	; G5 and E4 quarter
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	5				; 5
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit4			; G
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	4				; 4
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit4			; E
	OUT		Output			; R channel
	CALL	Delay
	; E5 and C4 quarter
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	5				; 5
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit4			; E
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	4				; 4
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit6			; C
	OUT		Output			; R channel
	CALL	Delay
	
	; Measure 2
	; Ab3 triplet
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	3				; 3
	SHIFT	7			
	AND		Bit9_7			
	ADD		&B0000000110	; Ab
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	CALL	Delay_Triplet
	; C4 and Eb3 triplet
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	4				; 4
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit6			; C
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	3				; 3
	SHIFT	7			
	AND		Bit9_7			
	ADD		Eb				; Eb
	OUT		Output			; R channel
	CALL	Delay_Triplet
	; Eb4 and Ab3 triplet
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	4				; 4
	SHIFT	7			
	AND		Bit9_7			
	ADD		Eb				; Eb
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	3				; 3
	SHIFT	7			
	AND		Bit9_7			
	ADD		Ab				; Ab
	OUT		Output			; R channel
	CALL	Delay_Triplet
	; Ab4 and Eb3 triplet
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	4				; 4
	SHIFT	7			
	AND		Bit9_7			
	ADD		Ab				; Ab
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	3				; 3
	SHIFT	7			
	AND		Bit9_7			
	ADD		Eb				; Eb
	OUT		Output			; R channel
	CALL	Delay_Triplet
	; C5 and Ab3 triplet
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	5				; 5
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit6			; C
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	3				; 3
	SHIFT	7			
	AND		Bit9_7			
	ADD		Ab				; Ab
	OUT		Output			; R channel
	CALL	Delay_Triplet
	; Eb5 and C4 triplet
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	5				; 5
	SHIFT	7			
	AND		Bit9_7			
	ADD		Eb				; Eb
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	4				; 4
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit6			; C
	OUT		Output			; R channel
	CALL	Delay_Triplet
	; Ab5 and Eb4 quarter
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	5				; 5
	SHIFT	7			
	AND		Bit9_7			
	ADD		Ab				; Ab
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	4				; 4
	SHIFT	7			
	AND		Bit9_7			
	ADD		Eb				; Eb
	OUT		Output			; R channel
	CALL	Delay
	; Eb5 and C4 quarter
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	5				; 5
	SHIFT	7			
	AND		Bit9_7			
	ADD		Eb				; Eb
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	LOADI	4				; 4
	SHIFT	7			
	AND		Bit9_7			
	ADD		Bit6			; C
	OUT		Output			; R channel
	CALL	Delay
	
	;Measure 3
	LOADI	0
	OUT		Output			; Reset R channel
	LOADI	3				; 3
	SHIFT	7			
	AND		Bit9_7			
	ADD		Ab				; Ab
	OUT		Hex0
	ADD		Channel			; L channel
	OUT		Output
	CALL	Delay_Triplet
	
	LOADI	0				; Reset sound
	OUT		Output
	LOAD	Channel
	OUT		Output
	
	LOADI	3				; Reset octave
	STORE	Octave
	
	JUMP	Loop
	
	
; Main interactive demo functionality
Loop:
	IN 		Switches		; Take in switch bits
	STORE	SwitchVar
	AND		Bit7			; Check if SW7 is up for octave up
	JPOS	OctaveUpWait	; Constantly loop until SW7 is down

	LOAD	SwitchVar
	AND		Bit8			; Check if SW8 if up for octave down
	JPOS	OctaveDownWait	; Constantly loop until SW8 is down
	
	
; Create output to the peripheral in the format understandable
; Channel 15 : Octave 9-7 : SW 6-0
	
	LOAD	Octave			
	SHIFT	7				; Shift octave 7 places
	AND		Bit9_7			; Bitmask 9_7 to make sure no overflow
	STORE 	Octave
	
	LOAD	SwitchVar		; Get toggle and shift 15 places
	AND		Bit9
	SHIFT	6
	AND		Bit15
	STORE	Channel
	
	LOAD	SwitchVar
	AND		Bit6_0
	ADD		Octave			; Append the octave
	ADD		Channel			; Append the channel toggle		
	OUT 	Output			; Out the bit vector to peripheral
	
	LOAD	Octave
	SHIFT	-7
	STORE 	Octave
	
	LOAD	Octave
	ADDI	1
	OUT		Hex0			; Out the current octave to peripheral
	
	JUMP	Loop
	
; Make sure both switches 7 & 8 arent both up maybe?

; Subroutines

; Octaves
OctaveUpWait:
	IN		Switches
	AND		Bit7
	JZERO	OctaveUp
	JUMP	OctaveUpWait
OctaveDownWait:
	IN		Switches
	AND		Bit8
	JZERO	OctaveDown
	JUMP	OctaveDownWait
OctaveUp:
	LOAD	Octave
	ADDI	1
	STORE	Octave
	JUMP	Loop
OctaveDown:
	LOAD	Octave
	ADDI	-1
	STORE	Octave
	JUMP	Loop

Delay:
	OUT		Timer
WaitingLoop:
	IN		Timer
	ADDI	-6
	JNEG	WaitingLoop
	
Delay_Triplet:
	OUT		Timer
WaitingLoop_Triplet:
	IN		Timer
	ADDI	-2
	JNEG	WaitingLoop_Triplet
	RETURN

;	Variables
Octave:		DW 3
SwitchVar:	DW 0
Channel:	DW 0

;	Useful values
Eb:			DW &B0000110000
Ab:			DW &B0000000110
Bb:			DW &B0000000011

Bit0:		DW &B0000000001
Bit1:		DW &B0000000010
Bit2:		DW &B0000000100
Bit3:		DW &B0000001000
Bit4:		DW &B0000010000
Bit5:		DW &B0000100000
Bit6:		DW &B0001000000
Bit7:		DW &B0010000000
Bit8:		DW &B0100000000
Bit9:		DW &B1000000000
Bit6_0: 	DW &B0001111111
Bit9_7:		DW &B1110000000
Bit15:		DW &B1000000000000000
Bit15_0:	DW &B1111111111111111

;	IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004
Hex1:      EQU 005
Output:	   EQU &H40
