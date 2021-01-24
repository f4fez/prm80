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

RAM_AREA_CONFIG		EQU	000h
RAM_AREA_FREQ		EQU	001h
RAM_AREA_STATE		EQU	002h

RAM_ID_CODE		EQU	000h
RAM_CONFIG_SUM		EQU	001h
RAM_FREQ_SUM		EQU	002h
RAM_STATE_SUM		EQU	003h
RAM_CHAN		EQU	010h
RAM_MODE		EQU	011h
RAM_SQUELCH		EQU	012h
RAM_MAX_CHAN		EQU	013h
RAM_SHIFT_HI		EQU	014h
RAM_SHIFT_LO		EQU	015h
RAM_PLL_DIV_HI		EQU	016h
RAM_PLL_DIV_LO		EQU	017h
RAM_SCAN_DURATION	EQU	018h

ID_CODE			EQU	040h

;----------------------------------------
; Chargement des registre de frequence
;  a partir du canal
;----------------------------------------
get_freq:
	call	wdt_reset
	; Recuperation du canal
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CHAN
	movx	a, @dptr
	mov	r1, a
get_freq_r1:	
	; Recuperation du chan_state
	mov	dph, #RAM_AREA_STATE
	mov	dpl, r1
	movx	a, @dptr
	mov	chan_state, a
	

get_freq2:
	jb	chan_state.1, get_freq_reverse
	
get_freq_normal:
	; Recuperation de la frequence
	mov	a, r1
	mov	dph, #RAM_AREA_FREQ
	rl	a
	mov	dpl, a
	movx	a, @dptr
	mov	tx_freq_hi, a
	
	inc	dpl
	movx	a, @dptr
	mov	tx_freq_lo, a

IF FREQ EQ 144
	mov	a, #fi_lo
	add	a, tx_freq_lo
	mov	rx_freq_lo, a
	mov	a, #fi_hi
	addc	a, tx_freq_hi
	mov	rx_freq_hi, a
ELSEIF FREQ EQ 430
	mov	a, tx_freq_lo
	clr	c
	subb	a, #fi_lo
	mov	rx_freq_lo, a
	mov	a, tx_freq_hi
	subb	a, #fi_hi
	mov	rx_freq_hi, a
ENDIF
	; Activation du shift au besoin
	jnb	chan_state.0, gfn_end
	jnb	chan_state.2, gnf_shift_n	; Test si shift - ou +
gnf_shift_p:		; Shift positif
	mov	r0, shift_lo
	mov	a, tx_freq_lo
	add	a, r0
	mov	tx_freq_lo, a
	mov	a, shift_hi
	addc	a, tx_freq_hi
	mov	tx_freq_hi, a
	jmp	gfn_end
gnf_shift_n:		; Shift negatif
	clr	c
	mov	r0, shift_lo
	mov	a, tx_freq_lo
	subb	a, r0
	mov	tx_freq_lo, a
	mov	a, tx_freq_hi 
	subb	a, shift_hi
	mov	tx_freq_hi, a
	
gfn_end:
	ret

get_freq_reverse:
	call	wdt_reset

	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CHAN
	movx	a, @dptr
	mov	dptr,	#freq_list
	mov	r1, a
	rl	a
	mov	r0, a
	movc	a, @a+dptr
	mov	tx_freq_hi, a
	
	inc	r0
	mov	a, r0
	movc	a, @a+dptr
	mov	tx_freq_lo, a

IF FREQ EQ 144
	mov	a, #fi_lo
	add	a, tx_freq_lo
	mov	rx_freq_lo, a
	mov	a, #fi_hi
	addc	a, tx_freq_hi
	mov	rx_freq_hi, a
ELSEIF FREQ EQ 430
	mov	a, tx_freq_lo
	clr	c
	subb	a, #fi_lo
	mov	rx_freq_lo, a
	mov	a, tx_freq_hi
	subb	a, #fi_hi
	mov	rx_freq_hi, a
ENDIF
	jnb	chan_state.2, grf_shift_n	; Test si shift - ou +
grf_shift_p:		; Shift positif
	mov	r0, shift_lo
	mov	a, rx_freq_lo
	add	a, r0
	mov	rx_freq_lo, a
	mov	a, shift_hi
	addc	a, rx_freq_hi
	mov	rx_freq_hi, a
	jmp	r_end
grf_shift_n:		; Shift negatif
	clr	c
	mov	r0, shift_lo
	mov	a, rx_freq_lo
	subb	a, r0
	mov	rx_freq_lo, a
	mov	a, rx_freq_hi
	subb	a, shift_hi
	mov	rx_freq_hi, a
