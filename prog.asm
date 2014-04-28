;; W sprawozdaniu: obliczenia teoretyczne i wyniki symulacji
;;
;; Szczegoly obliczen oraz program wyznaczajacy optymalne parametry:
;; https://github.com/radomik/TimerCycleCount

#include	<p16f877A.inc>	; definicje specyficzne dla mikrokontrolera
	
	__CONFIG _XT_OSC & _WDT_OFF & _PWRTE_ON & _BODEN_OFF & _LVP_OFF

RST	CODE	0x000		; wektor resetu procesora

	pagesel	main		; wybór strony pamieci programu
  	goto	main		; skok do poczatku programu

PGM	CODE

;; Zmienne
TMRCNT	equ		0x20
TMR0VAL	equ		0x21

;; bity rejestru OPTION_REG
TMR0CS	equ	5
TMR0SE	equ	4

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
	; Inicjalizacja niezbednych komponentów
	bcf		STATUS, RP0	; wybór banku 0
	bcf		STATUS, RP1
	clrf	PORTA		; inic. PORTA przez zerowanie zatrzasków wyjsciowych
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
	movwf	TMR0VAL
	call	init_presc_2; 12 cykli - inicjalizacja preskalera
loop_test_2:
	movf	TMR0VAL, 0	; W = kolejna wartosc TMR0 do testow
	
	call	delay_tmr0	
	decfsz	TMR0VAL, 1
	goto	loop_test_2

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/4
test_delay_4:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMR0VAL
	call	init_presc_4; 12 cykli - inicjalizacja preskalera
loop_test_4:
	movf	TMR0VAL, 0	; W = kolejna wartosc TMR0 do testow
	
	call	delay_tmr0
	decfsz	TMR0VAL, 1
	goto	loop_test_4

	clrw			   ; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/8
test_delay_8:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMR0VAL
	call	init_presc_8; 12 cykli - inicjalizacja preskalera
loop_test_8:
	movf	TMR0VAL, 0	; W = kolejna wartosc TMR0 do testow
	
	call	delay_tmr0
	decfsz	TMR0VAL, 1
	goto	loop_test_8

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/16
test_delay_16:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMR0VAL
	call	init_presc_16; 12 cykli - inicjalizacja preskalera
loop_test_16:
	movf	TMR0VAL, 0	; W = kolejna wartosc TMR0 do testow
	
	call	delay_tmr0
	decfsz	TMR0VAL, 1
	goto	loop_test_16

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/32
test_delay_32:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMR0VAL
	call	init_presc_32; 12 cykli - inicjalizacja preskalera
loop_test_32:
	movf	TMR0VAL, 0
	
	call	delay_tmr0
	decfsz	TMR0VAL, 1
	goto	loop_test_32

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/64
test_delay_64:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMR0VAL
	call	init_presc_64; 12 cykli - inicjalizacja preskalera
loop_test_64:
	movf	TMR0VAL, 0
	
	call	delay_tmr0
	decfsz	TMR0VAL, 1
	goto	loop_test_64

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/128
test_delay_128:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMR0VAL
	call	init_presc_128; 12 cykli - inicjalizacja preskalera
loop_test_128:
	movf	TMR0VAL, 0
	
	call	delay_tmr0
	decfsz	TMR0VAL, 1
	goto	loop_test_128

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; Procedura testowa opoznienia TMR0 z uzyciem preskalera 1/256
test_delay_256:
	movlw	.255	; testowane opoznienia od tej wartosci TMR0 do zera	
	movwf	TMR0VAL	
	call	init_presc_256; 12 cykli - inicjalizacja preskalera
loop_test_256:
	movf	TMR0VAL, 0
	
	call	delay_tmr0
	decfsz	TMR0VAL, 1
	goto	loop_test_256

	clrw				; test dla TMR0 = 0
	call	delay_tmr0
	return

;; 50us @ 4MHz, TMR0=245, Presc=2
delay_50us:				; 2 cykle call delay_
	movlw	d'245'		; 1 cykl
	call	init_presc_2; 12 cykli
	call	delay_tmr0	; 33 cykli
	return				; 2 cykle

;; 51ms @ 4MHz TMR0
delay_51ms:				; 2 cykle call delay1_
	movlw	.51			; 1 cykl ( liczba wywolan delay_tmr0 )
	movwf	TMRCNT		; 1 cykl
	call	init_presc_4; 12 cykli
