
SPARE		equ	3C3Bh

PSet:		push	iy
		ld	iy,(SPARE)
		ld	bc,-6
		add	iy,bc
		ld	(SPARE),iy
		ld	a,(iy+1)	; X high byte
		or	(iy+3)		; Y high byte
		jr	nz,cleanup	; jump if out of screen
		ld	c,(iy+4)	; C = mode: 0=clr, 1=set, 2=nop, 3=inv
		ld	a,191		; convert bottom-up to top-down
		sub	(iy+2)		;  Y coordinate
		jr	c,cleanup	; if overflown, it's out of the screen

		; Bit structure of the coordinates:
		;
		; Bit    7   6   5   4   3   2   1   0
		;      +---+---+---+---+---+---+---+---+
		;      | A4| A3| A2| A1| A0| PIXEL BIT |   X
		;      +---+---+---+---+---+---+---+---+
		;
		;      +---+---+---+---+---+---+---+---+
		;      |    PAGE   | A9| A8| A7| A6| A5|   Y
		;      +---+---+---+---+---+---+---+---+
		;
		; When finished, A7-A0 must go to L; A9-A8 + 24h must go to H;
		; PIXEL BIT + 1 must go to B; PAGE + 8 must go to the hardware

		ld	h,a		; H = Y
		ld	a,(iy+0)
		ld	d,a		; D = X
		and	7		; bit number
		inc	a
		ld	b,a		; B = shift counter
		ld	a,d		; A = X
		srl	h
		rra			; Shift out bit number, shift in A7-A5
		srl	h
		rra
		srl	h
		rra
		ld	l,a		; L is ready
		ld	a,h		; H still holds the page number
		rrca			; Remove the address bits
		rrca
		and	7		; Isolate page number
		add	a,0*32+8	; Set CPU Page register, add page 8
		out	(0E3h),a
		ld	a,h
		and	3		; Remove the page number
		add	a,24h		; Text RAM base addr, priority video
		ld	h,a		; H is ready
		ld	a,254		; Bitmask with bit 0 clear
bitLoop:	rrca			; Shift to correct bit position
		djnz	bitLoop
		ld	b,a		; B = bitmask

		ld	a,(hl)
		bit	1,c
		jr	nz,noAnd
		and	b		; if 0 or 1
noAnd:		bit	0,c
		jr	z,noXor
		xor	b		; if 1 or 3
		cpl
noXor:		ld	(hl),a

cleanup:	pop	iy
		jp	(iy)
