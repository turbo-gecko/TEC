; ----------------------------------------------------------------------------
; sd_app.asm
; Version: (See sd_data.asm swVerMsg)
; Last updated: 28/04/2024
;
; App for working with the TEC-FS file system
;
; Requires MON3 v1.4 or later
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; INCLUDE data for this app
; ----------------------------------------------------------------------------
#include "sd_data.asm"

	.org 04000h		; Start of code in RAM

	call spiInit

	ld c,_menuDriver
	ld hl,mainMenuCfg
	rst 10h

	ret			; To MON3 if exit....

; ----------------------------------------------------------------------------
; INCLUDE libraries
; ----------------------------------------------------------------------------

#include "sd_api.asm"
#include "lcd.asm"
#include "mon3_includes.asm"

; ============================================================================
; Menu routines
; ============================================================================

; ----------------------------------------------------------------------------
; Menu item 1 - SD Card Info
;		Displays TEC-FS SD card information
; ----------------------------------------------------------------------------
sdCardInfo:
	call clearLCD		; Clear the LCD
	call sdInit		; Initialise the SD card
	jp c,noCard		; No card detected

	call validateFormat
	ret c

	ld hl,cidPNMMsg		; Show card name message
	call printR1

	call getPNM		; Show card name
	ld b,1			; Set up row/colum position
	ld c,6
	call printAt

	ld hl,cardCapacity	; Show maximum files message
	call printR2

	call getMaxFiles	; Get the maximum number of files that
				; will fit on the SD card.
	ld l,a
	ld h,0
	ld ix,decimalBuff
	call decimal
	xor a			; Null terminate result
	ld (ix),a	
	ld hl,decimalBuff	; Display the max files
	call lcdStr

	ld hl,formatDateMsg	; Display date the card was formatted
	call printR3

	ld b,LCD_ROW4		; Row 4
	ld c,_commandToLCD
	rst 10h

	ld iy,sdBuff+FCB_RTC	; Output formatted timestamp
	call showTimeStamp

	ld c,_scanKeysWait
	rst 10h

	ret

; ----------------------------------------------------------------------------
; Menu item 2 - List Files
;		Lists the files on the SD card and displays file information
; ----------------------------------------------------------------------------
fileListLcd:
	ld hl,selectMsg		; setup correct message
	ld (selectMsgPtr),hl
	call selectSlot
	ret

; ----------------------------------------------------------------------------
; Menu item 3 - Load File
;		Loads a file from the SD card into memory
; ----------------------------------------------------------------------------
readFile:
	call sdInit			; Initialise the SD card
	jp c,noCard			; No card detected
	
	;call sdInitUpdate
	call validateFormat		; SD present and formatted?
	ret c

	ld hl,setLoadSlot		; setup correct message
	ld (selectMsgPtr),hl

	call selectSlot
	cp 0ffh				; exit?
	ret z

	ld (fcbOffset),a
	call calcOffset			; sets up IY register

	ld l,(iy+FCB_START_ADDR)	; TEC start in memory, FFFF = no file
	ld h,(iy+FCB_START_ADDR+1)	; TEC start in memory, FFFF = no file

	ld de,0ffffh			; 16-bit CP
	or a
	sbc hl,de
	add hl,de
	jr nz,fValid

	ld b,01				; error if selecting empty slot
	ld hl,noFileMsg
	call msgPause
	ret

fValid:	ld (transferStart),hl
	ld (transferPos),hl

	ld l,(iy+FCB_LENGTH)		; TEC memory length
	ld h,(iy+FCB_LENGTH+1)		; TEC memory length
	ld (transferLength),hl

	ld l,(iy+FCB_START_SECT+2)	; start sector
	ld h,(iy+FCB_START_SECT+3)	; start sector
	ld (currSector),hl

	ld l,(iy+FCB_SECT_COUNT)	; now many sectors to load
	ld h,(iy+FCB_SECT_COUNT+1)	; now many sectors to load
	ld (numSectors),hl

	ld hl,loadingMsg
	call transferStatus

; prep done, now load

blockFromSD:
	call readSdSector		; get block

	ld bc,512
	ld hl,(transferLength)
	or a
	sbc hl,bc
	add hl,bc
	jr nc,mBlk
	ld b,h
	ld c,l

