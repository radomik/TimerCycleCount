;; W sprawozdaniu: obliczenia teoretyczne i wyniki symulacji
;;
;; Szczegoly obliczen oraz program wyznaczajacy optymalne parametry:
;; https://github.com/radomik/TimerCycleCount

#include	<p16f877A.inc>	; definicje specyficzne dla mikrokontrolera
	
	__CONFIG _XT_OSC & _WDT_OFF & _PWRTE_ON & _BODEN_OFF & _LVP_OFF

RST	CODE	0x000		; wektor resetu procesora

	pagesel	main		; wyb�r strony pamieci programu
  	goto	main		; skok do poczatku programu

PGM	CODE

;; Zmienne
TMRCNT	equ		0x20

main:
	call 	main_init
	clrf	INTCON
	;call	test_delay_256
	call	delay_50us
	call	delay_51ms
	call	delay_561ms
	call	delay_2200ms
	goto	$

main_init:
	; Inicjalizacja niezbednych komponent�w
	bcf		STATUS, RP0	; wyb�r banku 0
	bcf		STATUS, RP1
	clrf	PORTA		; inic. PORTA przez zerowanie zatrzask�w wyjsciowych
	bsf		STATUS, RP0	; bank 1
	movlw	B'00000110'	; przelaczenie wejsc na cyfrowe
	movwf	ADCON1		; poprzez odlaczenie przetwornika A/C
	clrf	TRISA		; ustawienie wyprowadzen PORTA na wyjscia
	clrf	TRISB		; ustawienie wyprowadzen PORTB na wyjscia
	bcf		STATUS, RP0	; bank 0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/2
test_delay_2:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMRCNT
	call	init_presc_2; 10 cykli - inicjalizacja preskalera
loop_test_2:
	movf	TMRCNT, 0	; W = kolejna wartosc TMR0 do testow
	
	call	delay_tmr0	
	decfsz	TMRCNT, 1
	goto	loop_test_2

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/4
test_delay_4:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMRCNT
	call	init_presc_4; 10 cykli - inicjalizacja preskalera
loop_test_4:
	movf	TMRCNT, 0	; W = kolejna wartosc TMR0 do testow
	
	call	delay_tmr0
	decfsz	TMRCNT, 1
	goto	loop_test_4

	clrw			   ; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/8
test_delay_8:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMRCNT
	call	init_presc_8; 10 cykli - inicjalizacja preskalera
loop_test_8:
	movf	TMRCNT, 0	; W = kolejna wartosc TMR0 do testow
	
	call	delay_tmr0
	decfsz	TMRCNT, 1
	goto	loop_test_8

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/16
test_delay_16:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMRCNT
	call	init_presc_16; 10 cykli - inicjalizacja preskalera
loop_test_16:
	movf	TMRCNT, 0	; W = kolejna wartosc TMR0 do testow
	
	call	delay_tmr0
	decfsz	TMRCNT, 1
	goto	loop_test_16

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/32
test_delay_32:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMRCNT
	call	init_presc_32; 10 cykli - inicjalizacja preskalera
loop_test_32:
	movf	TMRCNT, 0
	
	call	delay_tmr0
	decfsz	TMRCNT, 1
	goto	loop_test_32

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/64
test_delay_64:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMRCNT
	call	init_presc_64; 10 cykli - inicjalizacja preskalera
loop_test_64:
	movf	TMRCNT, 0
	
	call	delay_tmr0
	decfsz	TMRCNT, 1
	goto	loop_test_64

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/128
test_delay_128:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMRCNT
	call	init_presc_128; 10 cykli - inicjalizacja preskalera
loop_test_128:
	movf	TMRCNT, 0
	
	call	delay_tmr0
	decfsz	TMRCNT, 1
	goto	loop_test_128

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/256
test_delay_256:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMRCNT	
	call	init_presc_256; 10 cykli - inicjalizacja preskalera
loop_test_256:
	movf	TMRCNT, 0
	
	call	delay_tmr0
	decfsz	TMRCNT, 1
	goto	loop_test_256

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; 50us @ 4MHz, TMR0=245, Presc=2
delay_50us:				; 2 cykle call delay_
	call	init_presc_2; 10 cykli
	movlw	d'245'		; 1 cykl
	call	delay_tmr0	; 33 cykli
	goto	$+1			; 2 cykle
	return				; 2 cykle

