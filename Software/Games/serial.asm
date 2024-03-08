;---------------------------------------------------------------------
; Serial library
;
; 2nd March 2024
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; Variables
;---------------------------------------------------------------------
S_TEMP_D:   .db		"000",0
S_TEMP_W:   .db		"00000",0

;---------------------------------------------------------------------
; Send a hex character representation of a byte out the serial port
;
; Inputs:
;   A   - Contains the byte to TX
; Updates:
;   S_TEMP_D    - Temporary variable for holding 2 
; Destroys:
;   A, C, HL
;---------------------------------------------------------------------
SER_BYTE:   ld		de,S_TEMP_D     ; 'a' should already be loaded with the byte to tx
            ld		c,09
            rst		10h

            ld		hl,(S_TEMP_D)   ; Send out the serial port
            ld		a,(S_TEMP_D)
            ld		c,22
            rst		10h

            ld		a,(S_TEMP_D+1)
            ld		c,22
            rst		10h

            ret

;---------------------------------------------------------------------
; Send a CR/LF pair out the serial port
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   A, C
;---------------------------------------------------------------------
SER_CRLF:   ld		a,13
            ld		c,22
            rst		10h

            ld		a,10
            ld		c,22
            rst		10h

            ret

;---------------------------------------------------------------------
; Send a string pointed to by HL out the serial port
;
; Inputs:
;   HL  - Contains the pointer to the string to TX
; Updates:
;   None
; Destroys:
;   A, C, HL
;---------------------------------------------------------------------
SER_STR:    ld		a,(hl)
            cp		0
            jr		z,SS_1

            ld		c,22
            rst		10h
            inc		hl
            jr		SER_STR

SS_1:       ret

;---------------------------------------------------------------------
; Send a formatted 16 bit value out the serial port
;
; Inputs:
;   HL   - Contains the character to tx
; Updates:
;   None
; Destroys:
;   A, C, DE, HL
;---------------------------------------------------------------------
SER_WORD:   ld		de,S_TEMP_W     ; hl should already be loaded with the word to tx
            ld		c,08
            rst		10h
            ld		a,0
            ld		(de),a

            ld		hl,S_TEMP_W
            call	SER_STR

            ret

;---------------------------------------------------------------------
; Convert the 16 bit value in BC to it's ASCII equivalent
;
; Inputs:
;   BC   - Contains the 16 bit value to convert
; Updates:
;   None
; Destroys:
;   A, BC, DE, HL
;---------------------------------------------------------------------
SER_HL2D:   ld		de,S_TEMP_W
            ld		bc,-10000
            call	H2D_1
            ld		bc,-1000
            call	H2D_1
            ld		bc,-100
            call    H2D_1
            ld		c,-10
            call	H2D_1
            ld		c,-1
H2D_1:      ld		a,'0'-1

H2D_2:      inc		a
            add		hl,bc
            jr		c,H2D_2
            sbc		hl,bc
            ld		(de),a
            inc		de

            ret
