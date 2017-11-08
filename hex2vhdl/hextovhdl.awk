#!/usr/bin/awk -f


BEGIN {
	printf("-- filename : %s\n",filename);
	bitsaddr = 16
	bitsdatas = 16
	memorysize = 4096;
	cptlignes = 0;
	datasize=0;
}

{
	print $0
}

$0 ~ "-- datas" {
   printf("type PM_mem_type is array(0 to %d) of std_logic_vector(%d downto 0);\n",memorysize-1,bitsdatas-1);
   printf("signal PM_mem : PM_mem_type := (\n");
# format :SSAAAATTDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDCC SS size datas AAAA adresse TT type DD dates  CC CRC  
   	while ((getline line < filename) > 0) {
         datasline[cptlignes] = line;
         cptlignes += 1;
	}
    close(filemane);
	i=0;
	staille = sprintf("0x%s",substr(datasline[i],2,2));
	taille = strtonum(staille);
	datasize = datasize + taille;  
    while ((i<cptlignes)&&(taille > 0)) {
		printf("    ");
		for(j=0;j<taille;j+=2) {
			octet1 = substr(datasline[i],10+j*2,2);
			octet2 = substr(datasline[i],12+j*2,2);
			printf("x\"%s%s\", ",octet2,octet1);
		}
		printf("\n");
		staille = sprintf("0x%s",substr(datasline[++i],2,2));
		taille = strtonum(staille);
		datasize = datasize + taille; 		
	}	
	printf("    ");	 
	reste = (memorysize -1 - datasize/2);
	for(i=1;i<(reste+1);i+=1) {
	    printf("x\"0000\", ");
	    if ((i % 8)==0) {
			printf("\n    ");
	    }
	}  
	printf("x\"0000\" );\n");
	printf("-- program size %d / %d\n",datasize,memorysize);
}


END {
}
