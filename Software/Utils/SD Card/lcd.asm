;---------------------------------------------------------------------
; LCD library
;
; 20th April 2024
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; The LCD address for colomun 1 on each row of the LCD
;---------------------------------------------------------------------
LCD_1	.equ 80h
LCD_2	.equ 0c0h
LCD_3	.equ 94h
LCD_4	.equ 0d4h

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
clearLCD:
	rst 28h		; Wait for LCD to not be busy before...

	ld a,01h	; ...sending the LCD clear command and...
	out (04),a
	rst 28H		; ...wait for it to complete

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
hlToLCD:
	ld bc,-10000	; Convert the 16 bit value in HL to it's ASCII equivalent
	call hlToLCD1
	ld bc,-1000
	call hlToLCD1
	ld bc,-100
	call hlToLCD1
	ld c,-10
	call hlToLCD1
	ld c,-1
hlToLCD1:
	ld a,'0'-1

hlToLCD2:
	inc a
	add hl,bc
	jr c,hlToLCD2
	sbc hl,bc
	ld c,14		; Send ASCII character to the LCD
	rst 10h

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
lToLCD:
	ld h,0		; Convert the 8 bit value in L to it's ASCII equivalent
	ld bc,-100
	call lToLCD1
	ld c,-10
	call lToLCD1
	ld c,-1

lToLCD1:
	ld a,'0'-1

lToLCD2:
	inc a
	add hl,bc
	jr c,lToLCD2
	sbc hl,bc
	ld c,14		; Send ASCII character to the LCD
	rst 10h

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
printR1:
	ld a,LCD_1	; Move cursor to LCD line 1...
	ld b,a
	ld c,15
	rst 10h

	ld c,13		; ...and display the message
	rst 10h

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
printR2:
	ld a,LCD_2	; Move cursor to LCD line 1...
	ld b,a
	ld c,15
	rst 10h

	ld c,13		; ...and display the message
	rst 10h

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
printR3:
	ld a,LCD_3	; Move cursor to LCD line 1...
	ld b,a
	ld c,15
	rst 10h

	ld c,13		; ...and display the message
	rst 10h

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
printR4:
	ld a,LCD_4	; Move cursor to LCD line 1...
	ld b,a
	ld c,15
	rst 10h

	ld c,13		; ...and display the message
	rst 10h

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
printAt:
	ld a,b		; Determine the row
	cp 1
	jr z,printAt1
	cp 2
	jr z,printAt2
	cp 3
	jr z,printAt3
	cp 4
	jr z,printAt4
	ret		; Invalid row so return
            
printAt1:
	ld a,LCD_1	; Calculate the row
	jr printAt5
            
printAt2:
	ld a,LCD_2
	jr printAt5
            
printAt3:
	ld a,LCD_3
	jr printAt5
            
printAt4:
	ld a,LCD_4
	jr printAt5
            
printAt5:
	add a,c		; Add the column
	ld b,a		; Display the message
	ld c,15
	rst 10h

	ld c,13            
	rst 10h

	ret
