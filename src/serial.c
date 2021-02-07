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
#include "serial.h"
#include "sys.h"
#include "mem.h"

__xdata unsigned char serial_rx_buffer[256];
__xdata unsigned char serial_tx_buffer[256];

__data unsigned char PtrRXin;             	//   .Pointeur d'entree buffer RX
__data unsigned char PtrRXout;              //   .Pointeur de sortie buffer RX
__data unsigned char RXnbo;                 //   .Nombre d'octets dans buffer RX
__data unsigned char PtrTXin;               //   .Pointeur d'entree buffer TX
__data unsigned char PtrTXout;              //   .Pointeur d'entree buffer TX
__data unsigned char TXnbo;                 //   .Nombre d'octets dans buffer TX. 
__bit serial_run;

inline void serial_init() {
    // In case of reinitialisation, be sure the sytem is a corect state
    ES = 0;
    serial_run = 0;
    PtrRXin = 0;
    PtrRXout = 0;
    RXnbo = 0;
    PtrTXin = 0;
    PtrTXout = 0;
    TXnbo = 0;

/*	__asm
                CLR        RD_err               ; - Initialiser les buffers :
	__endasm;*/

    // SMOD set 
    PCON |= 0b10000000;
    // 1 start bit, 8 data bits, 1 stop
    SCON = 0b01110010;
    // 4800 Bps
    TL1 = 243;
    TH1 = 243;
    TR1 = 1;

    PS = 1; // Low rpiority
    // Enable interupts
    ES = 1;
}

inline void serial_isr_code()
{
    wdt_reset();
    __asm
    // RX
                 JNB        RI, 01002$
                 MOV        A, _RXnbo
                 INC        A
                 JNZ        01000$
                 SJMP       01001$ // Goto end RX
01000$:          MOV        _RXnbo, A
                 MOV        DPH,#RAM_AREA_SERIAL_RX         ; Buffer RX : $0800 à $08FF
                 MOV        DPL, _PtrRXin
                 MOV        A, SBUF
                 MOVX       @DPTR,A
                 INC        _PtrRXin
01001$:          CLR        RI
    // TX
01002$:          JNB        TI,01004$
                 MOV        A, _TXnbo
                 JNZ        01003$
                 CLR        _serial_run
                 SJMP       01005$
01003$:          MOV        DPH,#RAM_AREA_SERIAL_TX       ; Buffer TX : $0900 à $09FF
                 MOV        DPL, _PtrTXout
                 MOVX       A,@DPTR
                 MOV        SBUF,A
                 INC        _PtrTXout
                 DEC        _TXnbo
                 SETB       _serial_run
01005$:          CLR        TI
// End interupt
01004$:
    __endasm;
}

int putchar (int c) __naked {
    __asm
01100$:         MOV         A, _TXnbo
                CJNE        A,#255,01101$
                // Reset watchdog
                orl	        PCON, #0x10
		        mov	        _T3, #WDT_INT
                SJMP        01100$
01101$:         CLR         ES
                MOV         A, DPL
                MOV         DPH,#RAM_AREA_SERIAL_TX
                MOV         DPL, _PtrTXin
                MOVX        @DPTR,A
                INC         _PtrTXin
                INC         _TXnbo
                JB          _serial_run, 01102$
                SETB        TI
01102$:
                SETB        ES
                mov	        dpl,a
	            ret
    __endasm;
}
