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
BUT_REPEAT_MASK		EQU	0ch
BUT_RESET		EQU	0ch

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
; Sending BP1
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

;-------------------------------------------
; Display of numbers on the left 3 lcd digits
;-------------------------------------------
; Afficher unites, valeur dans R0
; Display units, value in R0

lcd_print_digit_d100_l:
    mov		dptr, #ld_l100_table
	sjmp	lcd_print_digit
lcd_print_digit_d10_l:
    mov		dptr, #ld_l10_table
	sjmp	lcd_print_digit
lcd_print_digit_d1_l:
	mov	dptr, #ld_l1_table
	sjmp	lcd_print_digit

	
;----------------------------------------
; Affichage de chiffres sur le lcd
; Display of numbers on the lcd
;----------------------------------------
; Afficher unites, valeur dans R0
; Display units, value in R0
lcd_print_digit_d10:
    mov		dptr, #ld_r10_table
	sjmp	lcd_print_digit
lcd_print_digit_d1:
    mov		dptr, #ld_r1_table

lcd_print_digit:
	call	wdt_reset
	mov 	a, r0
	rl		a						; calculate position within _table (1..F)
	rl		a
	rl		a
	mov		r0, a
	movc	a, @a+dptr			; fetch all 8 values
	orl		lcd_dataB0,a
	inc		r0
	mov 	a, r0
	movc	a, @a+dptr
	orl		lcd_dataB1,a
	inc		r0
	mov 	a, r0
	movc	a, @a+dptr
	orl		lcd_dataB2,a
	inc		r0
	mov 	a, r0
	movc	a, @a+dptr
	orl		lcd_dataB3,a
	inc		r0
	mov 	a, r0
	movc	a, @a+dptr
	orl		lcd_dataA0,a
	inc		r0
	mov 	a, r0
	movc	a, @a+dptr
	orl		lcd_dataA1,a
	inc		r0
	mov 	a, r0
	movc	a, @a+dptr
	orl		lcd_dataA2,a
	inc		r0
	mov 	a, r0
	movc	a, @a+dptr
	orl		lcd_dataA3,a
	ret

;----------------------------------------
; Affichage d'une valeur en decimal
; Displaying a value in decimal
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

;------------------------------------------------
; Display a value in hexadecimal at left 3 digits
;------------------------------------------------
; Valeur dans R0
lcd_print_hex_l:
;	call	wdt_reset
;	mov		a, r0
;	mov		r2, a
;	anl		a, #0fh
;	mov		r0, a
;	call	lcd_print_digit_d1_l
;	mov		a, r2
;	anl		a, #0fh
;	mov		r0, a
;	call	lcd_print_digit_d100_l		;for testing both digits will show the same value
;	mov		a, r2
;	swap	a
;	anl		a, #0fh
;	mov		r0, a
;	call	lcd_print_digit_d10_l
	ret

;------------------------------------------
; Display dezimal values of shift frequency 
; at left 3 digits
;------------------------------------------
lcd_print_dez_l:
	
	call	wdt_reset

	call	lcd_clear_digits_l

	mov		a, shift_dLo

	mov		r2, a						; digit 1
	anl		a, #0fh
	mov		r0, a
	call	lcd_print_digit_d1_l		; value for lcd_print in R0

	mov		a, r2						; digit 10
	swap	a
	anl		a, #0fh
	mov		r0, a
	call	lcd_print_digit_d10_l		

	mov		a, shift_dHi				; digit 100
	anl		a, #0fh
	mov		r0, a
	call	lcd_print_digit_d100_l		;
	ret


;----------------------------------------
; Affichage d'une valeur en hexadecimal
; Display a value in hexadecimal
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
; Clearing the numbers 
;----------------------------------------
lcd_clear_digits_r:
	call	wdt_reset
	anl	lcd_dataB3, #003h
	anl	lcd_dataA0, #0fch
	anl	lcd_dataA3, #003h

	ret
	
;------------------------------------------
; Effacement des chiffres
; Clearing the numbers of the left 3 digits
;------------------------------------------
lcd_clear_digits_l:
	call	wdt_reset
	anl	lcd_dataB0, #00001111b
	anl	lcd_dataB1, #01111011b
	anl	lcd_dataB2, #11110000b
	anl	lcd_dataA0, #00000111b
	anl	lcd_dataA1, #01111001b
	anl	lcd_dataA2, #11110000b
	ret

