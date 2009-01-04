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

CONFIG_CHAN_COUNT       EQU     041h
CONFIG_SHIFT_LO         EQU     030h
CONFIG_SHIFT_HI         EQU     000h
CONFIG_PLL_DIV_HI	EQU	020h
CONFIG_PLL_DIV_LO	EQU	090h

freq_list:
        ; Channel : 0 Frequency : 145600000
        DB      02dh
        DB      080h
        ; Channel : 1 Frequency : 145612500
        DB      02dh
        DB      081h
        ; Channel : 2 Frequency : 145625000
        DB      02dh
        DB      082h
        ; Channel : 3 Frequency : 145637500
        DB      02dh
        DB      083h
        ; Channel : 4 Frequency : 145650000
        DB      02dh
        DB      084h
        ; Channel : 5 Frequency : 145662500
        DB      02dh
        DB      085h
        ; Channel : 6 Frequency : 145675000
        DB      02dh
        DB      086h
        ; Channel : 7 Frequency : 145687500
        DB      02dh
        DB      087h
        ; Channel : 8 Frequency : 145700000
        DB      02dh
        DB      088h
        ; Channel : 9 Frequency : 145712500
        DB      02dh
        DB      089h
        ; Channel : 10 Frequency : 145725000
        DB      02dh
        DB      08ah
        ; Channel : 11 Frequency : 145737500
        DB      02dh
        DB      08bh
        ; Channel : 12 Frequency : 145750000
        DB      02dh
        DB      08ch
        ; Channel : 13 Frequency : 145762500
        DB      02dh
        DB      08dh
        ; Channel : 14 Frequency : 145775000
        DB      02dh
        DB      08eh
        ; Channel : 15 Frequency : 145787500
        DB      02dh
        DB      08fh
        ; Channel : 16 Frequency : 145200000
        DB      02dh
        DB      060h
        ; Channel : 17 Frequency : 145212500
        DB      02dh
        DB      061h
        ; Channel : 18 Frequency : 145225000
        DB      02dh
        DB      062h
        ; Channel : 19 Frequency : 145237500
        DB      02dh
        DB      063h
        ; Channel : 20 Frequency : 145250000
        DB      02dh
        DB      064h
        ; Channel : 21 Frequency : 145262500
        DB      02dh
        DB      065h
        ; Channel : 22 Frequency : 145275000
        DB      02dh
        DB      066h
        ; Channel : 23 Frequency : 145287500
        DB      02dh
        DB      067h
        ; Channel : 24 Frequency : 145300000
        DB      02dh
        DB      068h
        ; Channel : 25 Frequency : 145312500
        DB      02dh
        DB      069h
        ; Channel : 26 Frequency : 145325000
        DB      02dh
        DB      06ah
        ; Channel : 27 Frequency : 145337500
        DB      02dh
        DB      06bh
        ; Channel : 28 Frequency : 145350000
        DB      02dh
        DB      06ch
        ; Channel : 29 Frequency : 145362500
        DB      02dh
        DB      06dh
        ; Channel : 30 Frequency : 145375000
        DB      02dh
        DB      06eh
        ; Channel : 31 Frequency : 145387500
        DB      02dh
        DB      06fh
        ; Channel : 32 Frequency : 145400000
        DB      02dh
        DB      070h
        ; Channel : 33 Frequency : 145412500
        DB      02dh
        DB      071h
        ; Channel : 34 Frequency : 145425000
        DB      02dh
        DB      072h
        ; Channel : 35 Frequency : 145437500
        DB      02dh
        DB      073h
        ; Channel : 36 Frequency : 145450000
        DB      02dh
        DB      074h
        ; Channel : 37 Frequency : 145462500
        DB      02dh
        DB      075h
        ; Channel : 38 Frequency : 145475000
        DB      02dh
        DB      076h
        ; Channel : 39 Frequency : 145487500
        DB      02dh
        DB      077h
        ; Channel : 40 Frequency : 145500000
        DB      02dh
        DB      078h
        ; Channel : 41 Frequency : 145512500
        DB      02dh
        DB      079h
        ; Channel : 42 Frequency : 145525000
        DB      02dh
        DB      07ah
        ; Channel : 43 Frequency : 145537500
        DB      02dh
        DB      07bh
        ; Channel : 44 Frequency : 145550000
        DB      02dh
        DB      07ch
        ; Channel : 45 Frequency : 145562500
        DB      02dh
        DB      07dh
        ; Channel : 46 Frequency : 145575000
        DB      02dh
        DB      07eh
        ; Channel : 47 Frequency : 145587500
        DB      02dh
        DB      07fh
        ; Channel : 48 Frequency : 144500000
        DB      02dh
        DB      028h
        ; Channel : 49 Frequency : 144800000
        DB      02dh
        DB      040h
        ; Channel : 50 Frequency : 145000000
        DB      02dh
        DB      050h
        ; Channel : 51 Frequency : 145012500
        DB      02dh
        DB      051h
        ; Channel : 52 Frequency : 145025000
        DB      02dh
        DB      052h
        ; Channel : 53 Frequency : 145037500
        DB      02dh
        DB      053h
        ; Channel : 54 Frequency : 145050000
        DB      02dh
        DB      054h
        ; Channel : 55 Frequency : 145062500
        DB      02dh
        DB      055h
        ; Channel : 56 Frequency : 145075000
        DB      02dh
        DB      056h
        ; Channel : 57 Frequency : 145087500
        DB      02dh
        DB      057h
        ; Channel : 58 Frequency : 145100000
        DB      02dh
        DB      058h
        ; Channel : 59 Frequency : 145112500
        DB      02dh
        DB      059h
        ; Channel : 60 Frequency : 145125000
        DB      02dh
        DB      05ah
        ; Channel : 61 Frequency : 145137500
        DB      02dh
        DB      05bh
        ; Channel : 62 Frequency : 145150000
        DB      02dh
        DB      05ch
        ; Channel : 63 Frequency : 145162500
        DB      02dh
        DB      05dh
        ; Channel : 64 Frequency : 145175000
        DB      02dh
        DB      05eh
        ; Channel : 65 Frequency : 145187500
        DB      02dh
        DB      05fh

