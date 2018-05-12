RSFLAGS=-O

assem : assembler.rs Makefile
	rustc $(RSFLAGS) -o assembler assembler.rs

comp : compiler.rs Makefile
	rustc $(RSFLAGS) -o compiler compiler.rs

TESTS=$(sort $(wildcard *.fun))
RUNS=$(patsubst %.fun,%.mif,$(TESTS))

test : $(RUNS)

$(RUNS) : %.mif : %.fun Makefile assem comp
	@./assembler $*.fun
	@./compiler
	@mv output.mif $*.mif

clean :
	rm -f *.mif
	rm -f compiler
	rm -f assembler
	rm -f *.s

