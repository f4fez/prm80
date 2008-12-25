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

ram_area_config	EQU	000h
ram_area_freq	EQU	001h
ram_area_state	EQU	002h

ram_id_code	EQU	000h
ram_config_sum	EQU	001h
ram_freq_sum	EQU	002h
ram_state_sum	EQU	003h
ram_chan	EQU	010h
ram_mode	EQU	011h
ram_squelch	EQU	012h
ram_max_chan	EQU	013h
ram_shift	EQU	014h
ram_pll_div_hi	EQU	015h
ram_pll_div_lo	EQU	016h

id_code		EQU	004h

;----------------------------------------
; Chargement des registre de frequence
;  a partir du canal
;----------------------------------------
get_freq:
	call	wdt_reset
	; Recuperation du canal
	mov	dph, #ram_area_config
	mov	dpl, #ram_chan
	movx	a, @dptr
	mov	r1, a
	
	; Recuperation du chan_state
	mov	dph, #ram_area_state
	mov	dpl, r1
	movx	a, @dptr
	mov	chan_state, a
	

get_freq2:
	jb	chan_state.1, get_freq_reverse
	
get_freq_normal:
	; Recuperation de la frequence
	mov	a, r1
	mov	dph, #ram_area_freq
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
	clr	c
	mov	r0, shift
	mov	a, tx_freq_lo
	subb	a, r0
	mov	tx_freq_lo, a
	jnb	cy, gfn_end
	dec	tx_freq_hi
gfn_end:
	ret

get_freq_reverse:
	call	wdt_reset

	mov	dph, #ram_area_config
	mov	dpl, #ram_chan
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
	
	mov	a, #fi_lo
	add	a, tx_freq_lo
	mov	rx_freq_lo, a
	mov	a, #fi_hi
	addc	a, tx_freq_hi
	mov	rx_freq_hi, a
	

	clr	c
	mov	r0, shift
	mov	a, rx_freq_lo
	subb	a, r0
	mov	rx_freq_lo, a
	jnb	cy, r_end
	dec	rx_freq_hi	

r_end:
	ret

;----------------------------------------
; Recuperation des parametres
;  Verification des checksum de la RAM
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
	mov	dph, #ram_area_config
	mov	dpl, #ram_mode
	movx	a, @dptr
	mov	mode, a
	
	mov	dpl, #ram_shift
	movx	a, @dptr
	mov	shift, a

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
	mov	dph, #ram_area_config
	mov	dpl, #ram_id_code
	movx	a, @dptr
	clr	c
	subb	a, #id_code
	jz	tc_check_sum0
	inc	r7
	
tc_check_sum0:	
	; Verfication checksum de la zone config
	call	load_config_area_checksum
	mov	dph, #ram_area_config
	mov	dpl, #ram_config_sum
	movx	a, @dptr
	clr	c
	subb	a, r0
	jz	tc_check_sum1
	inc	r7
tc_check_sum1:	
	; Verfication checksum de la zone freq
	call	load_freq_area_checksum
	mov	dph, #ram_area_config
	mov	dpl, #ram_freq_sum
	movx	a, @dptr
	clr	c
	subb	a, r0
	jz	tc_check_sum2
	inc	r7
tc_check_sum2:
	; Verfication checksum de la zone state
	call	load_state_area_checksum
	mov	dph, #ram_area_config
	mov	dpl, #ram_state_sum
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
	mov	dph, #ram_area_config
	mov	shift, #CONFIG_SHIFT
	mov	mode, #00h

	mov	dpl, #ram_chan
	mov	a, #0
	movx	@dptr, a
	mov	dpl, #ram_mode
	mov	a, #0
	movx	@dptr, a
	mov	dpl, #ram_squelch
	mov	a, #05h
	movx	@dptr, a
	mov	dpl, #ram_max_chan
	mov	a, #CONFIG_CHAN_COUNT
	movx	@dptr, a
	mov	dpl, #ram_shift
	mov	a, #CONFIG_SHIFT
	movx	@dptr, a
	mov	dpl, #ram_id_code
	mov	a, #id_code
	movx	@dptr, a
	mov	dpl, #ram_pll_div_hi
	mov	a, #CONFIG_PLL_DIV_HI
	movx	@dptr, a
	mov	dpl, #ram_pll_div_lo
	mov	a, #CONFIG_PLL_DIV_LO
	movx	@dptr, a
	
	; Calcul de la checksum
	call	load_config_area_checksum
	mov	dph, #ram_area_config
	mov	dpl, #ram_config_sum
	movx	@dptr, a
	ret

;----------------------------------------
; Chargement de la liste des cannaux
;  par defaut
;----------------------------------------
load_ram_default_freq:	
	;Load channels frequencies from program EPROM to RAM
	call	wdt_reset
	mov	dph, #ram_area_config	; Load max chan value in r0
	mov	dpl, #ram_max_chan
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
	mov	dph, #ram_area_freq	; Copy to RAM
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
	mov	dph, #ram_area_config
	mov	dpl, #ram_freq_sum
	movx	@dptr, a
	ret