mBlk:	ld de,(transferPos)		; copy to TEC memory
	ld hl,sdBuff
	ldir

	ld hl,(numSectors)
	dec hl
	ld (numSectors),hl

	ld a,h				; 0 left to go?
	or l
	jr z,loadDone

	ld hl,(currSector)		; next sector
	inc hl
	ld (currSector),hl

	ld hl,(transferLength)		; decrease count by length
	ld bc,512
	or a
	sbc hl,bc
	ld (transferLength),hl	; if there's a block theres a transfer....

	ld hl,(transferPos)		; next TEC memory location
	ld bc,512
	add hl,bc
	ld (transferPos),hl

	jr blockFromSD

loadDone:
	call spiInit

	ld b,LCD_ROW4			; row 4
	ld hl,loadOkMsg
	call msgPause
	ret

; ----------------------------------------------------------------------------
; Menu item 4 - Save File
;		Saves a block of memory to the SD card
; ----------------------------------------------------------------------------
writeFile:
	call sdInit			; Initialise the SD card
	jp c,noCard			; No card detected
	
	;call sdInitUpdate
	call validateFormat		; SD present and formatted?
	ret c

	ld hl,4000h			; default save parameters
	ld (transferStart),hl
	ld hl,7fffh
	ld (transferEnd),hl

saveP:	ld hl,setSaveParams		; allow user to edit parameters
	ld c,_paramDriver
	rst 10h

	ld hl,(transferEnd)		; validate parameters
	ld bc,(transferStart)
	or a				; 16-bit CP
	sbc hl,bc
	add hl,bc
	jp z,nogood			; retry if equal
	jp c,nogood			; retry if end<start

	sbc hl,bc			; fix up subtraction
	inc hl				; +1; start address itself counts
	ld (transferLength),hl		; parameters set

	ld hl,setSaveSlot		; setup correct message
	ld (selectMsgPtr),hl

	call selectSlot
	cp 0ffh				; exit?
	ret z

	ld (fcbOffset),a
	ld hl,(currSector)
	ld (fcbToUpdate),hl		; where FCB's go, later

; calculate correct currSector for write

	ld hl,0000h
	ld a,(currSector)		; selected by selectSlot
	ld b,a				; HL * 128 = page

	sub 64
	cp 0
	jr z,fixAADone
	ld de,1024

fixAA:	add hl,de
	djnz fixAA

fixAADone:
	ld a,(fcbOffset)		; calculate offset
	ld b,a
	cp 0
	jr z,fixADone
	ld de,128

fixA:	add hl,de
	djnz fixA

fixADone:
	ld de,128			; add final offset
	add hl,de

	ld (currSector),hl
	ld (startSector),hl

	ld hl,(transferStart)		; transfer default into working area
	ld (transferPos),hl

	ld hl,0
	ld (numSectors),hl

	ld hl,savingMsg			; display filename etc.
	call transferStatus

blockToSD:
	ld bc,512
	ld hl,(transferLength)
	or a
	sbc hl,bc
	add hl,bc
	jr nc,mBlk2
	ld b,h
	ld c,l

mBlk2:	ld de,sdBuff			; RAM > Buff
	ld hl,(transferPos)
	ldir

; prep done, now save
	call writeSdSector

; next sector calculations
	ld hl,(numSectors)		; count how many written
	inc hl
	ld (numSectors),hl

	ld hl,(transferLength)		; decrease count by length
	ld bc,512
	or a
	sbc hl,bc

	jr z,writeDone			; 0 bytes left
	jp m,writeDone			; we went negative, so done

	ld (transferLength),hl		; size of next block

nextblock:
	ld hl,currSector		; next sector
	inc (hl)
;	ld (currSector),hl

	ld hl,(transferPos)		; next RAM block
	ld bc,512
	add hl,bc
	ld (transferPos),hl
	jr blockToSD

writeDone:
	ld hl,(fcbToUpdate)		; get correct sector
	ld (currSector),hl
	call readSdSector

	call calcOffset

	ld hl,(transferStart)		; update start
	ld (iy+FCB_START_ADDR),l
	ld (iy+FCB_START_ADDR+1),h

	ld hl,(transferEnd)
	ld bc,(transferStart)
	or a
	sbc hl,bc
	inc hl				; +1 for start byte
	ld (iy+FCB_LENGTH),l		; update length
	ld (iy+FCB_LENGTH+1),h		; update length

	xor a				; not expand
	ld (iy+FCB_EXPAND),a

	ld hl,0
	ld (iy+FCB_START_SECT),l	; update start sector MSW
	ld (iy+FCB_START_SECT+1),h	; update start sector MSW
	ld hl,(startSector)
	ld (iy+FCB_START_SECT+2),l	; update start sector LSW
	ld (iy+FCB_START_SECT+3),h	; update start sector LSW

	ld hl,(numSectors)
	ld (iy+FCB_SECT_COUNT),l	; update number of sectors
	ld (iy+FCB_SECT_COUNT+1),h	; update number of sectors

	push iy				; put in the timestamp if RTC exists
	ld iy,sdBuff+FCB_RTC		; output format timestamp
	call addTimeStamp
	pop iy

	call writeSdSector		; save change
	call spiInit

	ld b,LCD_ROW4
	ld hl,saveOkMsg
	call msgPause
	ret

