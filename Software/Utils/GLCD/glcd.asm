;---------------------------------------------------------------------
; Grapihics LCD library
; For the 128x64 graphical LCD
;
; 3rd April 2024
;---------------------------------------------------------------------

GL_BUFCLEAR .EQU    17
GL_DELAY    .EQU    33
GL_INIT     .EQU    0
GL_PLOT     .EQU    12
GL_SETGMODE .EQU    4

GL_BUFPTR:  .dw

;---------------------------------------------------------------------
; Initialises the graphics LCD, sets it to graphics mode and clears
; the graphics buffer.
;
; Inputs:
;   None.
; Updates:
;   None
; Destroys:
;   AF, BC, DE, HL
;---------------------------------------------------------------------

GL_CLRGMODE:
            ld      a,GL_INIT       ; Initialise the GLCD
            rst     18h
            ld      a,GL_SETGMODE   ; Set graphics mode
            rst     18h
            ld      a,GL_BUFCLEAR   ; Clear the graphics buffer

            ret

;---------------------------------------------------------------------
; Draws a 128x64 bitmap to the graphical LCD
;
; Inputs:
;   GL_BUFPTR
;       - Pointer to the bitmap. The bitmap should be in the form of
;         64x16 bytes where each bit in the byte represents a pixel,
;         0 = on, 1 = off.
; Updates:
;   None
; Destroys:
;   AF, BC, DE, HL
;---------------------------------------------------------------------
            
GL_DRAW_BM:      
            call    GL_CLRGMODE     ; Initialise and clear the GLCD
            ld      hl,(GL_BUFPTR)  ; Get the pointer to the bitmapped image
            ld      bc,0            ; Reset screen origin to 0,0
GL_DB_1:     
            ld      e,(hl)
            push    hl
            ld      d,8
GL_DB_2:     
            rlc     e               ; Loop through each bit in the bitmapped
            push    de              ; byte and either turn on or off the pixel
            jr      c,GL_DB_3
            ld      a,19
            rst     18h
            jr      GL_DB_4
GL_DB_3:     
            ld      a,9
            rst     18h            
GL_DB_4:
            inc     b               ; Move to the next pixel
            pop     de
            dec     d
            ld      a,d
            cp      0
            jr      nz,GL_DB_2      ; Check to see if we have done all bits in the byte

            pop     hl              ; Move to the next byte in the bitmap
            inc     hl
            ld      a,b
            cp      128             ; Are we at the end of the current row?
            jr      nz,GL_DB_1      ; No, then do the next byte
            ld      a,0             ; Yes, then reset the column back to 0...
            ld      b,a
            
            inc     c               ; ...and increment the row counter
            ld      a,c
            cp      64              ; Are we at the bottom row?
            jr      nz,GL_DB_1      ; No, then go again
            
GL_DB_5:      
            ld      a,GL_PLOT       ; Output to the graphics LCD the bitmap
            rst     18h
            ld      c,GL_DELAY      ; Wait for the graphics LCD to complete its update
            ld      hl,4000h
            rst     10h

            ret
            
            .end