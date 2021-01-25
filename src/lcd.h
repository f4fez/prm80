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

#ifndef PRM_LCD_H
#define PRM_LCD_H

/**
 * Fill the LCD buffer. Used to clear or diaplay all segment. 
 */
void lcd_init_buf(unsigned char initVal);


/**
 * Clear buffer main digits segments.
 */
void lcd_clear_digits();

/** 
 * Load the main digits tens in the buffer.
 */
void lcd_print_digit10(unsigned char val);

/** 
 * Load the main digits units in the buffer.
 */
void lcd_print_digit1(unsigned char val);

/**
 * Load in the buffer an hexadecimal value for the main digits.
 * \param val Value to print on the lcd main digits area.
 */
void lcd_print_hex(unsigned char val);

/**
 * Load in the buffer a decimal value for the main digits.
 * The value should not exceed the maximum count of digits : 2 on PRM8060/70
 * \param val Value to print on the lcd main digits area.
 */
void lcd_print_dec(unsigned char val);

/**
 * Transfer the LCD buffer to the display chip.
 * Clear WDT at call.
 */
void lcd_refresh();

#endif