; ----------------------------------------------------------------------------
; Menu item 5 - Format SD Card
;		Formats the SD Card with TEC-FS
; ----------------------------------------------------------------------------
formatSD:
	call 	clearLCD			; Clear the LCD
	ld hl,FormatMsg
	call lcdStr

	call 	sdInit			; Initialise the SD card
	jp	c,noCard		; No card detected

	;call sdInitUpdate

; prep MBR
	ld hl,sdBuff			; zero out buffer
	ld de,sdBuff+1
	ld bc,511
	xor a
	ld (hl),a
	ldir
	ld hl,sdFormat			; copy format into buffer
	ld de,sdBuff
	ld bc,sdFormatLen
	ldir
	ld a,55h			; write partition signature
	ld (sdBuff+510),a
	ld a,0aah
	ld (sdBuff+511),a

	ld iy,sdBuff+FCB_RTC		; output format timestamp
	call addTimeStamp

	ld hl,0				; Write MBR sector
	ld (currSector),hl
	call writeSdSector

; now prep FCB file tables

	ld hl,sdBuff			; zero out buffer
	ld de,sdBuff+1
	ld bc,511
	xor a
	ld (hl),a
	ldir

; 8 blocks
	ld de,sdBuff
	ld b,8				; 64b * 8 = 512b

fillBuffFcb:
	push bc

	ld hl,fcbFormat			; copy format into buffer
	ld bc,fcbFormatLen
	ldir

	ld hl,fcbFormatSpc		; skip over empty bytes
	add hl,de
	ex de,hl

	pop bc
	djnz fillBuffFcb

	ld hl,0				; set first file number
	ld (byteBuff),hl
	ld hl,64			; set first sector number
	ld (currSector),hl

; now write that out to the card 16 times (16*8 = 128 files max)

fcbLp:
	call fnStamp			; tweak the filenames
	call writeSdSector

	ld hl,(currSector)
	inc hl
	ld (currSector),hl

	ld a,l				; find when at last sector
	cp 64+16+1
	jr nz,fcbLp

	call spiInit

	ld b,LCD_ROW2			; row 2
	ld hl,formatOkStr
	call msgPause
	ret

; ----------------------------------------------------------------------------
; Menu item 6 - HW Info
;		Reads the SD cards CID register and displays the cards
;		identification information
; ----------------------------------------------------------------------------
hwInfo:	call clearLCD		; Clear the LCD
	call sdInit		; Initialise the SD card
	call getCID		; get the SD card hw info
	jp nz,sdError
	
	ld (cidBufferPtr),hl
	
	ld hl,cidMIDMsg		; Display Manufacturer ID
	ld c,_stringToLCD
	rst 10h
	
	ld ix,(cidBufferPtr)
	ld a,(ix)
	ld de,byteStr
	ld c,_AToString
	rst 10h
	
	ld hl,byteStr
	ld c,_stringToLCD
	rst 10h
	
	ld hl,cidOIDMsg		; Display OEM ID
	ld c,_stringToLCD
	rst 10h
		
	ld ix,(cidBufferPtr)
	ld h,(ix+1)
	ld l,(ix+2)
	ld de,wordStr
	ld c,_HLToString
	rst 10h
	
	ld hl,wordStr
	ld c,_stringToLCD
	rst 10h
	
	ld hl,cidPNMMsg		; Display part name
	call printR2
	
	ld b,5			; PNM - Product name (see SD card Spec)
	ld ix,(cidBufferPtr)
