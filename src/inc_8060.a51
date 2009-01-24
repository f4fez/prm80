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

;----------------------------------------
; Constantes
;----------------------------------------
BUT_REPEAT_MASK		EQU	09h
BUT_RESET		EQU	09h

;----------------------------------------
; Chargement du lcd
;----------------------------------------
load_lcd:
	call	wdt_reset
	clr	ser_scl		; Hologe a l'etat bas
	clr	ser_sda		; Donnees a l'ete bas
	nop
	nop
	nop
	setb	lcd_dlen	; Prepare le lcd a recevoir des donnees
	nop
	setb	ser_scl		; Premier bit (leading zero)
	nop
	nop
	clr	ser_scl		; Fin premier bit
	mov	r0, #8		; 8 Bits a transemettre
	mov	A, lcd_dataA0
	call	ll_send
	mov	r0, #8		; 8 Bits a transemettre
	mov	A, lcd_dataA1
	call	ll_send	
	mov	r0, #5		; 4 Bits a transemettre + load bit
	mov	A, lcd_dataA2
	setb	Acc.4		; Bit 21 a 1 pour charger BP1
	call	ll_send
	clr	lcd_dlen	; Fin envoi donnees
	nop
	nop
	nop
	clr	ser_sda		; Donnees a l'etat bas
	setb	ser_scl		; Appliquer load pulse
	nop
	nop
	clr	ser_scl		; fin load pulse

; Sous routine d'envoi de l'octet dans A pour le lcd R0 contien le nombre de bits

ll_send:
	call	wdt_reset
	mov	c, acc.0	; Copie de l'octet a transferer dans C
	mov	ser_sda, c	; puis recopie sur le port
	nop
	nop
	setb	ser_scl		; Horloge à l'etat haut
	nop
	nop
	nop
	rr	a		; Preparer bit suivant
	clr	ser_scl		; Horloge a l'etat bas
	nop
	djnz	r0, ll_send	; fin de la boucle
	ret
	
;----------------------------------------
; Affichage de chiffres sur le lcd
;----------------------------------------
; Afficher unites, valeur dans R0
lcd_print_digit10:
        mov	dptr, #lpg10_table
	sjmp	lcd_print_digit
lcd_print_digit1:
        mov	dptr, #lpg1_table
lcd_print_digit:
	call	wdt_reset
	mov 	a, r0
	rl	a
	rl	a
	mov	r0, a
	movc	a, @a+dptr
	orl	lcd_dataA0,a
	inc	r0
	mov 	a, r0
	movc	a, @a+dptr
	orl	lcd_dataA1,a
	inc	r0
	mov 	a, r0
	movc	a, @a+dptr
	orl	lcd_dataA2,a
	ret

;----------------------------------------
; Affichage d'une valeur en decimal
;----------------------------------------
; Valeur dans R0
lcd_print_dec:
	call	wdt_reset
	mov	b, #0ah
	mov	a, r0
	div	ab
	mov	r0, a
	call	lcd_print_digit10
	mov	r0, b
	call	lcd_print_digit1
	ret
;----------------------------------------
; Affichage d'une valeur en hexadecimal
;----------------------------------------
; Valeur dans R0
lcd_print_hex:
	call	wdt_reset
	mov	a, r0
	mov	r2, a
	anl	a, #0fh
	mov	r0, a
	call	lcd_print_digit1
	mov	a, r2
	swap	a
	anl	a, #0fh
	mov	r0, a
	call	lcd_print_digit10
	ret

;----------------------------------------
; Effacement des chiffres
;----------------------------------------
lcd_clear_digits_r:
	call	wdt_reset
	anl	lcd_dataA0, #8fh
	anl	lcd_dataA1, #20h
	mov	lcd_dataA2, #0
	ret
	
