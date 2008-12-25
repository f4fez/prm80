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

;-----------------------------------------------
; TARGET should be 8060 or 8070
; FREQ	144 A9
;	430 U0
;-----------------------------------------------


$NOBUILTIN
$NOSYMBOLS
$NOMOD51
$NOPAGING

;+++++++++++++++++++++++++++++++++++++++
; Check if TARGET is defined if not
;  end with error
IFNDEF TARGET

$ERROR(TARGET not defined)
    END

ELSEIFNDEF FREQ
$ERROR(FREQ not defined)
    END

ELSE

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

lcd_data0	EQU	32h	; Premier octet pour le lcd
lcd_data1	EQU	33h	; Deuxieme octet pour le lcd
lcd_data2	EQU	34h	; Troisieme octet pour le lcd (4 bits seulement)

vol_hold	EQU	20h	; Sauvegarde le volume
disp_hold	EQU	38h	; Sauvegarde de de l'affichage des symboles


mode		EQU	21h	; Mode courant
				; b0: Squelch		b1: puissance
				; b2: Squelch ouvert	b3: TX
				; b4: PLL verouille	b5: Appui long memorise
				; b6: Anti-rebond actif	b7: Rafraichier lcd

chan_state	EQU	22h	; Option du canal
				; b0: shift		b1: reverse
				; b2: 			b3:
				; b4: 			b5: 
				; b6: 			b7:

RS232status	EQU	25h	; Registre d'etat du port serie.
charType	EQU	26h	; Contien le resultat de l'analyse d'n caractere
lock		EQU	27h	; Verroullage
				; b0: Touches		b1: TX
				; b2: Volume          	b3: RX
				; b4: 			b5: 
				; b6: 			b7:

but_timer	EQU	36h	; compteur pour l'anti rebond
but_timer2	EQU	41h
but_hold_state	EQU	3bh
but_repeat	EQU	3ch	; Tempo pour la repetion et l'appui long

;ref_div_hi	EQU	39h
;ref_div_lo	EQU	40h

rx_freq_hi	EQU	42h
rx_freq_lo	EQU	43h
tx_freq_hi	EQU	44h
tx_freq_lo	EQU	45h



shift		EQU	3ah	; Shift code sur 8 Bits (environ 3MHz max avec un pas de 12.5KHz)

PtrRXin         EQU     46h        ;   .Pointeur d'entree buffer RX
PtrRXout        EQU     47h        ;   .Pointeur de sortie buffer RX
RXnbo           EQU     48h        ;   .Nombre d'octets dans buffer RX
PtrTXin         EQU     49h        ;   .Pointeur d'entree buffer TX
PtrTXout        EQU     4ah        ;   .Pointeur d'entree buffer TX
TXnbo           EQU     4bh        ;   .Nombre d'octets dans buffer TX.
Page            EQU     4ch        ; - Numero de la page de octets.
RS_ASCmaj       EQU     4dh        ; - Octet RS232 conv. en majuscule.
RS_HexDec       EQU     4eh        ; - Octet RS232 converti en hexa.
AdrH            EQU     4fh        ; - Adresse passee par RS232 (MSB).
AdrL            EQU     50h        ; - Adresse passee par RS232 (LSB).
DataRS          EQU     51h        ; - Donnee passee par le port serie.
I2C_err         EQU     52h        ; - Renvoi d'erreur acces bus I2C.


;----------------------------------------
; Constantes
;----------------------------------------
sp_default	EQU	9fh	; Adresse du pointeur de pile pile a l'initialisation
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
but_repeat_mask		EQU	09h

pwm_freq	EQU	28

; Roles des bits du registre d'etat du port serie "RS232status" :
RD_err		EQU	RS232status.0 ; - Erreur lecture dans buffer RX.
TFR_run		EQU	RS232status.1 ; - Emission de donnees en cours

; Bits analyse du type de caractere
I2C_ACK         EQU     charType.0    ; - Bit "Acknowledge" lu sur l'I2C.
CH_maj          EQU     charType.1    ; - Caractere appartient [A..Z] ?
CH_min          EQU     charType.2    ; - Caractere appartient [a..z] ?
CH_hex          EQU     charType.3    ; - Caractere appartient [0..f/F] ?
CH_dec          EQU     charType.4    ; - Caractere appartient [0..9] ?
XXDD_OK         EQU     charType.5    ; - 2 chiffres hexa recus via RS232.
CH_enter        EQU     charType.6    ; - Caractere recu = ENTER.


;******************************************************************************
;******************************************************************************
;******************************************************************************

;----------------------------------------
; Secteur de boot
;----------------------------------------
	ORG		RESET			; Vecteur d'interruption du RESET
	LJMP	init			;Contourner la zone des vecteurs
							; d'interruption...

	ORG        EXTI0        ; Tant que les interruptions ne
	RETI                   	; sont pas utilisees, le code de
	ORG        TIMER0      	; fin d'interruption (RETI) ne sert 
	RETI                   	; a rien ; il est la uniquement à
	ORG        EXTI1       	; titre de precaution...
	RETI                   	; 
	ORG        TIMER1      	; 
	RETI                   	; 
	
	ORG        SINT        	; Routine d'interrution du port  
	LJMP       Int_RX_TX   	; serie 
				; seule interruption
				; utilisee pour l'instant !
	ORG        I2CBUS      	; 
	RETI                   	; 
	ORG        T2CAP0      	; 
	RETI                   	; 
	ORG        T2CAP1      	; 
	RETI                   	; 
	ORG        T2CAP2      	; 
	RETI                   	; 
	ORG        T2CAP3      	; 
	RETI                   	; 
	ORG        ADCONV      	; 
	RETI                   	; 
	ORG        T2CMP0      	; 
	RETI                   	; 
	ORG        T2CMP1      	; 
	RETI                   	; 
	ORG        T2CMP2      	; 
	RETI                   	; 
	ORG        T2OVER      	; 

