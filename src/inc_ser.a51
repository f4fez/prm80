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

; "InitRS232_1200" et "InitRS232_4800" : initialisation du port série
; (1200 ou 4800 bauds), des buffers RX / TX, et de l'interruption.
;
; Calcul de la valeur à fournir au Timer1 pour obtenir le débit voulu :
; TH1 = TL1 = 256-[(K x 12000000)/(384 x débit)]
;
; - avec K=1 (bit SMOD du registre PCON à 0) et "débit" = 1200 on obtient :
;   TH1 = TL1 = 256-[12000000/(384 x 1200)] = 229,9583333
;   Avec TH1 = TL1 = 230 on obtient un débit réel de 1201,92 bauds.
; - avec K=2 (bit SMOD du registre PCON à 1) et "débit" = 4800 on obtient :
;   TH1 = TL1 = 256-[(2 x 12000000)/(384 x 4800)] = 242,9791666
;   Avec TH1 = TL1 = 243 on obtient un débit réel de 4807,67 bauds.
;

InitRS232_1200:  		                ; En cas de réinitialisation 
                 CLR        ES0                ; du port déjà configuré (ex :
                 CLR        TR1                ; changement de la vitesse),
                                               ; commencer par désactiver
                                               ; Timer1 et les interruptions.
                 CLR        RD_err             ; - Initialiser les buffers :
                 CLR        TFR_run            ; Booleens :
                 MOV        PtrRXin,#0         ; RD_err=0, TFR_run=0.
                 MOV        PtrRXout,#0        ; Octets : 
                 MOV        RXnbo,#0           ; RXnbo=0, TXnbo=0,
                 MOV        PtrTXin,#0         ; PtrRXin=0, PtrRXout=0,
                 MOV        PtrTXout,#0        ; PtrTXin=0, PtrTXout=0.
                 MOV        TXnbo,#0           ; - Initialiser le hardware :
                 ANL        PCON,#01111111b    ; K=1 mettre SMOD=PCON.7 à "0". 
                 MOV        S0CON,#01110010b   ; Initialiser la liaison série
					       ; en mode 1200 bauds, 1 start,
                 MOV        TH1,#230           ; 8 bits, 1 stop ; utiliser le
                 MOV        TL1,#230           ; Timer 1 comme fréquence de
                 SETB       TR1                ; référence (avec Xtal=12MHz).
                 SETB       ES0                ; Désinhiber l'interruption de
                 		               ; pilotage du port série.
		 setb	    PS0		       ; Priorite port serie
                 call       Tempo50ms          ; Temporisation 50 ms.
                 PUSH       DPH                ; Sauvegarder DPTR.
                 PUSH       DPL                ; 
                 MOV        DPTR,#Message01    ;Message d'accueil et version.
                 call       MESS_RS232         ;
                 POP        DPL                ; Restituer DPTR.
                 POP        DPH                ; 
                 RET                           ; Fin de routine.

InitRS232_4800:  	                       ; En cas de réinitialisation 
                 CLR        ES0                ; du port déjà configuré (ex :
                 CLR        TR1                ; changement de la vitesse),
                                               ; commencer par désactiver
                                               ; Timer1 et les interruptions.
                 CLR        RD_err             ; - Initialiser les buffers :
                 CLR        TFR_run            ; Booleens :
                 MOV        PtrRXin,#0         ; RD_err=0, TFR_run=0.
                 MOV        PtrRXout,#0        ; Octets : 
                 MOV        RXnbo,#0           ; RXnbo=0, TXnbo=0,
                 MOV        PtrTXin,#0         ; PtrRXin=0, PtrRXout=0,
                 MOV        PtrTXout,#0        ; PtrTXin=0, PtrTXout=0.
                 MOV        TXnbo,#0           ; - Initialiser le hardware :
                 ORL        PCON,#10000000b    ; K=2 mettre SMOD=PCON.7 à "1". 
                 MOV        S0CON,#01110010b   ; Initialiser la liaison série
					       ; en mode 4800 bauds, 1 start,
                 MOV        TH1,#243           ; 8 bits, 1 stop ; utiliser le
                 MOV        TL1,#243           ; Timer 1 comme fréquence de
                 SETB       TR1                ; référence (avec Xtal=12MHz).
                 SETB       ES0                ; Désinhiber l'interruption de
                 	                       ; pilotage du port série.
		 setb	    PS0		       ; Priorite port serie
                 call       Tempo50ms          ; Temporisation 50 ms
                 PUSH       DPH                ; Sauvegarder DPTR.
                 PUSH       DPL                ; 
                 MOV        DPTR,#Message01    ; Message d'accueil et version.
                 call       MESS_RS232         ; 
                 POP        DPL                ; Restituer DPTR.
                 POP        DPH                ; 
                 RET                           ; Fin de routine.

; "Read_RS232" : extrait du buffer de réception RS232 une donnée en attente,
; et la place dans l'accumulateur A. Avant d'appeler la routine, vérifier
; éventuellement l'état du bit "BufRXvide" ; sinon, le bit "RD_err" sera 
; activé. Le buffer de réception se trouve en RAM externe de $0800 à $08FF.

Read_RS232:      CLR        ES0           ; 
                 PUSH       DPH           ; 
                 PUSH       DPL           ; 
                 PUSH       ACC           ; 
                 MOV        A,RXnbo       ; 
                 JNZ        rd_rx_buf     ; 
                 SETB       RD_err        ; 
                 POP        ACC           ; 
                 JMP        end_rdr       ; 
rd_rx_buf:       POP        ACC           ; 
                 MOV        DPH,#08h      ; 
                 MOV        DPL,PtrRXout  ; 
                 MOVX       A,@DPTR       ; 
                 INC        PtrRXout      ; 
                 CLR        RD_err        ; 
                 DEC        RXnbo         ; 
end_rdr:         POP        DPL           ; 
                 POP        DPH           ; 
                 SETB       ES0           ; 
                 RET                      ; 

; "Write_RS232" : Place le caractère à envoyer (contenu dans A) dans le
; buffer d'émission (lequel se trouve en RAM externe, de $0900 à $09FF).

Write_RS232:     PUSH       DPH              ; 
                 PUSH       DPL              ; 
                 PUSH       ACC              ; 
readTXnbo:       MOV        A,TXnbo          ; 
                 CJNE       A,#255,txnotfull ; 
                 call       wdt_reset    ; 
                 JMP        readTXnbo        ; 
txnotfull:       CLR        ES0              ; 
                 MOV        DPH,#09h         ; 
                 MOV        DPL,PtrTXin      ; 
                 POP        ACC              ; 
                 MOVX       @DPTR,A          ; 
                 INC        PtrTXin          ; 
                 INC        TXnbo            ; 
                 JB         TFR_run,end_wr   ; 
                 SETB       TI               ; 
