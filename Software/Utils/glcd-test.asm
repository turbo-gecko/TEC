;---------------------------------------------------------------------
; Graphics LCD test program
;
; 3rd April 2024
;---------------------------------------------------------------------


            .org    4000h
            
START:      
            ld      hl,BM_INTRO
            ld      (GL_BUFPTR),hl
            
            call    GL_DRAW_BM

            ret
            
#include    glcd.asm

;---------------------------------------------------------------------
; 128x64px Intro bitmap

            .org    1000h

BM_INTRO    .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     08h, 00h, 00h, 00h, 04h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 08h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 08h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 02h, 00h, 00h
            .db     00h, 00h, 00h, 00h, 04h, 00h, 00h, 00h, 7fh, 0e0h, 00h, 00h, 0c0h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0ffh, 0f0h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0efh, 0bch, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 01h, 00h, 00h, 00h, 00h, 03h, 0c7h, 0feh, 00h, 00h, 20h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 07h, 0c7h, 0ffh, 00h, 00h, 08h, 00h, 10h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 1fh, 0ffh, 0ffh, 80h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 39h, 0ffh, 0b9h, 0c0h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 06h, 00h, 00h, 00h, 00h, 00h, 31h, 0ffh, 0b0h, 0e0h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 04h, 00h, 00h, 00h, 00h, 31h, 0dfh, 0f0h, 70h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 04h, 00h, 00h, 00h, 00h, 7fh, 8fh, 0ffh, 70h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 7fh, 0fh, 0ffh, 0f0h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 1fh, 0fh, 0efh, 0f0h, 00h, 00h, 04h, 00h, 00h 
            .db     00h, 00h, 80h, 00h, 00h, 00h, 00h, 1fh, 0ffh, 0efh, 0f0h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 7fh, 0ffh, 0ffh, 0f0h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 3fh, 0ffh, 0ffh, 0f0h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 20h, 00h, 00h, 00h, 00h, 1fh, 0fbh, 0ffh, 0f0h, 00h, 00h, 00h, 04h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 07h, 0ffh, 0feh, 0f0h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 03h, 0ffh, 0fch, 70h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 03h, 0fdh, 0fch, 60h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 9fh, 0fch, 0e0h, 00h, 00h, 00h, 00h, 80h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0fh, 0ffh, 0c0h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 08h, 00h, 40h, 00h, 00h, 00h, 07h, 0ch, 5fh, 80h, 00h, 00h, 80h, 20h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 03h, 0fch, 0ffh, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 01h, 0fch, 0ffh, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 3fh, 0f8h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0f8h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 03h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 08h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 04h, 00h, 00h, 00h, 00h, 00h, 00h, 08h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 01h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 03h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 0fh, 0f8h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 1fh, 0fch, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h 
            .db     00h, 00h, 00h, 00h, 00h, 03h, 0f8h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h
            .db     00h, 00h, 00h, 00h, 00h, 03h, 0f0h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 03h, 0f0h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 13h, 0f0h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 1fh, 0f0h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 1fh, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 20h, 80h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 20h, 82h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 20h, 82h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 20h, 82h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 41h, 0c1h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 0e0h, 03h, 80h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 
            .db     0ffh, 0ffh, 80h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 00h, 0fh, 0ffh, 
            .db     0ffh, 0ffh, 0fch, 00h, 00h, 00h, 00h, 3fh, 0ffh, 00h, 00h, 00h, 00h, 07h, 0ffh, 0fch, 
            .db     0ffh, 0ffh, 0ffh, 0ffh, 0e0h, 00h, 3fh, 0ffh, 0ffh, 0ffh, 80h, 00h, 3fh, 0ffh, 0ffh, 0ffh, 
            .db     0fch, 0ffh, 0ffh, 0ffh, 0ffh, 02h, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 1fh, 0ffh, 0ffh, 0ffh, 0ffh, 
            .db     0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0feh, 7fh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0c7h, 0ffh, 0ffh, 
            .db     0ffh, 0ffh, 0ffh, 0ffh, 0dfh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 07h, 0ffh, 0ffh, 
            .db     0ffh, 0ffh, 0ffh, 0ffh, 0dfh, 0ffh, 0ffh, 0bfh, 0ffh, 0ffh, 0bfh, 0ffh, 0ffh, 07h, 0ffh, 0ffh, 
            .db     0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 9fh, 0ffh, 0ffh, 3fh, 0ffh, 0efh, 0ffh, 0ffh, 0ffh, 
            .db     0ffh, 0ffh, 03h, 0ffh, 7fh, 0ffh, 0f8h, 0fh, 0ffh, 0ffh, 0ffh, 0ffh, 8fh, 0ffh, 0ffh, 0ffh

            .end