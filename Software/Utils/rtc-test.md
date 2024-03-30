# RTC MON3 API Tester

NOTE: This is a work in progress. Not all APIs are in the test yet.

The test will modify the time on the RTC. Whilst it does save and restore the RTC settings, the clock will lose time (in seconds) comparable to how long the test takes to run.

## Description
The rtc-test program exercises all of the RTC API calls in the MON3 ROM from v2014.02 onwards.

The API calls tested include...

|RTC Routine  |   #|  0x|
|-------------|---:|---:|
|checkDS1302  |   0|   0|
|resetDS1302  |   1|  01|
|getTime      |   2|  02|
|setTime      |   3|  03|
|getDate      |   4|  04|
|setDate      |   5|  05|
|getDay       |   6|  06|
|setDay       |   7|  07|
|get1224Mode  |   8|  08|
|set12HrMode  |   9|  09|
|set24HrMode  |  10|  0A|
|readRTCByte  |  11|  0B|
|writeRTCByte |  12|  0C|
|burstRTCRead |  13|  0D|
|BCDToBin     |  14|  0E|
|binToBCD     |  15|  0F|
|formatTime   |  16|  10|
|formatDate   |  17|  11|
|RTCSetup     |  18|  12|

The information from the testing is output to the serial port where it can be captured by a terminal application.

## The Tests
If no RTC is found, the program will abort.

The program checks for the presence of the RTC and if found, displays a current status of the RTC.
This implicitely tests the following API calls:
- #0 checkDS1302
- #2 getTime
- #4 getDate
- #6 getDay
- #8 get1224Mode

Whilst the program uses the format API calls #16 formatTime and #17 formatDate, it does not explicitly test them during the initialisation of the test run.

### Test 1 - RTC Reset
Uses resetDS1302 #1 API call to reset the DS1302 to a known state.

### Test 2 - 12 hour mode test
Checks the update and output of the formatTime call #16 to check that the AM/PM is correctly displayed by setting the time of the RTC to various edge case times.

### Test 3 - 24 hour mode test
Checks the update and output of the formatTime call #16 to check that there is no AM/PM text and correctly displays the time by setting the time of the RTC to various edge case times.

