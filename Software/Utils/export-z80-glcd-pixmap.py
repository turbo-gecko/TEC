#!/usr/bin/env python
#
# A GIMP plugin to save the image in GLIB pixmap format
# The image must be "INDEXED" type (Image -> Mode -> Indexed... -> 1-bit
# The plugin creates both c and header files

from gimpfu import *
import os
from array import *

def export_glib_pixmap(img, layer, path, name):
    try:
        width = layer.width
        height = layer.height
        srcRgn = layer.get_pixel_rgn(0, 0, width, height, False, False)
        src_pixels = array("B", srcRgn[0:width, 0:height])

        c_file = open(path + "/" + name + ".asm","w")

        bytes = []
        byte = 0
	bit_cnt = 0
        for bit in src_pixels:
            byte = byte + (bit << bit_cnt)
            bit_cnt += 1
            if bit_cnt == 8:
                bit_cnt = 0
                bytes.append(int('{:08b}'.format(byte)[::-1], 2))
                byte = 0
        if bit_cnt != 0:
            bytes.append(byte)

        c_file.write("            .db  ")
        for cnt in range(len(bytes)):
            if cnt > 0:
                if cnt % 16:
                    c_file.write(", ");
                else:
                    c_file.write("\n            .db  ");
            c_file.write(str.format('{:03}', bytes[cnt], 16))
            
        c_file.write("\n")
        c_file.close()

    except Exception as err:
        gimp.message("Unexpected error: " + str(err))

register(
    "python_fu_export_z80_asm_pixmap",
    "Export z80 Aasm Pixmap",
    "Exports the image in z80 asm pixmap format",
    "sza2",
    "sza2",
    "2018",
    "<Image>/File/Export z80 asm Pixmap...",
    "INDEXED",
    [
#        (PF_IMAGE, "img", "Input image", None),
#        (PF_DRAWABLE, "drw", "Input drawable", None),
        (PF_DIRNAME, "path", "Output directory", os.getcwd()),
        (PF_STRING, "name", "Output name", "")
    ],
    [],
    export_glib_pixmap)

main()
