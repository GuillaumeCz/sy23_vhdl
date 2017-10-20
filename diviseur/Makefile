CC=ghdl
PROG=diviseur_generique
SRC=$(PROG).vhdl
VCD=$(PROG).vcd
SRCTB=$(PROG)_test.vhdl
ENTITE=$(PROG)_tb
OPTIONS= --std=02 --ieee=synopsys -fexplicit
STOPTIME=200ns
COMPOSANT=diviseur_generique.vhdl 

all: compile simule	execute
	
compile:
	$(CC) -a $(OPTIONS) $(COMPOSANT)
	$(CC) -a $(OPTIONS) $(SRC)
	$(CC) -a $(OPTIONS) $(SRCTB)

simule:
	$(CC) -e $(OPTIONS) $(ENTITE)
	
execute:
	$(CC) -r $(OPTIONS) $(ENTITE) --vcd=$(VCD) --stop-time=$(STOPTIME)
	
view:
	gtkwave $(VCD)
	
clean:
	$(CC) --clean
	rm  $(VCD) work-obj93.cf
