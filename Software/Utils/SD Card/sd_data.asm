; ----------------------------------------------------------------------------
; Data section for sd_app
; ----------------------------------------------------------------------------

		.org 01000h	; Start of data in RAM

; ----------------------------
; App version info
; ----------------------------
swVerMsg	.db "Version 0.01.01",0
swInfoMsg	.db "Development build",0

; ----------------------------
; Constants
; ----------------------------
; FCB offsets
FCB_START_ADDR	.equ 20
FCB_LENGTH	.equ 22
FCB_EXPAND	.equ 24
FCB_RTC		.equ 25
FCB_START_SECT	.equ 32
FCB_SECT_COUNT	.equ 36

; ----------------------------
OFS_SECOND	.equ 0
OFS_MINUTE	.equ 1
OFS_HOUR	.equ 2
OFS_DATE	.equ 3
OFS_MONTH	.equ 4
OFS_DAY		.equ 5
OFS_YEAR	.equ 6

MENU_LEN	.equ 7		; must be n-1

LCD_ROW1	.equ 080h
LCD_ROW2	.equ 0c0h
LCD_ROW3	.equ 094h
LCD_ROW4	.equ 0d4h

; ----------------------------

mainMenuCfg	.db 7
		.db "SD APP"			; 7 seg text
		.db "SD Card Utilities",0	; Menu title
		.db "SD Card Info",0		; Item 1
		.dw sdCardInfo
		.db "List Files",0		; Item 2
		.dw fileListLcd
		.db "Load File",0		; Item 3
		.dw readFile
		.db "Save File",0		; Item 4
		.dw writeFile
		.db "Format SD Card",0		; Item 5
		.dw formatSD
		.db "HW Info",0			; Item 6
		.dw hwInfo
		.db "SW Info",0			; Item 7
		.dw swInfo

sdFormat	.db "TEC-1G"			; Signature
		.db "SD Card Storage 000",0	; Volume Label
		.db 00,00,01,01,01,01,00	; 1am 1/1/2023
		.db 16				; directory Sectors
sdFormatLen	.equ $-sdFormat

fcbFormat	.db "File Number 000.bin",0	; name
		.dw 0ffffh			; start, ffff = no file
		.dw 0000h			; length
		.db 00,00,01,01,01,01,00	; 1am 1/1/2023
		.dw 0000h			; start sector # (32 bits)
		.dw 0000h
		.dw 0000h			; length in sectors
fcbFormatLen	.equ $-fcbFormat
fcbFormatSpc	.equ 64-fcbFormatLen

;		     12345678901234567890
cmd8Str		.db "CMD8: ",0
sdErrorStr	.db "SD Card Error ",0
noCardStr	.db "SD Card not Found",0
notFormatMsg	.db "SD Not Formatted",0
megaBytes	.db "MB",0
cardTypeStr	.db "SD Card type ",0
sdscCardMsg	.db "SDSC",0
sdhcCardMsg	.db "SDHC",0
FormatMsg	.db "Formatting SD Card",0
formatOkStr	.db "Format Completed",0
formatDateMsg	.db "Card Formatted:",0

setSaveParams	.db 2
		.db "Save  "			; 7 seg text
		.db "Set Save Parameters",0	; Menu title
		.db "Start Address: ",0		; Item 1
		.dw transferStart
		.db "End Address: ",0		; Item 2
		.dw transferEnd

badParamMsg	.db "Bad Parameters!!",0
selectMsg	.db "File List",0
noFileMsg	.db "(Empty Slot)",0

setSaveSlot	.db "Select save slot",0
savingMsg	.db "Saving file:",0
saveOkMsg	.db "Save OK!",0
setLoadSlot	.db "Select load slot",0
loadingMsg	.db "Loading file:",0
loadOkMsg	.db "Load OK!",0
sdNoType1Msg	.db "SDSC not supported  ",0

startAddr	.db "Start ",0
lenAddrMsg	.db " Len ",0
startSecMsg	.db "SDSec ",0

cidMIDMsg	.db "MID: ",0
cidOIDMsg	.db " OID: ",0
cidPNMMsg	.db "Name: ",0
cidPRVMsg	.db " Rev: ",0
cidPSNMsg	.db "Serial No.: ",0
cidMDTMsg	.db "Date (M/Y): ",0

anyKeyMsg	.db "Press any key",0
noMsg		.db 0

byteStr		.db "  ",0
wordStr		.db "    ",0
decWordStr	.db "     ",0

crlf:		.db 13,10,0

cardCapacity:	.db "Maximum Files: ",0

API_DATA	.equ $

; ----------------------------
	.org 3C00h

byteBuff	.block 4
decimalBuff	.block 7
spiCMD17var	.block 6
spiCMD24var	.block 6
sdErrorStrNum	.block 3
currSector	.block 2

transferStart	.block 2
transferEnd	.block 2
transferLength	.block 2
transferPos	.block 2
startSector	.block 2
numSectors	.block 2

fcbToUpdate	.block 2
fcbOffset	.block 1
menuPos		.block 1
menuSel		.block 1

selectMsgPtr	.block 2

dtBuff		.block 21