;----------------------------------------
; Chargement des etats des cannaux
;  par defaut
;----------------------------------------
load_ram_default_state:	
	;Load channels states from program EPROM to RAM
	call	wdt_reset
	mov	dph, #ram_area_config	; Load max chan value in r0
	mov	dpl, #ram_max_chan
	movx	a, @dptr
	mov	r0, a
lrd_copyloop2:
	mov	dptr,	#chan_state_table	; Load channel value
	mov	a, r0
	movc	a, @a+dptr
	mov	r1, a			; r1 : state

	mov	dph, #ram_area_state	; Copy to RAM
	mov	a, r0
	mov	dpl, a
	mov	a, r1
	movx	@dptr, a
	dec	r0
	cjne	r0, #0ffh, lrd_copyloop2
	
	; Calcul de la checksum
	call	load_state_area_checksum
	mov	dph, #ram_area_config
	mov	dpl, #ram_state_sum
	movx	@dptr, a
	
	ret

;----------------------------------------
; Sauvegarde du mode
;----------------------------------------	
save_mode:
	mov	a, #0ah
	anl	a, mode
	mov	dph, #ram_area_config
	mov	dpl, #ram_mode
	movx	@dptr, a
	
	; Calcul de la checksum
	call	load_config_area_checksum
	mov	dph, #ram_area_config
	mov	dpl, #ram_config_sum
	movx	@dptr, a
	ret

;----------------------------------------
; Activation / desactivation du shift
;----------------------------------------
switch_shift_mode:
	mov	dph, #ram_area_config
	mov	dpl, #ram_chan
	movx	a, @dptr
	mov	r0, a
	
	clr	chan_state.1
	
	mov	a, chan_state
	cpl	acc.0
	mov	chan_state, a
	
	mov	dph, #ram_area_state
	mov	dpl, r0
	movx	@dptr, a
	
	; Calcul de la checksum
	call	load_state_area_checksum
	mov	dph, #ram_area_config
	mov	dpl, #ram_state_sum
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
	
	mov	dph, #ram_area_config
	mov	dpl, #ram_chan
	movx	a, @dptr
	mov	r1, a
	
	mov	dph, #ram_area_state
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
	mov	dph, #ram_area_config
	mov	dpl, #ram_state_sum
	movx	@dptr, a
sr_end:
	ret

;----------------------------------------
; Calcul de la checksum de la zone state
;----------------------------------------
load_state_area_checksum:
	mov	dph, #ram_area_state
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
	mov	dph, #ram_area_freq
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
	mov	dph, #ram_area_config
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
	mov	dph, #ram_area_config
	mov	dpl, #ram_chan
	movx	a, @dptr
	inc	a
	movx	@dptr, a
	mov	b, a
	
	mov	dpl, #ram_max_chan
	movx	a, @dptr
	inc	a
	cjne	a, b, chan_update
	mov	a, #0
	mov	dpl, #ram_chan
	movx	@dptr, a
	jmp	chan_update
chan_dec:
	jb	mode.0, sql_dec
	mov	dph, #ram_area_config
	mov	dpl, #ram_chan
	movx	a, @dptr
	dec	a
	movx	@dptr, a 
	
	mov	b, #0ffh
	cjne	a, b, chan_update
	mov	dpl, #ram_max_chan
	movx	a, @dptr
	mov	dpl, #ram_chan
	movx	@dptr, a
chan_update:
	; Calcul de la checksum
	call	load_config_area_checksum
	mov	dph, #ram_area_config
	mov	dpl, #ram_config_sum
	movx	@dptr, a
	
	call	get_freq
	mov	r0, rx_freq_lo
	mov	r1, rx_freq_hi
	call	load_synth

	call	update_lcd

	ret

;*** Incrementation squelch
sql_inc:
	mov	dph, #ram_area_config
	mov	dpl, #ram_squelch
	movx	a, @dptr
	inc	a
	anl	a, #0fh
	movx	@dptr, a
	jmp	sql_update

;*** Decrementation squelch
sql_dec:
	mov	dph, #ram_area_config
	mov	dpl, #ram_squelch
	movx	a, @dptr
	dec	a
	anl	a, #0fh
	movx	@dptr, a

sql_update:
	; Calcul de la checksum
	call	load_config_area_checksum
	mov	dph, #ram_area_config
	mov	dpl, #ram_config_sum
	movx	@dptr, a

	mov	dpl, #ram_squelch
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
		call	wdt_reset
		jb	mode.0, ul_sql		; Si mode sql aller plus loin
		mov	dph, #ram_area_config	; sinon charger canal
		mov	dpl, #ram_chan
		movx	a, @dptr
		mov	r0, a
		jmp	ul_update
ul_sql:
		mov	dph, #ram_area_config
		mov	dpl, #ram_squelch
		movx	a, @dptr
		mov	r0, a
ul_update:
		call	lcd_clear_digits_r
		call	lcd_print_dec
		setb	mode.7
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
	mov	dph, #ram_area_config
	mov	dpl, #ram_squelch
	movx	a, @dptr
	swap	a
	mov	pwm0, a
	ret
	
	