;----------------------------------------
; Mise a jour des symboles
; Symbol update
;----------------------------------------
display_update_symb:
	mov	c, chan_state.2 	; Shift +
	mov	disp_state.7, c
	mov	c, chan_state.3		; Lock out
	mov	disp_state.6, c
	mov	c, mode.3 		; TX
	mov	disp_state.5, c
	mov	c, chan_state.0 	; Shift
	mov	disp_state.4, c
	mov	c, chan_state.1 	; Reverse
	mov	disp_state.3, c
	mov	c, mode.1 		; Power
	cpl	c
	mov	disp_state.2, c
	mov	c, mode.0 		; Squelch mode
	mov	disp_state.1, c
	mov	c, mode.2
	mov	disp_state.0, c
	
	mov	a, disp_state
	cjne	a, disp_hold, m_symb_update
	ret
	
m_symb_update:
	mov	a, #0fbh
	anl	a, lcd_dataA0
	mov	c, disp_state.5
	mov	Acc.2, c
	mov	lcd_dataA0, a

	mov	a, #00fh
	anl	a, lcd_dataA2
	jnb	disp_state.4, msu_shift_end	; If no shift : jump
	setb	Acc.5
	jb	disp_state.7, msu_shift_pos	; Test if shift is positive or negative
	setb	Acc.4
	jmp	msu_shift_end
msu_shift_pos:
	setb	Acc.6
msu_shift_end:	
	mov	lcd_dataA2, a
	
	mov	a, #070h
	anl	a, lcd_dataB0
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

	mov	a, #00fh
	anl	a, lcd_dataB2
	mov	c, disp_state.6
	mov	Acc.4, c
	mov	lcd_dataB2, a
	
	mov	disp_hold, disp_state
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
; Decoding of pressed keys
;----------------------------------------
b_decoding:
	mov	a, but_hold_state
	mov	but_hold_state, r0

	mov	b, r1						; Test appui long / Test long "preasure"
	jb	b.0, b_but1l				; si vrai sauter / so true jump
b_but1:	; 
	cjne	a, #1, b_but2
	call	switch_power			; TX power
	jmp	b_endbut
b_but2: ; 
	cjne	a, #2, b_but3
	call	switch_reverse			; Claus: does that switch work as expected?? seems to behave curios
	jmp	b_endbut
b_but3: ; 
	cjne	a, #4, b_but4
	call	chan_inc				; channel/squelch inc.
	jmp	b_endbut
b_but4: ; 
	cjne	a, #8, b_but5
	call	chan_dec				; channel/squelch dec.
	jmp	b_endbut
b_but5: ; 
	cjne	a, #16, b_but6
	call	switch_scan				; Scan
	jmp	b_endbut
b_but6: ; 
	cjne	a, #32, b_but7
	call	switch_mode				; Switch Mode (Channel <-> Squelch)
	jmp	b_endbut
b_but7: ; 
	cjne	a, #64, b_but8
	call	L_Disp_dec				; Test: Decrement Left 3 display digits
	jmp	b_endbut
b_but8: ; 
	cjne	a, #128, b_but16
	call	L_Disp_inc				; Test: Increment Left 3 display digits
	jmp	b_endbut
b_but16: ; 1 + 6
	cjne	a, #33, b_endbut
	call	switch_rssi				; RSSI displaying
	jmp	b_endbut

b_but1l:
	cjne	a, #1, b_but2l

	jmp	b_endbut
b_but2l:
	cjne	a, #2, b_but3l
	call	switch_shift_mode2
	call	bip
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
	call	switch_lock_out
	call	bip
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


;------------------------------------------
; Write Shift Frequency to display variable
; Hex value High = R0, Hex value Low = A
; dont modify accu and R0 ! 
;------------------------------------------

shift_dsp:
	push 	acc
	XCH		a,R0						; Push A, R0
	push	acc
	XCH		a,R0

	mov		R3,a						; Low Shift

										; shift frequency *12,5 (khz)
	
	mov		R2,#0

	mov		a, R0						;Calculate frequency 7Mhz = 700(=PLL value * 125/100 = * 1,25 = *1 + 1/4)
	mov		b, R3
	clr		c
	rrc		a							; /4
	XCH		a,b
	rrc		a
	XCH		a,b
	clr		c	
	rrc		a
	XCH		a,b
	rrc		a							; a = shift_dLo/4

	add		a, R3						; shift_d * (1+1/4=) 1,25
	XCH		a,b
	addc	a, R0
	XCH		a,b							; b=high value, a=low value



										; check how many times 100dez is inluded
	clr		c

check100:
	subb 	a,#100						; check digit 100
	XCH		a,b							;
	subb	a,#0						; High Byte -1 if carry (Low Byte underflow)
	XCH		a,b							;
	jc		check100done				; if High Byte < 0: we are done
	inc		R2							; next hundret
	sjmp	check100					; (remember carry is zero now)

