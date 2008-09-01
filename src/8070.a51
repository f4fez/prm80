$NOBUILTIN
$NOSYMBOLS
$NOMOD51
$INCLUDE (83c552.mcu)

;----------------------------------------
; SFRs
;----------------------------------------
AUXR1		EQU	0a2h

;----------------------------------------
; Variables
;----------------------------------------
serial_latch_lo	EQU	23h	; Valeur du premier verrou
serial_latch_hi	EQU	24h	; Valeur du deuxieme verrou

lcd_dataA0	EQU	32h	; Premier octet pour le lcd
lcd_dataA1	EQU	33h	; Deuxieme octet pour le lcd
lcd_dataA2	EQU	34h	; Troisieme octet
lcd_dataA3	EQU	35h	; Quatrieme octet
lcd_dataB0	EQU	36h	; Premier octet pour le lcd
lcd_dataB1	EQU	37h	; Deuxieme octet pour le lcd
lcd_dataB2	EQU	38h	; Troisieme octet
lcd_dataB3	EQU	39h	; Quatrieme octet

vol_hold	EQU	20h	; Sauvegarde le volume
disp_hold	EQU	4ah	; Sauvegarde de de l'affichage des symboles
disp_state	EQU	25h	; Symbole Ã  afficher
				; b0: Squelch ouvert	b1: mode squelch
				; b2: Puissance haute	b3: reverse
				; b4: shift

mode		EQU	21h	; Mode courant
				; b0: Squelch		b1: puissance
				; b2: Squelch ouvert	b3: 
				; b4: 			b5: Appui long memorise
				; b6: Anti-rebond actif	b7: Rafraichier lcd

chan_state	EQU	22h	; Option du canal
				; b0: shift		b1: reverse
				; b2:			b3:
				; b4: 			b5: 
				; b6: 			b7:


but_timer	EQU	48h	; compteur pour l'anti rebond
but_timer2	EQU	41h
but_hold_state	EQU	3bh
but_repeat	EQU	3ch	; Tempo pour la repetion et l'appui long

ref_div_hi	EQU	4bh
ref_div_lo	EQU	40h

rx_freq_hi	EQU	42h
rx_freq_lo	EQU	43h
tx_freq_hi	EQU	44h
tx_freq_lo	EQU	45h

shift		EQU	3ah	; Shift codÃ© sur 8 Bits (environ 3MHz max avec un pas de 12.5KHz)


;----------------------------------------
; Constantes
;----------------------------------------
sp_default	EQU	9fh	; Adresse du pointeur de pile pile à l'initialisation
wdt_int		EQU	0	; Interval du watchdog

; Port constants
ser_sda		EQU	P1.1	; Donnee du bus serie
ser_scl		EQU	P1.0	; Horloge du bus serie

latch_oe	EQU	P3.4
latch_str	EQU	P3.5

lcd_dlen	EQU	P4.2

synth_ce	EQU	P1.5

fi_lo		EQU	0b0h
fi_hi		EQU	006h

but_long_duration	EQU	15
but_repeat_duration	EQU	3
but_repeat_mask		EQU	0ch

pwm_freq	EQU	0

;******************************************************************************
;******************************************************************************
;******************************************************************************

;----------------------------------------
; Secteur de boot
;----------------------------------------
        org	0
	jmp	init
	
;----------------------------------------
; Chargement des fonctions annexe
;----------------------------------------
 $include (inc_front_8070.a51)	; Fonctions de gestion de l'afficheur
 $include (inc_sys.a51)	; Diverse fonctions systeème
 $include (inc_mem.a51) ; Gestion des cannaux