hwPNM:
	ld a,(ix+3)
	push ix
	ld c,_charToLCD
	rst 10h
	pop ix
	inc ix
	djnz hwPNM

	ld hl,cidPRVMsg		; Display Part revision number
	ld c,_stringToLCD
	rst 10h
	
	ld ix,(cidBufferPtr)
	ld a,(ix+8)
	and 0f0h
	rr	a
	rr	a
	rr	a
	rr	a
	ld de,byteStr
	ld c,_AToString
	rst 10h

	ld c,_charToLCD
	rst 10h

	ld a,'.'
	ld c,_charToLCD
	rst 10h

	ld ix,(cidBufferPtr)
	ld a,(ix+8)
	and 0fh
	ld de,byteStr
	ld c,_AToString
	rst 10h

	ld c,_charToLCD
	rst 10h

	ld hl,cidPSNMsg		; Display Part serial number
	call printR3
	
	ld ix,(cidBufferPtr)
	ld h,(ix+9)
	ld l,(ix+10)
	ld de,wordStr
	ld c,_HLToString
	rst 10h
	
	ld hl,wordStr
	ld c,_stringToLCD
	rst 10h
	
	ld ix,(cidBufferPtr)
	ld h,(ix+11)
	ld l,(ix+12)
	ld de,wordStr
	ld c,_HLToString
	rst 10h
	
	ld hl,wordStr
	ld c,_stringToLCD
	rst 10h

	ld hl,cidMDTMsg		; Display manufacturing date
	call printR4

	ld ix,(cidBufferPtr)
	ld h,(ix+13)
	ld l,(ix+14)
	ld a,l
	and 0fh
	cp 0ah
	jr c,hwMDT
	add a,06h
hwMDT:	
	ld de,byteStr
	ld c,_AToString
	rst 10h
	
	ld hl,byteStr
	ld c,_stringToLCD
	rst 10h

	ld a,'/'
	ld c,_charToLCD
	rst 10h
	
	ld ix,(cidBufferPtr)
	ld h,(ix+13)
	ld l,(ix+14)
	rl h
	rl h
	rl h
	rl h
	ld a,h
	and 0f0h
	ld b,a
	rr l
	rr l
	rr l
	rr l
	ld a,l
	and 0fh
	add a,b

	ld hl,2000
	ld b,0
	ld c,a
	add hl,bc
	
	ld ix,decWordStr
	call decimal
	
	ld hl,decWordStr
	ld c,_stringToLCD
	rst 10h

	ld hl,noMsg
	call msgPause
	
	ret

; ----------------------------------------------------------------------------
; Menu item 7 - SW Info
; 		Displays software version information
; ----------------------------------------------------------------------------
swInfo:
	call clearLCD		; Clear the LCD
	ld hl,swVerMsg
	call lcdStr
	
	ld b,LCD_ROW2		; Line 2
	ld c,_commandToLCD
	rst 10h

	ld hl,swInfoMsg
	call msgPause
	
	ret
	
; ============================================================================
; App function calls
; ============================================================================
sdInitUpdate:
	call getCardType	; bail if wrong card type
	jp c,sdError
	cp 0c0h
	ret nz

	call getPNM		; Get the part number string (pointer in HL)
	jp nz,sdError

	call clearLCD		; Clear the LCD
	call printR1		; and display the part number

	ld b,LCD_ROW2
	ld c,_commandToLCD
	rst 10h
	ld hl,cardTypeStr
	call lcdStr

;	ld a,(sdBuff)
	call getCardType
;	and 0c0h
	rlca
	rlca
;	inc a
	dec a
	call showByte
	push af

	ld hl,sdhcCardMsg
	call getCardType
	cp 80h
	jr nz,sdSize
	ld hl,sdscCardMsg

sdSize:	call lcdStr
	pop af
	cp 1			; type 2
	jr z,notType2

; ----- decode type 2

; type 2 not decoding top 6 bits - will get large cards wrong.

	ld a,(sdBuff+8)		; get size bytes
	ld h,a
	ld a,(sdBuff+9)
	ld l,a

	inc hl			; calc is c_size + 1
	srl h
	rr l

	ld ix,decimalBuff
	call decimal
	xor a			; null terminate result
	ld (ix),a

	ld b,LCD_ROW3
	ld c,_commandToLCD
	rst 10h

	ld hl,decimalBuff
	call lcdStr
	ld hl,megaBytes
	call lcdStr
	
	ld c,_scanKeysWait
	rst 10h

	ret
	
notType2:
	ld hl,sdNoType1Msg
	call lcdStr
	
	ld c,_scanKeysWait
	rst 10h
	
	ret c

; ----------------------------------------------------------------------------
fnStamp:
	push bc
	push de

	ld de,sdBuff+0bh
	ld b,8
	
