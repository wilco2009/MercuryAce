
HiResMode:	ld	a,2*32+1		; Writes to CHARRAM go to page 1
		out	(0E3h),a

		; Prepare character set
		ld	hl,2800h
		ld	bc,4*256+127
		xor	a
L1:		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),a
		inc	l
		ld	(hl),c
		inc	l
		ld	(hl),c
		inc	l
		ld	(hl),c
		inc	l
		ld	(hl),c
		dec	c
		inc	a
		inc	l
		jr	nz,L1
		inc	h
		djnz	L1

		; Clear hires VRAM
		ld	a,0*32+8
L2:		out	(0E3h),a
		ld	hl,2000h
		ld	de,2001h
		ld	bc,1023
		ld	(hl),l
		ldir
		inc	a
		cp	0*32+8+6
		jr	nz,L2

		ld	a,4*32+1	; HiRes
		out	(0E3h),a
		ld	a,3*32+1	; Display CHARRAM using page 1
		out	(0E3h),a
		ld	a,1*32+8	; Display BGRAM starting on page 8
		out	(0E3h),a
		;ld	a,0*32+8	; Writes to BGRAM go to page 8
		;out	(0E3h),a	; (disabled - let user code do that)
		jp	(iy)