loop_51ms:
	movlw	.14			; 1 cykl ( wartosc TMR0 )
	call	delay_tmr0	; 
	decfsz	TMRCNT, f	; 1 / 2 cykle
	goto	loop_51ms	; 2 / 0 cykli

	movlw	.34			; 1 cykl
	call	delay_tmr0	;

	return				; 2 cykle

;; 561ms @ 4MHz TMR0
delay_561ms:			; 2 cykle call delay1_
	movlw	.42			; 1 cykl ( liczba wywolan delay_tmr0 )
	movwf	TMRCNT		; 1 cykl
	call	init_presc_64; 12 cykli
loop_561ms:
	movlw	.53			; 1 cykl ( wartosc TMR0 )
	call	delay_tmr0	; 
	decfsz	TMRCNT, f	; 1 / 2 cykle
	goto	loop_561ms	; 2 / 0 cykli
	
	movlw	.26
	call	delay_tmr0

	return				; 2 cykle

;; 2200ms @ 4MHz TMR0
delay_2200ms:			; 2 cykle call delay1_
	movlw	.45			; 1 cykl ( liczba wywolan delay_tmr0 )
	movwf	TMRCNT		; 1 cykl
	call	init_presc_256; 12 cykli
loop_2200ms:
	movlw	.69			; 1 cykl ( wartosc TMR0 )
	call	delay_tmr0	; 
	decfsz	TMRCNT, f	; 1 / 2 cykle
	goto	loop_2200ms	; 2 / 0 cykli

	movlw	.80			; dodatkowe opoznienie
	call	delay_tmr0	;
	nop
	return				; 2 cykle

;; Inicjalizacja preskalera TMR0 na 1/2 
;; Czas wykonania: 12 cykli
init_presc_2:
	bsf 	STATUS, RP0 ; wybór banku 1 w celu uzyskania dostêpu do OPTION_REG
	bcf		OPTION_REG, TMR0CS	; czestotliwosc taktowania TMR0: zegar wewnetrzny / 4
	bcf		OPTION_REG, TMR0SE	; zwiêkszenie wartosci TMR0 przy narastajacym zboczu na RA4/TOCKI
	bcf		OPTION_REG, PSA		; preskaler przyporzadkowany do TMR0
	bcf		OPTION_REG, PS2		; ustawienie preskalera
	bcf		OPTION_REG, PS1		; ...
	bcf		OPTION_REG, PS0		; ... na 1/2
	bcf		STATUS, RP0 ; wybór banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/4 
;; Czas wykonania: 12 cykli
init_presc_4:
	bsf 	STATUS, RP0 ; wybór banku 1 w celu uzyskania dostêpu do OPTION_REG
	bcf		OPTION_REG, TMR0CS	; czestotliwosc taktowania TMR0: zegar wewnetrzny / 4
	bcf		OPTION_REG, TMR0SE	; zwiêkszenie wartosci TMR0 przy narastajacym zboczu na RA4/TOCKI
	bcf		OPTION_REG, PSA		; preskaler przyporzadkowany do TMR0
	bcf		OPTION_REG, PS2		; ustawienie preskalera
	bcf		OPTION_REG, PS1		; ...
	bsf		OPTION_REG, PS0		; ... na 1/4
	bcf		STATUS, RP0 ; wybór banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/8 
;; Czas wykonania: 12 cykli
init_presc_8:
	bsf 	STATUS, RP0 ; wybór banku 1 w celu uzyskania dostêpu do OPTION_REG
	bcf		OPTION_REG, TMR0CS	; czestotliwosc taktowania TMR0: zegar wewnetrzny / 4
	bcf		OPTION_REG, TMR0SE	; zwiêkszenie wartosci TMR0 przy narastajacym zboczu na RA4/TOCKI
	bcf		OPTION_REG, PSA		; preskaler przyporzadkowany do TMR0
	bcf		OPTION_REG, PS2		; ustawienie preskalera
	bsf		OPTION_REG, PS1		; ...
	bcf		OPTION_REG, PS0		; ... na 1/8
	bcf		STATUS, RP0 ; wybór banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/16 
