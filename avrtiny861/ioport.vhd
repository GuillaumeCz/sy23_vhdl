library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Entité Ioport
  -- Composant gérant les entrée et sortie d'un port
entity ioport is
	Generic (BASE_ADDR	: integer := 16#19#);
    Port ( clk :		in		STD_LOGIC;
	       Rst :		in		STD_LOGIC;
           addr :		in		STD_LOGIC_VECTOR (5 downto 0);
           ioread :		out		STD_LOGIC_VECTOR (7 downto 0);
           iowrite :	in		STD_LOGIC_VECTOR (7 downto 0);
           rd : 		in		STD_LOGIC;
           wr : 		in  	STD_LOGIC;
		   ioport : 	inout	STD_LOGIC_VECTOR (7 downto 0));
end ioport;

architecture ioport_architecture of ioport is

-- Initialisation
-- Definition des constantes d'adresses des registres
constant PORT_ADDR : 							integer := BASE_ADDR + 2;
constant DDR_ADDR : 							integer := BASE_ADDR + 1;
constant PIN_ADDR : 							integer := BASE_ADDR;

-- registre PORT   
signal PORT_register: 						STD_LOGIC_VECTOR(7 downto 0)				:= (others => '0');
-- registre DDR
signal DDR_register : 						STD_LOGIC_VECTOR(7 downto 0)				:= (others => '0');
-- registre PIN
signal PIN_register : 						STD_LOGIC_VECTOR(7 downto 0)				:= (others => '0');

begin

  -- Processus de gestion des addresses
process (clk, Rst)
-- variable locale exprimant la valeur de l'adresse du registre pointé
variable a_int : natural;
-- variable locale exprimant le mode de fonctionnement (lecture / ecriture)
variable rdwr : std_logic_vector(1 downto 0);
begin
	if (Rst = '1') then
		-- En vas de reset, tous les signaux des registres sont initialisés à Z 
		--PORT_register	<= (others => 'Z');
		DDR_register 	<= (others => '0');
	elsif (rising_edge(clk)) then
		-- A chaque periode de l'horloge...
		-- Saisie de l'adresse en entré dans la variable locale a_int 
		a_int := Conv_integer(addr);
		-- Concatenation des signaux d'entré des modes de lecture et d'ecriture
		rdwr  := rd & wr;
		if (a_int = PORT_ADDR) then
		-- Cas ou l'adresse en entrée corresponde à celle du registre PORT
			case rdwr is
				when "10" => -- rd
					 -- si le mode est en lecture, affectation de la valeur du registre PORT au signal de sortie en lecture
					ioread		<= PORT_register;
				when "01" => -- wr
					-- si le mode est en écriture affectation de la valeur de sortie ioport avec celle du registre PORT en fonction du registre DDR
					-- si la valeur lue vaut 1 affectation du bit de registre PORT au bit correspondant dans ioport
					if DDR_register(0) = '1' then
						ioport(0) <= PORT_register(0);
					end if;
					if DDR_register(1) = '1' then
						ioport(1) <= PORT_register(1);
					end if;
					if DDR_register(2) = '1' then
						ioport(2) <= PORT_register(2);
					end if;
					if DDR_register(3) = '1' then
						ioport(3) <= PORT_register(3);
					end if;
					if DDR_register(4) = '1' then
						ioport(4) <= PORT_register(4);
					end if;
					if DDR_register(5) = '1' then
						ioport(5) <= PORT_register(5);
					end if;
					if DDR_register(6) = '1' then
						ioport(6) <= PORT_register(6);
					end if;
					if DDR_register(7) = '1' then
						ioport(7) <= PORT_register(7);
					end if;
					
				-- Ne rien faire dans les autres cas
				when others => NULL; 
			end case;
		elsif (a_int = DDR_ADDR) then
		-- Cas où l'adresse en entré corresponde au registre DDR
			case rdwr is
				when "10" => -- rd
					-- si le mode est en ecriture, addectation de la valeur du registre DDR dans le signal de sortie de lecture  
					ioread			<= DDR_register;
				when "01" => -- wr
					-- si le mode est en lecture,  saisie des valeurs en entrées dans le registre DDR
					DDR_register 	<= iowrite;
					-- Ne rien faire dans les autres cas 
				when others => NULL; 
			end case;
		elsif (a_int = PIN_ADDR) then
		-- Cas ou l'adresse en entré corresponde au registre PIN 
			case rdwr is
				when "10" => -- rd
					-- si le mode est en ecriture, affectation de la valeur du registre PIN au signal de sortie de lecture
					ioread 			<= PIN_register;
				-- Dans les autres cas, ne rien faire
				when "01" => NULL; -- wr
				when others => NULL; 
			end case;
		end if;
	end if;
end process;	

-- En fonction de chaque valeur des bits du registre DDR, affectation des valeurs de bits correspondant à ioport ou bien celui de l'entrée en écriture
PORT_register(0) <= ioport(0) when DDR_register(0) = '0' else
					iowrite(0)when DDR_register(0) = '1' and wr = '1';
PORT_register(1) <= ioport(1) when DDR_register(1) = '0' else
					iowrite(1)when DDR_register(1) = '1' and wr = '1';
PORT_register(2) <= ioport(2) when DDR_register(2) = '0' else
					iowrite(2)when DDR_register(2) = '1' and wr = '1';
PORT_register(3) <= ioport(3) when DDR_register(3) = '0' else
					iowrite(3)when DDR_register(3) = '1' and wr = '1';
PORT_register(4) <= ioport(4) when DDR_register(4) = '0' else
					iowrite(4)when DDR_register(4) = '1' and wr = '1';
PORT_register(5) <= ioport(5) when DDR_register(5) = '0' else
					iowrite(5)when DDR_register(5) = '1' and wr = '1';
PORT_register(6) <= ioport(6) when DDR_register(6) = '0' else
					iowrite(6)when DDR_register(6) = '1' and wr = '1';
PORT_register(7) <= ioport(7) when DDR_register(7) = '0' else
					iowrite(7)when DDR_register(7) = '1' and wr = '1';
					
-- Saisie de la valeur de PIN register depuis le signal d'entré 
PIN_register <= ioport;

end ioport_architecture;