end_wr:          POP        DPL              ; 
                 POP        DPH              ; 
                 SETB       ES0              ; 
                 RET                         ; 

; "SPACE_RS232" : envoie un espace ' ' sur la liaison série.

SPACE_RS232:     PUSH       ACC              ; 
                 MOV        A,#' '           ; 
                 call       Write_RS232      ; 
                 POP        ACC              ; 
                 RET                         ; 

; "CRLF_RS232" : envoie un "Carriage Return" puis un "Line Feed"
; sur la liaison série, et effectue ainsi un retour à la ligne.

CRLF_RS232:      PUSH       ACC              ; 
                 MOV        A,#00Dh          ; 
                 call       Write_RS232      ; 
                 MOV        A,#00Ah          ; 
                 call       Write_RS232      ; 
                 POP        ACC              ; 
                 RET                         ; 

; "MES_RS232" : envoie un message sur la liaison série RS232.
; Le pointeur DPTR contient l'adresse du message à envoyer.

MESS_RS232:      PUSH       ACC              ; 
car_suiv:        MOV        A,#0             ; 
                 MOVC       A,@A+DPTR        ; 
                 JZ         fin_mess         ; 
                 call       Write_RS232      ; 
                 INC        DPTR             ; 
                 JMP        car_suiv         ; 
fin_mess:        POP        ACC              ; 
                 RET                         ; 

; "HEX_RS232" : Le contenu de A est envoyé sur le port série 
; sous la forme de deux caractères ASCII (donc en hexadécimal).

HEX_RS232:       PUSH       DPH              ; 
                 PUSH       DPL              ; 
                 PUSH       ACC              ; 
                 MOV        DPTR,#TableHEX   ; 
                 SWAP       A                ; 
                 ANL        A,#00001111b     ; 
                 MOVC       A,@A+DPTR        ; 
                 call       Write_RS232      ; 
                 POP        ACC              ; 
                 PUSH       ACC              ; 
                 ANL        A,#00001111b     ; 
                 MOVC       A,@A+DPTR        ; 
                 call       Write_RS232      ; 
		 POP        ACC              ; 
                 POP        DPL              ; 
                 POP        DPH              ; 
                 RET                         ; 		 

TableHEX:        DB         "0123456789ABCDEF" ; 

; "DEC_RS232 : Le contenu de A est envoye sur le por serie
; au format decimal
DEC_RS232:
                PUSH    ACC
		mov	b, #0ah
		div	ab
		add	a, #'0'
		call	Write_RS232
		mov	a, b
		add	a, #'0'
		call	Write_RS232
		POP     ACC
		RET

; "WaitRS232" : attend si nécessaire l'arrivée d'un caractère par
;               la liaison série, puis le lit (il est mis dans A).

WaitRS232:       call       wdt_reset    ; Ré-initialiser le WatchDog.
                 MOV        A,RXnbo          ; Pas de données dans le buffer ?
                 JZ         WaitRS232        ; -> recommencer la boucle...
                 call       Read_RS232       ; Donnée présente : la lire.
                 RET                         ; Fin de routine.

; "XXinRS232" : attend l'arrivée de deux chiffres hexadécimaux sur le
;               port série (sous forme ASCII). Active le bit XXDD_OK si
;               ceux-ci sont bien arrivés, le résultat étant mis dans 
;               l'accumulateur A, sinon A vaut -1. La routine renvoie
;               l'écho des touches sur le port si elles sont correctes.

; "XXinRS232" : waits for the arrival of two hexadecimal digits on the
;               serial port (as ASCII). Enable bit XXDD_OK if
;               these arrived well, the result being put into 
;               the accumulator A, otherwise A is -1. The routine returns
;               the echo of the keys on the port if they are correct.

XXinRS232:       PUSH       0                  ; Sauvegarder R0. 
                 call       WaitRS232          ; Attendre une touche.
                 call       AnalyseChar        ; Analyser sa valeur :
                 JNB        CH_hex,err_XXin    ; Hexa ? sinon erreur.
                 MOV        A,RS_ASCmaj        ; Si OK, renvoyer la touche
                 call       Write_RS232        ; en majuscule sur le port.
                 MOV        A,RS_HexDec        ; Lire les quatre bits
                 SWAP       A                  ; (quartet de poids fort).
                 MOV        R0,A               ; Sauvegarder A dans R0.
                 call       WaitRS232          ; Attendre une touche.
                 call       AnalyseChar        ; Analyser sa valeur :
                 JNB        CH_hex,err_XXin    ; Hexa ? si non, erreur.
                 MOV        A,RS_ASCmaj        ; Si OK, renvoyer la touche
                 call       Write_RS232        ; en majuscule sur le port.
                 MOV        A,R0               ; Récupérer A et lui ajouter
                 ORL        A,RS_HexDec        ; les quatre bits du quartet
                 SETB       XXDD_OK            ; de poids faible.
                 JMP        fin_XXin           ; Activer l'indicateur XXDD_OK.
err_XXin:        MOV        A,#-1              ; Si erreur, Accu = -1 puis
                 CLR        XXDD_OK            ; désactiver l'indicateur.
fin_XXin:        POP        0                  ; Récupérer R0.
                 RET                           ; Fin de routine.

; "DDinRS232" : attend l'arrivée de deux chiffres décimaux sur le port
;               série (sous forme ASCII). Active le bit XXDD_OK si
;               ceux-ci sont bien arrivés, le résultat étant mis dans 
;               l'accumulateur A, sinon A vaut -1. La routine renvoie
;               l'écho des touches sur le port si elles sont correctes.

; "DDinRS232":  awaits the arrival of two decimal digits on the port
;               serial (in ASCII form). Enable bit XXDD_OK if
;               these arrived well, the result being put into 
;               the accumulator A, otherwise A is -1. The routine returns
;               the echo of the keys on the port if they are correct.

DDinRS232:       PUSH       B                  ; Sauvegarder B.
                 PUSH       0                  ; Sauvegarder R0. 
                 call       WaitRS232          ; Attendre une touche.
                 call       AnalyseChar        ; Analyser sa valeur :
                 JNB        CH_dec,err_DDin    ; Décimal ? sinon erreur.
                 call       Write_RS232        ; Si OK, renvoyer la touche
                 MOV        A,RS_HexDec        ; sur le port. 
                 MOV        B,#10              ; Lire les dizaines...
                 MUL        AB                 ; ...et calculer (10 x A).
                 MOV        R0,A               ; Sauvegarder A dans R0.
                 call       WaitRS232          ; Attendre une touche.
                 call       AnalyseChar        ; Analyser sa valeur :
                 JNB        CH_dec,err_DDin    ; Décimal ? si non, erreur.
                                               ; Si OK, renvoyer la touche
                 call       Write_RS232        ; sur le port.
                 MOV        A,R0               ; Récupérer A et lui ajouter
                 ADD        A,RS_HexDec        ; les quatre bits du quartet
                 SETB       XXDD_OK            ; de poids faible (unités).
                 JMP        fin_DDin           ; Activer l'indicateur XXDD_OK.