nfLoop:	ld hl,(byteBuff)
	ld c,_HLToString
	rst 10h

	inc hl
	ld (byteBuff),hl

	ld hl,64-4
	add hl,de
	ex de,hl

	djnz nfLoop

	pop de
	pop bc
	ret

; ----------------------------------------------------------------------------
; returns
; combination of A (selected item) + currSector = required FCB entry
; A=FFh = Cancel
; ----------------------------------------------------------------------------
selectSlot:
	call 	clearLCD			; Clear the LCD
	call 	sdInit			; Initialise the SD card
	jp	c,noCard		; No card detected
	
	;call sdInitUpdate
	call validateFormat
	ret c				; bail if bad SD

	ld hl,64			; get first FCB into buffer
	ld (currSector),hl

updateSect:
	call readSdSector
	call spiInit

	xor a
	ld (menuPos),a			; menu draw from first slot
	ld (menuSel),a			; menu selected first item

mLoop:	call 	clearLCD			; Clear the LCD
	ld hl,(selectMsgPtr)
	call lcdStr

	ld b,LCD_ROW1+18
	ld c,_commandToLCD
	rst 10h

	ld a,(currSector)		; page update
	sub 63

	ld h,0
	ld l,a
	ld ix,decimalBuff
	call decimal
	xor a				; null terminate result
	ld (ix),a

	ld hl,decimalBuff
	call lcdStr

	call drawMenu
	ld c,_scanKeysWait
	rst 10h
	
	cp 0
	jr z,fileDetails

	cp 2
	jr z,isMinusSect

	cp 3
	jr z,isPlusSect

	cp 13h				; addr
	jr nz,notGo

	ld a,0ffh			; exit flag
	ret

notGo:	cp 10h
	call z,isPlus

	cp 11h
	call z,isMinus

	cp 12h
	jr nz, mLoop
	ld a,(menuSel)			; set value chosen
	ret

isPlusSect:
	ld hl,(currSector)
	inc hl
	ld a,l
	cp 80
	jr z,mLoop
	ld (currSector),hl
	jr updateSect

isMinusSect:
	ld hl,(currSector)
	dec hl
	ld a,l
	cp 63
	jr z,mLoop
	ld (currSector),hl
	jr updateSect

isPlus:
	ld a,MENU_LEN
	ld b,a
	ld a,(menuSel)
	cp b				; at max already ?
	ret z				; if max, bail
	inc a				; otherwise update
	ld (menuSel),a			; save new selection
	ld c,a				; copy A to C
	ld a,(menuPos)			; get menu display position
	add a,03			; for coming up CP
	ld b,a				; b = menu pos
	ld a,c				; a = menu sel
	cp b				; if (b+3)>a then no change
	ret c				; return if >
	ld a,(menuPos)			; update menuPos
	inc a
	ld (menuPos),a
	xor a
	ret

isMinus:
	ld a,(menuSel)			; get current
	dec a				; decrease by 1
	ret m				; if result <0, exit as we aready at top
	ld (menuSel),a			; save new position
	ld c,a				; store new pos in c
	ld a,(menuPos)			; do we need to scroll the list?
	ld b,a				; b = menu pos
	ld a,c				; a = sel pos
	cp b				; compare
	ret nc				; no action if in range
	ld (menuPos),a			; otherwise update menu pos
	xor a
	ret

; ----------------------------------------------------------------------------
; display a file's details - timstamp, memory block, SD sectors etc.
; ----------------------------------------------------------------------------
fileDetails:
	call 	clearLCD			; Clear the LCD

	ld a,(menuSel)
	call showFilename
	jp c,waitKey			; no more if (no file)

	ld b,LCD_ROW2			; Line 2
	ld c,_commandToLCD
	rst 10h
	ld hl,startAddr
	call lcdStr


	ld a,(menuSel)
	ld (fcbOffset),a
	call calcOffset			; sets up IY

	ld l,(iy+FCB_START_ADDR)		; start
	ld h,(iy+FCB_START_ADDR+1)
	call HLtoLCD

	ld hl,lenAddrMsg
	call lcdStr

	ld l,(iy+FCB_LENGTH)		; length
	ld h,(iy+FCB_LENGTH+1)
	call HLtoLCD

	ld b,LCD_ROW3			; Line 3
	ld c,_commandToLCD
	rst 10h
	ld hl,startSecMsg
	call lcdStr

	ld l,(iy+FCB_START_SECT+2)	; start sector
	ld h,(iy+FCB_START_SECT+3)	; start sector
	call HLtoLCD

	ld hl,lenAddrMsg
	call lcdStr

	ld l,(iy+FCB_SECT_COUNT)	; now many sectors to load
	ld h,(iy+FCB_SECT_COUNT+1)	; now many sectors to load
	call HLtoLCD


	ld b,LCD_ROW4			; Line 4
	ld c,_commandToLCD
	rst 10h

	push iy
	ld iy,sdBuff+FCB_RTC			; output format timestamp
	call showTimeStamp
	pop iy
 
