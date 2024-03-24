#RTC MON3 API Tester

##Description
The rtc-test program exercises all of the RTC API calls in the MON3 ROM from v2014.02 onwards.

The API calls tested include...

|RTC Routine  |   #|  0x|Test|
|-------------|---:|---:|---:|
|checkDS1302  |   0|   0| Yes|
|resetDS1302  |   1|  01|
|getTime      |   2|  02| Yes|
|setTime      |   3|  03|
|getDate      |   4|  04| Yes|
|setDate      |   5|  05|
|getDay       |   6|  06| Yes|
|setDay       |   7|  07|
|get1224Mode  |   8|  08| Yes|
|set12HrMode  |   9|  09|
|set24HrMode  |  10|  0A|
|readRTCByte  |  11|  0B|
|writeRTCByte |  12|  0C|
|burstRTCRead |  13|  0D|
|BCDToBin     |  14|  0E|
|binToBCD     |  15|  0F|
|formatTime   |  16|  10| Yes|
|formatDate   |  17|  11| Yes|
|RTCSetup     |  18|  12|

The information from the testing is output to the serial port where it can be captured by a terminal application.

##The Tests
The following is what is output to the serial port on startup. If no RTC is found, the program will abort.

'========================================
MON3 RTC tester version 0.01.01
 - RTC found...
 - Current date : 24/03/2024
 - Current day  : Sunday
 - Current time : 21:56:16
 - Current mode : 12 hour (80H)
----------------------------------------'

The program checks for the presence of the RTC and if found, displays a current status of the RTC.
This implicitely tests the following API calls:
- #0 checkDS1302
- #2 getTime
- #4 getDate
- #6 getDay
- #8 get1224Mode

Whilst the program uses the format API calls #16 formatTime and #17 formatDate, it does not explicitly test them during the initialisation of the test run.

###Test 1 - RTC Reset
Uses resetDS1302 #1 API call to reset the DS1302 to a known state.