r_end:
	ret

;----------------------------------------
; Recuperation des parametres
; Verification des checksum de la RAM
;----------------------------------------
load_parameters:
	call	test_checksums		;Test si la ram est valide
	jz	lp_load		
	call	bip
	call	read_eeprom		; Si RAM invalide charger eeprom et retester
	call	test_checksums		
	jz	lp_load
	call	load_ram_default	; Si eeprom invalide egalement alors reinit usine
	call	bip
lp_load:
	;Charger les donnees de la ram
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_MODE
	movx	a, @dptr
	mov	mode, a
	
	mov	dpl, #RAM_SHIFT_LO
	movx	a, @dptr
	mov	shift_lo, a
	mov	dpl, #RAM_SHIFT_HI
	movx	a, @dptr
	mov	shift_hi, a
	
	mov	dpl, #RAM_SCAN_DURATION
	movx	a, @dptr
	mov	scan_duration, a
	ret

;----------------------------------------
; Test checksum
; Verifi les checksums de 3 zones ainsi
; que l'octet d'identification
; Retourne 0 dans a si OK
;----------------------------------------
test_checksums:
	mov	r7, #0
	
	; Verifier l'octet de controle
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_ID_CODE
	movx	a, @dptr
	clr	c
	subb	a, #ID_CODE
	jz	tc_check_sum0
	inc	r7
	
tc_check_sum0:	
	; Verfication checksum de la zone config
	call	load_config_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CONFIG_SUM
	movx	a, @dptr
	clr	c
	subb	a, r0
	jz	tc_check_sum1
	inc	r7
tc_check_sum1:	
	; Verfication checksum de la zone freq
	call	load_freq_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_FREQ_SUM
	movx	a, @dptr
	clr	c
	subb	a, r0
	jz	tc_check_sum2
	inc	r7
tc_check_sum2:
	; Verfication checksum de la zone state
	call	load_state_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_STATE_SUM
	movx	a, @dptr
	clr	c
	subb	a, r0
	jz	tc_check_sum_end
	inc	r7
tc_check_sum_end:
	mov	a, r7
	ret
;----------------------------------------
; Chargement de tous les parametres 
;  par defaut + reinit eeprom
;----------------------------------------
load_ram_default:
	call	load_ram_default_config
	call	load_ram_default_freq
	call	load_ram_default_state
	call	prog_eeprom
	ret

;----------------------------------------
; Chargement des parametres generaux
;  par defaut
;----------------------------------------
load_ram_default_config:
	call	wdt_reset
	mov	dph, #RAM_AREA_CONFIG
	mov	shift_lo, #CONFIG_SHIFT_LO
	mov	shift_hi, #CONFIG_SHIFT_HI
	mov	mode, #00h

	mov	dpl, #RAM_CHAN
	mov	a, #0
	movx	@dptr, a
	mov	dpl, #RAM_MODE
	mov	a, #0
	movx	@dptr, a
	mov	dpl, #RAM_SQUELCH
	mov	a, #05h
	movx	@dptr, a
	mov	dpl, #RAM_MAX_CHAN
	mov	a, #CONFIG_CHAN_COUNT
	movx	@dptr, a
	mov	dpl, #RAM_SHIFT_LO
	mov	a, #CONFIG_SHIFT_LO
	movx	@dptr, a
	mov	dpl, #RAM_SHIFT_HI
	mov	a, #CONFIG_SHIFT_HI
	movx	@dptr, a
	mov	dpl, #RAM_ID_CODE
	mov	a, #ID_CODE
	movx	@dptr, a
	mov	dpl, #RAM_PLL_DIV_HI
	mov	a, #CONFIG_PLL_DIV_HI
	movx	@dptr, a
	mov	dpl, #RAM_PLL_DIV_LO
	mov	a, #CONFIG_PLL_DIV_LO
	movx	@dptr, a
	mov	dpl, #RAM_SCAN_DURATION
	mov	a, #CONFIG_SCAN_DURATION
	movx	@dptr, a
	
	; Calcul de la checksum
	call	load_config_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CONFIG_SUM
	movx	@dptr, a
	ret

;----------------------------------------
; Chargement de la liste des cannaux
;  par defaut
;----------------------------------------
load_ram_default_freq:	
	;Load channels frequencies from program EPROM to RAM
	call	wdt_reset
	mov	dph, #RAM_AREA_CONFIG	; Load max chan value in r0
	mov	dpl, #RAM_MAX_CHAN
	movx	a, @dptr
	mov	r0, a
