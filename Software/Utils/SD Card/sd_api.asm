; ----------------------------------------------------------------------------
; sd_api.asm
; Version: 0.1
; Last updated: 28/04/2024
;
; SD card API for TEC-1G.
;
; Requires MON3 v1.4 or later
; ----------------------------------------------------------------------------

; ----------------------------------------------------------------------------
; Constants
; ----------------------------------------------------------------------------
; In any app that calls these api's, make sure that API_DATA is set to a valid
; RAM address. This can be done by using
;
; API_DATA	.equ $
;
; at the end of the data segment of the calling app.

;API_DATA	.equ 1000h	; uncomment if testing file dependencies when
				; building standalone. This is normally left
				; commented out.
RESET_CLK_COUNT	.equ 80
SD_INIT_RETRIES	.equ 10
SD_CLK		.equ 1

; ----------------------------------------------------------------------------
; INCLUDE libraries
; ----------------------------------------------------------------------------

#include	"spi_library.asm"

; ============================================================================
; Api calls
; ============================================================================
; ----------------------------------------------------------------------------
; sdInit#0
; Initialise communications to the SD card and checks for a compatible SD card
;
; Input:	None
; Output:	Carry flag set if no card detected
; Destroys:	A, BC, HL
; ----------------------------------------------------------------------------
sdInit:
	ld a,SD_INIT_RETRIES	; Number of retries for SD card detection
	ld (sdInitRetry),a
	
sdInitLoop
	call spiInit		; set SD interface to idle state

	ld b,RESET_CLK_COUNT	; toggle clk 80 times
	ld a,SPI_IDLE		; set CS and MOSI high

sdReset
	out (SPI_PORT),a
	set SD_CLK,a		; set CLK
	out (SPI_PORT),a
	nop
	res SD_CLK,a		; clear CLK
	out (SPI_PORT),a
	djnz sdReset

	ld a,SPI_IDLE		; now turn CS off - puts SD card into SPI mode
	and SPI_CS1
	out (SPI_PORT),a

	ld hl,spiCMD0
	call sendSPICommand	; should come back as 01 if card present
	cp 01h
	jr z,sdReset2		; SD card detected
	ld a,(sdInitRetry)	; no SD card detected so load retry counter
	cp 0			
	jr z,sdReset1		; no more retries left
	dec a
	ld (sdInitRetry),a	; update the retry counter
	jr sdInitLoop		; and try again
	
sdReset1
	scf
	ret

sdReset2

; ----
; CMD8 - get status bits. CMD8 is in version 2.0+, of the SD spec.
; only SDHC cards support CMD8
; ----

	ld hl,spiCMD8
	call sendSPICommand
	cp 01
	jr nz,cmd8Done		; skip past if CMD8 not supported (older cards)

cmd8OK
	ld b,4			; dump 4 bytes of CMD8 status

get5Byte
	call readSPIByte
	djnz get5Byte

cmd8Done

;------
; ACMD41 - setup card state (needs CMD55 sent first to put it into ACMD mode)
;------
sendCMD55
	call lDelay
	ld hl,spiCMD55
	call sendSPICommand
	ld hl,spiACMD41
	call sendSPICommand	; expect to get 00; init'd. If not, init is in progress
	cp 0
	jr z, initDone
	jr sendCMD55		; try again if not ready. Can take several cycles

; we are initialised!!
initDone
	ret

; ----------------------------------------------------------------------------
; getPNM#1
; Read the cards Part Number and return a pointer to a 5 character, null
; terminated string containing the Part Number as ASCII text.
;
; Input:	None.
; Output:	HL -- Pointer to null terminated part number string.
;		Zero flag set to non-zero value on error.
; Destroys:	A, HL, IX, IY
; ----------------------------------------------------------------------------
getPNM:
	push bc			; Save registers
	push de

	call getCID		; Get the SD card hw info
	jr z,getPNM1		; OK, then continue
	pop de			; Restore registers
	pop bc

	scf			; Set carry flag set.
	ret nz			; and non-zero flag on return

getPNM1
	push hl			; Index to data in the CID buffer
	pop ix
	ld hl,sdStrPNM		; Index to the PNM string
	push hl
	pop iy
	ld b,5			; PNM - Product name length (see SD card Spec)
getPNM2
	ld a,(ix+3)		; Loop through the 5 bytes of PNM data
	ld (iy),a		; and copy to the string
	inc ix
	inc iy
	djnz getPNM2

	ld hl,sdStrPNM		; HL points to the Part Number string
	ld a,0			; Ensure zero flag is set for successful

	pop de			; Restore registers
	pop bc

	ret			; and return.

; ----------------------------------------------------------------------------
; getCardType#2
; Check and return whether the card is SDSC or SDHC
;
; Requires
;
; Input:	None.
; Output:	A -- 80h = SDSC, C0h = SDHC
;		Carry flag set if no card detected
; Destroys:	A
; ----------------------------------------------------------------------------
getCardType:
	push bc			; Save registers
	push de
	push hl

	call getCID		; Get the SD card hw info
	jr z,getCT1		; OK, then continue
	pop hl			; if not, restore registers
	pop de
	pop bc

	scf			; Return with carry flag set on error.
	ret nz			; and return