check100done:
	add		a,#100						; restore "rest" (0..99)
	
	mov		b,#10
	div		ab
	anl		a,#0Fh						;
	SWAP	a							; *10 is high byte 
	add		a,b							; add rest (*1)				
	mov		shift_dLo,a					;	
	
	mov		a,R2						;
	anl		a,#0Fh	
	mov		shift_dHi,a					;	
	
	pop		acc
	XCH		a, R0						; restore R0
	pop 	acc
	ret

;----------------------------------------
; Tables pour l'afficheur
; Tables for the display 
; Byte-Register order: B0..B3, A0..A3
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
	db	0A0h
	db	001h
	db	0h
	db	0h
	db	0E0h
	db	0h	; B
	db	0h
	db	0h
	db	0E0h
	db	000h
	db	0h
	db	0h
	db	060h
	db	0h	; C
	db	0h
	db	0h
	db	060h
	db	001h
	db	0h
	db	0h
	db	020h
	db	0h	; D
	db	0h
	db	0h
	db	0E0h
	db	000h
	db	0h
	db	0h
	db	0C0h
	db	0h	; E
	db	0h
	db	0h
	db	060h
	db	001h
	db	0h
	db	0h
	db	060h
	db	0h	; F
	db	0h
	db	0h
	db	020h
	db	001h
	db	0h
	db	0h
	db	060h

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
	db	014h
	db	002h
	db	0h
	db	0h
	db	01Ch
	db	0h	; B
	db	0h
	db	0h
	db	01Ch
	db	000h
	db	0h
	db	0h
	db	00Ch
	db	0h	; C
	db	0h
	db	0h
	db	00Ch
	db	002h
	db	0h
	db	0h
	db	004h
	db	0h	; D
	db	0h
	db	0h
	db	01Ch
	db	000h
	db	0h
	db	0h
	db	018h
	db	0h	; E
	db	0h
	db	0h
	db	00Ch
	db	002h
	db	0h
	db	0h
	db	00Ch
	db	0h	; F
	db	0h
	db	0h
	db	004h
	db	002h
	db	0h
	db	0h
	db	00Ch
	
	
;---------------------------------------------
; Tables for the additional 3 left 8070 digits 
; Byte-Register order: B0..B3, A0..A3
;---------------------------------------------
ld_l1_table:
	db	0b				; 0
	db	0b
	db	00001110b
	db	0b
	db	00001000b
	db	0b
	db	00001010b
	db	0b
	
	db	0b				; 1
	db	0b
	db	00001000b
	db	0b
	db	0b
	db	0b
	db	00001000b
	db	0b
	
	db	0b				; 2
	db	0b
	db	00000110b
	db	0b
	db	00001000b
	db	0b
	db	00001100b
	db	0b
	
	db	0b				; 3
	db	0b
	db	00001100b
	db	0b
	db	00001000b
	db	0b
	db	00001100b
	db	0b
	
	db	0b				; 4
	db	0b
	db	00001000b
	db	0b
	db	0b
	db	0b
	db	00001110b
	db	0b
	
	db	0b				; 5
	db	0b
	db	00001100b
	db	0b
	db	00001000b
	db	0b
	db	00000110b
	db	0b
	
	db	0b				; 6
	db	0b
	db	00001110b
	db	0b
	db	00001000b
	db	0b
	db	00000110b
	db	0b
	
	db	0b				; 7
	db	0b
	db	00001000b
	db	0b
	db	00001000b
	db	0b
	db	00001000b
	db	0b
	
	db	0b				; 8
	db	0b
	db	00001110b
	db	0b
	db	00001000b
	db	0b
	db	00001110b
	db	0b
	
	db	0b				; 9
	db	0b
	db	00001100b
	db	0b
	db	00001000b
	db	0b
	db	00001110b
	db	0b
	
	db	0b				; A
	db	0b
	db	00001010b
	db	0b
	db	00001000b
	db	0b
	db	00001110b
	db	0b
	
	db	0b				; B
	db	0b
	db	00001110b
	db	0b
	db	00000000b
	db	0b
	db	00000110b
	db	0b

	db	0b				; C
	db	0b
	db	00000110b
	db	0b
	db	00001000b
	db	0b
	db	00000010b
	db	0b
	
	db	0b				; D
	db	0b
	db	00001110b
	db	0b
	db	00000000b
	db	0b
	db	00001100b
	db	0b
	
	db	0b				; E
	db	0b
	db	00000110b
	db	0b
	db	00001000b
	db	0b
	db	00000110b
	db	0b
	
	db	0b				; F
	db	0b
	db	00000010b
	db	0b
	db	00001000b
	db	0b
	db	00000110b
	db	0b

