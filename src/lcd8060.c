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
#include "lcd.h"
#include "sys.h"

__data unsigned char lcd_dataA0;		// LCD buffer Byte 0
__data unsigned char lcd_dataA1;		// LCD buffer Byte 1
__data unsigned char lcd_dataA2;		// LCD buffer Byte 2

void lcd_init_buf(unsigned char initVal) {
	lcd_dataA0 = initVal;
	lcd_dataA1 = initVal;
	lcd_dataA2 = initVal;
}

void lcd_clear_digits() {
	__asm
		anl	_lcd_dataA0, #0x8f
		anl	_lcd_dataA1, #0x20
		mov	_lcd_dataA2, #0
	__endasm;
}

void lcd_print_digit10(unsigned char val) {
	val;
	wdt_reset();
	__asm
		mov 	a, dpl
		rl		a
		rl		a
		mov		r0, a
		mov		dptr, #_main_lcd_10_table
		movc	a, @a+dptr
		orl		_lcd_dataA0,a
		inc		r0
		mov 	a, r0
		movc	a, @a+dptr
		orl		_lcd_dataA1,a
		inc		r0
		mov 	a, r0
		movc	a, @a+dptr
		orl		_lcd_dataA2,a
	__endasm;
}

void lcd_print_digit1(unsigned char val) {
	val;
	wdt_reset();
	__asm
		mov 	a, dpl
		rl		a
		rl		a
		mov		r0, a
		mov		dptr, #_main_lcd_1_table
		movc	a, @a+dptr
		orl		_lcd_dataA0,a
		inc		r0
		mov 	a, r0
		movc	a, @a+dptr
		orl		_lcd_dataA1,a
		inc		r0
		mov 	a, r0
		movc	a, @a+dptr
		orl		_lcd_dataA2,a
	__endasm;
}

void lcd_print_hex(unsigned char val) {
	val;
	__asm
		mov	a, 	dpl
		mov	r2, a
		anl	a, 	#0x0f
		mov		dpl, a
		/* r2 is not pushed on the stack since sub-functions are pure assembly and
		   we know that r2 is not altered */
		lcall	_lcd_print_digit1
		mov		a, r2
		swap	a
		anl	a,	#0x0f
		mov		dpl, a
		lcall	_lcd_print_digit10
	__endasm;
}

void lcd_print_dec(unsigned char val) {
	val;
	__asm
		mov		b, #0x0a
		mov		a, dpl
		div		ab
		mov		dpl, a
		/* b is not pushed on the stack since sub-functions are pure assembly and
		   we know that b is not altered */
		lcall	_lcd_print_digit10
		mov		dpl, b
		lcall	_lcd_print_digit1
	__endasm;	
}

void lcd_refresh() {
	wdt_reset();
	__asm
		clr		_PIN_SCLK		; Clock low level
		clr		_PIN_SDATA		; Data low level
		nop
		nop
		nop
		setb	_DISPLAY_CE		; Prepare lcd a receive data
		nop
		setb	_PIN_SCLK		; First bit (leading zero)
		nop
		nop
		clr		_PIN_SCLK		; End first bit
		mov	r0, #8				; 8 Bits to send
		mov	A, 	_lcd_dataA0
		lcall	00001$
		mov	r0, #8				; 8 Bits to send
		mov	A, 	_lcd_dataA1
		lcall	00001$	
		mov	r0, #5				; 4 Bits to send + load bit
		mov	A, 	_lcd_dataA2
		setb	acc.4			; Bit 21 to 1 to load BP1
		lcall	00001$
		clr		_DISPLAY_CE		; End of data payload
		nop
		nop
		nop
		clr		_PIN_SDATA		; Data low level
		setb	_PIN_SCLK		; Apply load pulse
		nop
		nop
		clr		_PIN_SCLK		; End load pulse
		ret						; 30/03/2015 : Test with ret here
		
		;Sub function to send the data A byte to the lcd. R0 contain the number of bits to send
		;ll_send
		00001$:
		mov		c, acc.0		; Copy next bit to send in C
		mov		_PIN_SDATA, c	; Then put it on the output
		nop
		nop
		setb	_PIN_SCLK		; Clock high level
		nop
		nop
		nop
		rr		a				; Prepare next bit
		clr		_PIN_SCLK		; Clock  low level
		nop	
		djnz	r0, 00001$		; End of send loop

	__endasm;	
}

/**
 * Table to bind symbols to LCD segment registers (4).
 * 1 Decimal.
 */
__code unsigned char main_lcd_1_table[] = {
	0x0,	// 0
	0x5c,
	0x03,
	0x0,
	0x0,	// 1
	0x40,
	0x01,
	0x0,
	0x0,	// 2
	0x98,
	0x03,
	0x0,
	0x0,	// 3
	0x0D0,
	0x03,
	0x0,
	0x0,	// 4
	0x0c4,
	0x01,
	0x0,
	0x0,	// 5
	0x0d4,
	0x02,
	0x0,
	0x0,	// 6
	0x0dc,
	0x02,
	0x0,
	0x0,	// 7
	0x40,
	0x03,
	0x0,
	0x0,	// 8
	0x0dc,
	0x03,
	0x0,
	0x0,	// 9
	0x0d4,
	0x03,
	0x0,
	0x0,	// A
	0x0cc,
	0x03,
	0x0,
	0x0,	// B
	0x0dc,
	0x0,
	0x0,
	0x0,	// C
	0x1c,
	0x02,
	0x0,
	0x0,	// D
	0x0d8,
	0x01,
	0x0,
	0x0,	// E
	0x9c,
	0x02,
	0x0,
	0x0,	// F
	0x8c,
	0x02,
	0x0
};

/**
 * Table to bind symbols to LCD segment registers (4).
 * 10 Decimal.
 */
__code unsigned char main_lcd_10_table[] = {
	0x70,	// 0
	0x03,
	0x04,
	0x0,
	0x40,	// 1
	0x00,
	0x04,
	0x0,
	0x10,	// 2
	0x03,
	0x0c,
	0x0,
	0x50,	// 3
	0x01,
	0x0c,
	0x0,
	0x60,	// 4
	0x00,
	0x0c,
	0x0,
	0x70,	// 5
	0x01,
	0x08,
	0x0,
	0x70,	// 6
	0x03,
	0x08,
	0x0,
	0x50,	// 7
	0x00,
	0x04,
	0x0,
	0x70,	// 8
	0x03,
	0x0c,
	0x0,
	0x70,	// 9
	0x01,
	0x0c,
	0x0,
	0x70,	// A
	0x02,
	0x0c,
	0x0,
	0x60,	// B
	0x03,
	0x08,
	0x0,
	0x30,	// C
	0x03,
	0x00,
	0x0,
	0x40,	// D
	0x03,
	0x0c,
	0x0,
	0x30,	// E
	0x03,
	0x08,
	0x0,
	0x30,	// F
	0x02,
	0x08,
	0x0
};