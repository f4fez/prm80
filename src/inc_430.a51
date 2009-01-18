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

CONFIG_CHAN_COUNT       EQU     004h
CONFIG_SHIFT_LO         EQU     060h
CONFIG_SHIFT_HI         EQU     002h
CONFIG_PLL_DIV_HI	EQU	020h
CONFIG_PLL_DIV_LO	EQU	090h
CONFIG_SCAN_DURATION	EQU	008h

freq_list:
        ; Channel : 0 Frequency : 430000000
        DB      086h
        DB      060h
        ; Channel : 1 Frequency : 430250000
        DB      086h
        DB      074h
        ; Channel : 2 Frequency : 430500000
        DB      086h
        DB      088h
        ; Channel : 3 Frequency : 431000000
        DB      086h
        DB      0b0h
        ; Channel : 4 Frequency : 432500000
        DB      087h
        DB      028h

chan_state_table:
        DB      00h    ; Channel : 0
        DB      00h    ; Channel : 1
        DB      00h    ; Channel : 2
        DB      00h    ; Channel : 3
        DB      00h    ; Channel : 4
