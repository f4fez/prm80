;    Copyright (c) 2007, 2008 Florian MAZEN and Pierre COL
;    
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <http://www.gnu.org/licenses/>.

; Segmentation of external memory now moved to an own file so memory structure can be seen easily
; and DPTR can be loaded with 16 Bit values, also


XSEG	AT 0000H						; RAM_Area_Config, don't change the order of variables					

RAM_ID_CODE:		DS	1
RAM_CONFIG_SUM:		DS	1
RAM_FREQ_SUM:		DS	1
RAM_SHIFT_SUM:		DS	1
RAM_STATE_SUM:		DS	1

XSEG	AT 0010H						; why this offset?				
RAM_CHAN:			DS	1
RAM_MODE:			DS	1
RAM_SQUELCH:		DS	1
RAM_MAX_CHAN:		DS	1
RAM_SHIFT_HI:		DS	1
RAM_SHIFT_LO:		DS	1
RAM_PLL_DIV_HI:		DS	1
RAM_PLL_DIV_LO:		DS	1
RAM_SCAN_DURATION:	DS	1
RAM_L_Disp:			DS	1

ID_CODE				EQU	040h

XSEG	AT 0100H						; RAM_AREA_FREQ				
Ch0_RX_freq:		DS 256				; 2 Bytes per Channel, reserved for 128 channels max

XSEG	AT 0200H						; RAM_AREA_Shift				
Ch0_Shift_freq:		DS 256				; 2 Bytes per Channel, reserved for 128 channels max

XSEG	AT 0300H						; RAM_AREA_State				
Ch0_State_freq:		DS 128				; 1 Bytes per Channel, reserved for 128 channels max


RAM_AREA_CONFIG		EQU	High RAM_ID_CODE 	;Constants needed for compatibility topics
RAM_AREA_FREQ		EQU	High Ch0_RX_freq	
RAM_AREA_SHIFT		EQU High Ch0_Shift_freq	; channel specific shift frequency
RAM_AREA_STATE		EQU	High Ch0_State_freq





CSEG									; Back to Code segment (has to set as default)