;; Czas wykonania: 12 cykli
init_presc_16:
	bsf 	STATUS, RP0 ; wybór banku 1 w celu uzyskania dostêpu do OPTION_REG
	bcf		OPTION_REG, TMR0CS	; czestotliwosc taktowania TMR0: zegar wewnetrzny / 4
	bcf		OPTION_REG, TMR0SE	; zwiêkszenie wartosci TMR0 przy narastajacym zboczu na RA4/TOCKI
	bcf		OPTION_REG, PSA		; preskaler przyporzadkowany do TMR0
	bcf		OPTION_REG, PS2		; ustawienie preskalera
	bsf		OPTION_REG, PS1		; ...
	bsf		OPTION_REG, PS0		; ... na 1/16
	bcf		STATUS, RP0 ; wybór banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/32 
;; Czas wykonania: 12 cykli
init_presc_32:
	bsf 	STATUS, RP0 ; wybór banku 1 w celu uzyskania dostêpu do OPTION_REG
	bcf		OPTION_REG, TMR0CS	; czestotliwosc taktowania TMR0: zegar wewnetrzny / 4
	bcf		OPTION_REG, TMR0SE	; zwiêkszenie wartosci TMR0 przy narastajacym zboczu na RA4/TOCKI
	bcf		OPTION_REG, PSA		; preskaler przyporzadkowany do TMR0
	bsf		OPTION_REG, PS2		; ustawienie preskalera
	bcf		OPTION_REG, PS1		; ...
	bcf		OPTION_REG, PS0		; ... na 1/32
	bcf		STATUS, RP0 ; wybór banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/64
;; Czas wykonania: 12 cykli
init_presc_64:
	bsf 	STATUS, RP0 ; wybór banku 1 w celu uzyskania dostêpu do OPTION_REG
	bcf		OPTION_REG, TMR0CS	; czestotliwosc taktowania TMR0: zegar wewnetrzny / 4
	bcf		OPTION_REG, TMR0SE	; zwiêkszenie wartosci TMR0 przy narastajacym zboczu na RA4/TOCKI
	bcf		OPTION_REG, PSA		; preskaler przyporzadkowany do TMR0
	bsf		OPTION_REG, PS2		; ustawienie preskalera
	bcf		OPTION_REG, PS1		; ...
	bsf		OPTION_REG, PS0		; ... na 1/64
	bcf		STATUS, RP0 ; wybór banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/128
;; Czas wykonania: 12 cykli
init_presc_128:
	bsf 	STATUS, RP0 ; wybór banku 1 w celu uzyskania dostêpu do OPTION_REG
	bcf		OPTION_REG, TMR0CS	; czestotliwosc taktowania TMR0: zegar wewnetrzny / 4
	bcf		OPTION_REG, TMR0SE	; zwiêkszenie wartosci TMR0 przy narastajacym zboczu na RA4/TOCKI
	bcf		OPTION_REG, PSA		; preskaler przyporzadkowany do TMR0
	bsf		OPTION_REG, PS2		; ustawienie preskalera
	bsf		OPTION_REG, PS1		; ...
	bcf		OPTION_REG, PS0		; ... na 1/128
	bcf		STATUS, RP0 ; wybór banku 0
	return

;; Inicjalizacja preskalera TMR0 na 1/256
;; Czas wykonania: 12 cykli
init_presc_256:
	bsf 	STATUS, RP0 ; wybór banku 1 w celu uzyskania dostêpu do OPTION_REG
	bcf		OPTION_REG, TMR0CS	; czestotliwosc taktowania TMR0: zegar wewnetrzny / 4
	bcf		OPTION_REG, TMR0SE	; zwiêkszenie wartosci TMR0 przy narastajacym zboczu na RA4/TOCKI
	bcf		OPTION_REG, PSA		; preskaler przyporzadkowany do TMR0
	bsf		OPTION_REG, PS2		; ustawienie preskalera
	bsf		OPTION_REG, PS1		; ...
	bsf		OPTION_REG, PS0		; ... na 1/256
	bcf		STATUS, RP0 ; wybór banku 0
	return

;; Parametr:
;; W - wartoœæ jaka zostanie zapisana do rejestru TMR0
;; Przed wykonaniem funkcji nale¿y zainicjalizowaæ preskaler
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
	btfss	INTCON, TMR0IF		; czekamy na przepe³nienie licznika
		goto	$-1				; czekaj dopóki INTCON<TMR0IF> jest wyzerowany

	bcf		INTCON, TMR0IF		; wyczyszczenie flagi przepelnienia
	return

 end