;; 51ms @ 4MHz TMR0
delay_51ms:				; 2 cykle call delay1_
	movlw	.50			; 1 cykl ( liczba wywolan delay_tmr0 )
	movwf	TMRCNT		; 1 cykl
	call	init_presc_4; 10 cykli
loop_51ms:
	movlw	.10			; 1 cykl ( wartosc TMR0 )
	call	delay_tmr0	; 
	decfsz	TMRCNT, f	; 1 / 2 cykle
	goto	loop_51ms	; 2 / 0 cykli

	movlw	.13			; 1 cykl
	call	delay_tmr0	;

	return				; 2 cykle

;; 561ms @ 4MHz TMR0
delay_561ms:			; 2 cykle call delay1_
	movlw	.35			; 1 cykl ( liczba wywolan delay_tmr0 )
	movwf	TMRCNT		; 1 cykl
	call	init_presc_64; 10 cykli
loop_561ms:
	movlw	.12			; 1 cykl ( wartosc TMR0 )
	call	delay_tmr0	; 
	decfsz	TMRCNT, f	; 1 / 2 cykle
	goto	loop_561ms	; 2 / 0 cykli
	
	movlw	.39
	call	delay_tmr0

	return				; 2 cykle

;; 2200ms @ 4MHz TMR0
delay_2200ms:			; 2 cykle call delay1_
	movlw	.45			; 1 cykl ( liczba wywolan delay_tmr0 )
	movwf	TMRCNT		; 1 cykl
	call	init_presc_256; 10 cykli
loop_2200ms:
	movlw	.69			; 1 cykl ( wartosc TMR0 )
	call	delay_tmr0	; 
	decfsz	TMRCNT, f	; 1 / 2 cykle
	goto	loop_2200ms	; 2 / 0 cykli

	movlw	.80			; dodatkowe opoznienie
	call	delay_tmr0	;
	goto	$+1
	nop
	return				; 2 cykle

;; Inicjalizacja preskalera TMR0 na 1/2 
;; Czas wykonania: 12 cykli
init_presc_2:
	bsf 	STATUS, RP0 ; wyb�r banku 1 w celu uzyskania dost�pu do OPTION_REG
	movf	OPTION_REG, 0
	andlw	b'10000000'	; wyczysc szystkie bity poza (7)
	iorlw	b'01000000'	; INTEDG=1, T0CS=0, T0SE=0, PSA=0, PS = 1/2
	movwf	OPTION_REG
	bcf		STATUS, RP0 ; wyb�r banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/4 
;; Czas wykonania: 12 cykli
init_presc_4:
	bsf 	STATUS, RP0 ; wyb�r banku 1 w celu uzyskania dost�pu do OPTION_REG
	movf	OPTION_REG, 0
	andlw	b'10000000'	; wyczysc szystkie bity poza (7)
	iorlw	b'01000001'	; INTEDG=1, T0CS=0, T0SE=0, PSA=0, PS = 1/4
	movwf	OPTION_REG
	bcf		STATUS, RP0 ; wyb�r banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/8 
;; Czas wykonania: 12 cykli
init_presc_8:
	bsf 	STATUS, RP0 ; wyb�r banku 1 w celu uzyskania dost�pu do OPTION_REG
	movf	OPTION_REG, 0
	andlw	b'10000000'	; wyczysc szystkie bity poza (7)
	iorlw	b'01000010'	; INTEDG=1, T0CS=0, T0SE=0, PSA=0, PS = 1/8
	movwf	OPTION_REG
	bcf		STATUS, RP0 ; wyb�r banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/16 
;; Czas wykonania: 12 cykli
init_presc_16:
	bsf 	STATUS, RP0 ; wyb�r banku 1 w celu uzyskania dost�pu do OPTION_REG
	movf	OPTION_REG, 0
	andlw	b'10000000'	; wyczysc wszystkie bity poza (7)
	iorlw	b'01000011'	; INTEDG=1, T0CS=0, T0SE=0, PSA=0, PS = 1/16
	movwf	OPTION_REG
	bcf		STATUS, RP0 ; wyb�r banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/32 
;; Czas wykonania: 12 cykli
init_presc_32:
	bsf 	STATUS, RP0 ; wyb�r banku 1 w celu uzyskania dost�pu do OPTION_REG
	movf	OPTION_REG, 0
	andlw	b'10000000'	; wyczysc szystkie bity poza (7)
	iorlw	b'01000100'	; INTEDG=1, T0CS=0, T0SE=0, PSA=0, PS = 1/32
	movwf	OPTION_REG
	bcf		STATUS, RP0 ; wyb�r banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/64
