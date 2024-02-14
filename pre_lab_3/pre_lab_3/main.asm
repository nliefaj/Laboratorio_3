//*******************************************************************
//ENCABEZADO
//*******************************************************************
// UNIVERSIDAD DEL VALLE DE GUATEMALA
// PROGRAMACIÓN DE MICROCONTROLADORES
// PRE-LABORATORIO 3
// AUTOR: LEFAJ, NATHALIE FAJARDO
//CREADO: 2/13/2024 10:34:14 PM
.INCLUDE "M328PDEF.inc"
.cseg
.org 0x00
	JMP MAIN			//Vector reset
.org 0x08				//Vector interrupçion puerto c
	JMP ISR_PCINT1
.DEF count_pins=R20
.DEF counter=R21

MAIN:
/**********************
                            Stack
**********************/
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17

/**********************
                            SETUP
**********************/

Setup:
	
	LDI R16, 0b0000_0000
	OUT DDRC, R16 //Set PORTC as input

	LDI r16,0b0000_0011 //habilitamos pullup para todos los puertos C (botones)
	OUT PORTC,r16

	LDI R16, 0b1111_1111//Configura el puerto D (LEDS) como salida
	OUT DDRD,R16

	LDI R16, 0b0000_1111
	OUT DDRB, R16 //Set PORTB as output

	LDI R16, 0b0011 //coloca la máscara a lo pines pertenecientes
	STS PCMSK1, R16					

	LDI R16,0b0010//pines de control
	STS PCICR,R16

	SEI					

LOOP:
	//outleds
	OUT PORTB,count_pins
	RJMP LOOP
//************************
// SUB RUTINA
//***********************
ISR_PCINT1:
	PUSH R16
	IN R16,SREG
	PUSH R16

	INC counter
	CPI counter,1
	BREQ JIUMP
	RJMP verificar

verificar:
	CLR counter
	SBIS PORTC,0
	RJMP resta
	RJMP suma

suma:
	INC count_pins
	SBRS count_pins,4
	RJMP JIUMP
	LDI count_pins,0b0000_0000
	RJMP JIUMP
resta:
	DEC count_pins
	SBRS count_pins, 7
	RJMP JIUMP
	CLR count_pins
	RJMP JIUMP

JIUMP:
	POP R16
	OUT SREG,R16
	POP R16
	RETI