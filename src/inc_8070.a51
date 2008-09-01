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
; Chargement du lcd
;----------------------------------------
load_lcd:
; Envoi BP0
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
	mov	r0, #8		; 8 Bits a transemettre
	mov	A, lcd_dataA2
	call	ll_send
	mov	r0, #8		; 8 Bits a transemettre
	mov	A, lcd_dataA3
	call	ll_send
	
	clr	c		; Bit 33 a 0 pour charger BP0 (A)
	mov	ser_sda, c	; puis recopie sur le port
	nop
	nop
	setb	ser_scl		; Horloge à l'etat haut
	nop
	nop
	nop
	clr	ser_scl		; Horloge a l'etat bas
	nop
	nop
	nop
	
	clr	lcd_dlen	; Fin envoi donnees
	nop
	nop
	nop
	clr	ser_sda		; Donnees a l'etat bas
	setb	ser_scl		; Appliquer load pulse
	nop
	nop
	clr	ser_scl		; fin load pulse
	
	nop
	nop
	nop
	nop
	nop
	
; Envoi BP1
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
	mov	A, lcd_dataB0
	call	ll_send
	mov	r0, #8		; 8 Bits a transemettre
	mov	A, lcd_dataB1
	call	ll_send
	mov	r0, #8		; 8 Bits a transemettre
	mov	A, lcd_dataB2
	call	ll_send
	mov	r0, #8		; 8 Bits a transemettre
	mov	A, lcd_dataB3
	call	ll_send
	
	setb	c		; Bit 33 a 1 pour charger BP1 (B)
	mov	ser_sda, c	; puis recopie sur le port
	nop
	nop
	setb	ser_scl		; Horloge à l'etat haut
	nop
	nop
	nop
	clr	ser_scl		; Horloge a l'etat bas
	nop
	nop
	nop
	
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
	mov	c, acc.0	; Copie du bit a transferer dans C
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
; Afficher unités, valeur dans R0
lcd_print_digit_d10:
        mov	dptr, #ld_r10_table
	sjmp	lcd_print_digit
lcd_print_digit_d1:
        mov	dptr, #ld_r1_table
lcd_print_digit:
	call	wdt_reset
	mov 	a, r0
	rl	a
	rl	a
	rl	a
	mov	r0, a
	movc	a, @a+dptr
	orl	lcd_dataB0,a
	inc	r0
	mov 	a, r0
	movc	a, @a+dptr
	orl	lcd_dataB1,a
	inc	r0
	mov 	a, r0
	movc	a, @a+dptr
	orl	lcd_dataB2,a
	inc	r0
	mov 	a, r0
	movc	a, @a+dptr
	orl	lcd_dataB3,a
	inc	r0
	mov 	a, r0
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
	inc	r0
	mov 	a, r0
	movc	a, @a+dptr
	orl	lcd_dataA3,a
	ret

;----------------------------------------
; Affichage d'une valeur en décimal
;----------------------------------------
; Valeur dans R0
lcd_print_dec:
	call	wdt_reset
	mov	b, #0ah
	mov	a, r0
	div	ab
	mov	r0, a
	call	lcd_print_digit_d10
	mov	r0, b
	call	lcd_print_digit_d1
	ret
;----------------------------------------
; Affichage d'une valeur en hexadécimal
;----------------------------------------
; Valeur dans R0
lcd_print_hex:
	call	wdt_reset
	mov	a, r0
	mov	r2, a
	anl	a, #0fh
	mov	r0, a
	call	lcd_print_digit_d1
	mov	a, r2
	swap	a
	anl	a, #0fh
	mov	r0, a
	call	lcd_print_digit_d10
	ret

;----------------------------------------
; Effacement des chiffres
;----------------------------------------
lcd_clear_digits_r:
	call	wdt_reset
	anl	lcd_dataB3, #003h
	anl	lcd_dataA0, #0fch
	anl	lcd_dataA3, #003h

	ret

;----------------------------------------
; Mise a jour des symboles
;----------------------------------------
update_symb:
	mov	a, #0fbh
	anl	a, lcd_dataA0
	mov	c, disp_state.5
	mov	Acc.2, c
	mov	lcd_dataA0, a
	
	mov	a, #070h
	anl	a, lcd_dataB0
	mov	c, disp_state.4
	mov	Acc.2, c
	mov	c, disp_state.3
	mov	Acc.3, c
	mov	c, disp_state.2
	mov	Acc.0, c

	mov	lcd_dataB0, a
	
	mov	a, #0fch
	anl	a, lcd_dataB1
	mov	c, disp_state.0
	mov	Acc.0, c
	mov	c, disp_state.1
	mov	Acc.1, c
	mov	lcd_dataB1, a
	
