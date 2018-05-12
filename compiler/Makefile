RSFLAGS=-O

assem : assembler.rs Makefile
	rustc $(RSFLAGS) -o assembler assembler.rs

comp : compiler.rs Makefile
	rustc $(RSFLAGS) -o compiler compiler.rs

TESTS=$(sort $(wildcard *.fun))
RUNS=$(patsubst %.fun,%.hex,$(TESTS))

test : $(RUNS)

$(RUNS) : %.hex : %.fun Makefile assembler
	@./assembler $*.fun
	@./compiler
	@mv output.hex $*.hex

clean :
	rm -f *.hex
	rm -f compiler
	rm -f assembler