;; Czas wykonania: 12 cykli
init_presc_64:
	bsf 	STATUS, RP0 ; wyb�r banku 1 w celu uzyskania dost�pu do OPTION_REG
	movf	OPTION_REG, 0
	andlw	b'10000000'	; wyczysc szystkie bity poza (7)
	iorlw	b'01000101'	; INTEDG=1, T0CS=0, T0SE=0, PSA=0, PS = 1/64
	movwf	OPTION_REG
	bcf		STATUS, RP0 ; wyb�r banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/128
;; Czas wykonania: 12 cykli
init_presc_128:
	bsf 	STATUS, RP0 ; wyb�r banku 1 w celu uzyskania dost�pu do OPTION_REG
	movf	OPTION_REG, 0
	andlw	b'10000000'	; wyczysc szystkie bity poza (7)
	iorlw	b'01000110'	; INTEDG=1, T0CS=0, T0SE=0, PSA=0, PS = 1/128
	movwf	OPTION_REG
	bcf		STATUS, RP0 ; wyb�r banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/256
;; Czas wykonania: 12 cykli
init_presc_256:
	bsf 	STATUS, RP0 ; wyb�r banku 1 w celu uzyskania dost�pu do OPTION_REG
	movf	OPTION_REG, 0
	andlw	b'10000000'	; wyczysc szystkie bity poza (7)
	iorlw	b'01000111'	; INTEDG=1, T0CS=0, T0SE=0, PSA=0, PS = 1/256
	movwf	OPTION_REG
	bcf		STATUS, RP0 ; wyb�r banku 0
	return

;; Parametr:
;; W - warto�� jaka zostanie zapisana do rejestru TMR0
;; Przed wykonaniem funkcji nale�y zainicjalizowa� preskaler
;; jedna z procedur: init_presc_x
;; Odmierzany czas: 
;; 	T [cykle] = (256 - W)*(4/f_osc)*Presc + poprawka
;;  gdzie:
;;		W 	  - wartosc rejestru W na poczatku procedury {0...255}
;;		f_osc - czestotliwosc zegara [MHz] (4 MHz dla ZL4PIC)
;;		Presc - wartosc preskalera {2, 4, 8, 16, 32, 64, 128, 256}
;;		poprawka - dodatkowa liczba cykli okreslona ponizsza tabela
;; | Presc | poprawka [cykle]                         |
;; |  2    | 10 + ( (W % 3 == 0) ? 0 : (3 - W % 3) )  |
;; |  4    | 10 + ( (W + 1) % 3 )                     |
;; |  8    | 10 + ( (W % 3 == 0) ? 0 : (3 - W % 3) )  |
;; |  16   | 10 + ( (W % 3 == 2) ? 0 : (1 + W % 3) )  |
;; |  32   | 10 + ( (W % 3 == 0) ? 0 : (3 - W % 3) )  |
;; |  64   | 10 + ( (W % 3 == 2) ? 0 : (1 + W % 3) )  |
;; |  128  | 10 + ( (W % 3 == 0) ? 0 : (3 - W % 3) )  |
;; |  256  | 10 + ( (W % 3 == 2) ? 0 : (1 + W % 3) )  |
;;
;; Zakresy czasow odmierzanych przez procedure w zaleznosci od preskalera
;; 		* czas minimalny dla W = 255
;; 		* czas maksymalny dla W = 0
;; | Presc | T_min [cykle] | T_max [cykle]     |
;; |  2    | 12            | 522     ; W={0,1} |  
;; |  4    | 15            | 1035    ; W={0}   |
;; |  8    | 18            | 2058    ; W={0}   |
;; |  16   | 27            | 4107    ; W={0}   |
;; |  32   | 42            | 8202    ; W={0}   |
;; |  64   | 75            | 16395   ; W={0}   |
;; |  128  | 138           | 32778   ; W={0}   |
;; |  256  | 267           | 65547   ; W={0}   |
delay_tmr0:
	movwf	TMR0				; TMR0 = W (parametr procedury)
	nop
	btfss	INTCON, TMR0IF		; czekamy na przepe�nienie licznika
		goto	$-1				; czekaj dop�ki INTCON<TMR0IF> jest wyzerowany

	bcf		INTCON, TMR0IF		; wyczyszczenie flagi przepelnienia
	return

 end