waitKey:
	ld c,_scanKeysWait
	rst 10h
	cp 13h
	jp z, updateSect	; exit details screen
	jr waitKey

; ----------------------------------------------------------------------------
drawMenu:
	ld e,MENU_LEN
	inc e

	ld b,LCD_ROW2+1
	ld c,_commandToLCD
	rst 10h
	ld a,(menuPos)
	call showFilename

	ld b,LCD_ROW3+1
	rst 10h
	inc a
	call showFilename

	ld b,LCD_ROW4+1
	rst 10h
	inc a
	call showFilename

; position pointer

putPtr:	ld a,(menuPos)
	ld b,a
	ld a,(menuSel)
	sub b

	ld b,LCD_ROW4

; a = 0 , 1 or 2. Which row to put pointer ?
	jr nz,try3
	ld b,LCD_ROW2
	jr drawPointer

try3:	dec a
	jr nz,drawPointer
	ld b,LCD_ROW3

drawPointer:
	ld c,_commandToLCD
	rst 10h
	ld a,0a5h			; pointer ASCII code (square block)
	ld c,_charToLCD
	rst 10h
	ret

; -----------------------------------------------------
; showFilename
;  call:
; A: location in menu required
; -----------------------------------------------------
showFilename:
	push af
	push bc
	push de

	ld (fcbOffset),a
	call calcOffset

	ld l,(iy+FCB_START_ADDR)
	ld h,(iy+FCB_START_ADDR+1)

	ld de,0ffffh			; 16-bit CP
	or a
	sbc hl,de
	add hl,de
	jr z,fnFound

	push iy
	pop hl
	call lcdStr
	or a				; clear carry flag, file found

sfExit:	pop de
	pop bc
	pop af
	ret

fnFound:
	ld a,(fcbOffset)
	ld c,a
	ld a,(currSector)
	sub 64
	sla a				; a*8
	sla a
	sla a
	add a,c				; a + offset
	call showByte			; shows empty slot number
; -----
	ld HL,noFileMsg
	call lcdStr
	scf				; set carry-, file not found
	jr sfExit

nogood:	ld b,01h
	ld hl,badParamMsg
	call msgPause
	jp saveP

; ----------------------------------------------------------------------------
; Fetch timestamp from RTC and add, if present. Otherwise don't change
; anything
; IY = base pointer to 7 byte timestamp block
; ----------------------------------------------------------------------------
addTimeStamp:
	ld b,checkDS1302Present
	ld c,_RTCAPI
	rst 10h
	ret c				; exit if no RTC

	ld b,getDay
	ld c,_RTCAPI
	rst 10h
	ld (iy+OFS_DAY),d

	ld b,getDate
	ld c,_RTCAPI
	rst 10h
	ld (iy+OFS_DATE),h
	ld (iy+OFS_MONTH),l
	ld (iy+OFS_YEAR),e

	ld b,get1224Mode
	ld c,_RTCAPI
	rst 10h
	push af				; save RTC mode

	ld b,set24HrMode		; set RTC mode required
	ld c,_RTCAPI
	rst 10h

	ld b,getTime			; files are 24-hour stamped
	ld c,_RTCAPI
	rst 10h
	ld (iy+OFS_HOUR),h
	ld (iy+OFS_MINUTE),l
	ld (iy),d

	pop af				; restore RTC mode
	cp 80h
	jr nz,timeStampDone
	ld b,set12HrMode		; only needed if it was 12hr originally
	ld c,_RTCAPI
	rst 10h

timeStampDone:
	ret