;----------------------------------------
; Affichage des synboles
;----------------------------------------
display_update_symb:
	mov	a, #070h
	anl	lcd_dataA0, a
	mov	a, #0dfh
	anl	lcd_dataA1, a
	clr	a
	mov	b, P5
	; Reverse
	mov	c, chan_state.1
	mov	Acc.3, c
	; Mode squelch
	mov	c, mode.0
	mov	Acc.0, c
	; TX
	mov	c, mode.3
	mov	Acc.2, c	
	; Haute puissance
	mov	c, mode.1
	cpl	c
	mov	Acc.7, c
	orl	lcd_dataA0, a
	; Shift
	mov	c, chan_state.0
	mov	Acc.5, c
	mov	r0, a
	anl	a, #020h
	orl	lcd_dataA1, a
	mov	a, r0
	cjne	a, disp_hold, m_symb_update

	ret
m_symb_update:
	mov	disp_hold, a
	setb	mode.7
	ret

;----------------------------------------
; Test des boutons
;----------------------------------------
check_buttons:
	mov	b, #0
	call	wdt_reset
	mov	dptr, #0d000h
	movx	a, @dptr
	mov	r0, a
	jb	acc.1, cb_but2
	setb	b.0
cb_but2:
	jb	acc.2, cb_but3
	setb	b.1
cb_but3:
	mov	dptr, #0e000h
	movx	a, @dptr
	mov	r0, a
	jb	acc.1, cb_but4
	setb	b.2
cb_but4:
	jb	acc.2, cb_end
	setb	b.3
cb_end:
	mov	a, b
	ret

;----------------------------------------
; Test du bouton 1750
; Avec un call : 20us
;----------------------------------------
check_button_1750:
	mov	b, #0
	call	wdt_reset
	mov	dptr, #0d000h
	movx	a, @dptr
	mov	r0, a
	mov	c, acc.2
	ret

;----------------------------------------
; Decodage des touches appuyees
;----------------------------------------
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
	cpl	mode2.0				; Scan
	call	bip
	jmp	b_endbut
b_but4l:
	cjne	a, #8, b_endbut
	call	chan_inc
	jmp	b_endbut

b_endbut:
	ret

;----------------------------------------
; Tables pour l'afficheur
;----------------------------------------
lpg1_table:
	db	0h	; 0
	db	5ch
	db	03h
	db	0h
	db	0h	; 1
	db	40h
	db	01h
	db	0h
	db	0h	; 2
	db	98h
	db	03h
	db	0h
	db	0h	; 3
	db	0D0h
	db	03h
	db	0h
	db	0h	; 4
	db	0c4h
	db	01h
	db	0h
	db	0h	; 5
	db	0d4h
	db	02h
	db	0h
	db	0h	; 6
	db	0dch
	db	02h
	db	0h
	db	0h	; 7
	db	40h
	db	03h
	db	0h
	db	0h	; 8
	db	0dch
	db	03h
	db	0h
	db	0h	; 9
	db	0d4h
	db	03h
	db	0h
	db	0h	; A
	db	0cch
	db	03h
	db	0h
	db	0h	; B
	db	0dch
	db	0h
	db	0h
	db	0h	; C
	db	1ch
	db	02h
	db	0h
	db	0h	; D
	db	0d8h
	db	01h
	db	0h
	db	0h	; E
	db	9ch
	db	02h
	db	0h
	db	0h	; F
	db	8ch
	db	02h
	db	0h
	
lpg10_table:
	db	70h	; 0
	db	03h
	db	04h
	db	0h
	db	40h	; 1
	db	00h
	db	04h
	db	0h
	db	10h	; 2
	db	03h
	db	0ch
	db	0h
	db	50h	; 3
	db	01h
	db	0ch
	db	0h
	db	60h	; 4
	db	00h
	db	0ch
	db	0h
	db	70h	; 5
	db	01h
	db	08h
	db	0h
	db	70h	; 6
	db	03h
	db	08h
	db	0h
	db	50h	; 7
	db	00h
	db	04h
	db	0h
	db	70h	; 8
	db	03h
	db	0ch
	db	0h
	db	70h	; 9
	db	01h
	db	0ch
	db	0h
	db	70h	; A
	db	02h
	db	0ch
	db	0h
	db	60h	; B
	db	03h
	db	08h
	db	0h
	db	30h	; C
	db	03h
	db	00h
	db	0h
	db	40h	; D
	db	03h
	db	0ch
	db	0h
	db	30h	; E
	db	03h
	db	08h
	db	0h
	db	30h	; F
	db	02h
	db	08h
	db	0h

