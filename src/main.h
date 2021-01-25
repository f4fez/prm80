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

#ifndef PRM_MAIN_H
#define PRM_MAIN_H

#define TYPE_PRM8060 8060
#define TYPE_PRM8070 8070

#ifndef DEVICE
#define DEVICE TYPE_PRM8060
#endif

// Port constants
#define latch_oe		P3.4
#define latch_str		P3.5

#define synth_ce		P1.5

#define fi_lo			0b0h
#define fi_hi			006h

#define but_long_duration		15
#define but_repeat_duration		3

#define RSSI_COUNTER_INIT		6

#define PWM_FREQ		28

// Roles des bits du registre d'etat du port serie "RS232status" :
// Erreur lecture dans buffer RX.
#define RD_err			RS232status.0
// Emission de donnees en cours
#define TFR_run			RS232status.1

// Bits analyse du type de caractere
// Bit "Acknowledge" lu sur l'I2C.
#define I2C_ACK              charType.0 
// Caractere appartient [A..Z] ?
#define CH_maj               charType.1
// Caractere appartient [a..z] ?
#define CH_min               charType.2
//Caractere appartient [0..f/F] ?
#define CH_hex               charType.3
// Caractere appartient [0..9] ?
#define CH_dec               charType.4 
// 2 chiffres hexa recus via RS232.
#define XXDD_OK              charType.5
// Caractere recu = ENTER.
#define CH_enter             charType.6 

void init();

#endif
