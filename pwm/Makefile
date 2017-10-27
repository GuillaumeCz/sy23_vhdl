CC=ghdl
PROG=pwm
SRC=$(PROG).vhd
VCD=$(PROG).vcd
SRCTB=$(PROG)_tb.vhd
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
