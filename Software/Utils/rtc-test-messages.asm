;--------------------------------------
; LCD messages

ABORT       .db     "Aborting the program"
ANY_KEY_P   .db     "   Press any key    ",0
INTRO_1     .db     "MON3 RTC API Tester ",0
RTC_DATE    .db     "Date - ",0
RTC_FOUND   .db     "RTC found",0
RTC_N_FOUND .db     "RTC not found",0
RTC_TIME    .db     "Time - ",0

;--------------------------------------
; Serial port messages

S_HEADER    .db     "========================================",0
S_I_DATE    .db     "Date : ",0
S_I_DAY     .db     "Day  : ",0
S_I_MODE    .db     "Mode : ",0
S_I_TIME    .db     "Time : ",0
S_INTRO_1   .db     "MON3 RTC tester version ",0
S_LINE      .db     "----------------------------------------",0
S_LINE_2    .db     "--------------------",0
S_MODE_12H  .db     "12 hour (80H)",0
S_MODE_24H  .db     "24 hour (00H)",0
S_MODE_BAD  .db     "undefined ",0
S_NO_RTC    .db     "No RTC found! Aborting test.",0
S_READY     .db     "Ready to start testing. Press a key to continue",0
S_RTC_FOUND .db     "RTC found",0
S_RTC_REST  .db     "Restoring RTC settings...",0
S_RTC_SAVE  .db     "Saving RTC settings...",0

;--------------------------------------
; Test case messages

TEST_DESC   .db     "Description : ",0
TEST_NAME   .db     "Name        : ",0
TEST_NUMBER .db     "Test Number : ",0

T1_NAME     .db     "RTC Reset",0
T1_DESC     .db     "Uses resetDS1302 #1 API call to reset the DS1302 to a known state",0
T1_MSG_1    .db     "* Resetting the RTC using resetDS1302 #1 API call...",0

T2_NAME     .db     "12 hour mode check",0
T2_DESC     .db     "Checks the 12 hour mode for different times",0
T2_MSG_1    .db     "* Setting 12 hour mode...",0
T2_MSG_2    .db     "* Setting the time to 00:00:01 am",0
T2_MSG_3    .db     "* Setting the time to 11:59:59 am",0
T2_MSG_4    .db     "* Setting the time to 12:00:00 pm",0
T2_MSG_5    .db     "* Setting the time to 11:59:59 pm",0

T3_NAME     .db     "24 hour mode check",0
T3_DESC     .db     "Checks the 24 hour mode for different times",0
T3_MSG_1    .db     "* Setting 24 hour mode...",0
T3_MSG_2    .db     "* Setting the time to 00:00:01",0
T3_MSG_3    .db     "* Setting the time to 11:59:59",0
T3_MSG_4    .db     "* Setting the time to 12:00:00",0
T3_MSG_5    .db     "* Setting the time to 23:59:59",0

