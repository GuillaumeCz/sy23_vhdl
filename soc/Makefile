#$@  	Le nom de la cible
#$< 	Le nom de la première dépendance
#$^ 	La liste des dépendances
#$? 	La liste des dépendances plus récentes que la cible
#$* 	Le nom du fichier sans suffixe
#.PHONY: clean mrproper
MAKE=make

DIRBUILD=build
DATAMEM=/opt/Xilinx/14.2/ISE_DS/ISE/bin/lin64/data2mem
HEXTOVHDLAWK=hex2vhdl/hextovhdl.awk
DIRBIT=avrtiny861
BMMFILE=$(DIRBUILD)/attiny861.bmm
BITFILE=$(DIRBIT)/microcontroleur.bit
BITFILENEW=$(DIRBIT)/microcontroleur_new.bit
DIRPM=${DIRBIT}
PMVHDBACKFILE=${DIRPM}/pm.vhd.back
PMVHDFILE=${DIRPM}/pm.vhd
HEXFILE=$(DIRBUILD)/pm.hex
ELFFILE=$(DIRBUILD)/pm.elf
PMMODELE=hex2vhdl/pm_modele.vhd


all: compile


compile:
	$(MAKE) -C c
	
newbit:
	$(DATAMEM) -bm $(BMMFILE) -bd $(ELFFILE) -bt $(BITFILE) -ob $(BITFILENEW)
	
newvhd:
	cp ${PMVHDFILE} ${PMVHDBACKFILE}	
	${HEXTOVHDLAWK}	-v filename=$(HEXFILE) $(PMMODELE) > $(PMVHDFILE)
	
clean: clean-c

clean-c: 
	$(MAKE) -C c clean
	
clean-asm: 
	$(MAKE) -C asm clean
	
clean-xilinx:
	rm $(DIRBIT)/*.html $(DIRBIT)/*.ncd
	rm -f -R  $(DIRBIT)/iseconfig $(DIRBIT)/_xmsgs