; ----------------------------------------------------------------------------
; Fetch timestamp from buffer and output to LCD
; IY = base pointer to 7 byte timestamp block
; ----------------------------------------------------------------------------
showTimeStamp:
	ld b,formatTime			; inputs for the formatTime API
	ld c,_RTCAPI
	ld h,(iy+OFS_HOUR)
	ld l,(iy+OFS_MINUTE)
	ld d,(iy+OFS_SECOND)
	
	push iy
	ld iy,dtBuff
	rst 10h
	pop iy
	
	ld hl,dtBuff
	call lcdStr

	ld a,20h			; space
	ld c,_charToLCD
	rst 10h

	ld h,(iy+OFS_DATE)
	ld l,(iy+OFS_MONTH)
	ld e,(iy+OFS_YEAR)
	ld d,20h
	
	push iy
	ld iy,dtBuff
	ld b,formatDate			; date
	ld c,_RTCAPI
	rst 10h
	pop iy
	
	ld hl,dtBuff
	call lcdStr
	
	ret

; ----------------------------------------------------------------------------
; IY = pointer into sdBuff of current file's FCB entry
;
; requires fcbOffset to be calculated prior
; ----------------------------------------------------------------------------
calcOffset:
	push af
	push bc
	push de

	ld a,(fcbOffset)
	ld iy,sdBuff
	cp 0
	jr z,cFil
	ld b,a
	ld de,64

cOffset:
	add iy,de
	djnz cOffset

cFil:	pop de
	pop bc
	pop af
	ret

; ----------------------------------------------------------------------------
; Show transfer message & status
; HL = load/save message pointer
; ----------------------------------------------------------------------------
transferStatus:
	call 	clearLCD			; Clear the LCD
	call lcdStr			; load/save message

	ld b,LCD_ROW2			; Line 2
	ld c,_commandToLCD
	rst 10h

	call calcOffset			; get correct filename pointer
	push iy
	pop hl
	call lcdStr

	ld b,LCD_ROW3			; Line 3
	ld c,_commandToLCD
	rst 10h

	ld hl,(transferStart)
	call HLtoLCD
	ld a,'-'
	ld c, _charToLCD
	rst 10h

	ld hl,(transferStart)
	ld bc,(transferLength)
	add hl,bc
	dec hl				; fixup count
	call HLtoLCD

	ret

; ----------------------------------------------------------------------------
; read a sector from SD card
; reads from currSector
; ----------------------------------------------------------------------------
readSdSector:
	ld hl,spiCMD17			; load up our variable
	ld de,spiCMD17var
	ld bc,6
	ldir

	ld hl,(currSector)
	ld a,h				; swap byte order
	ld h,l
	ld l,a
	ld (spiCMD17var+3),hl		; put our sector # here

	ld hl,spiCMD17var		; write command
	call sendSPICommand		; check command worked (=0)
	cp 0
	jp nz,sdError
	ld bc,514
	call readSPIBlock
	ret

; ----------------------------------------------------------------------------
; Write a sector to SD card
;
; Calculates CRC16
; Writes 512b sdBuff to SD card at sector currSector
; ----------------------------------------------------------------------------
writeSdSector:
	ld ix,sdBuff			; get CRC16
	ld de,512
	call crc16
	ld a,h
	ld (sdBuff+512),a		; and save CRC16
	ld a,l
	ld (sdBuff+513),a

	ld hl,spiCMD24			; load up our variable
	ld de,spiCMD24var
	ld bc,6
	ldir

	ld hl,(currSector)
	ld a,h				; swap byte order
	ld h,l
	ld l,a
	ld (spiCMD24var+3),hl		; put our sector # here

	ld hl,spiCMD24var		; write command
	call sendSPICommand		; check command worked (=0)
	cp 0
	jp nz,sdError

	call writeSPIBlock
	cp 05h				; check write worked
	jp nz, sdError
	ret

; ----------------------------------------------------------------------------
; Checks to see if SD card is formatted by finding MBR signature
;
; Returns with CF set if bad, clear if OK
; destroys sdBuff
; ----------------------------------------------------------------------------
validateFormat:
	call spiInit

	ld hl,0				; fetch sector
	ld (currSector),hl
	call readSdSector

	call spiInit

	ld hl,sdFormat
	ld de,sdBuff
	ld b,6

stCp:	ld a,(de)
	ld c,a
	ld a,(hl)
	cp c
	jr nz,stCpFail
	inc de
	inc hl
	djnz stCp
	
	or a				; clear CF
	ret

stCpFail:
	ld hl,notFormatMsg
	call lcdStr
	ld c,_scanKeysWait
	rst 10h

	scf				; set CF
	ret

