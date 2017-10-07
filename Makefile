CC=ghdl
PROG=RS232
SRC=$(PROG).vhdl
VCD=$(PROG).vcd
SRCTB=$(PROG)_tb.vhdl
ENTITE=$(PROG)_tb
OPTIONS= --ieee=synopsys
STOPTIME=400ns

all:
	$(CC) -a $(OPTIONS) $(SRC)
	$(CC) -a $(OPTIONS) $(SRCTB)
	$(CC) -e $(OPTIONS) $(ENTITE)
	$(CC) -r $(OPTIONS) $(ENTITE) --vcd=$(VCD) --stop-time=$(STOPTIME)
	
view:
	gtkwave $(VCD)
	
clean:
	$(CC) --clean
	rm  $(VCD) work-obj93.cf
