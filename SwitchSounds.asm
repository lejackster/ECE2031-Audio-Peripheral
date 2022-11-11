;	SwitchSounds.asm
;	8 switches for the 8 notes in an octave
;	2 buttons move up and down octaves
;	Only play a tone when one switch is up (handled by VHDL)
;	0x40-0x4F reserved

ORG 0

	JUMP	Loop
	
Loop:
	IN 		Switches
	STORE	SwitchVar
	AND		Bit7
	JPOS	OctaveUpWait

	LOAD	SwitchVar
	AND		Bit8
	JPOS	OctaveDownWait
	
	; Create output to the peripheral in the format understandable
	; Octave 10-7 : SW6-0
	LOAD	Octave
	SHIFT	7		; Shift 7 bits to make room for the scale
	STORE	Octave
	
	LOAD	SwitchVar
	AND		Bit6_0	; Get scale
	ADD		Octave	; Append the octave
	
	OUT 	Output
	JUMP	Loop
	
; make sure both switches 7 & 8 arent up maybe?
OctaveUpWait:
	LOAD	SwitchVar
	AND		Bit7
	JPOS	OctaveUpWait
	JUMP	OctaveUp
	
OctaveDownWait:
	LOAD	SwitchVar
	AND		Bit8
	JPOS	OctaveDownWait
	JUMP	OctaveDown
	
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

;	Variables
Octave:		DW	4
SwitchVar:	DW	0
Scale:		DW	0

;	Useful values
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

;	IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Hex0:      EQU 004
Hex1:      EQU 005
Output:	   EQU &H40
;add buttons
