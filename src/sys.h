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

#ifndef PRM_SYS_H
#define PRM_SYS_H

#include "80c552.h"

/** P1.0 Serial Clock (Synth, latch, lcd) */
#define PIN_SCLK P1_0
#define _PIN_SCLK _P1_0
/** P1.1 Serial Data (Synth, latch, lcd) */
#define PIN_SDATA P1_1
#define _PIN_SDATA _P1_1
/** P1.2 Rx Sync (Modem) */
#define PIN_RX_SYNC P1_2
/** P1.3 Tx Synch (Modem) */
#define PIN_TX_SYNCH P1_3
/*  P1.4 N/A */
/** P1.5 Synthetizer CE */
#define PIN_SYNTH_CE P1_5
/** P1.6 SCL */
#define PIN_SCL P1_6
/** P1.7 SDA */
#define PIN_SDA P1_7
 
/** P3.0 RxD */
#define PIN_RXD P3_0
/** P3.1 TxD */
#define PIN_TXD P3_1
/*  P3.2 N/A */
/** P3.3 OPT CTRL */
#define PIN_OPT_CTRL P3_3
/** P3.4 Latch OE */
#define PIN_LATCH_OE P3_4
/** P3.5 Latch transfer */
#define PIN_LACTH_STR P3_5
/*  P3.6 /WR */
/*  P3.7 /RD */

/*
	P4.0 PTT input
	P4.1 SP mute
	*/
/** P4.2 Display CE */
#define _DISPLAY_CE		_P4_2

/*
	P4.3 On/off
	P4.4 Rx Data (Modem)
	P4.5 SCI DAO Tx data (Modem)
	P4.6 SCI DA1 Carrier detection (Modem)
	P4.7 SCI DA2 Enable TX (Modem)
*/
/*
	P5.0 TCS option Input
	P5.1 Squelch signal input
	P5.2 Pll lock (low)
	P5.3 Alarm input
	P5.4 PA enable (low when > 0.5W)
	P5.5 Mike cradle
	P5.6 Analog RSSI input
	P5.7 Analog volume input
*/

// Watchdog timer value
#define WDT_INT			0

void wdt_reset();

/**
 * Initialize all low level sub components.
 */
void sys_init();

/**
 * Transfer the latch buffers to the chips.
 */
void sys_load_serial_latch();

/**
 * Enable latch output.
 */
void sys_enable_latch_output();

/**
 * Read the current button state. Each button set correspond to a bit in the 
 * returned value.
 *
 * \return Buttons state.
 */
unsigned char sys_read_buttons();
#endif