; ----------------------------------------------------------------------------
; General Subroutines
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; msgPause
; B = LCD Command
; HL = ASCIIZ String
; ----------------------------------------------------------------------------
msgPause:
	ld c,_commandToLCD
	rst 10h
	call lcdStr
	ld c,_scanKeysWait
	rst 10h
	ret

; ----------------------------------------------------------------------------
; Error Handling Routines
; ----------------------------------------------------------------------------
sdError:
	ld de,sdErrorStrNum		; save error code
	ld c,_AToString
	rst 10h
	xor a
	ld (de),a
	ld hl,sdErrorStr
	call lcdStr
	ld hl,sdErrorStrNum

sdErr2:	call lcdStr
	call spiInit
	halt
	ret

noCard:	call spiInit
	ld hl,noCardStr
	;jr sdErr2
	call lcdStr
	call spiInit

	ld c,_scanKeysWait
	rst 10h

	ret
	;rst 00h

; ----------------------------------------------------------------------------
; display a byte on LCD as hex digits
; input A = byte to display
; ----------------------------------------------------------------------------
showByte:
	push af
	push bc
	push de
	push hl

	ld de,byteBuff
	ld c,_AToString
	rst 10h
	ld a,20h
	ld (byteBuff+2),a
	xor a
	ld (byteBuff+3),a

	ld hl,byteBuff
	call lcdStr

	pop hl
	pop de
	pop bc
	pop af
	ret

; ----------------------------------------------------------------------------
; Write buffer to SD card sector
;
; returns:
; A = result code. 05h = success
; ----------------------------------------------------------------------------
writeSPIBlock:
	push bc
	push de
	ld hl,sdBuff
	ld de,514		; #bytes to write

sendToken:
	ld c,0feh		; send start block token
	call spiWrb

blockLoopW:			; load in all the bytes incl. CRC16
	ld c,(hl)
	call spiWrb
	inc hl
	dec de
	ld a,d
	or e
	jr nz, blockLoopW

	call readSPIByte	; get the write response token
	ld c,a			; save result into C

waitDone:
	call spiRdb		; 00 = busy - wait for card to finish
	cp 00h
	jr z,waitDone

	ld a,c			; restore result to A register
	and 1fh			; return code 05 = success
	pop de
	pop bc
	ret

; -----------------------------------------------------------------------------
; DECIMAL - HL to decimal
; IX = memory location to store result
; trashes a, bc, de
; -----------------------------------------------------------------------------
decimal:
	ld e,1				; 1 = don't print a digit

	ld bc,-10000
	call Num1
	ld bc,-1000
	call Num1
	ld bc,-100
	call Num1
	ld c,-10
	call Num1
	ld c,-1

Num1:	ld a,'0'-1

Num2:	inc a
	add hl,bc
	jr c,Num2
	sbc hl,bc

	ld d,a				; backup a
	ld a,e
	or a
	ld a,d				; restore it in case
	jr z,prout			; if E flag 0, all ok, print any value

	cp '0'				; no test if <>0
	ret z				; if a 0, do nothing (leading zero)

	ld e,0				; clear flag & print it

prout:
	ld (ix),a
	inc ix
	ret

; ----------------------------------------------------------------------------
; Write ASCIIZ string at HL to LCD Screen
; ----------------------------------------------------------------------------
lcdStr:
	push af
	push hl

	ld c,_stringToLCD
	rst 10h

lcdStrDone:
	pop hl
	pop af
	ret

; ----------------------------------------------------------------------------
; Write the value of HL to LCD Screen
; ----------------------------------------------------------------------------
HLtoLCD:
	ld de,byteBuff
	ld c,_HLToString
	rst 10h
	xor a
	ld (de),a
	ld hl,byteBuff
	call lcdStr
	ret

; ----------------------------------------------------------------------------
; CRC-16-CCITT checksum
;
; Poly: &1021
; Seed: &0000
;
; Input:
;  IX = Data address
;  DE = Data length
;
; Output:
;  HL = CRC-16
;  IX,DE,BC,AF modified
; ----------------------------------------------------------------------------
crc16:	ld hl,0000h
	ld c,8

crc16_read:
	ld a,h
	xor (ix+0)
        ld h,a
        inc ix
        ld b,c

crc16_shift:
        add hl,hl
        jr nc,crc16_noxor
        ld a,h
        xor 010h
        ld h,a
        ld a,l
    	xor 021h
        ld l,a

crc16_noxor:
        djnz crc16_shift
        dec de
        ld a,d
        or e
        jr nz,crc16_read
 	ret

	.end
