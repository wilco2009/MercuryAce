
AnyKey:		xor	a
		in	a,(254)
		cpl
		and	31
		jr	z,AnyKey
L1:		in	a,(254)
		cpl
		and	31
		jr	nz,L1
		jp	(iy)
