;---------------------------------------------------------------------
; Moon Lander
;
; 30th March 2024
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; Compiler directives
;---------------------------------------------------------------------
; Enables dumping of variables to the serial port
;#define     DUMP_EN

; Enables output of stats and debug info to the serial port
;#define     SERIAL_OUT_EN

; Enables the use of the expansion RAM
;#define     EX_RAM_EN

;---------------------------------------------------------------------
; Constants
;---------------------------------------------------------------------

C_BURN      .equ    0
C_FUEL      .equ    300
C_HEIGHT    .equ    500
C_THRTL     .equ    0
C_TIME      .equ    0
C_VEL       .equ    50

LED_PORT    .equ    0fbh

KEY_DELAY   .equ    6000h
TIME_DELAY  .equ    0200h

;---------------------------------------------------------------------
; Data/Variables
;---------------------------------------------------------------------

#ifdef EX_RAM_EN
            .org    0B000h
#else
            .org    1000h
#endif

ANY_KEY_P   .db     "   Press any key    ",0
THRTL_P     .db     "Throttle 00-99 ? ",0

ABORT_M     .db     "* Aborted landing! *",0
BUMPY_M     .db     "** Bumpy landing! **",0
CRASH_M     .db     "Crashed! - All dead ",0
GOOD_M      .db     "** Great landing! **",0
INTRO_1_M   .db     " -= Moon Lander! =- ",0
INTRO_2_M   .db     "  Press 00 - 99 to  ",0
INTRO_3_M   .db     " adjust the descent ",0
INTRO_4_M   .db     " Press <A> to abort ",0
INTRO_5_M   .db     " during the descent ",0
INTRO_6_M   .db     "Press <B>  to replay",0

NO_FUEL_M   .db     " <EMPTY>",0

BURN_T      .db     "Fuel Burn ",0
DOWN_T      .db     "  [DOWN]",0
FUEL_T      .db     "Fuel ",0
HEIGHT_T    .db     "Height ",0
THRTL_T     .db     "Throttle (%) ",0
TIME_T      .db     " - T ",0
UP_T        .db     "  [ UP ]",0
VEL_T       .db     "Vel.   ",0
VEL1_T      .db     "Vel1.  ",0
ZERO_T      .db     "00000",0

#ifdef      SERIAL_OUT_EN
S_TIME_T    .db     "Time ",0
#endif

BUMPY_S     .db     06h,03h,06h,03h,06h,03h,06h,03h,06h,03h,06h,03h,06h,03h,06h,03h
            .db     06h,03h,06h,03h,06h,03h,06h,03h,06h,03h,06h,03h,06h,03h,1fh

CRASH_S     .db     03h,03h,00h,03h,03h,00h,03h,00h,03h,03h,00h,06h,06h,00h,05h,00h
            .db     05h,00h,00h,03h,00h,03h,03h,00h,02h,00h,03h,03h,03h,00h,1fh

INTRO_S     .db     03h,0ch,08h,0ch,01h,03h,05h,06h,08h,0ah,0ch,01h,0ah,08h,06h,05h,03h,1fh

SUCCESS_S   .db     02h,08h,06h,0ah,0dh,12h,12h,12h,0dh,0dh,0dh,0ah,0dh,0ah,06h,00h
            .db     06h,0ah,0dh,12h,12h,12h,06h,06h,06h,0dh,0dh,0dh,00h,00h,1fh
            
BURN        .db     0
FUEL        .dw     300
HEIGHT      .dw     500
THRTL       .db     0
TIME        .db     0
VEL         .dw     50
VEL1        .dw     0
V_AVG       .dw     0

BAR_GRAPH   .db     0ffh

TEMP_D      .dw     0
TEMP_W      .db     "00000",0
TEMP_7_SEG  .db     "000000",0

TIMER_1     .dw     0

EOV         .db     0ffh

;---------------------------------------------------------------------
; Main Program
;---------------------------------------------------------------------

            .org    4000h
#ifdef EX_RAM_EN
            jp      8000h
            .org    8000h
#endif

START:      call    CLEAR_LCD       ; Clear the LCD

            ld      a,C_BURN        ; Initialise variables
            ld      (BURN),a

            ld      hl,C_FUEL
            ld      (FUEL),hl

            ld      hl,C_HEIGHT
            ld      (HEIGHT),hl

            ld      a,C_THRTL
            ld      (THRTL),a

            ld      a,C_TIME
            ld      (TIME),a

            ld      hl,C_VEL
            ld      (VEL),hl
            ld      (VEL1),hl
            ld      (V_AVG),hl

