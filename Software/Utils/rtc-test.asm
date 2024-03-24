;---------------------------------------------------------------------
; RTC MON3 API Tester
;
; Tests the RTC API calls in MON3
;
; 24th March 2024
;---------------------------------------------------------------------

;---------------------------------------------------------------------
; Compiler directives
;---------------------------------------------------------------------
; Enables dumping of variables to the serial port
;#define     DUMP_EN

; Enables the use of the expansion RAM
;#define     EX_RAM_EN

;---------------------------------------------------------------------
; Constants
;---------------------------------------------------------------------

RTC_API_0   .equ    002Eh
RTC_API_1   .equ    012Eh
RTC_API_2   .equ    022Eh
RTC_API_3   .equ    032Eh
RTC_API_4   .equ    042Eh
RTC_API_5   .equ    052Eh
RTC_API_6   .equ    062Eh
RTC_API_7   .equ    072Eh
RTC_API_8   .equ    082Eh
RTC_API_9   .equ    092Eh
RTC_API_10  .equ    0A2Eh
RTC_API_11  .equ    0B2Eh
RTC_API_12  .equ    0C2Eh
RTC_API_13  .equ    0D2Eh
RTC_API_14  .equ    0E2Eh
RTC_API_15  .equ    0F2Eh
RTC_API_16  .equ    102Eh
RTC_API_17  .equ    112Eh
RTC_API_18  .equ    122Eh

C_KEY_DELAY .equ    6000h

;---------------------------------------------------------------------
; Data/Variables
;---------------------------------------------------------------------

#ifdef EX_RAM_EN
            .org    0B000h
#else
            .org    1000h
#endif

#include    "rtc-test-messages.asm"

;--------------------------------------
; VERSION must be the first variable after the messages for use with DUMP_EN
VERSION     .db     "0.01.01",0

BUFFER_D    .db     "--/--/----",0
BUFFER_T    .db     "--:--:-- xx",0

I_DATE_DM   .dw     0
I_DATE_YR   .dw     0
I_DAY       .db     0
I_DAY_STR   .db     "        ",0
I_T_MODE    .db     0
I_TIME_HM   .dw     0
I_TIME_S    .db     0

T_DESC      .dw     0
T_FAIL      .dw     0
T_NAME      .dw     0
T_NUMBER    .dw     0
T_PASS      .dw     0

TIMER_1     .dw     0

;--------------------------------------
; EOV marks the end of the variables and is used with DUMP_EN
EOV         .db     0ffh

;---------------------------------------------------------------------
; Main Program
;---------------------------------------------------------------------

            .org    4000h
#ifdef EX_RAM_EN
            jp      8000h
            .org    8000h
#endif

;--------------------------------------
; Startup

START:      call    CLEAR_LCD       ; Clear the LCD

            ld      c,20            ; Enable serial port
            rst     10h

INTRO:      call    SER_INTRO       ; Send serial intro message
            
            ld      hl,INTRO_1      ; Display the intro message to LCD
            call    PRINT_R1

;--------------------------------------
; Main

MAIN:       ld      bc,RTC_API_0    ; Check to see if the RTC module is present
            rst     10h
            
            jp      c,NO_RTC        ; RTC not found

            ld      hl,S_RTC_FOUND  ; Display the "RTC found" message
            call    SER_STR
            call    SER_CRLF

            call    SAVE_RTC        ; Save the RTC settings

            call    SER_DATE        ; Get date and send to serial port...

            ld      hl,BUFFER_T     ; ...and LCD
            call    PRINT_R2
            
            call    SER_DAY         ; Get the day of the week and send to serial port
            
            call    SER_TIME        ; Get time and send to serial port...
            
            ld      hl,BUFFER_T     ; ...and the LCD
            call    PRINT_R3
            
            call    SER_MODE        ; Get and display 12/24 hour mode to the serial port

            call    TEST_RUN        ; Perform the tests...
            
            jp      END
            
NO_RTC:     call    CLEAR_LCD       ; Clear the LCD
            ld      hl,RTC_N_FOUND  ; Display the "RTC not found" message
            call    PRINT_R1

            ld      hl,S_NO_RTC     ; Send message to serial port as well
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,S_LINE
            call    SER_STR
            call    SER_CRLF