getCT1
	ld hl,spiCMD58		; Get OCR Register
	call sendSPICommand
	cp 0
	jp z,checkOCROK
	pop hl			; if not, restore registers
	pop de
	pop bc

	scf			; Return with carry flag set on error.
	ret
	
checkOCROK
	ld b,4			; 4 bytes returned
	ld hl,sdBuff

getR3Response
	call readSPIByte
	ld (hl),a
	inc hl
	djnz getR3Response

	ld a,(sdBuff)		; bit 7 = valid, bit 6 = SDHC if 1, SCSC if 0
	and 0c0h

	pop hl			; Restore registers
	pop de
	pop bc

	ret			; and return

; ----------------------------------------------------------------------------
; getMaxFiles#3
; Check and return whether the card is SDSC or SDHC
;
; Input:	None.
; Output:	A -- 80h = SDSC, C0h = SDHC
;		Carry flag set if no card detected
; Destroys:	A
; ----------------------------------------------------------------------------


; ============================================================================
; Function calls
; ============================================================================

; ----------------------------------------------------------------------------
; Read the cards CID register and return a pointer to it in HL
; ----------------------------------------------------------------------------
getCID:
	ld hl,spiCMD10
	call sendSPICommand	; check command worked (=0)
	cp 0
	ret nz

	ld bc,16		; how many bytes of data we need to get
	call readSPIBlock

	ld b,15
	ld de,sdCIDRegister
	ld hl,sdBuff
getCID2
	ld a,(hl)		; copy CID register from buffer to var
	ld (de),a 
	inc de
	inc hl
	djnz getCID2
	
	ld hl,sdCIDRegister	; return pointer to the CID register in hl
	
	ret

; ----------------------------------------------------------------------------
; Read SD card sector to buffer
; BC = #Bytes to read
; ----------------------------------------------------------------------------
readSPIBlock:
	ld hl,sdBuff

waitToken
	call spiRdb
	cp 0ffh			; ffh == not ready yet
	jr z,waitToken
; todo = 0000xxxx = error token; handle this
; todo, add timeout
	cp 0feh			; feh == start token. We discard this.
	jr nz,waitToken

blockLoopR			; load in all the bytes
	call spiRdb
	ld (hl),a
	inc hl
	dec bc
	ld a,b
	or c
	jr nz, blockLoopR
	ret

; ----------------------------------------------------------------------------
; ReadSPIByte; reads with loop to wait for ready (FFh = not ready)
;
; Returns - read value in A; if FFh returned, there was a timeout error
; ----------------------------------------------------------------------------
readSPIByte:
	push bc
	push de
	ld b,32			; wait up to 32 tries, but should need 1-2

readLoop
	call spiRdb		; get value in A
	cp 0ffh
	jr nz,result
	djnz readLoop

result
	pop de
	pop bc
	ret

; ----------------------------------------------------------------------------
; sendSPICommand
; Input HL = 6 byte command
; returns A = response code
; ----------------------------------------------------------------------------
sendSPICommand:
;	push bc
;	push de
	ld b,6
sendSPIByte
	ld c,(hl)
	call spiWrb
	inc hl
	djnz sendSPIByte
	call readSPIByte
;	pop de
;	pop bc
	ret

; ----------------------------------------------------------------------------
; Error Handling Routines
; ----------------------------------------------------------------------------


; ----------------------------------------------------------------------------
; General purpose delay loop
; ----------------------------------------------------------------------------
lDelay:	push af
	push de

	ld de,0c000h

lInner	dec de
	ld a,d
	or e
	jr nz, lInner

	pop de
	pop af
	ret

; ----------------------------------------------------------------------------
; Data and variables
; ----------------------------------------------------------------------------
		.org API_DATA

cidBufferPtr	.dw			; Pointer to the CID buffer

sdInitRetry	.db 0			; Keeps track of init retry counter

; ---------------------------- SPI commands
spiCMD0		.db 40h,0,0,0,0,95h	; reset			R1
spiCMD8		.db 48h,0,0,1,0aah,87h	; send_if_cond		R7
spiCMD9		.db 49h,0,0,1,0aah,87h	; send_CSD		R1
spiCMD10	.db 4ah,0,0,0,0,1h	; send_CID		R1
spiCMD16	.db 50h,0,0,2,0,1h	; Set sector size	R1
spiCMD17	.db 51h,0,0,0,0,1h	; read single block	R1
spiCMD24	.db 58h,0,0,0,0,1h	; write single block	R1
spiCMD55	.db 77h,0,0,0,0,1h	; APP_CMD		R1
spiCMD58	.db 7ah,0,0,0,0,1h	; READ_OCR		R3
spiACMD41	.db 69h,40h,0,0,0,1h	; send_OP_COND		R1

sdBuff		.block 512+2		; 512b + CRC16

; ---------------------------- Strings
sdStrPNM	.db "     ",0		; 5 character part number

; ---------------------------- SD CID register
sdCIDRegister
sdcidMID	.block 1		; Manufacturer ID
sdsidOID	.block 2		; OEM/Application ID
sdcidPNM	.block 5		; Product name
sdcidPRV	.block 1		; Product revision
sdcidPSN	.block 4		; Product serial number
sdcidMDT	.block 2		; Manufacturing date
sdcidCRC	.block 1		; CRC7

sdApiEod				; End of the data block

	.end