INTRO:      ld      hl,INTRO_1_M    ; Display the intro messages
            ld      c,13
            rst     10h

            ld      hl,INTRO_2_M
            call    PRINT_R2

            ld      hl,INTRO_3_M
            call    PRINT_R3

            ld      de,INTRO_S
            ld      c,35
            rst     10h

            ld      hl,ANY_KEY_P    ; Display the wait message
            call    PRINT_R4

            call    KEY_WAIT        ; Wait for a key press

            call    CLEAR_LCD       ; Clear the LCD

            ld      hl,INTRO_4_M    ; Continue the intro message
            ld      c,13
            rst     10h

            ld      hl,INTRO_5_M
            call    PRINT_R2

            ld      hl,INTRO_6_M
            call    PRINT_R3

            ld      hl,ANY_KEY_P    ; ...and display the wait message
            call    PRINT_R4

            call    KEY_WAIT        ; Wait for a key press

MAIN:       call    STATS           ; Display the current stats on the LCD

#ifdef SERIAL_OUT_EN
            call    SER_STAT        ; Send the current stats to the serial port
#endif

            call    GET_THRTL       ; Prompt for and get the new throttle value

            ld      a,(TIME)        ; Update the time counter
            inc     a
            ld      (TIME),a

            call    CALC_F          ; Calculate how much fuel is left
            call    CALC_V          ; Calculate the velocity of the lander

MAIN_1:     call    CALC_H          ; Calculate the height above the Biddleonian moon surface

            ld      hl,(HEIGHT)     ; Have we landed?
            ld      de,1
            sbc     hl,de
            bit     7,h             ; Check to see if the height is now negative
            jr      nz,LANDED       ; If so, we have landed...

            jp      MAIN

LANDED:     ld      hl,0            ; Set the height to the moons surface
            ld      (HEIGHT),hl

            call    STATS           ; Update the stats on the LCD

            ld      a,(VEL)         ; If we have 0 velocity we have nailed it!
            or      a
            jr      z,GOOD

            cp      5               ; If we have a velocity of 4 or less, it's a bumpy landing
            jr      c,BUMPY

            ld      hl,CRASH_M      ; Otherwise we have had a rapid unscheduled disassembly
            call    PRINT_R4

            ld      de,CRASH_S
            ld      c,35
            rst     10h

            jr      END

BUMPY:      ld      hl,BUMPY_M      ; A bumpy landing
            call    PRINT_R4

            ld      de,BUMPY_S
            ld      c,35
            rst     10h

            jr      END

GOOD:       ld      hl,GOOD_M       ; Nailed it!
            call    PRINT_R4
            
            ld      de,SUCCESS_S
            ld      c,35
            rst     10h

END:        ld      a,(BAR_GRAPH)
            out     (LED_PORT),a
            
            call    SCAN_7_SEG      ; Leave the landing message on the LCD. Wait for a key press

            cp      0ffh
            jr      z,END
            
            ld      c,3             ; Beep
            rst     10h

            ld      hl,KEY_DELAY    ; Add short delay to debounce key press
            ld      c,33
            rst     10h

            call    CLEAR_LCD
            
            ld      hl,INTRO_6_M    ; Prompt for play again
            ld      c,13
            rst     10h
            
END_1:      ld      a,(BAR_GRAPH)
            out     (LED_PORT),a
            
            call    SCAN_7_SEG
            cp      0ffh
            jr      z,END_1
            cp      11
            jr      nz,END_2        ; Check for the 'Replay' key B
            jp      START           ; And go again      

END_2:      ld      a,00h
            out     (LED_PORT),a
            
            rst     00h             ; All done!

;---------------------------------------------------------------------
; External modules/subroutines
;---------------------------------------------------------------------
#include    "lcd.asm"

#ifdef      SERIAL_OUT_EN
#include    "serial.asm"
#endif

;---------------------------------------------------------------------
; Subroutines
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; Calculate fuel remaining
;   Determines how much of the fuel has been used at the rate of burn
;   being equal to 1/4 of the throttle percentage.
;
; Inputs:
;   FUEL    - Current amount of fuel left
;   THRTL   - Current throttle position as a %
; Updates:
;   BURN    - New burn rate
;   FUEL    - New fuel level
; Destroys:
;   A, DE, HL
;---------------------------------------------------------------------
CALC_F:     ld      hl,(FUEL)
            ld      d,0
            ld      a,(THRTL)       ; Burn is 1/4 of throttle %
            srl     a
            srl     a
            ld      (BURN),a
            ld      e,a
            and     a
            sbc     hl,de
            jr      nc,CF_1         ; Check for no fuel left
            ld      hl,0
            ld      a,0
            ld      (BURN),a

