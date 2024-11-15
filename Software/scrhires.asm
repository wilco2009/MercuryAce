
ScrHiRes:	rst	18h
		ex	de,hl
		ld	b,6

L1:		ld	a,0*32+8+6	; Pages 8-13
		sub	b
		out	(0E3h),a
		push	bc
		ld	de,2000h
		ld	bc,1024
		ldir
		pop	bc

		djnz	L1

		xor	a
		out	(0E3h),a

		jp	(iy)