;--------------------------------------
; The End!

END:        call    SER_CRLF
            
            ld      c,21            ; Disable serial port
            rst     10h
            
            call    PRESS_KEY       ; Wait for a key press

            rst     00h             ; All done!

;---------------------------------------------------------------------
; External modules/subroutines
;---------------------------------------------------------------------
#include    "lcd.asm"
#include    "serial.asm"

;---------------------------------------------------------------------
; Subroutines
;---------------------------------------------------------------------

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
DUMP:       ld      hl,VERSION      ; ** DEBUG ** Dump variables
            ld      de,EOV
            ld      c,28
            rst     10h

            ret
#endif

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
; Display press any key message and wait for a key press
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   BC
;---------------------------------------------------------------------
PRESS_KEY:  ld      a,LCD_4         ; Move cursor to LCD line 4...
            ld      b,a
            ld      c,15
            rst     10h

            ld      hl,ANY_KEY_P    ; ...and display the wait message
            ld      c,13
            rst     10h

            call    KEY_WAIT        ; Wait for a key press

            call    CLEAR_LCD       ; Clear the LCD

            ret

;---------------------------------------------------------------------
; Restores the current RTC settings. 
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   A, BC, DE, HL
;---------------------------------------------------------------------
REST_RTC:   ld      hl,S_RTC_REST
            call    SER_STR
            call    SER_CRLF

            ld      hl,(I_TIME_HM)
            ld      a,(I_TIME_S)
            ld      d,a

            ld      bc,RTC_API_3    ; Set the current time
            rst     10h

            ld      hl,(I_DATE_DM)
            ld      de,(I_DATE_YR)

            ld      bc,RTC_API_5    ; Set the current date
            rst     10h
            
            ld      a,(I_DAY)
            ld      d,a

            ld      bc,RTC_API_7    ; Set the current day
            rst     10h
 
            ret

;---------------------------------------------------------------------
; Saves the current RTC settings. 
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   A, BC, DE, HL
;---------------------------------------------------------------------
SAVE_RTC:   ld      hl,S_RTC_SAVE
            call    SER_STR
            call    SER_CRLF

            ld      bc,RTC_API_2    ; Get the current time
            rst     10h
            
            ld      (I_TIME_HM),hl  ; Save the time
            ld      a,d
            ld      (I_TIME_S),a

            ld      bc,RTC_API_4    ; Get the current date
            rst     10h
            
            ld      (I_DATE_DM),hl  ; Save the date
            ld      (I_DATE_YR),de

            ld      bc,RTC_API_6    ; Get the current day
            rst     10h
            
            ld      a,d             ; Save the day
            ld      (I_DAY),a

            ld      bc,RTC_API_8    ; Get the 12/24 hour mode
            rst     10h

            ld      (I_T_MODE),a    ; Save the 12/24 hour mode 
            ret

;---------------------------------------------------------------------
; Sends formatted date to the serial port
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   BC, HL, IY
;---------------------------------------------------------------------
SER_DATE:   ld      bc,RTC_API_4    ; Get the current date
            rst     10h
            
            ld      bc,RTC_API_17   ; Format the date
            ld      iy,BUFFER_T
            rst     10h
            
            ld      hl,S_I_DATE     ; Display the current date message
            call    SER_STR
                        
            ld      hl,BUFFER_T
            call    SER_STR
            call    SER_CRLF
            
            ret
            
;---------------------------------------------------------------------
; Sends formatted day to the serial port
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   D, HL
;---------------------------------------------------------------------
SER_DAY:    ld      hl,S_I_DAY      ; Display the current day message
            call    SER_STR
                        
            ld      bc,RTC_API_6    ; Get the current day
            rst     10h
            
            call    SER_STR
            call    SER_CRLF
            
            ret
            
;---------------------------------------------------------------------
; Display introduction messages to the serial port
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   C, HL
;---------------------------------------------------------------------
SER_INTRO:  call    SER_CRLF
            call    SER_CRLF

            ld      hl,S_HEADER
            call    SER_STR
           
            call    SER_CRLF

            ld      hl,S_INTRO_1
            call    SER_STR
           
            ld      hl,VERSION
            call    SER_STR
           
            call    SER_CRLF
            
            ret

