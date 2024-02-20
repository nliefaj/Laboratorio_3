//*******************************************************************
//ENCABEZADO
//*******************************************************************
// UNIVERSIDAD DEL VALLE DE GUATEMALA
// PROGRAMACIÓN DE MICROCONTROLADORES
// PRE-LABORATORIO 3
// AUTOR: LEFAJ, NATHALIE FAJARDO
//CREADO: 2/14/2024 15:52:10 PM
.INCLUDE "M328PDEF.inc"
.cseg
.org 0x00
	JMP MAIN			//Vector reset
.org 0x08				//Vector interrupçion puerto c
	JMP ISR_PCINT1
.org 0x0020
	JMP ISR_TIMER
.DEF count_pins=R20
.DEF counter=R21
.DEF count_decenas=R22

MAIN:
	LDI R16, LOW(RAMEND)
	OUT SPL,R16
	LDI R17,HIGH(RAMEND)
	OUT SPH,R17

	LDI ZH, HIGH(TABLA7SEG<<1)
	LDI ZL, LOW(TABLA7SEG<<1)
	LPM R16,Z
/**********************
                            SETUP
**********************/

Setup:
	LDI R16, 0b0000_1100
	OUT DDRC, R16 //Set PC0 y PC1 como input, y PC2 y PC3 como output

	LDI r16,0b0000_0011 //habilitamos pullup para todos los puertos C (botones)
	OUT PORTC,r16

	LDI R16, 0b1111_1111//Configura el puerto D (LEDS) como salida
	OUT DDRD,R16

	LDI R16, 0b0011_1111
	OUT DDRB, R16 //Set PORTB as output

	LDI R16, 0b0011 //coloca la máscara a lo pines pertenecientes
	STS PCMSK1, R16	
	
	LDI R16,0b0010//pines de control
	STS PCICR,R16

	LDI R16, 0b0000_0011
	STS TCCR0B,R16

	LDI R16,178
	OUT TCNT0,R16

	LDI R16,0b0000_0001
	STS TIMSK0,R16

	LDI R16,0
	STS UCSR0B,R16

	CALL delayT0
	SEI					
LOOP:
	//outleds
	OUT PORTB,count_pins

	//enciende el display que tiene que mostrar y deja que los valores se muestren a tiempo completo
	//bloque unidades
	CBI PORTC,PC3
	LDI ZH, HIGH(TABLA7SEG<<1)
	LDI ZL, LOW(TABLA7SEG<<1)
	ADD ZL,counter
	LPM R24,Z //Load from program memory R16
	LSL R24
	OUT PORTD,R24
	CALL delaybounce
	SBI PORTC,PC3
	CALL delaybounce

	//bloque para decenas
	CBI PORTC,PC2
	LDI ZH, HIGH(TABLA7SEG<<1)
	LDI ZL, LOW(TABLA7SEG<<1)
	ADD ZL,count_decenas
	LPM R24,Z //Load from program memory R16
	LSL R24
	OUT PORTD,R24
	CALL delaybounce
	SBI PORTC,PC2
	CALL delaybounce

	RJMP LOOP
//************************
// SUB RUTINA
//***********************
delayT0:
	LDI R16, (1 << CS02) | (1 << CS00)
	OUT TCCR0B, R16

	LDI R16, 178
	OUT TCNT0, R16

	RET
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

ISR_TIMER:
	PUSH R16
	IN R16,SREG
	PUSH R16

	SBI PORTB,PB5

	LDI R16,100
	OUT TCNT0,R16

	INC R23
	CPI R23, 100
	BRNE SALTO
	CLR R23

	INC counter
	CPI counter, 0b0000_1010
	BREQ overflow
	RJMP SALTO

SALTO:
	POP R16
	OUT SREG,R16
	POP R16
	RETI

overflow:
	LDI counter,0b0000
	INC count_decenas
	CPI count_decenas, 0b0000_0110
	BREQ overflow_decenas
	RJMP SALTO

overflow_decenas:
	LDI count_decenas,0b0000_0000
	RJMP SALTO

delaybounce:
	LDI r16,250//250 para notar el valor de muestreo en los display
	delay:
		DEC r16
		BRNE delay
	RET
//*******************************************************************
//TABLA DE VALORES
//*******************************************************************
TABLA7SEG: .DB 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F,0x77,0x7C,0x39,0x5E,0x79,0x71; Hacer tabla de verdad para ver bien los números