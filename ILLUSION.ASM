; "Illusion", Atari XL/XE Intro 256B
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2021-08-21

delay	equ 235		; lower value means slower animation

.IF (gfxend0 - gfxbgn0 - 1 > 92)
	.ERROR 'The image height is too big!'
.ENDIF

rtclok	equ $0012
rowcrs	equ $0054
colcrs	equ $0055
oldrow	equ $005a
oldcol	equ $005b
oldcol2	equ $00c0
vvblkd	equ $0224
sdmctl	equ $022f
gprior	equ $026f
pcolr0	equ $02c0
pcolr1	equ $02c1
color0	equ $02c4
color1	equ $02c5
color2	equ $02c6
color4	equ $02c8
atachr	equ $02fb
hposp0	equ $d000
sizep0	equ $d008
sizep1	equ $d009
sizep2	equ $d00a
grafp0	equ $d00d
colpm0	equ $d012
gractl	equ $d01d
audf1	equ $d200
audc1	equ $d201
random	equ $d20a
pmbase	equ $d407
wsync	equ $d40a
vcount	equ $d40b
xitvbv	equ $e462
osgraph	equ $ef9c
osprint	equ $f1a4
ospoint	equ $f1d8
osdraw	equ $f9c2


	org $2000

start
	; enter graphics mode
	lda #$07
	jsr osgraph

	; set colors
	lda #$0f
	tay
loopa1	sta pcolr0-$08,y
	dey
	bpl loopa1

	; fill gfxend0 with repeated bytes
	ldx #$28
	lda #80
loopa2	sta gfxend0+7,x
	dex
	bpl loopa2

	; show image
	sty atachr
	lda #(92-(gfxend0-gfxbgn0-1))/2
	sta rowcrs
	sta oldrow
	ldy #gfxend0-gfxbgn0-1	; image height
loopa3	inc rowcrs
	inc oldrow
	lda gfxbgn0,y
	sta colcrs
	lda gfxend0,y
	sta oldcol
	sta oldcol2
	tya
	pha
	jsr osdraw

	lda #159
	;sec			; not necessary
	sbc oldcol2
	sta oldcol
	
	lda #159
	;sec			; not necessary
	sbc colcrs
	sta colcrs
	jsr osdraw
	
	pla
	tay
	dey
	bpl loopa3

	lda #%10100111
	sta audc1

	; animation
loopa4	lda vcount
	bne skipa1
	sta audf1
	inx
	bne skipa1
	dec opcoda2+1
	inc opcoda1+1
	ldx #delay
	sta audf1		; sounds better with this
	lda opcoda1+1
	lsr
	lsr
	bcs skipa1
	lda #$ff
	sta audf1
skipa1	
opcoda1	cmp #$00
	bcs skipa2
	clc
opcoda2	adc #$00
	and #%00000011
	bne skipa3
skipa2	lda #$00
	beq skipa4
skipa3	lda #$ff
skipa4	ldy #$ff-$03
	sta wsync
loopa5	sta grafp0-$ff+$03,y
	iny
	bne loopa5
	beq loopa4		; infinite loop


	; scanimation image
	icl 'HEARTDTA.ASM'


	org hposp0

	.byte 32+32, 32+32+32, 32+32+32+32, 32+32+32+32+32, 0, 0, 0, 0


	;org sizep0

	.byte 3, 3, 3, 3