err_DDin:        MOV        A,#-1              ; Si erreur, Accu = -1 puis
                 CLR        XXDD_OK            ; désactiver l'indicateur.
fin_DDin:        POP        0                  ; Récupérer R0.
                 POP        B                  ; Récupérer B.
                 RET                           ; Fin de routine.

; "Page_RS232" : envoie une page de 16 octets en hexa sur le port
;                série, depuis la RAM externe ; le DPTR contient 
;                l'adresse de début des données en RAM externe ;
;                à la fin, sa valeur a donc augmenté de 16.

; "Page_RS232" : sends a 16 bytes page in hexa on the port
;                serial, from external RAM; the DPTR contains 
;                the start address of the data in external RAM ;
;                at the end, its value is therefore augmentEde 16.  
Page_RS232:      PUSH       ACC                ; 
                 PUSH       0                  ; 
                 MOV        R0,#16             ; 
nextbyteofpage:  MOVX       A,@DPTR            ; 
                 call       HEX_RS232          ; 
                 call       SPACE_RS232        ; 
                 INC        DPTR               ; 
                 DJNZ       R0,nextbyteofpage  ; 
                 POP        0                  ; 
                 POP        ACC                ; 
                 RET                           ; 

;; Routine d'interruption : ;;

; byte : PtrRXin PtrRXout RXnbo PtrTXin PtrTXout TXnbo  RS232status
; bool : BufRXplein BufRXvide BufTXplein BufTXvide RD_err WR_err TFR_run

Int_RX_TX:       PUSH       PSW            ; 
                 PUSH       ACC            ; 
                 PUSH       DPH            ; 
                 PUSH       DPL            ; 
                 call       wdt_reset  ; 
rx_byte:         JNB        RI,tx_byte     ; 
                 MOV        A,RXnbo        ; 
                 INC        A              ; 
                 JNZ        rx_ok          ; 
                 JMP        fin_rx         ; 
rx_ok:           MOV        RXnbo,A        ; 
                 MOV        DPH,#08h       ; Buffer RX : $0800 à $08FF
                 MOV        DPL,PtrRXin    ; 
                 MOV        A,S0BUF        ; 
                 ANL        A,#01111111b   ; 
                 MOVX       @DPTR,A        ; 
                 INC        PtrRXin        ; 
fin_rx:          CLR        RI             ; 
tx_byte:         JNB        TI,fin_rx_tx   ; 
                 MOV        A,TXnbo        ; 
                 JNZ        tx_ok          ; 
                 CLR        TFR_run        ; 
                 JMP        fin_tx         ; 
tx_ok:           MOV        DPH,#09h       ; Buffer TX : $0900 à $09FF
                 MOV        DPL,PtrTXout   ; 
                 MOVX       A,@DPTR        ; 
                 CLR        ACC.7          ; 
                 MOV        C,P            ; 
                 MOV        ACC.7,C        ; 
                 MOV        S0BUF,A        ; 
                 INC        PtrTXout       ; 
                 DEC        TXnbo          ; 
                 SETB       TFR_run        ; 
fin_tx:          CLR        TI             ; 
fin_rx_tx:       POP        DPL            ; 
                 POP        DPH            ; 
                 POP        ACC            ; 
                 POP        PSW            ; 
                 RETI                      ; Fin de routine d'interruption.

;***********************************************************************;