;---------------------------------------------------------------------
; Display 12/24 hour mode to the serial port
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   A, BC, HL
;---------------------------------------------------------------------
SER_MODE:   ld      hl,S_I_MODE     ; Send 12/24 hour mode status to serial port
            call    SER_STR

            ld      bc,RTC_API_8    ; Get the 12/24 hour mode
            rst     10h
            
            jr      z,SM_1          ; 24 hour mode
            cp      80h
            jr      z,SM_2          ; 12 hour mode
            ld      hl,S_MODE_BAD   ; WTF mode
            jr      SM_3

SM_1:       ld      hl,S_MODE_24H
            jr      SM_3

SM_2:       ld      hl,S_MODE_12H
SM_3:       call    SER_STR
            call    SER_CRLF

            ret

;---------------------------------------------------------------------
; Sends formatted time to the serial port
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   BC, HL, IY
;---------------------------------------------------------------------
SER_TIME:   ld      bc,RTC_API_2    ; Get the current time
            rst     10h
            
            ld      bc,RTC_API_16   ; Format the time
            ld      iy,BUFFER_T
            rst     10h
            
            ld      hl,S_I_TIME     ; Display the current time message
            call    SER_STR
                        
            ld      hl,BUFFER_T
            call    SER_STR
            call    SER_CRLF
            
            ret

;---------------------------------------------------------------------
; Main routine from which the individual tests are called. 
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   C
;---------------------------------------------------------------------
TEST_RUN:   call    TEST_1
            call    TEST_2
            call    TEST_3            
            
            ld      hl,S_LINE       ; Send line break
            call    SER_STR
            call    SER_CRLF
            
            call    REST_RTC        ; Restore the saved RTC settings

            ret


;---------------------------------------------------------------------
; Main routine from which the individual tests are called. 
;
; Inputs:
;   None
; Updates:
;   None
; Destroys:
;   C
;---------------------------------------------------------------------
TEST_BEGIN: ld      hl,S_LINE       ; Send divider line to the serial port
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,TEST_NUMBER  ; Send test number to the serial port
            call    SER_STR
            
            ld      hl,(T_NUMBER)
            call    SER_HL2D           
            ld      hl,S_TEMP_W
            call    SER_STR
            call    SER_CRLF

            ld      hl,TEST_NAME    ; Send test name to the serial port
            call    SER_STR
            
            ld      hl,(T_NAME)
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,TEST_DESC    ; Send test description to the serial port
            call    SER_STR
            
            ld      hl,(T_DESC)
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,S_LINE_2     ; Send short line
            call    SER_STR
            call    SER_CRLF
            
            ret

;---------------------------------------------------------------------
; Test 1
;---------------------------------------------------------------------
TEST_1:     ld      hl,1            ; Send out test header info to serial port
            ld      (T_NUMBER),hl
            
            ld      hl,T1_NAME
            ld      (T_NAME),hl
            
            ld      hl,T1_DESC
            ld      (T_DESC),hl
            
            call    TEST_BEGIN
            
            call    SAVE_RTC
            
            ld      hl,T1_MSG_1     ; Send reset msg to the serial port
            call    SER_STR
            call    SER_CRLF

            ld      bc,RTC_API_1    ; Reset the RTC
            rst     10h

            call    SER_DATE        ; Get date and send to serial port
            call    SER_DAY         ; Get the day of the week and send to serial port
            call    SER_TIME        ; Get time and send to serial port
            call    SER_MODE        ; Get 12/24 hour mode and send to the serial port
           
            call    REST_RTC        ; Restore the saved RTC settings
            
            call    SER_DATE        ; Get date and send to serial port
            call    SER_DAY         ; Get the day of the week and send to serial port
            call    SER_TIME        ; Get time and send to serial port
            call    SER_MODE        ; Get 12/24 hour mode and send to the serial port
            
            ret