CF_1        ld      (FUEL),hl       ; Update fuel

            ret

;---------------------------------------------------------------------
; Calculate the new height
;   Determines the new height of the lander above the lunar surface
;   by subtracting the average velocity.
;
; Inputs:
;   HEIGHT  - Current height
;   V_AVG   - Calculated average velocity
; Updates:
;   HEIGHT  - New height above the lunar surface
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
CALC_H:     ld      hl,(HEIGHT)     ; Calculate the new height
            ld      bc,(V_AVG)
            and     a
            sbc     hl,bc
            ld      (HEIGHT),hl

            ret

;---------------------------------------------------------------------
; Calculate the new velocity
;   Determines the new velocity of the lander as average of the 
;   previous velocity and the new velocity, plus the gravitational
;   pull of the moon.
;   (VEL + (VEL - BURN + 5)) / 2 (Biddleonian physics)
;
; Inputs:
;   VEL     - Current velocity
;   BURN    - Current burn rate
; Updates:
;   VEL1    - New velocity
;   V_AVG   - Calculated average velocity
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
CALC_V:     ld      hl,(VEL)        ; Calculate the new velocity...
            ld      b,0
            ld      a,(BURN)
            ld      c,a
            and     a
            sbc     hl,bc
            ld      bc,5
            add     hl,bc           ; ...then add 5 to it 
            ld      (VEL1),hl

            ld      bc,(VEL)        ; Get the average of the old and new velocities
            add     hl,bc
            bit     7,h             ; Check to see if we have a negative number
            jr      nz,CV_1
            srl     h               ; Divide by 2
            jr      CV_2
CV_1        srl     h
            set     7,h
CV_2        rr      l
            ld      (V_AVG),hl

            ld      hl,(VEL1)
            ld      (VEL),hl

            ret

#ifdef DUMP_EN
;---------------------------------------------------------------------
; Dumps the variables to the serial port
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   C, DE, HL
;---------------------------------------------------------------------
DUMP:       ld      hl,BURN         ; ** DEBUG ** Dump variables
            ld      de,EOV-BURN
            ld      c,28
            rst     10h

            ret
#endif

;---------------------------------------------------------------------
; Get the new throttle position
;   Prompts for, and gets the new throttle position
;
; Inputs:
;   Key presses 00 to 99 from the keypad
; Updates:
;   THRTL   - New throttle position
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
GET_THRTL:  ld      hl,THRTL_P      ; Display the prompt for the throttle %
            call    PRINT_R4

            ld      a,(THRTL)
            ld      l,a
            call    L_TO_LCD

            ld      a,LCD_4 + 17    ; Move cursor to data entry on LCD line 4
            ld      b,a
            ld      c,15
            rst     10h
            
            ld      a,(BAR_GRAPH)
            out     (LED_PORT),a
            
GT_1:       call    SCAN_7_SEG      ; Check for key press
            cp      10              ; Check for a valid key press
            jr      z,GT_5          ; Check for the 'Abort' key A
            jr      c,GT_2
            cp      0ffh            ; Check for a timeout
            jr      z,GT_5
            jr      GT_1

GT_2:       ld      l,a
            ld      c,3             ; Beep
            rst     10h

            ld      a,l             ; Multiply the key press by 10
            rlc     a               ; x2
            rlc     a               ; x4
            rlc     a               ; x8
            add     a,l             ; +key
            add     a,l             ; +key
            ld      (TEMP_D),a      ; Store first digit
            
            ld      hl,KEY_DELAY    ; Add short delay to debounce key press
            ld      c,33
            rst     10h

GT_3:       call    SCAN_7_SEG      ; Check for key press
            ld      b,a             ; Store key value returned
            cp      10              ; Check for a valid key press
            jr      z,GT_6          ; Check for the 'Abort' key A
            jr      c,GT_4
            jr      GT_3

GT_4:       cp      0ffh            ; Check for a timeout
            jr      z,GT_5
            
            ld      a,(TEMP_D)      ; Get first digit
            add     a,b
            ld      (THRTL),a
            
GT_5:       ld      l,a
            call    L_TO_LCD

            push    bc
            ld      l,a
            ld      c,3             ; Beep
            rst     10h
            pop     bc
            
            ld      hl,KEY_DELAY    ; Add short delay to debounce key press
            ld      c,33
            rst     10h
            
            ld      a,0ffh
            ld      (BAR_GRAPH),a

            ret