; "AnalyseChar" : Analyse le caractère ASCII contenu dans A : 
; - s'il vaut $0D (= ENTER), active "CH_enter",
; - s'il est compris entre 'a' et 'z' inclus, active "CH_min",
; - s'il est compris entre 'A' et 'Z' inclus, active "CH_maj",
; - s'il est compris entre '0' et '9' inclus, active "CH_dec" et place la 
;   valeur décimale correspondante (de 0 à 9) dans la variable "RS_HexDec".
; - s'il est compris entre '0' et '9' inclus, ou entre 'A' et 'F' inclus,
;   ou entre 'a' et 'f' inclus, active "CH_hex" et place la valeur hexa
;   correspondante (de 0 à 15) dans la variable "RS_HexDec".
; De plus, la routine place le caractère dans la variable "RS_ASCmaj" en
; le convertissant en majuscule (s'il est en minuscule).

; "CharAnalysis": Analyzes the ASCII character contained in A : 
; - if it is $0D (= ENTER), activate "CH_enter",
; - if it is between 'a' and 'z' inclusive, activate "CH_min",
; - if it is between 'A' and 'Z' inclusive, activate "CH_maj",
; - if it is between '0' and '9' inclusive, activate "CH_dec" and place the 
;   corresponding decimal value (from 0 to 9) in the variable "RS_HexDec".
; - if it is between '0' and '9' inclusive, or between 'A' and 'F' inclusive,
;   or between 'a' and 'f' included, activate "CH_hex" and set the value hexa
;   corresponding (from 0 to 15) in the variable "RS_HexDec".
; Moreover, the routine puts the character in the variable "RS_ASCmaj" in
; converting it to uppercase (if it is lowercase).



AnalyseChar:     PUSH       ACC             ; 
                 MOV        RS_ASCmaj,A     ; 
                 MOV        RS_HexDec,#-1   ; 
                 CLR        CH_min          ; 
                 CLR        CH_maj          ; 
                 CLR        CH_dec          ; 
                 CLR        CH_hex          ; 
                 CLR        CH_enter        ; 
                 JB         ACC.7,fin_ana   ; 
tst_enter:                                  ; 
                 CJNE       A,#00Dh,tst_min ; 
                 SETB       CH_enter        ; 
                 JMP        fin_ana         ; 
tst_min:                                    ; 
                 CLR        C               ; 
                 SUBB       A,#'a'          ; 
                 JB         ACC.7,tst_maj   ; 
                 CLR        C               ; 
                 SUBB       A,#26           ; 
                 JNB        ACC.7,tst_maj   ; 
                 SETB       CH_min          ; 
                 ANL        RS_ASCmaj,#0DFh ; 
tst_maj:                                    ; 
                 POP        ACC             ; 
                 PUSH       ACC             ; 
                 CLR        C               ; 
                 SUBB       A,#'A'          ; 
                 JB         ACC.7,tst_dec   ; 
                 CLR        C               ; 
                 SUBB       A,#26           ; 
                 JNB        ACC.7,tst_dec   ; 
                 SETB       CH_maj          ; 
tst_dec:                                    ; 
                 POP        ACC             ; 
                 PUSH       ACC             ; 
                 CLR        C               ; 
                 SUBB       A,#'0'          ; 
                 JB         ACC.7,tst_hex   ; 
                 CLR        C               ; 
                 SUBB       A,#10           ; 
                 JNB        ACC.7,tst_hex   ; 
                 SETB       CH_dec          ; 
                 SETB       CH_hex          ; 
                 ADD        A,#10           ; 
                 MOV        RS_HexDec,A     ; 
tst_hex:                                    ; 
                 MOV        A,RS_ASCmaj     ; 
                 CLR        C               ; 
                 SUBB       A,#'A'          ; 
                 JB         ACC.7,fin_ana   ; 
                 CLR        C               ; 
                 SUBB       A,#6            ; 
                 JNB        ACC.7,fin_ana   ; 
                 ADD        A,#16           ; 
                 MOV        RS_HexDec,A     ; 
                 SETB       CH_hex          ; 
fin_ana:         POP        ACC             ; 
                 RET                        ; 

;******************************************************************************
; "TERMINAL" : prise de control par la liaison série. Ce n'est pas un
; sous-programme, on n'y accède pas par un CALL, mais par un JMP effectué
; depuis la boucle du programme principal ; on en sort par un JMP qui 
; pointe vers la boucle principale "MainLoop" lorsque l'utilisateur 
; appui sur la touche [*] (= étoile) du clavier du terminal de control.

; "TERMINAL": control via the serial link. This is not a subroutine, 
; it is not accessed by a CALL, but by a JMP performed
; from the loop of the main program; we exit through a JMP that 
; points to the main loop "MainLoop" when the user 
; Press the [*] (= star) key on the keyboard of the control terminal.

TERMINAL:  
                 MOV        A,RXnbo          ; Pas de données dans le buffer ?
                 JNZ        terminal_cont    ; -> rendre la main...
		 JMP	    terminal_end
terminal_cont:
                 call       Read_RS232       ; Donnée présente : la lire.
                 call       AnalyseChar        ;   touche et son arrivée par
                 MOV        A,RS_ASCmaj        ;   la liaison série.
                                               ; - La convertir en majuscule.
                                               
                                               ; 
tch_diese:       CJNE       A,#'#',tch_0       ; - Touche [#] ?
                 MOV        A,#'!'             ;   Renvoyer un point 
                 call       Write_RS232        ;   d'exclamation "!".
                 JMP        tch_suiv           ;   Return an exclamation mark "!"

tch_0:           CJNE       A,#'0',tch_1       ; - Touche [0] ?
                 jmp	    0		       	   ;   Reset
                                               ; 
tch_1:           CJNE       A,#'1',tch_2       ; - Touche [1] ?
                 MOV        DPTR,#Message03    ;   afficher l'état du port P1.
                 call       MESS_RS232         ; 
                 MOV        A,P1               ; 
                 call       HEX_RS232          ; 
                 JMP        tch_suiv           ; 
                                               ; 
tch_2:           CJNE       A,#'2',tch_3       ; - Touche [2] ?
                 MOV        DPTR,#Message04    ;   afficher l'état du port P2.
                 call       MESS_RS232         ; 
                 MOV        A,P2               ; 
                 call       HEX_RS232          ; 
                 JMP        tch_suiv           ; 
                                               ; 
tch_3:           CJNE       A,#'3',tch_4       ; - Touche [3] ?
                 MOV        DPTR,#Message05    ;   afficher l'état du port P3.
                 call       MESS_RS232         ; 
                 MOV        A,P3               ; 
                 call       HEX_RS232          ; 
                 JMP        tch_suiv           ; 
                                               ; 
tch_4:           CJNE       A,#'4',tch_5       ; - Touche [4] ?
                 MOV        DPTR,#Message06    ;   afficher l'état du port P4.
                 call       MESS_RS232         ; 
                 MOV        A,P4               ; 
                 call       HEX_RS232          ; 
                 JMP        tch_suiv           ; 
                                               ; 
tch_5:           CJNE       A,#'5',tch_C       ; - Touche [5] ?
                 MOV        DPTR,#Message07    ;   afficher l'état du port P5.
                 call       MESS_RS232         ; 
                 MOV        A,P5               ; 
                 call       HEX_RS232          ; 
                 JMP        tch_suiv           ; 
                                               ; 
tch_C:           CJNE       A,#'C',tch_D       ; - Touche [C] ?
				 CALL	    list_chan
                 JMP        tch_suiv           ;
tch_D:           CJNE       A,#'D',tch_E       ; - Touche [D] ?
                 MOV        DPTR,#Message39    ; 
                 call       MESS_RS232         ; 
                 call       XXinRS232          ; 
                 JNB        XXDD_OK, tch_d_end ; 
				 mov	    mode, a
				 call	    load_state
				 call	    update_lcd		 
tch_d_end:
				 JMP        tch_suiv           ; 		 
tch_E:           CJNE       A,#'E',tch_F       ; - Touche [E] ?
				 CALL	    send_state	       ;    Etat du systeme
                 JMP        tch_suiv           ;    System status
		 
tch_F:           CJNE       A,#'F',tch_H       ; - Touche [F] ?
                 MOV        DPTR,#Message18    ;   set squelch
                 call       MESS_RS232         ;   allowed values (numbers):
                 call       DDinRS232          ;   00..09, 10..15
                 JNB        XXDD_OK, tch_f_end ;   other dez values are accepted but
				 anl	    a, #0fh			   ;   will lead to wrong results
				 mov	    dph, #ram_area_config 
				 mov	    dpl, #ram_squelch  ;   A...F are not allowed/accepted
				 movx	    @dptr, a
				 call	    sql_update
tch_f_end:
                 JMP        tch_suiv           ;  
                                               ; 
tch_H:           CJNE       A,#'H',tch_I       ; - Touche [H] ?
                 MOV        DPTR,#MessageAide  ;   Afficher le message d'aide
                 call       MESS_RS232         ;   (liste des fonctions).
                 JMP        tch_suiv           ; 
                                               ; 
tch_I:           CJNE       A,#'I',tch_K       ; - Touche [I] ?
                 MOV        DPTR,#Message26    ;   Re-initialiser les canaux
                 call       MESS_RS232         ;   en RAM externe, après 
                 call       WaitRS232          ;   confirmation par 
                 call       AnalyseChar        ;   l'utilisateur.
                 MOV        A,RS_ASCmaj        ; 
                 CJNE       A,#'Y',stop_init   ; 
                 call       load_ram_default   ; 
				 call	    load_state
				 jmp	    0			; And reset
                 JMP        tch_suiv
stop_init:       MOV        DPTR,#Message28    ; 
mess_init:       call       MESS_RS232         ; 
                 JMP        tch_suiv           ; 

tch_K:           CJNE       A,#'K',tch_L       ; - Touche [K] ?
                 MOV        DPTR,#Message37    ; 
                 call       MESS_RS232         ; 
                 call       XXinRS232          ; 
                 JNB        XXDD_OK, tch_k_end ; 
				 mov	    lock, a
tch_k_end:
                 JMP        tch_suiv           ;  

tch_L:           CJNE       A,#'L',tch_M       ; - Touche [L] ?
                 MOV        DPTR,#Message08    ;   Afficher les deux octets   
                 call       MESS_RS232         ;   representant l'etat du
                 MOV        A,serial_latch_hi  ;   verrou.
                 call       HEX_RS232          ; 
                 MOV        A,serial_latch_lo  ; 
                 call       HEX_RS232          ; 
                 JMP        tch_suiv           ; 
                                               ; 
tch_M:           CJNE       A,#'M',tch_N       ; - Touche [M] ?
                 call       Modif_RAM          ;   Lire et modifier les octets   Read and modify bytes
                 JMP        tch_suiv           ;   de la RAM externe à partir    external RAM from
                                               ;   d'une adresse au choix.       an address of your choice
											   ;
tch_N:           CJNE       A,#'N',tch_O       ; - Touche [N] ?
                 MOV        DPTR,#Message19    ; 
                 call       MESS_RS232         ; 
                 call       DDinRS232          ; 
                 JNB        XXDD_OK, tch_n_end ; 
				 mov	    dph, #ram_area_config
				 mov	    dpl, #ram_chan
				 movx	    @dptr, a
				 call	    chan_update
tch_n_end:
                 JMP        tch_suiv           ;  
tch_O:           CJNE       A,#'O',tch_P       ; - Touche [O] ?
				 MOV        DPTR,#Message38    ;   Definir volume
                 call       MESS_RS232         ; 
                 call       DDinRS232          ; 
                 JNB        XXDD_OK, tch_o_end ; 
				 cpl	    a
				 swap	    a
				 call	    load_volume
tch_o_end:
				 JMP        tch_suiv           ;  
tch_P:           CJNE       A,#'P',tch_Q       ; - Touche [P] ?
				 call	    prog_chan	       ;   Programmation d'un canal
				 JMP        tch_suiv           ;  
tch_Q:           CJNE       A,#'Q',tch_R       ; - Touche [Q] ?
				 call	    set_max_chan	   ;   Definit le nombre de canaux
				 JMP        tch_suiv           ;
tch_R:           CJNE       A,#'R',tch_S       ; - Touche [R] ?
				 call	    set_frequencies	   ;   set frequencies
				 JMP        tch_suiv           ;  
tch_S:           CJNE       A,#'S',tch_T       ; - Touche [S] ?
                 call       READ_EEPROM        ;   Lire les 2048 octets 
                 MOV        A,I2C_err          ;   de l'EEPROM I2C et les 
                 call       HEX_RS232          ;   transférer dans la RAM
                 call       SPACE_RS232        ;   externe ($0000 à $07FF).
                 MOV        A,Page             ; 
                 call       HEX_RS232          ; 
                 call       CRLF_RS232         ; 
		 call	    load_state
		 call	    update_lcd
                 JMP        tch_suiv           ; 
tch_T:           CJNE       A,#'T',tch_U       ; - Touche [T] ?
				 call	    set_chan_state     ;   Ecrire le chanstate
				 jmp	    tch_suiv		   ;   Write the channel state
                                               ; 
tch_U:           CJNE       A,#'U',tch_V       ; - Touche [U] ?
                 call       Show_RAM_int       ;   Afficher la RAM interne du
                 JMP        tch_suiv           ;   MPU : 256 octets, en hexa.
                                               ; 

tch_V:           CJNE       A,#'V',tch_X       ; - Touche [V] ?
                 MOV        DPTR,#MessageVersion  ;   Afficher la version
                 call       MESS_RS232         ; 
                 JMP        tch_suiv           ; 
                                               ; 
tch_X:           CJNE       A,#'X',tch_Y       ; - Touche [X] ?
                 call       PROG_EEPROM        ;   Programmer les 2048 octets
                 MOV        A,I2C_err          ;   de $0000 à $07FF de la RAM
                 call       HEX_RS232          ;   externe, dans l'EEPROM I2C.
                 call       SPACE_RS232        ; 
                 MOV        A,Page             ; 
                 call       HEX_RS232          ; 
                 call       CRLF_RS232         ; 
                 JMP        tch_suiv           ; 
                                               ; 
tch_Y:           CJNE       A,#'Y',tch_Z       ; - Touche [Y] ?
                 call       Show_EEPROM        ;   Afficher les 2 ko de la
                 JMP        tch_suiv           ;   mémoire I2C "AT24C16".
                                               ; 
tch_Z:           CJNE       A,#'Z',tch_autre   ; - Touche [Z] ? Afficher les
                 call       Show_RAMext        ;   2 premiers ko de la RAM
                 JMP        tch_suiv           ;   externe, de $0000 à $07FF.
                                               ; 
tch_autre:       call       Write_RS232        ; - Autre touche : 
                 MOV        DPTR,#Message09    ;   afficher la touche et un 
                 call       MESS_RS232         ;   point d'interrogation.
                 ;JMP       tch_suiv           ; 
tch_suiv:        MOV        DPTR,#Message10    ; - Passer à la ligne et  
                 call       MESS_RS232         ;   afficher le prompt ">".
terminal_end:		 
		 ret
                 JMP        TERMINAL           ; 

;***********************************************************************;

; "Show_RAMext" : afficher en hexa les deux premiers kilo-octets de
;                 données contenues dans la RAM externe (adresses
;                 $0000 à $07FF).

Show_RAMext:     PUSH       ACC                ; 
                 PUSH       DPH                ; 
                 PUSH       DPL                ; 
                 MOV        DPTR,#Message16    ; 
                 call       MESS_RS232         ; 
                 MOV        DPTR,#0000h        ; 
                 MOV        Page,#0            ; 
ram_page:        call       CRLF_RS232         ; 
                 MOV        A,#'$'             ; 
                 call       Write_RS232        ; 
                 MOV        A,#'0'             ; 
                 call       Write_RS232        ; 
                 MOV        A,Page             ; 
                 ;call       HEX2LCD            ; 
                 call       HEX_RS232          ; 
                 MOV        A,#'0'             ; 
                 call       Write_RS232        ; 
                 call       SPACE_RS232        ; 
                 MOV        A,#':'             ; 
                 call       Write_RS232        ; 
                 call       SPACE_RS232        ; 
                 CALL       Page_RS232         ; 
                 INC        Page               ; 
                 MOV        A,Page             ; 
                 CJNE       A,#128,ram_page    ; 
                 call       CRLF_RS232         ; 
                 POP        DPL                ; 
                 POP        DPH                ; 
                 POP        ACC                ; 
                 RET                           ; 

; "Show_EEPROM" : afficher en hexa sur la liaison série le contenu
;                 de la mémoire I2C AT24C16 (2 ko).
;                 Chaque page de 16 octets est lue puis affichée,
;                 les données transitent par une zone de 16 octets
;                 située en RAM externe (de $0A00 à $0A0F).

Show_EEPROM:     PUSH       ACC                ; 
                 PUSH       DPH                ; 
                 PUSH       DPL                ; 
                 MOV        DPTR,#Message14    ; 
                 call       MESS_RS232         ; 
                 MOV        Page,#0            ; 
show_page:       MOV        DPTR,#Message12    ; 
                 call       MESS_RS232         ; 
                 MOV        A,Page             ; 
                 ;call       HEX2LCD            ; 
                 call       HEX_RS232          ; 
                 MOV        DPTR,#Message13    ; 
                 call       MESS_RS232         ; 
                 MOV        DPTR,#0A00h        ; 
                 call       I2C_RD_Page        ; 
                 MOV        A,I2C_err          ; 
                 JNZ        err_show_eeprom    ; 
                 MOV        DPTR,#0A00h        ; 
                 CALL       Page_RS232         ; 
                 INC        Page               ; 
                 MOV        A,Page             ; 
                 CJNE       A,#128,show_page   ; 
                 JMP        end_show_eeprom    ; 
err_show_eeprom: MOV        DPTR,#Message30    ; 
                 call       MESS_RS232         ; 
                 MOV        A,I2C_err          ; 
                 ADD        A,#'0'             ; 
                 call       Write_RS232        ; 
end_show_eeprom: call       CRLF_RS232         ; 
                 POP        DPL                ; 
                 POP        DPH                ; 
                 POP        ACC                ; 
                 RET                           ; 


; "Show_RAM_int" : Afficher la RAM interne en hexa sur le port série
;                  (16 lignes de 16 octets).

Show_RAM_int:    PUSH       ACC                ; 
                 PUSH       0                  ; 
                 PUSH       DPH                ; 
                 PUSH       DPL                ; 
                 MOV        DPTR,#Message29    ; 
                 call       MESS_RS232         ; 
                 POP        DPL                ; 
                 POP        DPH                ; 
                 MOV        R0,#0              ; 
                 MOV        A,R0               ; 
aff_byte_ram:    ANL        A,#00001111b       ; 
                 JNZ        aff_valri          ; 
                 call       CRLF_RS232         ; 
                 MOV        A,#'$'             ; 
                 call       Write_RS232        ; 
                 MOV        A,R0               ; 
                 call       HEX_RS232          ; 
                 call       SPACE_RS232        ; 
                 MOV        A,#':'             ; 
                 call       Write_RS232        ; 
aff_valri:       call       SPACE_RS232        ; 
                 MOV        A,@R0              ; 
                 call       HEX_RS232          ; 
                 INC        R0                 ; 
                 MOV        A,R0               ; 
                 JNZ        aff_byte_ram       ; 
                 call       CRLF_RS232         ; 
                 POP        0                  ; 
                 POP        ACC                ; 
                 RET                           ; 


; "Modif_RAM" : routine appelée par la commande M ; elle demande sur
;               quatre digits hexa l'adresse à modifier dans la RAM,
;               lit et affiche la valeur corresondante, puis demande
;               deux digits hexa correspondant à la nouvelle valeur,
;               et la charge en RAM ; la routine peut être interrompue
;               en cours par l'appui sur une touche non hexadécimale.

Modif_RAM:       PUSH       ACC                ; 
                 PUSH       DPH                ; 
                 PUSH       DPL                ; 
                 MOV        DPTR,#Message17    ; 
                 call       MESS_RS232         ; 
                 call       XXinRS232          ; 
                 JNB        XXDD_OK,fin_mod    ; 
                 MOV        AdrH,A             ; 
                 call       XXinRS232          ; 
                 JNB        XXDD_OK,fin_mod    ; 
                 MOV        AdrL,A             ; 
                 MOV        DPH,AdrH           ; 
                 MOV        DPL,AdrL           ; 
mod_byte:        call       CRLF_RS232         ; 
                 MOV        A,#'$'             ; 
                 call       Write_RS232        ; 
                 MOV        A,DPH              ; 
                 call       HEX_RS232          ; 
                 MOV        A,DPL              ; 
                 call       HEX_RS232          ; 
                 call       SPACE_RS232        ; 
                 MOVX       A,@DPTR            ; 
                 call       HEX_RS232          ; 
                 call       SPACE_RS232        ; 
                 call       XXinRS232          ; 
                 JB         CH_enter,incr_adr  ; 
                 JNB        XXDD_OK,fin_mod    ; 
                 MOVX       @DPTR,A            ; 
incr_adr:        INC        DPTR               ; 
                 JMP        mod_byte           ; 
fin_mod:         call       CRLF_RS232         ; 
		 call	    load_state
		 call	    update_lcd
                 POP        DPL                ; 
                 POP        DPH                ; 
                 POP        ACC                ; 
                 RET                           ; 

; Liste les cannaux et leur configuration
; List the channels and their configuration

list_chan:
	PUSH    ACC
    PUSH    DPH
    PUSH    DPL
		 
	MOV     DPTR,#Message31 
    call    MESS_RS232
	mov		dph, #ram_area_config
	mov		dpl, #ram_max_chan
	movx	a, @dptr
	mov		r1, a
	inc		r1					; Nombre total de cannaux + 1
	mov		r0, #0				; Boucle de comptage initialisee a 0
lc_loop:
	; Envoi du numero du canal
	; Send channel number
	mov		a, r0
	call	DEC_RS232
    mov		a,#';'
    call	Write_RS232
;	call	SPACE_RS232
		
	; Envoi de la valeur de la pll
	; Send pll value (nominal frequency)
	mov	a, r0
	mov	dph, #ram_area_freq
	rl	a
	mov	dpl, a
	movx	a, @dptr
	call	HEX_RS232
	inc	dpl
	movx	a, @dptr
	call	HEX_RS232
    mov		a,#';'
    call	Write_RS232
;	call	SPACE_RS232	
	
	; Envoi de la valeur de la shift
	; Send shift value
	mov	a, r0
	mov	dph, #ram_area_shift
	rl	a
	mov	dpl, a
	movx	a, @dptr
	call	HEX_RS232
	inc	dpl
	movx	a, @dptr
	call	HEX_RS232
    mov		a,#';'
    call	Write_RS232
;	call	SPACE_RS232	

	; Envoi du chan state
	; Send channel State
	mov	dph, #ram_area_state
	mov	dpl, r0
	movx	a, @dptr
	call	HEX_RS232
	call	CRLF_RS232
	inc	r0
	clr	c		; Comparaison du compteur de boucle et 
	mov	a, r1		; de la valeur final, bouclage si non
	subb	a, r0		; fini
	jnz	lc_loop
		 
	POP     DPL
        POP     DPH
        POP     ACC
        RET
	
; Programme un canal
prog_chan:
	PUSH    ACC
    PUSH    DPH
    PUSH    DPL
	
	MOV     DPTR,#Message32
    CALL	MESS_RS232
	CALL	DDinRS232
    JB	XXDD_OK, pc_cont
	jmp	fin_progchan
pc_cont:
	mov		r0, a					; Copie le canal a modifier dans R0
	call	CRLF_RS232
	MOV     DPTR,#Message33			;PLL
	CALL	MESS_RS232				;===
	CALL	XXinRS232
	JNB     XXDD_OK,fin_progchan1
	MOV     r1,A					; PLL MSB dans R1
	CALL    XXinRS232
	JNB     XXDD_OK,fin_progchan1
	MOV     r2,A					; PLL LSB dans R2
	call	CRLF_RS232

	MOV     DPTR,#Message34			;SHIFT
	CALL	MESS_RS232				;=====
	CALL	XXinRS232
	JB    	XXDD_OK,shift_progchan
fin_progchan1:						;(distance for JB/JNB too far)
	LJMP	fin_progchan

shift_progchan:
	MOV     r6,A					; SHIFT MSB dans R6
	CALL    XXinRS232
	JNB     XXDD_OK,fin_progchan
	MOV     r7,A					; SHIFT LSB dans R7
	call	CRLF_RS232

	MOV     DPTR,#Message20			;STATE
	CALL	MESS_RS232				;=====
	CALL	XXinRS232
	JNB     XXDD_OK,fin_progchan
	mov		r3, a					; Etat(State) du canal dans R3
	call	CRLF_RS232
	
	; Test si le canal existe ou pas
	mov		dph, #ram_area_config	; Load max chan value dans r4
	mov		dpl, #ram_max_chan
	movx	a, @dptr
	mov		r4, a
	clr		c
	subb	a, r0
	jnb		cy, pc_write
	; Si le canal n'existe pas alors demander une confirmation avant la creation
	MOV     DPTR,#Message35
    CALL	MESS_RS232
	CALL    WaitRS232
    CALL    AnalyseChar
    MOV     A,RS_ASCmaj
	call	CRLF_RS232
    CJNE    A,#'Y',fin_progchan 
	
	; Creation d'un canal
	inc		r4
	mov		a, r4
	mov		r0, a
	mov		dph, #ram_area_config
	mov		dpl, #ram_max_chan
	movx	@dptr, a
	
	
	; Ecriture de la nouvelle valeur pour la pll
	; Write the new value for the pll 
pc_write:
	mov		a, r0
	mov		dph, #ram_area_freq
	rl		a
	mov		dpl, a
	mov		a, r1
	movx	@dptr, a
	inc		dpl
	mov		a, r2
	movx	@dptr, a
	
	mov		a, r0
	mov		dph, #ram_area_shift
	rl		a
	mov		dpl, a
	mov		a, r6
	movx	@dptr, a
	inc		dpl
	mov		a, r7
	movx	@dptr, a

	mov		dph, #ram_area_state
	mov		dpl, r0
	mov		a, r3
	movx	@dptr, a
	
	; Calcul des checksums
	call	load_freq_area_checksum
	mov		dph, #ram_area_config
	mov		dpl, #ram_freq_sum
	movx	@dptr, a
	call	load_state_area_checksum
	mov		dph, #ram_area_config
	mov		dpl, #ram_state_sum
	movx	@dptr, a
	call	load_config_area_checksum
	mov		dph, #ram_area_config
	mov		dpl, #ram_config_sum
	movx	@dptr, a

fin_progchan:
	CALL	CRLF_RS232
	POP     DPL
    POP     DPH
    POP     ACC
    RET
	
set_max_chan:
	PUSH    ACC
    PUSH    DPH
    PUSH    DPL	
	MOV     DPTR,#Message36
    CALL	MESS_RS232
	CALL	DDinRS232
    JNB		XXDD_OK,fin_set_max_chan

	mov		dph, #ram_area_config
	mov		dpl, #ram_max_chan
	movx	@dptr, a
	mov		a, #0
	mov		dpl, #ram_chan
	movx	@dptr, a
	; Rafraichir lcd
	mov		r0, a
	call	lcd_clear_digits_r
	call	lcd_print_dec
	setb	mode.7
	; Calcul de la checksum
	call	load_config_area_checksum
	mov		dph, #ram_area_config
	mov		dpl, #ram_config_sum
	movx	@dptr, a
	
fin_set_max_chan:
	call	CRLF_RS232		
	POP     DPL
    POP     DPH
    POP     ACC
    RET
	
; Envoi l'etat du poste
; Sending the current status
; Mode - Chan - chan_state - Squelch - Volume - Lock - Freq RX - Freq TX
send_state:
	push	ACC
	push	DPH
	push	DPL
	mov	a, mode
	call	HEX_RS232
	mov	dph, #ram_area_config
	mov	dpl, #ram_chan
	movx	a, @dptr
	call	HEX_RS232
	mov	a, chan_state
	call	HEX_RS232
	mov	dpl, #ram_squelch
	movx	a, @dptr
	call	HEX_RS232
	mov	a, vol_hold
	call	HEX_RS232
	mov	a, lock
	call	HEX_RS232
	mov	a, rx_freq_hi
	call	HEX_RS232
	mov	a, rx_freq_lo
	call	HEX_RS232
	mov	a, tx_freq_hi
	call	HEX_RS232
	mov	a, tx_freq_lo
	call	HEX_RS232
	pop	DPL
	pop	DPH
	pop	ACC
	RET

set_chan_state:	
            MOV         DPTR,#Message20 
            call        MESS_RS232
            call        DDinRS232
            JNB         XXDD_OK, scs_end
	    mov		chan_state, a
		 
	    mov		dph, #ram_area_config
	    mov		dpl, #ram_chan
	    movx	a, @dptr
	    mov		r1, a
	
	    mov		dph, #ram_area_state
	    mov		dpl, r1
	    mov		a, chan_state
	    movx	@dptr, a

	    setb	mode.7					; Force LCD refresh
	    call	get_freq
	    mov		r0, rx_freq_lo
	    mov		r1, rx_freq_hi
	    call	load_synth

	    ; Calcul de la checksum
	    call	load_state_area_checksum
	    mov		dph, #ram_area_config
	    mov		dpl, #ram_state_sum
	    movx	@dptr, a
scs_end:
	    ret

set_frequencies:
	MOV	DPTR,#Message21    	; RX freq
        call    MESS_RS232
        call    XXinRS232
        jnb     XXDD_OK, sf_end
	mov	r0, a	       		; RX hi
        call    XXinRS232
        jnb     XXDD_OK, sf_end
	mov	r1, a	       		; RX lo
	call	CRLF_RS232
	MOV     DPTR,#Message22		; TX freq
        call    MESS_RS232
        call    XXinRS232
        jnb     XXDD_OK, sf_end
	mov	r2, a		       	; TX hi
        call    XXinRS232
        jnb     XXDD_OK, sf_end
	mov	r3, a		       	; TX lo

	; Copie des variables
	mov		rx_freq_hi, r0
	mov		rx_freq_lo, r1
	mov		tx_freq_hi, r2
	mov		tx_freq_lo, r3

	jb		mode.3, sf_tx 
	; Si mode RX / if RX mode
	mov	r0, rx_freq_lo
	mov	r1, rx_freq_hi	    
	call	load_synth
	jmp		sf_end
sf_tx:	; Si mode TX/ if TX mode
	mov	r0, tx_freq_lo
	mov	r1, tx_freq_hi	    
	call	load_synth
sf_end:
	call	lcd_clear_digits_r
	clr		mode.0
	mov		chan_state, #0
	call	display_update_symb
	setb	mode.7	
	ret
	    
; Messages ASCII predefinis, pour le dialogue par la liaison serie :

Message01:    DB   00Dh,00Ah
IF TARGET EQ 8060
              DB   "PRM8060"
ELSEIF TARGET EQ 8070
              DB   "PRM8070"
ENDIF

IF FREQ EQ 144
			  DB   " 144"
ELSEIF FREQ EQ 430
			  DB   " 430"
ENDIF
			  DB   " Firmware (c) F4FEZ / F8EGQ / DC0CM",00Dh,00Ah
              DB   "Version 5 Beta, 18/01/2021.",00Dh,00Ah
			  DB   ">",0
Message03:    DB   "P1 = $",0 
Message04:    DB   "P2 = $",0 
Message05:    DB   "P3 = $",0 
Message06:    DB   "P4 = $",0 
Message07:    DB   "P5 = $",0 
Message08:    DB   "Latch = $",0 
Message09:    DB   " ?",0 
Message10:    DB   00Dh,00Ah,">",0 
Message11:    DB   00Dh,00Ah
              DB   "Type 'H' for help",00Dh,00Ah,00Dh,00Ah,">",0 
Message12:    DB   00Dh,00Ah,"Page $",0 
Message13:    DB   "/$7F : ",0 
Message14:    DB   "24C16 EEPROM data : ",00Dh,00Ah,0 
Message15:    DB   " OK !",0 
Message16:    DB   "First 2Kb data from external RAM : "
              DB   00Dh,00Ah,0 
Message17:    DB   "External RAM adress $XXXX : $",0 
Message18:    DB   "Squelch : ",0
Message19:    DB   "Channel : ",0
Message20:    DB   "Channel state : $",0
Message21:    DB   "RX frequency : ",0
Message22:    DB   "TX frequency : ",0
Message26:    DB   "Erase RAM and channels (Y/N) ? ",0 
Message28:    DB   "N",00Dh,00Ah,"command canceled...",00Dh,00Ah,0
Message29:    DB   "Display the 256 bytes from internal RAM : ",0
Message30:    DB   "error I2C number ",0
Message31:    DB   "Channel;Frequency;Shift;State",0Dh,0Ah,0
Message32:    DB   "Channel to set : ",0
Message33:    DB   "PLL value to load : $",0
Message34:	  DB   "Shift value : $",0
Message35:    DB   "This channel number doesn't exist. Add new channel (Y/N) ? ", 0
Message36:    DB   "Channels number (00 to 99) : ",0
Message37:    DB   "Lock : ",0
Message38:    DB   "Volume : ",0
Message39:    DB   "Mode : ",0

MessageVersion: 
IF TARGET EQ 8060
              DB   "PRM8060 V4.0"
ELSEIF TARGET EQ 8070
              DB   "PRM8070 V5 Beta 0"
ENDIF

IF FREQ EQ 144
	      DB   " 144", 0
ELSEIF FREQ EQ 430
	      DB   " 430", 0
ENDIF

MessageAide:  DB   "H",0Dh,0Ah
              DB   " Commandes disponibles :",0Dh,0Ah
              DB   " [0] = Reset.",0Dh,0Ah
              DB   " [1] a [5] = Show 80c552 port state P1 to P5.",0Dh,0Ah
              DB   " [C] = Print channels list.",0Dh,0Ah
              DB   " [D] = Set system byte.",0Dh,0Ah
              DB   " [E] = Show system state (Mode-Chan-Chanstate-Sql-Vol-Lock-RX freq-TX freq).",0Dh,0Ah
              DB   " [F] = Set squelch.",0Dh,0Ah
              DB   " [H] = Print this help page.",0Dh,0Ah
              DB   " [I] = Erase and init RAM and EEPROM.",0Dh,0Ah
              DB   " [K] = Set lock byte.",0Dh,0Ah
              DB   " [L] = Print latch state.",0Dh,0Ah
              DB   " [M] = Edit external RAM manualy.",0Dh,0Ah
              DB   " [N] = Set current channel.",0Dh,0Ah
              DB   " [O] = Set volume.",0Dh,0Ah
			  DB   " [P] = Edit/Add channel.",0Dh,0Ah
			  DB   " [Q] = Set channels number.",0Dh,0Ah
			  DB   " [R] = Set synthetiser frequencies.",0Dh,0Ah
              DB   " [U] = Print 80c552 internal RAM.",0Dh,0Ah
              DB   " [S] = Copy EEPROM to external RAM.",0Dh,0Ah
              DB   " [T] = Set current channel state.",0Dh,0Ah
              DB   " [V] = Print firmware version.",0Dh,0Ah
              DB   " [X] = Copy external RAM to EEPROM.",0Dh,0Ah
              DB   " [Y] = Print first 2 kb from the EEPROM I2C 24c16.",0Dh,0Ah
              DB   " [Z] = Print external RAM ($0000 to $07FF).",0Dh,0Ah,0
	      
