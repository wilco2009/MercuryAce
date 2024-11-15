
Roller:		rst	18h
		ex	de,hl
		ld	b,6

L1:		ld	a,0*32+1+6	; Pages 1-6
		sub	b
		out	(0E3h),a
		ld	a,b
		push	hl		; Save origin address
		ld	de,2000h
		ld	bc,1024
		ldir			; First copy
		ld	b,a
		ld	a,0*32+1+12	; pages 7-12
		sub	b
		out	(0E3h),a
		ld	a,b
		pop	hl		; Restore origin to make another copy
		ld	de,2000h
		ld	bc,1024
		ldir			; Second copy
		ld	b,a
		djnz	L1

L2:		ld	c,06h
L3:		ld	a,1*32+1+6
		sub	c
		out	(0E3h),a
		ld	b,20h

L4:		;ld	a,7*32+32	; the result of this is 256...
		xor	a		;  so, just set it to 0
		sub	b
		out	(0E3h),a
		halt
		ld	a,7Fh		; Detect SPACE
		in	a,(254)
		rrca
		jr	nc,quit		; Quit if pressed
		djnz	L4		; Next scanline
		dec	c
		jr	nz,L3		; Next page (32 scanlines per page)
		jr	L2		; Start again

quit:		ld	a,7Fh
		in	a,(254)
		rrca
		jr	nc,quit		; Wait until SPACE is released

		xor	a		; Activate page 0 for CPU access
		out	(0E3h),a	; (allows Forth to keep processing)

		jp	(iy)		; Finish
