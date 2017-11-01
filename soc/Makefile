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
REPERTOIRE=porta


all: compile newvhd vhdl


compile:
	$(MAKE) -C c REPERTOIRE=$(REPERTOIRE)
	
vhdl:
	$(MAKE) -C avrtiny861
	
execute:
	$(MAKE) -C avrtiny861 execute
	
view:
	$(MAKE) -C avrtiny861 view
	
newvhd:
	cp ${PMVHDFILE} ${PMVHDBACKFILE}	
	${HEXTOVHDLAWK}	-v filename=$(HEXFILE) $(PMMODELE) > $(PMVHDFILE)
	
clean: clean-vhdl clean-c clean-build


clean-build:
	rm $(HEXFILE) $(ELFFILE)	

clean-c: 
	$(MAKE) -C c clean
	
clean-asm: 
	$(MAKE) -C asm clean
	
clean-vhdl:
	$(MAKE) -C avrtiny861 clean