lrd_copyloop1:
	mov	dptr,	#freq_list	; Load channel value
	mov	a, r0
	rl	a
	movc	a, @a+dptr
	mov	r1, a			; r1 : freq_lo
	mov	a, r0
	rl	a
	inc	a
	movc	a, @a+dptr
	mov	r2, a			; r2 : freq_hi
	mov	dph, #RAM_AREA_FREQ	; Copy to RAM
	mov	a, r0
	rl	a
	mov	dpl, a
	mov	a, r1
	movx	@dptr, a
	inc	dpl
	mov	a, r2
	movx	@dptr, a
	dec	r0
	cjne	r0, #0ffh, lrd_copyloop1
	
	call	load_freq_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_FREQ_SUM
	movx	@dptr, a
	ret

;----------------------------------------
; Chargement des etats des cannaux
;  par defaut
;----------------------------------------
load_ram_default_state:	
	;Load channels states from program EPROM to RAM
	call	wdt_reset
	mov	dph, #RAM_AREA_CONFIG	; Load max chan value in r0
	mov	dpl, #RAM_MAX_CHAN
	movx	a, @dptr
	mov	r0, a
lrd_copyloop2:
	mov	dptr,	#chan_state_table	; Load channel value
	mov	a, r0
	movc	a, @a+dptr
	mov	r1, a			; r1 : state

	mov	dph, #RAM_AREA_STATE	; Copy to RAM
	mov	a, r0
	mov	dpl, a
	mov	a, r1
	movx	@dptr, a
	dec	r0
	cjne	r0, #0ffh, lrd_copyloop2
	
	; Calcul de la checksum
	call	load_state_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_STATE_SUM
	movx	@dptr, a
	
	ret

;----------------------------------------
; Sauvegarde du mode
;----------------------------------------	
save_mode:
	mov	a, #0ah
	anl	a, mode
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_MODE
	movx	@dptr, a
	
	; Calcul de la checksum
	call	load_config_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CONFIG_SUM
	movx	@dptr, a
	ret

;----------------------------------------
; Activation / desactivation du shift
;----------------------------------------
switch_shift_mode:
	jnb	mode2.0, switch_shift_load	; Test if scanning, channel is not saved in the same place
	mov	r0, chan_scan
	jmp	switch_shift_update
switch_shift_load:
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CHAN
	movx	a, @dptr
	mov	r0, a
switch_shift_update:
	clr	chan_state.1
	
	mov	a, chan_state
	cpl	acc.0
	mov	chan_state, a
	
	mov	dph, #RAM_AREA_STATE
	mov	dpl, r0
	movx	@dptr, a
	
	; Calcul de la checksum
	call	load_state_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_STATE_SUM
	movx	@dptr, a
	
	call	get_freq
	mov	r0, rx_freq_lo
	mov	r1, rx_freq_hi
	call	load_synth
	
	ret

;----------------------------------------
; Shift activation / desactivation 
; and switch positive / negative
;----------------------------------------
switch_shift_mode2:
	jnb	mode2.0, switch_shift2_load	; Test if scanning, channel is not saved in the same place
	mov	r0, chan_scan
	jmp	switch_shift2_update
switch_shift2_load:
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CHAN
	movx	a, @dptr
	mov	r0, a
switch_shift2_update:
	clr	chan_state.1
	
	mov	a, chan_state
	jb	Acc.0, ssm2_shift_enable
	setb	Acc.0					; Shift disable : enable it
	clr	Acc.2
	jmp	ssm2_cont
ssm2_shift_enable:
	jb	Acc.2, ssm2_shift_pos
	setb	Acc.2
	jmp	ssm2_cont
ssm2_shift_pos:
	clr	Acc.0
	clr	Acc.2
ssm2_cont:
	mov	chan_state, a
	
	mov	dph, #RAM_AREA_STATE
	mov	dpl, r0
	movx	@dptr, a
	
	; Calcul de la checksum
	call	load_state_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_STATE_SUM
	movx	@dptr, a
	
	call	get_freq
	mov	r0, rx_freq_lo
	mov	r1, rx_freq_hi
	call	load_synth
	
	ret

;----------------------------------------
; Passage en mode reverse
;----------------------------------------
switch_reverse:
	call	wdt_reset
	jnb	chan_state.0, sr_end

	jnb	mode2.0, switch_reverse_load		; Test if scanning, channel is not saved in the same place
	mov	r1, chan_scan
	jmp	switch_reverse_update