GT_6:       ld	    h,0FFh          ; Abort sound!
	        ld	    b,01h

GT_7:   	inc	    b
	        ld      a,80h
	        out 	(01),a
	        call	GT_9
	        xor     a
	        out     (01),a
	        call	GT_9

	        dec 	h
	        jr  	nz,GT_8

GT_8:	    call    CLEAR_LCD

            ld      hl,ABORT_M      ; Display the abort message
            ld      c,13
            rst     10h

            ld      a,LCD_4         ; Move cursor to LCD line 4...
            ld      b,a
            ld      c,15
            rst     10h

            ld      hl,ANY_KEY_P    ; ...and display the wait message
            ld      c,13
            rst     10h

            jp      END

GT_9:       ld 	    c,b

GT_10:   	dec     c
	        jr  	nz,GT_10
	        ret

;---------------------------------------------------------------------
; Convert the 16 bit value in HL to it's ASCII equivalent
;
; Inputs:
;   HL   - Contains the 16 bit value to convert
; Updates:
;   None
; Destroys:
;   A, BC, DE, HL
;---------------------------------------------------------------------
HL_TO_ASC:  ld		de,TEMP_W
            ld		bc,-10000
            call	HL2A_1
            ld		bc,-1000
            call	HL2A_1
            ld		bc,-100
            call    HL2A_1
            ld		c,-10
            call	HL2A_1
            ld		c,-1
HL2A_1:     ld		a,'0'-1

HL2A_2:     inc		a
            add		hl,bc
            jr		c,HL2A_2
            sbc		hl,bc
            ld		(de),a
            inc		de

            ret

;---------------------------------------------------------------------
; Wait for a key press
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   C
;---------------------------------------------------------------------
KEY_WAIT:   ld      c,11h
            rst     10h
            ret

;---------------------------------------------------------------------
; Update the 7 segment display and scan for keypress. This Function
; blocks until a key is pressed.
;
; Inputs:
;   HEIGHT  - Current height
;   THRTL   - Current throttle position as a %
; Updates:
;   TEMP_7_SEG  - Contents of the temp 7 segment display variable
;   A           - Contains key pressed
; Destroys:
;   A, DE, HL
;---------------------------------------------------------------------
SCAN_7_SEG: ld      hl,(FUEL)
            call    HL_TO_ASC
            
            ld      a,(TEMP_W + 2)
            ld      c,6
            rst     10h
            ld      (TEMP_7_SEG),a

            ld      a,(TEMP_W + 3)
            ld      c,6
            rst     10h
            ld      (TEMP_7_SEG + 1),a

            ld      a,(TEMP_W + 4)
            ld      c,6
            rst     10h
            ld      (TEMP_7_SEG + 2),a

            ld      a,' '
            ld      c,6
            rst     10h
            ld      (TEMP_7_SEG + 3),a
            
            ld      a,(THRTL)
            ld      h,0
            ld      l,a
            call    HL_TO_ASC
            
            ld      a,(TEMP_W + 3)
            ld      c,6
            rst     10h
            ld      (TEMP_7_SEG + 4),a

            ld      a,(TEMP_W + 4)
            ld      c,6
            rst     10h
            ld      (TEMP_7_SEG + 5),a
            
            ld      hl,TIME_DELAY
            ld      (TIMER_1),hl

S7S_1:      ld      hl,(TIMER_1)        ; Check timer
            dec     hl
            ld      (TIMER_1),hl
            ld      a,h
            cp      0
            jr      nz,S7S_2
            ld      a,l
            cp      0
            jr      z,S7S_3
            
S7S_2:      ld      de,TEMP_7_SEG
            rst     20
            
            jr      nz,S7S_1
            ret

S7S_3:      ld      a,(BAR_GRAPH)
            sla     a
            out     (LED_PORT),a
            ld      (BAR_GRAPH),a
            
            cp      00h
            jr      nz,S7S_4
            ld      a,0ffh
            ld      (BAR_GRAPH),a
            
            ret
            
S7S_4:      ld      hl,TIME_DELAY       ; Timer has expired so reset...
            ld      (TIMER_1),hl

            ld      hl,(FUEL)           ; Check to see if there is still fuel
            ld      bc,0
            sbc     hl,bc
            jr      nz,S7S_2

            ld      a,(TEMP_7_SEG)      ; ...and toggle between 000 and blank display
            cp      0
            jr      nz,S7S_5
            jp      SCAN_7_SEG

