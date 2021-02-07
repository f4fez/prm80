//    Copyright (c) 2007, 2015 Florian MAZEN and Pierre COL
//    
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY// without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include "80c552.h"
#include "sys.h"
#include "main.h"

/**
 * First latch buffer
 *  b0: /TX Power			b1: N/A
 *  b2: Out ALM      		b3: Out 1
 *  b4: Out 2				b5: Mike mute
 *  b6: Clock shift			b7: synthesizer validation
 */
__data unsigned char serial_latch_lo = 0x81;	
/**
 * Second latch buffer.
 *  b0: 	Vol 3 (MSB)			b1: Vol 2
 *  b2: 	Vol 1          		b3: Vol 0 (LSB)
 *  b4: 	RX mute				b5: 9v8
 *  b6: 	TX/RX				b7: PA on
 */
__data unsigned char serial_latch_hi = 0x31;	

inline void wdt_reset() {
	__asm
		orl	PCON, #0x10
		mov	_T3, #WDT_INT
	__endasm;
}

/**
 * Send a single byte to the serial latch.
 * \param b Byte to send
 */
static void sys_send_serial_latch_byte(unsigned char b) {
	b;
	__asm
		mov		r2, #8					; 8 bytes: 8 loops
		mov		a, dpl
	00001$:
		clr		_PIN_SCLK				; Clock low level
		mov		c, acc.7				; Copy byte to transfer in C
		mov		_PIN_SDATA, c			; puis recopie sur le port
		nop
		nop
		setb	_PIN_SCLK				; Generer un front montant
		rl		a						; Preparer bit suivant
		djnz	r2,00001$				; fin de la boucle
	__endasm;
}

void sys_load_serial_latch() {
	wdt_reset();
	sys_send_serial_latch_byte(serial_latch_hi);
	sys_send_serial_latch_byte(serial_latch_lo);
	PIN_SCLK = 0; 		// Clock pin low level
	PIN_LACTH_STR = 1; 	// Generate a front to apply the output
	//PIN_LATCH_OE = 0;
	PIN_LACTH_STR = 0;
}

void sys_init() {
	// Ports initialisation
	P1 = 0x5d;
	P3 = 0xdf;
	P4 = 0xf9; //fb : mute ?
	P5 = 0xff;
	
	/*
	// ADC Initialisation
	mov	r0, #80h			; ADC en mode 8 bits
	mov	auxr1, r0*/
	
	// PWM initialisation
	PWMP = PWM_FREQ;
	
	// Timer initialisation
	TMOD = 0b00100001;
	
	//TR0 = 1; // Enable timer 0
	//ET0 = 1; // Enable timer interrupt

	// Initialize latch
	sys_load_serial_latch();
	sys_enable_latch_output();

	serial_init();

	EA = 1;
}

void sys_enable_latch_output() {
	PIN_LATCH_OE = 0;
}

unsigned char sys_read_buttons() {
	#if DEVICE == TYPE_PRM8060
	__asm
		mov		b, #0
		mov		dptr, #0x0d000
		movx	a, @dptr
		mov		r0, a
		jb		acc.1, 00011$
		setb	b.0
	00011$:
		jb		acc.2, 00012$
		setb	b.1
	00012$:
		mov		dptr, #0x0e000
		movx	a, @dptr
		mov		r0, a
		jb		acc.1, 00013$
		setb	b.2
	00013$:
		jb		acc.2, 00014$
		setb	b.3
	00014$:
	__endasm;
	#endif
	
	#if DEVICE == TYPE_PRM8070
	__asm
		mov		b, #0
		mov		dptr, #0x0d000
		movx	a, @dptr
		mov		r0, a
		jb		acc.0, 00020$
		setb	b.0
	00020$:
		jb		acc.1, 00021$
		setb	b.1
	00021$:
		jb		acc.2, 00022$
		setb	b.2
	00022$:
		mov		dptr, #0x0e000
		movx	a, @dptr
		mov		r0, a
		jb		acc.0, 00023$
		setb	b.3
	00023$:
		jb		acc.1, 00024$
		setb	b.4
	00024$:
		jb		acc.2, 00025$
		setb	b.5
	00025$:
		mov		dptr, #0x0c000
		movx	a, @dptr
		mov		r0, a
		jb		acc.1, 00026$
		setb	b.6
	00026$:
		jb		acc.2, 00027$
		setb	b.7
	00027$:
	__endasm;
	#endif
	return B;
}
