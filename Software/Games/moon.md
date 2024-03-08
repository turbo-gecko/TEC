# Moon #

![Lunar Lander](Moon.jpg)

The poeple of Biddlelonia are about to make their first landing on their moon with their second lander. It has been a fully automated trip so far, but for the final descent you have to manually adjust the main engine throttle for a smooth touchdown!

The throttle is adjustable from fully closed 00% to wide open 99%. Why not 100%? Well there was a problem when testing the first lander where the turbo encabultor went into uncontrolled oscillations resulting in excessive magnetic reductance that led to a rapid unscheduled disassembly of the lunar lander! To prevent such a disaster from happening a second time, the throttle is controlled by the lunar lander computer to only accept throttle values between 00% and 99%.

Keep an eye on your height, velocity and fuel levels. These are displayed on your main computer screen.
Your current fuel level and throttle position is indicated on the computers seven segment read-outs.
Try to have your throttle position just above the lunar surface at such a point that you settle on the surface with no downward velocity. The lander can sustain landing with a small amount of downward velocity that will result in a bumpy landing. Too much however, and it's 'game over man!'

## Source files ##
  - moon.asm - Main program
  - lcd.asm - LCD routines
  - serial.asm - Serial routines
  - moon.hex - Binary ready for downloading the the TEC-1G for those that don't want to compile the code.

The program has been tested with TASM 3.2 using the command line 
`tasm -80 -g0 moon.asm moon.hex`

Near the top of moon.asm, there are 2 #defines. SERIAL_OUT_EN enables the stats to be sent out the serial port. You can capture a game this way. DUMP_EN is for debugging and is rarely, if ever, used.

The main starting parameters are listed as constants that can be adjusted to change the games initial state.

## To Do ##
  - Display 'how to play' instructions.
  - Add sound effects.
  - Add fuel level bar graph
  - Add bar graphs on the LCD for height and velocity.
  - Graphical shenanigans on the graphical LCD.

## Notes ##
This is very much a 'work in progress' and will have bugs!

I have not done Z80 assembler coding for nearly 30 years so I am essentially starting from scratch again. Seasoned Z80 ASM coders will undoubtedly find a bunch of issues and inefficiencies and thats OK. This is a simple game and my intent is to learn as much about the TEC-1G's capabilities and to demonstrate what it can do in a single program.

The game is for me a learning exercise. I hope others get to learn from it as well and take whatever they may find useful to incorporate into their own projects.

Enjoy!
