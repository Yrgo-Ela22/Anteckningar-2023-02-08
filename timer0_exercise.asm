;********************************************************************************
; timer0_exercise.asm: Ansluter en lysdiod till pin 8 (PORTB0) samt en tryckknapp
;                      till pin 13 (PORTB5). Vid nedtryckning av tryckknappen
;                      togglas timerkretsen Timer 0 mellan att vara p� och av.
;
;                      - N�r Timer 0 �r p� togglas lysdioden var 100:e ms.
;                      - N�r Timer 0 �r av �r lysdioden sl�ckt.
;
;                      Timer 0 st�lls med prescaler 1024, s� att vi f�r 
;                      uppr�kningsfrekvensen 15 625 Hz, vilket medf�r 
;                      inkrementering var 0.064 vs och d�rmed ett overflow-
;                      avbrott var 0.064m * 256 = 16.384:e ms. D�rmed genomf�rs
;                      sex overflow-avbrott p� 100 ms.
;********************************************************************************
.EQU LED1             = PORTB0 ; Lysdiod 1 ansluten till pin 8 (PORTB0).
.EQU BUTTON1          = PORTB5 ; Tryckknapp 1 ansluten till pin 13 (PORTB5).
.EQU TIMER0_MAX_COUNT = 6      ; Motsvarar ca 100 ms f�rdr�jning.

.EQU RESET_vect       = 0x00   ; Reset-vektor, programmets startpunkt.
.EQU PCINT0_vect      = 0x06   ; Avbrottsvektor f�r PCI-avbrott p� I/O-port B (pin 8 - 13).
.EQU TIMER0_OVF_vect  = 0x20   ; Avbrottsvektor f�r Timer 0 i Normal Mode.

;********************************************************************************
; .DSEG: Dataminnet - H�r lagras statiska variabler (specifikt i SRAM).
;        F�r deklaration av variabler anv�nds f�ljande syntax:
;
;        variabelnamn: .datatyp antal_byte
;********************************************************************************
.DSEG
.ORG SRAM_START
   counter0: .byte 1 ; static uint8_t counter0 = 0;

;********************************************************************************
; .CSEG: Programminnet - H�r lagras programkoden.
;********************************************************************************
.CSEG

;********************************************************************************
; RESET_vect: Programmets startpunkt. Programhopp sker till subrutinen main
;             f�r att starta programmet.
;********************************************************************************
.ORG RESET_vect
   RJMP main

;********************************************************************************
; PCINT0_vect: Avbrottsvektor (adress) f�r PCI-avbrott p� I/O-port B.
;              Programhopp sker till motsvarande avbrottsrutin ISR_PCINT0
;              f�r att hantera avbrottet.
;********************************************************************************
.ORG PCINT0_vect
   RJMP ISR_PCINT0

;********************************************************************************
; TIMER0_OVF_vect: Avbrottsvektor (adress) f�r overflow-avbrott p� Timer 0.
;                  Programhopp sker till motsvarande avbrottsrutin 
;                  ISR_TIMER0_OVF f�r att hantera avbrottet.
;********************************************************************************
.ORG TIMER0_OVF_vect
   RJMP ISR_TIMER0_OVF

;********************************************************************************
; ISR_PCINT0: Avbrottsrutin f�r PCI-avbrott p� I/O-port, som anropas vid
;             nedtryckning och uppsl�ppning av tryckknappen. Vid nedtryckning
;             togglas Timer 0. Om Timer 0 st�ngs av sl�cks ocks� lysdioden.
;********************************************************************************
ISR_PCINT0:
   IN R24, PINB            
   ANDI R24, (1 << BUTTON1) 
   BREQ ISR_PCINT0_end      
timer0_toggle:
   LDS R24, TIMSK0        
   ANDI R24, (1 << TOIE0)  
   BRNE timer0_off         
timer0_on:                  
   STS TIMSK0, R16         
   RETI                  
timer0_off:
   CLR R24                  
   STS TIMSK0, R24         
   IN R24, PORTB            
   ANDI R24, ~(1 << LED1) 
   OUT PORTB, R24          
ISR_PCINT0_end:
   RETI                   

;********************************************************************************
; ISR_TIMER0_OVF: Avbrottsrutin f�r overflow-avbrott p� Timer 0, vilket sker
;                 var 16.384:e ms n�r timern �r aktiverad. Var 6:e avbrott
;                 (efter ca 100 ms) togglas lysdioden.
;********************************************************************************
ISR_TIMER0_OVF:
   LDS R24, counter0         
   INC R24                   
   CPI R24, TIMER0_MAX_COUNT 
   BRLO ISR_TIMER0_OVF_end   
   OUT PINB, R16             
   CLR R24                  
ISR_TIMER0_OVF_end:
   STS counter0, R24         
   RETI                    

;********************************************************************************
; main: Initierar systemet vid start. Programmet h�lls ig�ng s� l�nge
;       matningssp�nning tillf�rs.
;********************************************************************************
main:

;********************************************************************************
; setup: S�tter lysdioden till utport, aktiverar den interna pullup-resistorn
;        samt PCI-avbrott p� tryckknappens pin, st�ller in Timer 0 s� att
;        overflow-avbrott sker var 16.384:e ms. 
;********************************************************************************
setup:
   LDI R16, (1 << LED1)               
   OUT DDRB, R16                      
   LDI R17, (1 << BUTTON1)           
   OUT PORTB, R17                     
   STS PCICR, R16                     
   STS PCMSK0, R17                    
   LDI R18, (1 << CS02) | (1 << CS00) 
   OUT TCCR0B, R18                   
   SEI                               

;********************************************************************************
; main_loop: H�ller ig�ng programmet s� l�nge matningssp�nning tillf�rs.
;********************************************************************************
main_loop:
   RJMP main_loop
   