;----------------------------------------
; Initialisation de bas niveau
;----------------------------------------
init:
	; Initialisation des ports 
	mov	r0,#5dh
	mov	P1,r0
	mov	r0,#0dfh
	mov	P3,r0
	mov	r0,#0ffh
	mov	P5,r0
	mov	r0,#0f9h
	mov	P4,r0

	; Initialisation de la pile
	mov	r0, #sp_default
	mov	SP, r0

	; Initialisation des SFRs
	mov	r0, #80h			; ADC en mode 8 bits
	mov	auxr1, r0
	mov	r0, pwm_freq			; Frequence de la pwm
	mov	pwmp, r0

	; Initialisation des variables
	mov	lcd_dataA0, #0
	mov	lcd_dataA1, #0
	mov	lcd_dataA2, #0
	mov	lcd_dataA3, #0
	mov	lcd_dataB0, #0
	mov	lcd_dataB1, #0
	mov	lcd_dataB2, #0
	mov	lcd_dataB3, #0

	mov	vol_hold, #01h 		; Pour etre a peut pres sur de charger le volume au premier lancement
	mov	but_timer, #00
	mov	but_timer2, #0fbh
	mov	disp_hold, #0ffh
	mov	but_hold_state, #0
	mov	but_repeat, #but_long_duration
	
	mov	ref_div_hi, #20h
	mov	ref_div_lo, #90h
	
;----------------------------------------
; Initialisation de haut niveau
;----------------------------------------
	; Verifier si un reset est demande
	call	check_buttons			; Charger etat bouton
	cjne	a, #0Ch, init_no_reset
	call	load_ram_default	 	; reset memory
init_no_reset:

	; Chargement parametre
	call	load_parameters

	; Initialisation du verrou
	mov	serial_latch_lo, #81h
	mov	serial_latch_hi, #31h
	call	load_serial_latch
	
	call	wdt_reset
	call	get_freq

	mov	r0, rx_freq_lo
	mov	r1, rx_freq_hi
	call	load_synth

	; Initialisation du squelch
	mov	dph, #ram_area_config
	mov	dpl, #ram_squelch
	movx	a, @dptr
	swap	a
	mov	pwm0, a

	call	set_volume

	call	load_power
	call	wdt_reset
	
	; Affichage du canal
	mov	dph, #ram_area_config
	mov	dpl, #ram_chan
	movx	a, @dptr
	mov	r0, a

	call	lcd_print_dec
	setb	mode.7
	mov	r7, #0fh

;----------------------------------------
; Boucle principal
;----------------------------------------
m_loop:	

;*** Test du squelch
	call	wdt_reset
	call	squelch

;*** Test TX
	jb	P4.0, m_notx
	call	tx
m_notx:

;*** Test des boutons
	call	wdt_reset
	call	buttons


;*** Affichage des symboles speciaux
	call	wdt_reset
	call	display_update_symb

;*** Reglage du volume
	call	wdt_reset
	call	set_volume	

;*** Affichage sur le lcd
	call	wdt_reset
	jnb	mode.7, m_end
	call	load_lcd
	clr	mode.7

m_end:
	jmp	m_loop


;----------------------------------------
; Gestion des fonctions des boutons
;----------------------------------------
buttons:
	inc	but_timer			; Incrementation des timers
	mov	a, but_timer
	jnz	b_ar
	inc	but_timer2
b_ar:
	jnb	mode.6, b_ar_end		; Passer si antirebond inactif
	clr	c
	mov	a, but_timer2
	subb	a, #1				; trebond = 1
	jnc	b_ar_end			; si cpt > trebond : sauter
	ret					; sinon fin
b_ar_end:
	call	check_buttons			; Charger etat bouton
	mov	r0, a
	cjne	a, but_hold_state, b_state_dif	; Si etat differant sauter
	clr	mode.6				; Desactiver AR
	jnz	b_cont
	ret
b_cont:
	clr	c
	mov	a, but_timer2
	subb	a, but_repeat			; Soit tlong, soit trepeat
	jnc	b_long				; si cpt > but_repeat : sauter
	ret					; sinon fin	
b_long:
	mov	a, #but_repeat_mask		; Verifier si repetition autorise
	anl	a, r0
	mov	b, r0
	cjne	a, b, b_l_norepeat
	mov	but_repeat, #but_repeat_duration
	jmp	b_l_cont
b_l_norepeat:
	jb	mode.5, b_long_end
b_l_cont:
	setb	mode.5				; Appui long
	mov	r1, #01
	mov	a, r0
	mov	but_timer, #0
	mov	but_timer2, #0
	jmp	b_decoding
b_long_end:
	ret
	
b_state_dif:
	setb	mode.6				; Activer AR
	mov	but_timer, #0
	mov	but_timer2, #0
	clr	c
	mov	a, but_hold_state
	subb	a, r0
	jnc	b_key_release			; Si Etat < Etat precedent : saute car touche relachÃe
	mov	but_hold_state, r0		; sinon une touche vient d'etre appuye
	ret

