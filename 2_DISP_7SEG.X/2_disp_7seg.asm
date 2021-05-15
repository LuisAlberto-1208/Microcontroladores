; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR


; PIC16F84A Configuration Bit Settings

; Assembly source line config statements

#include "p16f84a.inc"

; CONFIG
; __config 0xFFF9
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _CP_OFF

 
 CONTADOR EQU 0x20
 LIMITE EQU 0x21
 CONTADOR2 EQU 0x22
 LIMITE2 EQU 0x23
 MONITOR EQU 0x30
 MONITOR2 EQU 0x31
 A EQU 0x32
 NUMERO EQU 0x33
 DELAY EQU 0x34
 CONT EQU 0x24
 
    
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
    
; TODO ADD INTERRUPTS HERE IF USED
ISR CODE 0x0004
    GOTO TIMER_INT



MAIN_PROG CODE                      ; let linker place main program

START

	    BSF STATUS, RP0
	    MOVLW 0x00
	    MOVWF TRISB
            MOVLW 0x01
	    MOVWF TRISA
            BCF OPTION_REG, T0CS
	    BCF OPTION_REG, T0SE
	    BCF OPTION_REG, PSA
	    BSF OPTION_REG, PS0
	    BSF OPTION_REG, PS1
	    BSF OPTION_REG, PS2
	    MOVLW 0x00
	    MOVWF INTCON
	    BSF INTCON, T0IE
	    BSF INTCON, GIE
	    BCF STATUS, RP0
    
	    MOVLW 0x3F
	    MOVWF 0x10
	    MOVLW 0x06
	    MOVWF 0x11
	    MOVLW 0x5B
	    MOVWF 0x12
	    MOVLW 0x4F
	    MOVWF 0x13
	    MOVLW 0x66
	    MOVWF 0x14
	    MOVLW 0x6D
	    MOVWF 0x15
	    MOVLW 0x7D
	    MOVWF 0x16
	    MOVLW 0x07
	    MOVWF 0x17
	    MOVLW 0x7F
	    MOVWF 0x18
	    MOVLW 0x6F
	    MOVWF 0x19
    
	    MOVLW 0x04
	    MOVWF DELAY
	    
INICIO	    MOVLW 0x00
	    MOVWF CONT		    ;El contador que estará aumentando cada que
				    ;se presiona el botón se inicia en cero.
	    
IDENTIFICA  BTFSS PORTA, RA0
	    GOTO PONLOS		    ;Si el botón no está persionado, muestra el
				    ;número que tiene CONT.
	    GOTO INCREMENTO	    ;Si el botón es presionado, aumenta en uno
				    ;el valor de CONT y lo muestra.
	    
INCREMENTO  INCF CONT
	    MOVLW 0x10
	    SUBWF CONT, 0
	    BTFSS STATUS, Z
	    GOTO PONLOS
	    GOTO INICIO		    ;Si CONT ya es mayor a 15(10), reinicia el
				    ;conteo.
	    
PONLOS	    MOVF CONT, 0
	    MOVWF MONITOR	    ;Manda a monitor el valor que se tiene que
				    ;mostrar.
	    BTFSS MONITOR, 3	    ;Si el numero es mayor o menor que 8.
				    
				    ;Verifica si el número es de dos cifras o
				    ;sólo de una, para, de esta manera, si es 
				    ;el caso de que sea de dos cifras, encender
				    ;el segundo display.
	    GOTO IDENT_1
	    BTFSS MONITOR, 2	    
	    GOTO ULTIMO
	    GOTO DECENA

ULTIMO	    BTFSS MONITOR, 1
	    GOTO IDENT_1
	
DECENA	    MOVLW 0x06
	    MOVWF PORTB
	    BCF PORTA, RA1
	    BSF PORTA, RA2
	    MOVLW 0x07
	    ANDWF MONITOR, 0
	    MOVWF MONITOR2
	    MOVLW 0x02
	    SUBWF MONITOR2, 1
	    MOVF MONITOR2, 0
	    MOVWF NUMERO
	    CLRF A
	    CLRF CONTADOR
	    CALL RETRASO
	
IDENT_1	    BTFSC PORTA, RA2
	    GOTO IDENT_2
	    MOVF MONITOR, 0
	    MOVWF NUMERO
	    CLRF A
	
IDENT_2	    MOVF A, 0
	    SUBWF NUMERO, 0
	    BTFSS STATUS, Z
	    GOTO NEXT
	    GOTO EXHIBE
	
NEXT	    INCF A
	    GOTO IDENT_2
	
EXHIBE	    MOVLW 0x10			;Manda el número corresponiente al dis-
					;play, mediante direccionamiento indi-
					;recto.
	    MOVWF FSR
	    MOVF A, 0
	    ADDWF FSR, 1
	    MOVF INDF, 0
	    BCF PORTA, RA2
	    BCF PORTA, RA1
	    MOVWF PORTB
	    BCF PORTA, RA2
	    BSF PORTA, RA1
	    CLRF CONTADOR
	    CALL RETRASO
	    GOTO IDENTIFICA
	
RETRASO	    MOVF CONTADOR, 0
	    SUBWF DELAY, 0
	    BTFSS STATUS, Z
	    GOTO RETRASO
	    CLRF CONTADOR
	    RETURN
	
TIMER_INT   INCF CONTADOR
	    BCF INTCON, T0IF
	    MOVLW 0x0A
	    MOVWF TMR0
	    RETFIE

    END