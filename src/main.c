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
#include "main.h"
#include "sys.h"
#include "lcd.h"
#include "serial.h"

__bit  vol_hold = 0x01;			// Save volume value. Used to detect change
__bit  mode;    				// Mode
										// b0: Squelch/channel 		b1: power
										// b2: Squelch open 		b3: TX
										// b4: PLL lock     		b5: Appui long memorise
										// b6: debounce flag		b7: Refresh lcd
__bit  mode2 = 0x00;			// Mode, 2nd byte
										// b0: scan running			b1: scan increment chan
										// b2: RSSI print enable	b3: RSSI print flag
										// b4: 						b5: 
										// b6: 						b7:
					
__bit chan_state;				// Option du canal
										// b0: shift actif			b1: reverse
										// b2: shift +				b3: lock out
										// b4: 						b5: 
										// b6: 						b7:

__bit  RS232status;				// Registre d'etat du port serie.
__bit  charType;				// Contien le resultat de l'analyse d'n caractere
__bit  lock = 0x00;				// Verroullage
										// b0: Touches				b1: TX
										// b2: Volume          		b3: RX
										// b4: 						b5: 
										// b6: 						b7:

__bit  disp_state;				// Symbole a afficher pour prm8070
										// b0: Squelch ouvert		b1: mode squelch
										// b2: Puissance haute		b3: reverse
										// b4: shift				b5: tx
										// b6: Lock out				b7: shift +

unsigned char disp_hold = 0xff;	// Sauvegarde de de l'affichage des symboles

/** Debounce counter */
//unsigned char but_timer = 0x00;
//unsigned char but_timer2 = 0xfb;	
//unsigned char but_hold_state = 0x00;
/** Long press counter */
//unsigned char but_repeat = but_long_duration;

//unsigned char scan_counter;		// Use to compue scanner timming
//unsigned char scan_duration;	// Time to wait between channel : value * 50ms

//unsigned int rx_freq;
//unsigned int tx_freq;

//unsigned int shift;			// Shift code sur 16Bits
/*
PtrRXin             	//   .Pointeur d'entree buffer RX
PtrRXout                //   .Pointeur de sortie buffer RX
RXnbo                  	//   .Nombre d'octets dans buffer RX
PtrTXin                	//   .Pointeur d'entree buffer TX
PtrTXout               	//   .Pointeur d'entree buffer TX
TXnbo                  	//   .Nombre d'octets dans buffer TX.
Page                   	// - Numero de la page de octets.
RS_ASCmaj              	// - Octet RS232 conv. en majuscule.
RS_HexDec              	// - Octet RS232 converti en hexa.
AdrH                   	// - Adresse passee par RS232 (MSB).
AdrL                   	// - Adresse passee par RS232 (LSB).
DataRS                 	// - Donnee passee par le port serie.
I2C_err                	// - Renvoi d'erreur acces bus I2C.*/

/** rssi counter for 50ms interuption */
unsigned char rssi_counter = RSSI_COUNTER_INIT;
unsigned char rssi_hold;		// rssi previous value
unsigned char chan_scan;		// Hold channel for scanning 

/**
 * Initialize the system.
 * - First initialize CPU registers and basic components (I/O, ADC, PWM, serial latch...)
 * - Load parameters from memory
 * - If needed, load the RAM / EEPROM
 * - Apply the loaded system state
 * - Initialize RS232 connection
 * - Enable interrupts (Timer, RS232)
 */
void init() {
	//Low level component initialisation
	sys_init();
	
	// LCD test pattern
	lcd_init_buf(0xff);
	lcd_refresh();
	
	// Check for reset
	/*sys_read_buttons()
	cjne	a, #BUT_RESET, init_no_reset
	call	bip
	call	load_ram_default	 	; reset memory*/

	// Chargement parametre
	//validate_ram();
	//mode = ram_mode;
	//shift = (ram_shift_hi << 8) | ram_shift_lo;

	// Chargement de l'etat du poste
	/*call	load_state*/

	// Chargement du volume
	/*call	set_volume*/

	// Initialisation de la liaison serie
	serial_init();
	
	lcd_init_buf(0);

	wdt_reset();
	
	// Activation des interruption
	//setb	EA*/
}

void main() {
	unsigned char but;
	wdt_reset();
	init();
	lcd_clear_digits();
	//lcd_print_hex(33);
	lcd_refresh();
	for(;;) {
		wdt_reset();
		lcd_clear_digits();
		but = sys_read_buttons();
		lcd_print_hex(but);
		lcd_refresh();
	}
}