b_key_release:
	jb	mode.5, b_kr_long		; Si appui long : sauter
	mov	r1, #0				; Effacent flag appui long
	mov	a, r0
	jz	b_decoding			; Si les touches sont relachÃ©es
	ret
b_kr_long:
	clr	mode.5
	mov	but_hold_state, r0
	mov	but_repeat, #but_long_duration
	ret

; Decodage des touches appuyÃes
b_decoding:
	mov	a, but_hold_state
	mov	but_hold_state, r0

	mov	b, r1				; Test appui long
	jb	b.0, b_but1l			; si vrai sauter
b_but1:	; 
	cjne	a, #1, b_but2
	call	switch_power
	jmp	b_endbut
b_but2: ; 
	cjne	a, #2, b_but3
	call	switch_shift_mode
	jmp	b_endbut
b_but3: ; 
	cjne	a, #4, b_but4
	call	chan_inc
	jmp	b_endbut
b_but4: ; 
	cjne	a, #8, b_but5
	call	chan_dec
	jmp	b_endbut
b_but5: ; 
	cjne	a, #16, b_but6
	call	switch_reverse
	jmp	b_endbut
b_but6: ; 
	cjne	a, #32, b_but7
	call	switch_mode
	jmp	b_endbut
b_but7: ; 
	cjne	a, #64, b_but8

	jmp	b_endbut
b_but8: ; 
	cjne	a, #128, b_endbut

	jmp	b_endbut
b_but1l:
	cjne	a, #1, b_but2l

	jmp	b_endbut
b_but2l:
	cjne	a, #2, b_but3l

	jmp	b_endbut
b_but3l:
	cjne	a, #4, b_but4l
	call	chan_inc
	jmp	b_endbut
b_but4l:
	cjne	a, #8, b_but5l
	call	chan_dec
	jmp	b_endbut
b_but5l:
	cjne	a, #16, b_but6l

	jmp	b_endbut
b_but6l:
	cjne	a, #32, b_but7l

	jmp	b_endbut
b_but7l:
	cjne	a, #64, b_but8l

	jmp	b_endbut
b_but8l:
	cjne	a, #128, b_endbut

	jmp	b_endbut

b_endbut:
	ret

;***** Boucle emission *****
tx:
	; Suppression du squelch si besoin
	jnb	mode.0, tx_cont
	clr	mode.0
	call	chan_update_display
	clr	disp_state.1
tx_cont:
	; Affichage du mode
	setb	disp_state.5
	mov	disp_hold, disp_state
	call	update_symb
	call	wdt_reset
	call	load_lcd
	
	mov	r0, tx_freq_lo
	mov	r1, tx_freq_hi
	mov	a, #40h
	orl	serial_latch_hi, a
	call	load_serial_latch
	call	load_synth
	
	mov	a, #80h
	orl	serial_latch_hi, a
	call	load_serial_latch
	mov	r0, #0ffh
tx_lp:
	call	wdt_reset
	call	check1750
	jnb	P4.0, tx_lp

	; Affichage du mode
	clr	disp_state.5

	mov	r0, rx_freq_lo
	mov	r1, rx_freq_hi
	mov	a, #3fh
	anl	serial_latch_hi, a
	call	load_serial_latch
	call	load_synth

	ret
;----------------------------------------
; Affichage des synboles
;----------------------------------------
display_update_symb:
	
	clr	a	
	; Shift
	mov	c, chan_state.0
	mov	Acc.4, c
	; Squelch ouvert
	mov	c, mode.2
	mov	Acc.0, c
	; Mode reverse
	mov	c, chan_state.1
	mov	Acc.3, c
	; Mode squelch
	mov	c, mode.0
	mov	Acc.1, c
	; Haute puissance
	mov	c, mode.1
	cpl	c
	mov	Acc.2, c
	mov	disp_state, a
	cjne	a, disp_hold, m_symb_update
	ret

m_symb_update:
	mov	disp_hold, a
	call	update_symb
	setb	mode.7
	ret

$include (inc_config.a51) ; Chargement de la configuration
	end