switch_reverse_load:
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CHAN
	movx	a, @dptr
	mov	r1, a
switch_reverse_update:
	mov	dph, #RAM_AREA_STATE
	mov	dpl, r1
	cpl	chan_state.1
	mov	a, chan_state
	movx	@dptr, a

	setb	mode.7
	call	get_freq
	mov	r0, rx_freq_lo
	mov	r1, rx_freq_hi
	call	load_synth

	; Calcul de la checksum
	call	load_state_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_STATE_SUM
	movx	@dptr, a
sr_end:
	ret

;----------------------------------------
; Calcul de la checksum de la zone state
;----------------------------------------
load_state_area_checksum:
	mov	dph, #RAM_AREA_STATE
	mov	dpl, #0
	mov	r0, #0
	mov	a, #0
lsac_loop:
	call	wdt_reset
	movx	a, @dptr
	add	a, r0
	mov	r0, a
	inc	dpl
	mov	r1, dpl
	cjne	r1, #0, lsac_loop
	ret

;----------------------------------------
; Calcul de la checksum de la zone freq
;----------------------------------------	
load_freq_area_checksum:	
	mov	dph, #RAM_AREA_FREQ
	mov	dpl, #0
	mov	r0, #0
	mov	a, #0
lfac_loop:
	call	wdt_reset
	movx	a, @dptr
	add	a, r0
	mov	r0, a
	inc	dpl
	mov	r1, dpl
	cjne	r1, #0, lfac_loop
	ret

;----------------------------------------
; Calcul de la checksum de la zone config
;----------------------------------------
load_config_area_checksum:	
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #10
	mov	r0, #0
	mov	a, #0
lcac_loop:
	call	wdt_reset
	movx	a, @dptr
	add	a, r0
	mov	r0, a
	inc	dpl
	mov	r1, dpl
	cjne	r1, #0, lcac_loop
	ret

;----------------------------------------
; Changement de mode (Canal / Squelch)
;----------------------------------------
switch_mode:
	cpl	mode.0
	call	update_lcd
	ret

;----------------------------------------
; Inc / Dec canal ou squelch
;----------------------------------------
;*** Incrementation de la fonction courante (Canal / Squelch)
chan_inc:
	jb	mode.0, sql_inc
	jnb	mode2.0, chan_inc_load		; Test if scanning, channel is not saved in the same place
	mov	a, chan_scan
	jmp	chan_inc_inc
chan_inc_load:
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CHAN
	movx	a, @dptr
chan_inc_inc:
	inc	a
	movx	@dptr, a
	mov	b, a
	
	mov	dpl, #RAM_MAX_CHAN
	movx	a, @dptr
	inc	a
	cjne	a, b, chan_update
	mov	a, #0
	mov	dpl, #RAM_CHAN
	movx	@dptr, a
	jmp	chan_update
chan_dec:
	jb	mode.0, sql_dec
	jnb	mode2.0, chan_dec_load		; Test if scanning, channel is not saved in the same place
	mov	a, chan_scan
	jmp	chan_dec_dec
chan_dec_load:
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CHAN
	movx	a, @dptr
chan_dec_dec:
	dec	a
	movx	@dptr, a 
	
	mov	b, #0ffh
	cjne	a, b, chan_update
	mov	dpl, #RAM_MAX_CHAN
	movx	a, @dptr
	mov	dpl, #RAM_CHAN
	movx	@dptr, a
chan_update:
	; Calcul de la checksum
	call	load_config_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CONFIG_SUM
	movx	@dptr, a
	
	call	get_freq
	mov	r0, rx_freq_lo
	mov	r1, rx_freq_hi
	call	load_synth

	call	update_lcd

	ret

;*** Incrementation squelch
sql_inc:
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_SQUELCH
	movx	a, @dptr
	inc	a
	anl	a, #0fh
	movx	@dptr, a
	jmp	sql_update

;*** Decrementation squelch
sql_dec:
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_SQUELCH
	movx	a, @dptr
	dec	a
	anl	a, #0fh
	movx	@dptr, a

sql_update:
	; Calcul de la checksum
	call	load_config_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CONFIG_SUM
	movx	@dptr, a

	mov	dpl, #RAM_SQUELCH
	movx	a, @dptr
	mov	r0, a
	swap	a
	mov	pwm0, a
	
	call	update_lcd
	ret