;----------------------------------------
; Chargement des fonctions annexe
;----------------------------------------
IF TARGET EQ 8060
 $include (inc_8060.a51)	; Fonctions de gestion de l'afficheur et des touches
ENDIF

 $include (inc_sys.a51)	; Diverse fonctions systeme
 $include (inc_mem.a51) ; Gestion des cannaux
 $include (inc_ser.a51) ; Gestion du port serie

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
	mov	lcd_data0, #0ffh
	mov	lcd_data1, #0ffh
	mov	lcd_data2, #0ffh
	
	mov	lock, #00
	mov	vol_hold, #01h 		; Pour etre a peut pres sur de charger le volume au premier lancement
	mov	but_timer, #00
	mov	but_timer2, #0fbh
	mov	disp_hold, #0ffh
	mov	but_hold_state, #0
	mov	but_repeat, #but_long_duration
	
;----------------------------------------
; Initialisation de haut niveau
;----------------------------------------
	call	load_lcd

	; Initialisation du verrou
	mov	serial_latch_lo, #81h
	mov	serial_latch_hi, #31h
	call	load_serial_latch

	; Verifier si un reset est demande
	call	check_buttons			; Charger etat bouton
	cjne	a, #09h, init_no_reset
	call	bip
	call	load_ram_default	 	; reset memory
init_no_reset:

	; Chargement parametre
	call	load_parameters

	; Chargement de l'etat du poste
	call	load_state

	; Chargement du volume
	call	set_volume

	; Initialisation de la liaison serie
	CALL	InitRS232_4800

	call	wdt_reset
	
	; Affichage du canal
	call	update_lcd
	
	mov	r7, #0fh

;----------------------------------------
; Boucle RX
;----------------------------------------
m_loop:	

;*** Test du squelch
	call	wdt_reset
	call	squelch

;*** Test de la liaison serie	
	call	TERMINAL		; Passer la main au terminal

;*** Test des boutons
	call	wdt_reset
	call	buttons

;*** Test si Mode erreur synthe (PLL non verouillee)
	jnb	mode.4, m_loop		; Si erreur : boucler

;*** Test TX
	mov	c, P4.0
	orl	c, lock.1		; Test du verroullage TX
	jb	CY, m_notx
	call	tx
m_notx:

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
	; Test verroullage touches
	jnb	lock.0, b_no_lock
	jmp	b_endbut
b_no_lock:
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

; Decodage des touches appuyees
b_decoding:
	mov	a, but_hold_state
	mov	but_hold_state, r0

	mov	b, r1				; Test appui long
	jb	b.0, b_but1l			; si vrai sauter
b_but1:	; Gauche bas
	cjne	a, #1, b_but2
	call	chan_dec
	jmp	b_endbut
b_but2: ; Droit
	cjne	a, #2, b_but3
	call	switch_reverse
	jmp	b_endbut
b_but3: ; Gauche milieu
	cjne	a, #4, b_but4
	call	switch_mode
	jmp	b_endbut
b_but4: ; Gauche haut
	cjne	a, #8, b_endbut
	call	chan_inc
	jmp	b_endbut
b_but1l:
	cjne	a, #1, b_but2l
	call	chan_dec
	jmp	b_endbut
b_but2l:
	cjne	a, #2, b_but3l
	call	switch_power	
	call	bip
	jmp	b_endbut
	
b_but3l:
	cjne	a, #4, b_but4l
	call	switch_shift_mode
	call	bip
	jmp	b_endbut
b_but4l:
	cjne	a, #8, b_endbut
	call	chan_inc
	jmp	b_endbut

b_endbut:
	ret

	
;***** Boucle emission *****
tx:
	; Suppression du squelch si besoin
	jnb	mode.0, tx_cont
	clr	mode.0
	call	update_lcd
	
tx_cont:
	setb	mode.3
	; Affichage du mode
	mov	a, #04h
	orl	lcd_data0, a
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
	call	TERMINAL		; Passer la main au terminal
	jnb	P4.0, tx_lp

	; Affichage du mode
	mov	a, #0fbh
	anl	lcd_data0, a
	call	wdt_reset
	call	load_lcd

	mov	r0, rx_freq_lo
	mov	r1, rx_freq_hi
	mov	a, #3fh
	anl	serial_latch_hi, a
	call	load_serial_latch
	call	load_synth
	
	clr	mode.3

	ret

IF FREQ EQ 144
$include (inc_144.a51) ; Chargement de la configuration version 144MHz
ELSEIF FREQ EQ 430
$include (inc_430.a51) ; Chargement de la configuration version 430MHz
ENDIF
	end

ENDIF ; IFNDEF TARGET
