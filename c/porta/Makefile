#$@  	Le nom de la cible
#$< 	Le nom de la première dépendance
#$^ 	La liste des dépendances
#$? 	La liste des dépendances plus récentes que la cible
#$* 	Le nom du fichier sans suffixe
#.PHONY: clean mrproper


CC=avr-gcc
OBJCOPY=avr-objcopy
OBJDUMP=avr-objdump
#ASFLAGS=-mmcu=attiny261 --gdwarf2
#CCFLAGS=-mmcu=attiny261 -Wall -gdwarf-2 -std=gnu99 -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums -MD -MP -MT
CCFLAGS=-mmcu=attiny861 -Wall -std=gnu99 -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums -MD -MP -MT
LDFLAGS=-mmcu=attiny861
OBJCOPYFLAGS=-O ihex -R .eeprom 
OBJDUMPFLAGS=-h -S


DIRBUILD=../../build
SRC=porta.c
OBJ= $(SRC:.c=.o)
ELF=$(DIRBUILD)/pm.elf
HEX= $(DIRBUILD)/pm.hex
LSS= $(SRC:.c=.lss)
MAP= $(SRC:.c=.map)
DFILE= $(SRC:.c=.d)



all: 
	$(CC) $(CCFLAGS) $(OBJ) -c $(SRC)
	$(CC) $(LDFLAGS) -Wl,-Map=$(MAP) -o $(ELF) $(OBJ)	
	$(OBJCOPY) $(OBJCOPYFLAGS) $(ELF) $(HEX)
	$(OBJDUMP) $(OBJDUMPFLAGS) $(ELF) > $(LSS)

	
clean:
	rm  $(DFILE) $(OBJ) $(MAP)  $(LSS)