chan_state_table:
        DB      01h    ; Channel : 0
        DB      01h    ; Channel : 1
        DB      01h    ; Channel : 2
        DB      01h    ; Channel : 3
        DB      01h    ; Channel : 4
        DB      01h    ; Channel : 5
        DB      01h    ; Channel : 6
        DB      01h    ; Channel : 7
        DB      01h    ; Channel : 8
        DB      01h    ; Channel : 9
        DB      01h    ; Channel : 10
        DB      01h    ; Channel : 11
        DB      01h    ; Channel : 12
        DB      01h    ; Channel : 13
        DB      01h    ; Channel : 14
        DB      01h    ; Channel : 15
        DB      00h    ; Channel : 16
        DB      00h    ; Channel : 17
        DB      00h    ; Channel : 18
        DB      00h    ; Channel : 19
        DB      00h    ; Channel : 20
        DB      00h    ; Channel : 21
        DB      00h    ; Channel : 22
        DB      00h    ; Channel : 23
        DB      00h    ; Channel : 24
        DB      00h    ; Channel : 25
        DB      00h    ; Channel : 26
        DB      00h    ; Channel : 27
        DB      00h    ; Channel : 28
        DB      00h    ; Channel : 29
        DB      00h    ; Channel : 30
        DB      00h    ; Channel : 31
        DB      00h    ; Channel : 32
        DB      00h    ; Channel : 33
        DB      00h    ; Channel : 34
        DB      00h    ; Channel : 35
        DB      00h    ; Channel : 36
        DB      00h    ; Channel : 37
        DB      00h    ; Channel : 38
        DB      00h    ; Channel : 39
        DB      00h    ; Channel : 40
        DB      00h    ; Channel : 41
        DB      00h    ; Channel : 42
        DB      00h    ; Channel : 43
        DB      00h    ; Channel : 44
        DB      00h    ; Channel : 45
        DB      00h    ; Channel : 46
        DB      00h    ; Channel : 47
        DB      00h    ; Channel : 48
        DB      00h    ; Channel : 49
        DB      00h    ; Channel : 50
        DB      00h    ; Channel : 51
        DB      00h    ; Channel : 52
        DB      00h    ; Channel : 53
        DB      00h    ; Channel : 54
        DB      00h    ; Channel : 55
        DB      00h    ; Channel : 56
        DB      00h    ; Channel : 57
        DB      00h    ; Channel : 58
        DB      00h    ; Channel : 59
        DB      00h    ; Channel : 60
        DB      00h    ; Channel : 61
        DB      00h    ; Channel : 62
        DB      00h    ; Channel : 63
        DB      00h    ; Channel : 64
        DB      00h    ; Channel : 65