;----------------------------------------	
; "PROG_EEPROM" : Programme les 2048 octets du debut de la RAM 
;                 externe ($0000 a $07FF) dans l'EEPROM I2C AT24C16. 
;                 "I2C_err" renvoie 0 si OK ; sinon, le code d'erreur. 
;                 En cas d'erreur, "Page" contient le numero de la page
;                 ou s'est produite l'erreur (0 a 127), sinon Page=128.
;                 La programmation dure environ 2 secondes (elle prend
;                 en charge la remise a zero du "Watchdog Timer"). 
 
PROG_EEPROM:     PUSH       ACC            ; 
                 PUSH       DPH            ; 
                 PUSH       DPL            ; 
                 MOV        Page,#0        ; 
                 MOV        DPTR,#0        ; 
                 MOV        A,Page         ; 
wr_page:
                 CALL       I2C_WR_Page    ; 
                 MOV        A,I2C_err      ; 
                 JNZ        fin_wr_all     ; 
                 INC        Page           ; 
                 MOV        A,Page         ; 
                 CJNE       A,#128,wr_page ; 
fin_wr_all:      POP        DPL            ; 
                 POP        DPH            ; 
                 POP        ACC            ; 
                 RET                       ; 

;----------------------------------------	
; "READ_EEPROM" : Lit les 2048 octets de l'EEPROM I2C AT24C16 et place
;                 les donnees au debut de la RAM externe, de l'adresse
;                 $0000 a l'adresse $07FF. 
;                 "I2C_err" renvoie 0 si OK ; sinon, le code d'erreur. 
;                 En cas d'erreur, "Page" contient le numero de la page
;                 ou s'est produite l'erreur (0 a 127), sinon Page=128.
 
READ_EEPROM:     PUSH       ACC            ; 
                 PUSH       DPH            ; 
                 PUSH       DPL            ; 
                 MOV        Page,#0        ; 
                 MOV        DPTR,#0        ; 
                 MOV        A,Page         ; 
rd_page:
                 CALL       I2C_RD_Page    ; 
                 MOV        A,I2C_err      ; 
                 JNZ        fin_rd_all     ; 
                 INC        Page           ; 
                 MOV        A,Page         ; 
                 CJNE       A,#128,rd_page ; 
fin_rd_all:      POP        DPL            ; 
                 POP        DPH            ; 
                 POP        ACC            ; 
                 RET

;----------------------------------------
; Mise a jour du lcd
;----------------------------------------
update_lcd:
		jb	mode2.2, ul_end
		call	wdt_reset
		jb	mode.0, ul_sql			; Si mode sql aller plus loin
		jnb	mode2.0, update_lcd_load	; Test if scanning, channel is not saved in the same place
		mov	a, chan_scan
		jmp	update_lcd_update
update_lcd_load:
		mov	dph, #RAM_AREA_CONFIG		; sinon charger canal
		mov	dpl, #RAM_CHAN
		movx	a, @dptr
update_lcd_update:
		mov	r0, a
		jmp	ul_update
ul_sql:
		mov	dph, #RAM_AREA_CONFIG
		mov	dpl, #RAM_SQUELCH
		movx	a, @dptr
		mov	r0, a
ul_update:
		call	lcd_clear_digits_r
		call	lcd_print_dec
		setb	mode.7
ul_end:
		ret		 

;----------------------------------------
; Recharger l'etat du poste :
;  - Frequence
;  - Puissance
;  - Squelch
;----------------------------------------
load_state:
	call	wdt_reset
	call	get_freq

	mov	r0, rx_freq_lo
	mov	r1, rx_freq_hi
	call	load_synth
	
	call	load_power

	; Initialisation du squelch
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_SQUELCH
	movx	a, @dptr
	swap	a
	mov	pwm0, a
	ret

;----------------------------------------
; Enable or diisable channel lock out
; for scanning
;----------------------------------------
switch_lock_out:
	call	wdt_reset
	jnb	mode2.0, switch_lo_load	; Test if scanning, channel is not saved in the same place
	mov	r1, chan_scan
	jmp	switch_lo_update
switch_lo_load:
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_CHAN
	movx	a, @dptr
	mov	r1, a
switch_lo_update:
	mov	dph, #RAM_AREA_STATE
	mov	dpl, r1
	cpl	chan_state.3
	mov	a, chan_state
	movx	@dptr, a

	setb	mode.7

	; Calcul de la checksum
	call	load_state_area_checksum
	mov	dph, #RAM_AREA_CONFIG
	mov	dpl, #RAM_STATE_SUM
	movx	@dptr, a
	ret