ld_l10_table:
	db	01110000b		; 0
	db	0b
	db	0b
	db	0b
	db	11010000b
	db	0b
	db	0b
	db	0b
	
	db	00010000b		; 1
	db	0b
	db	0b
	db	0b
	db	00010000b
	db	0b
	db	0b
	db	0b
	
	db	01100000b		; 2
	db	0b
	db	0b
	db	0b
	db	10110000b
	db	0b
	db	0b
	db	0b
	
	db	00110000b		; 3
	db	0b
	db	0b
	db	0b
	db	10110000b
	db	0b
	db	0b
	db	0b
	
	db	00010000b		; 4
	db	0b
	db	0b
	db	0b
	db	01110000b
	db	0b
	db	0b
	db	0b
	
	db	00110000b		; 5
	db	0b
	db	0b
	db	0b
	db	11100000b
	db	0b
	db	0b
	db	0b
	
	db	01110000b		; 6
	db	0b
	db	0b
	db	0b
	db	11100000b
	db	0b
	db	0b
	db	0b
	
	db	00010000b		; 7
	db	0b
	db	0b
	db	0b
	db	10010000b
	db	0b
	db	0b
	db	0b
	
	db	01110000b		; 8
	db	0b
	db	0b
	db	0b
	db	11110000b
	db	0b
	db	0b
	db	0b
	
	db	00110000b		; 9
	db	0b
	db	0b
	db	0b
	db	11110000b
	db	0b
	db	0b
	db	0b
	
	db	01010000b		; A
	db	0b
	db	0b
	db	0b
	db	11110000b
	db	0b
	db	0b
	db	0b
	
	db	01110000b		; B
	db	0b
	db	0b
	db	0b
	db	01100000b
	db	0b
	db	0b
	db	0b
	
	db	01100000b		; C
	db	0b
	db	0b
	db	0b
	db	11000000b
	db	0b
	db	0b
	db	0b
	
	db	01110000b		; D
	db	0b
	db	0b
	db	0b
	db	00110000b
	db	0b
	db	0b
	db	0b
	
	db	01100000b		; E
	db	0b
	db	0b
	db	0b
	db	11100000b
	db	0b
	db	0b
	db	0b
	
	db	01000000b		; F
	db	0h
	db	0h
	db	0h
	db	11100000b
	db	0h
	db	0h
	db	0h
	
ld_l100_table:
	db	0b			; 0
	db	10000100b
	db	00000001b
	db	0b
	db	0b
	db	10000110b
	db	0b
	db	0b
	
	db	0b			; 1
	db	00000100b
	db	0b
	db	0b
	db	0b
	db	00000100b
	db	0b
	db	0b
	
	db	0b			; 2
	db	10000000b
	db	00000001b
	db	0b
	db	0b
	db	00000110b
	db	00000001b
	db	0b
	
	db	0b			; 3
	db	00000100b
	db	00000001b
	db	0b
	db	0b
	db	00000110b
	db	00000001b
	db	0b
	
	db	0b			; 4
	db	00000100b
	db	0b
	db	0b
	db	0b
	db	10000100b
	db	00000001b
	db	0b
	
	db	0b			; 5
	db	00000100b
	db	00000001b
	db	0b
	db	0b
	db	10000010b
	db	00000001b
	db	0b
	
	db	0b			; 6
	db	10000100b
	db	00000001b
	db	0b
	db	0b
	db	10000010b
	db	00000001b
	db	0b
	
	db	0b			; 7
	db	00000100b
	db	0b
	db	0b
	db	0b
	db	00000110b
	db	0b
	db	0b
	
	db	0b			; 8
	db	10000100b
	db	00000001b
	db	0b
	db	0b
	db	10000110b
	db	00000001b
	db	0b
	
	db	0b			; 9
	db	00000100b
	db	00000001b
	db	0b
	db	0b
	db	10000110b
	db	00000001b
	db	0b
	
	db	0b			; A
	db	10000100b
	db	00000000b
	db	0b
	db	0b
	db	10000110b
	db	00000001b
	db	0b
	
	db	0b			; B
	db	10000100b
	db	00000001b
	db	0b
	db	0b
	db	10000000b
	db	00000001b
	db	0b
	
	db	0b			; C
	db	10000000b
	db	00000001b
	db	0b
	db	0b
	db	10000010b
	db	0b
	db	0b
	
	db	0b			; D
	db	10000100b
	db	00000001b
	db	0b
	db	0b
	db	00000100b
	db	00000001b
	db	0b
	
	db	0b			; E
	db	10000000b
	db	00000001b
	db	0b
	db	0b
	db	10000010b
	db	00000001b
	db	0b
	
	db	0b			; F
	db	10000000b
	db	0b
	db	0b
	db	0b
	db	10000010b
	db	00000001b
	db	0b