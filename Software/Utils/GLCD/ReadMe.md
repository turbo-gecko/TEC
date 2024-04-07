# GLCD Demo
This folder contains files for working with the graphics LCD TEC deck.

- glcd-test.asm is for displaying the bitmap Moon.xcf on the graphics LCD TEC deck.
- glcd.asm is the library code for converting the byte array representing the bitmap for display on the GLCD.
- glcd-test.hex is the compiled program ready for download to the TEC-1G
- moon_pixmap.asm is the auto-generated pixmap byte array. (See below)
- export-z80-glcd-pixmap.py is the plug-in to use with GIMP.

## How to convert a bitmap to a byte array.
I have relatively simple workflow to auto-produce the bitmap as an asm file which can be used in your programs.

I have installed GIMP, followed the instructions at [https://siliconlabs.my.site.com/.../creating-monochrome...](https://siliconlabs.my.site.com/community/s/article/creating-monochrome-bitmap-files-for-lcd-glib-using-gimp?language=en_US) and instead of using the filter at this web page, use the filter export-z80-glcd-pixmap.py which is included here. 

Make sure you do the change to monochrome palette, crop and resize to 128x64 pixels before you export. A sample bitmap called Moon.xcf is also available here to practice with.
