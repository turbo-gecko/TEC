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

;---------------------------------------------------------------------
; Displays a message at Row 1
;
; Inputs:
;   HL  - Contains address of the message to print
; Updates:
;   None
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
PRINT_R1:   ld      a,LCD_1         ; Move cursor to LCD line 1...
            ld      b,a
            ld      c,15
            rst     10h

            ld      c,13            ; ...and display the message
            rst     10h

            ret

;---------------------------------------------------------------------
; Displays a message at Row 2
;
; Inputs:
;   HL  - Contains address of the message to print
; Updates:
;   None
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
PRINT_R2:   ld      a,LCD_2         ; Move cursor to LCD line 2...
            ld      b,a
            ld      c,15
            rst     10h

            ld      c,13            ; ...and display the message
            rst     10h

            ret

;---------------------------------------------------------------------
; Displays a message at Row 3
;
; Inputs:
;   HL  - Contains address of the message to print
; Updates:
;   None
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
PRINT_R3:   ld      a,LCD_3         ; Move cursor to LCD line 3...
            ld      b,a
            ld      c,15
            rst     10h

            ld      c,13            ; ...and display the message
            rst     10h

            ret

;---------------------------------------------------------------------
; Displays a message at Row 4
;
; Inputs:
;   HL  - Contains address of the message to print
; Updates:
;   None
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
PRINT_R4:   ld      a,LCD_4         ; Move cursor to LCD line 4...
            ld      b,a
            ld      c,15
            rst     10h

            ld      c,13            ; ...and display the message
            rst     10h

            ret

;---------------------------------------------------------------------
; Displays a message at the specific row and column
;
; Inputs:
;   BC  - B = row, C = column
;   HL  - Contains address of the message to print
; Updates:
;   None
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
PRINT_AT:   ld      a,b             ; Determine the row
            cp      1
            jr      z,PRINT_AT_1
            cp      2
            jr      z,PRINT_AT_2
            cp      3
            jr      z,PRINT_AT_3
            cp      4
            jr      z,PRINT_AT_4
            ret                     ; Invalid row so return
            
PRINT_AT_1: ld      a,LCD_1         ; Calculate the row
            jr      PRINT_AT_5
            
PRINT_AT_2: ld      a,LCD_2
            jr      PRINT_AT_5
            
PRINT_AT_3: ld      a,LCD_3
            jr      PRINT_AT_5
            
PRINT_AT_4: ld      a,LCD_4
            jr      PRINT_AT_5
            
PRINT_AT_5: add     a,c             ; Add the column
            ld      b,a             ; Display the message
            ld      c,15
            rst     10h

            ld      c,13            
            rst     10h

            ret
