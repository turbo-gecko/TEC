# Serial port and hex loader for TEC-1G

I wanted to be able to use a hardware based serial port on the TEC-1G for speeding up the download of hex files when writing and testing software.
To do this, I used the following hardware:
- The adapter I designed for use with the TEC-1G (![see here](https://github.com/turbo-gecko/TEC/tree/main/Hardware/Z80%20to%20RC%20Bus%20Adapter))
- The [SC139 – Serial 68B50 Module (RC2014)](https://smallcomputercentral.com/sc139-serial-68b50-module-rc2014/) by Stephen Cousins at Small Computer Central

Photo of the hardware...

![Photo](https://github.com/turbo-gecko/TEC/blob/main/Software/Utils/hex-load/20240411_191709.jpg)

**acia.asm** is the device driver for the serial card. Note that the default port in the code is 0C8H. If you use a different port, AC_P_BASE will need to be changed accordingly.
There is also a loopback test program that can be enabled to test the board on it's own.
If the supplied 7.3728 MHz crystal is used as the clock for the SC-139, this will equate to 115,200 bps. I have used a 2.4576 MHz crystal on my SC-139 which equates to 38,400 bps which seems to be about the max for a <4 MHz Z80.
Either way, the driver supports RTS signalling for RTS/CTS hardware flow control.

**hex-load.asm** is a simple Intel hex file loader that can be used to transfer Intel hex files via the ACIA card to the TEC-1G. 
The hex-load.hex file is ready to be downloaded to the expansion RAM/ROM. As I have an FRAM fitted, the hex-load program is always available and I don't have to re-download it every time I power up the TEC-1G.
Go to address bd00H and run the program. On the serial terminal will be displayed...

    Intel hex file loader v1.1
    Send file when ready. Press <Esc> to quit.

From the serial terminal program, send a text file such as 'moon.hex' from the games folder and the download will be echoed to the terminal. 

    :18100000202020507265737320616E79206B65792020202000546872EC
    :181018006F74746C652030302D3939203F20002A2041626F72746564EF
    :18103000206C616E64696E6721202A002A2A2042756D7079206C616E64
    8< ---snip--- >8
    :00000001FF

When done, a 'Transfer complete' message will be display and the program will exit.

    Transfer complete.

Enjoy!
