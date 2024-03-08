;---------------------------------------------------------------------
; LCD library
;
; 2nd March 2024
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; The LCD address for colomun 1 on each row of the LCD
;---------------------------------------------------------------------
LCD_1:      .equ	80h
LCD_2:      .equ	0c0h
LCD_3:      .equ	94h
LCD_4:      .equ	0d4h

;---------------------------------------------------------------------
; Sends the clear command to the LCD
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   A
;---------------------------------------------------------------------
CLEAR_LCD:  rst		28h             ; Wait for LCD to not be busy before...

            ld		a,01h           ; ...sending the LCD clear command and...
            out		(04),a
            rst		28H             ; ...wait for it to complete

            ret

;---------------------------------------------------------------------
; Displays a 16 bit integer in 5 digit format 00000 on the LCD
;
; Inputs:
;   HL  - Register containing the 16 bit integer
; Updates:
;   None
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
HL_TO_LCD:  ld		bc,-10000       ; Convert the 16 bit value in HL to it's ASCII equivalent
            call	HTA_1
            ld		bc,-1000
            call	HTA_1
            ld		bc,-100
            call	HTA_1
            ld		c,-10
            call	HTA_1
            ld		c,-1
HTA_1:      ld		a,'0'-1

HTA_2:      inc		a
            add		hl,bc
            jr		c,HTA_2
            sbc		hl,bc
            ld		c,14            ; Send ASCII character to the LCD
            rst		10h
            ret

;---------------------------------------------------------------------
; Displays an 8 bit integer in 3 digit format 000 on the LCD
;
; Inputs:
;   L   - Register containing the 8 bit integer
; Updates:
;   None
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
L_TO_ASC:   ld		h,0             ; Convert the 8 bit value in L to it's ASCII equivalent
            ld		bc,-100
            call	LTA_1
            ld		c,-10
            call	LTA_1
            ld		c,-1

LTA_1:      ld		a,'0'-1

LTA_2:      inc		a
            add		hl,bc
            jr		c,LTA_2
            sbc		hl,bc
            ld		c,14            ; Send ASCII character to the LCD
            rst		10h
            ret

