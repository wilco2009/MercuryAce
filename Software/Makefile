ASM := pasmo
PYTHON := python3
WORDS := hiresmode textmode scrhires rollhires pset anykey

all: hires.j.tap hires.s.tap

%.bin : %.asm
	$(ASM) $< $@

hires.j.tap: $(WORDS:%=%.bin)
	$(PYTHON) jupmcdic.py hires $^

%.s.tap: %.j.tap
	$(PYTHON) jtap2sptap.py $< $@