S7S_5:      ld      a,' '
            ld      c,6
            rst     10h
            ld      (TEMP_7_SEG),a
            ld      (TEMP_7_SEG + 1),a
            ld      (TEMP_7_SEG + 2),a

            jr      S7S_2

#ifdef SERIAL_OUT_EN
;---------------------------------------------------------------------
; Send the stats out the serial port
;
; Inputs:
;   HEIGHT  - Current height
;   TIME    - Turn number
;   FUEL    - Remaining fuel
;   VEL1    - Current velocity
;   THRTL   - Current throttle percentage
; Updates:
;   None
; Destroys:
;   A, BC, DE, HL
;---------------------------------------------------------------------
SER_STAT:   ld      c,20            ; Enable serial port
            rst     10h

            ld      hl,S_TIME_T
            call    SER_STR

            ld      a,(TIME)
            ld      h,0
            ld      l,a
            call    SER_HL2D
            ld      hl,S_TEMP_W
            call    SER_STR

            call    SER_CRLF

            ld      hl,HEIGHT_T
            call    SER_STR

            ld      hl,(HEIGHT)
            call    SER_HL2D
            ld      hl,S_TEMP_W
            call    SER_STR

            call    SER_CRLF

            ld      hl,FUEL_T
            call    SER_STR

            ld      hl,(FUEL)
            call    SER_HL2D
            ld      hl,S_TEMP_W
            call    SER_STR

            call    SER_CRLF

            ld      hl,VEL_T
            call    SER_STR

            ld      hl,(VEL1)
            bit     7,h             ; Check for negative falling velocity
            jr      z,SST_1
            ex      de,hl
            ld      hl,0
            sbc     hl,de

            jr      SST_2

SST_1:      ld      a,'-'
            ld      c,22
            rst     10h

SST_2:      call    SER_HL2D
            ld      hl,S_TEMP_W
            call    SER_STR

            call    SER_CRLF

            ld      hl,BURN_T
            call    SER_STR

            ld      a,(BURN)
            ld      h,0
            ld      l,a
            call    SER_HL2D
            ld      hl,S_TEMP_W
            call    SER_STR

            call    SER_CRLF

            ld      hl,THRTL_T
            call    SER_STR

            ld      a,(THRTL)
            ld      h,0
            ld      l,a
            call    SER_HL2D
            ld      hl,S_TEMP_W
            call    SER_STR

            call    SER_CRLF
            call    SER_CRLF

#ifdef DUMP_EN
            call    DUMP
#endif

            ld      c,21            ; Disable serial port
            rst     10h

            ret

#endif

;---------------------------------------------------------------------
; Display the lander stats on the LCD
;
; Inputs:
;   HEIGHT  - Current height
;   TIME    - Turn number
;   FUEL    - Remaining fuel
;   VEL1    - Current velocity
;   THRTL   - Current throttle percentage
; Updates:
;   None
; Destroys:
;   A, BC, DE, HL
;---------------------------------------------------------------------
STATS:      call    CLEAR_LCD       ; Clear the LCD

            ld      hl,HEIGHT_T     ; Display the height above the surface
            ld      c,13
            rst     10h

            ld      hl,(HEIGHT)
            call    HL_TO_LCD

            ld      hl,TIME_T       ; Display the current time sequence
            ld      c,13
            rst     10h

            ld      a,(TIME)
            ld      l,a
            call    L_TO_LCD

            ld      hl,VEL_T        ; Display the current velocity
            call    PRINT_R2

            ld      b,2             ; Set LCD row and column for velocity dir
            ld      c,12
            
            ld      hl,(VEL1)
            bit     7,h             ; Check for negative velocity
            jr      z,STATS_2
            ex      de,hl
            ld      hl,0
            sbc     hl,de
            ld      (TEMP_D),hl

            ld      hl,UP_T         ; Display the velocity direction
            call    PRINT_AT

            jr      STATS_3

STATS_2:    ld      (TEMP_D),hl

            ld      hl,DOWN_T       ; Display the velocity direction
            call    PRINT_AT

STATS_3:    ld      a,LCD_2 + 7     ; Move cursor to velocity pos. on LCD line 2
            ld      b,a
            ld      c,15
            rst     10h
            
            ld      hl,(TEMP_D)
            call    HL_TO_LCD

            ld      hl,THRTL_T      ; Display the prompt for the burn rate
            call    PRINT_R4
            
            ld      a,(THRTL)
            ld      l,a
            call    L_TO_LCD

            ret

            .end
