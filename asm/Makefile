#$@  	Le nom de la cible
#$< 	Le nom de la première dépendance
#$^ 	La liste des dépendances
#$? 	La liste des dépendances plus récentes que la cible
#$* 	Le nom du fichier sans suffixe
#.PHONY: clean mrproper
AS=avr-as
LD=avr-ld
OBJCOPY=avr-objcopy
OBJDUMP=avr-objdump
#ASFLAGS=-mmcu=attiny261 --gdwarf2
ASFLAGS=-mmcu=attiny861
OBJCOPYFLAGS=-O ihex -R .eeprom 
OBJDUMPFLAGS=-h -S


DIRBUILD=../build
SRC=porta.asm
ELF=$(DIRBUILD)/pm.elf
HEX= $(DIRBUILD)/pm.hex
LSS= $(SRC:.asm=.lss)


all:  
	$(AS) $(ASFLAGS) $(SRC)
	$(LD) -o $(ELF) a.out
	$(OBJCOPY) $(OBJCOPYFLAGS) $(ELF) $(HEX)
	$(OBJDUMP) $(OBJDUMPFLAGS) $(ELF) > $(LSS)	
	
clean:
	rm  a.out $(ELF) $(HEX) $(LSS)
