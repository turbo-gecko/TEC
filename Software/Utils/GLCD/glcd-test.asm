;---------------------------------------------------------------------
; Graphics LCD test program
;
; 4th April 2024
;---------------------------------------------------------------------


            .org    4000h
            
START:      
            ld      hl,BITMAP
            ld      (GL_BUFPTR),hl
            
            call    GL_DRAW_BM

            ret
            
#include    glcd.asm

;---------------------------------------------------------------------
; 128x64px Intro bitmap

            .org    1000h

#include    moon_pixmap.asm

            .end