;	mov	a, #08fh
;	mov	Acc.0, c
;	mov	lcd_dataB2, a
	
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
	jb	acc.0, cb_but2
	setb	b.0
cb_but2:
	jb	acc.1, cb_but3
	setb	b.1
cb_but3:
	jb	acc.2, cb_but4
	setb	b.2
cb_but4:
	mov	dptr, #0e000h
	movx	a, @dptr
	mov	r0, a
	jb	acc.0, cb_but5
	setb	b.3
cb_but5:
	jb	acc.1, cb_but6
	setb	b.4
cb_but6:
	jb	acc.2, cb_but7
	setb	b.5
cb_but7:
	mov	dptr, #0c000h
	movx	a, @dptr
	mov	r0, a
	jb	acc.1, cb_but8
	setb	b.6
cb_but8:
	jb	acc.2, cb_end
	setb	b.7
cb_end:
	mov	a, b
	ret

;----------------------------------------
; Tables pour l'afficheur
;----------------------------------------
ld_r1_table:
	db	0h	; 0
	db	0h
	db	0h
	db	0E0h
	db	001h
	db	0h
	db	0h
	db	0A0h
	db	0h	; 1
	db	0h
	db	0h
	db	080h
	db	000h
	db	0h
	db	0h
	db	080h
	db	0h	; 2
	db	0h
	db	0h
	db	060h
	db	001h
	db	0h
	db	0h
	db	0C0h
	db	0h	; 3
	db	0h
	db	0h
	db	0C0h
	db	001h
	db	0h
	db	0h
	db	0C0h
	db	0h	; 4
	db	0h
	db	0h
	db	080h
	db	000h
	db	0h
	db	0h
	db	0E0h
	db	0h	; 5
	db	0h
	db	0h
	db	0C0h
	db	001h
	db	0h
	db	0h
	db	060h
	db	0h	; 6
	db	0h
	db	0h
	db	0E0h
	db	001h
	db	0h
	db	0h
	db	060h
	db	0h	; 7
	db	0h
	db	0h
	db	080h
	db	001h
	db	0h
	db	0h
	db	080h
	db	0h	; 8
	db	0h
	db	0h
	db	0E0h
	db	001h
	db	0h
	db	0h
	db	0E0h
	db	0h	; 9
	db	0h
	db	0h
	db	0C0h
	db	001h
	db	0h
	db	0h
	db	0E0h
	db	0h	; A
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h	; B
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h	; C
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h	; D
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h	; E
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	080h
	db	0h	; F
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
ld_r10_table:
	db	0h	; 0
	db	0h
	db	0h
	db	01Ch
	db	002h
	db	0h
	db	0h
	db	014h
	db	0h	; 1
	db	0h
	db	0h
	db	010h
	db	000h
	db	0h
	db	0h
	db	010h
	db	0h	; 2
	db	0h
	db	0h
	db	00Ch
	db	002h
	db	0h
	db	0h
	db	018h
	db	0h	; 3
	db	0h
	db	0h
	db	018h
	db	002h
	db	0h
	db	0h
	db	018h
	db	0h	; 4
	db	0h
	db	0h
	db	010h
	db	000h
	db	0h
	db	0h
	db	01Ch
	db	0h	; 5
	db	0h
	db	0h
	db	018h
	db	002h
	db	0h
	db	0h
	db	00Ch
	db	0h	; 6
	db	0h
	db	0h
	db	01Ch
	db	002h
	db	0h
	db	0h
	db	00Ch
	db	0h	; 7
	db	0h
	db	0h
	db	010h
	db	002h
	db	0h
	db	0h
	db	010h
	db	0h	; 8
	db	0h
	db	0h
	db	01Ch
	db	002h
	db	0h
	db	0h
	db	01Ch
	db	0h	; 9
	db	0h
	db	0h
	db	018h
	db	002h
	db	0h
	db	0h
	db	01Ch
	db	0h	; A
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h	; B
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h	; C
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h	; D
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h	; E
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	008h	; F
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	db	0h
	