;---------------------------------------------------------------------
; Test 2
;---------------------------------------------------------------------
TEST_2:     ld      hl,2            ; Send out test header info to serial port
            ld      (T_NUMBER),hl
            
            ld      hl,T2_NAME
            ld      (T_NAME),hl
            
            ld      hl,T2_DESC
            ld      (T_DESC),hl
            
            call    TEST_BEGIN
 
            ld      hl,T2_MSG_1     ; Send 12 hour mode msg to the serial port
            call    SER_STR
            call    SER_CRLF
            
            ld      bc,RTC_API_9   ; Set the RTC to 12 hour mode
            rst     10h

            ld      hl,T2_MSG_2     ; Setting the time to 00:00:01 msg
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,0000h
            res     5,h             ; Reset bit 5 to indicate AM
            ld      d,01h

            ld      bc,RTC_API_3    ; Set the time
            rst     10h

            call    SER_TIME        ; Get time and send to serial port
            call    SER_MODE        ; Get 12/24 hour mode and send to the serial port

            ld      hl,T2_MSG_3     ; Setting the time to 11:59:59 msg
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,1159h
            res     5,h             ; Reset bit 5 to indicate AM
            ld      d,59h

            ld      bc,RTC_API_3    ; Set the time
            rst     10h

            call    SER_TIME        ; Get time and send to serial port
            call    SER_MODE        ; Get 12/24 hour mode and send to the serial port

            ld      hl,T2_MSG_4     ; Setting the time to 12:00:00 pm msg
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,1200h
            set     5,h             ; Set bit 5 to indicate PM
            ld      d,00h

            ld      bc,RTC_API_3    ; Set the time
            rst     10h

            call    SER_TIME        ; Get time and send to serial port
            call    SER_MODE        ; Get 12/24 hour mode and send to the serial port

            ld      hl,T2_MSG_5     ; Setting the time to 11:59:59 pm msg
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,2359h
            set     5,h             ; Set bit 5 to indicate PM
            ld      d,59h

            ld      bc,RTC_API_3    ; Set the time
            rst     10h

            call    SER_TIME        ; Get time and send to serial port
            call    SER_MODE        ; Get 12/24 hour mode and send to the serial port

            ret

;---------------------------------------------------------------------
; Test 3
;---------------------------------------------------------------------
TEST_3:     ld      hl,3            ; Send out test header info to serial port
            ld      (T_NUMBER),hl
            
            ld      hl,T3_NAME
            ld      (T_NAME),hl
            
            ld      hl,T3_DESC
            ld      (T_DESC),hl
            
            call    TEST_BEGIN
 
            ld      hl,T3_MSG_1     ; Send 24 hour mode msg to the serial port
            call    SER_STR
            call    SER_CRLF
            
            ld      bc,RTC_API_10   ; Set the RTC to 24 hour mode
            rst     10h

            ld      hl,T3_MSG_2     ; Setting the time to 00:00:01 msg
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,0000h
            ld      d,01h

            ld      bc,RTC_API_3    ; Set the time
            rst     10h

            call    SER_TIME        ; Get time and send to serial port
            call    SER_MODE        ; Get 12/24 hour mode and send to the serial port

            ld      hl,T3_MSG_3     ; Setting the time to 11:59:59 msg
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,1159h
            ld      d,59h

            ld      bc,RTC_API_3    ; Set the time
            rst     10h

            call    SER_TIME        ; Get time and send to serial port
            call    SER_MODE        ; Get 12/24 hour mode and send to the serial port

            ld      hl,T3_MSG_4     ; Setting the time to 12:00:00 msg
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,1200h
            ld      d,00h

            ld      bc,RTC_API_3    ; Set the time
            rst     10h

            call    SER_TIME        ; Get time and send to serial port
            call    SER_MODE        ; Get 12/24 hour mode and send to the serial port

            ld      hl,T3_MSG_5     ; Setting the time to 23:59:59 msg
            call    SER_STR
            call    SER_CRLF
            
            ld      hl,2359h
            ld      d,59h

            ld      bc,RTC_API_3    ; Set the time
            rst     10h

            call    SER_TIME        ; Get time and send to serial port
            call    SER_MODE        ; Get 12/24 hour mode and send to the serial port

            ret

;---------------------------------------------------------------------
            .end




