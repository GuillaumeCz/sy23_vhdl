LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.numeric_std.ALL;
 
ENTITY ioport_tb IS
END ioport_tb;
 
ARCHITECTURE behavior OF ioport_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
COMPONENT ioport
	Generic (BASE_ADDR	: integer := 16#19#);
    Port ( clk :		in		STD_LOGIC;
	       Rst :		in		STD_LOGIC;
           addr :		in		STD_LOGIC_VECTOR (5 downto 0);
           ioread :		out		STD_LOGIC_VECTOR (7 downto 0);
           iowrite :	in		STD_LOGIC_VECTOR (7 downto 0);
           rd : 		in		STD_LOGIC;
           wr : 		in  	STD_LOGIC;
		   ioport : 	inout	STD_LOGIC_VECTOR (7 downto 0));
END COMPONENT;
    
--Constant
constant N 		: integer := 8;
constant bauds 	: integer := 115200;
constant sysclk : real := 50.0e6 ; -- 50MHz
constant clkdiv : integer := integer(sysclk / real(bauds));

-- Entrée
-- Signal d'entrée d'une horloge
signal clk : 				std_logic 		:= '0';
-- Signal d'entré de remise à 0
signal rst : 				std_logic 		:= '0';
-- Signal d'entrée de adresse du registre pointé
signal addr : 				std_logic_vector (5 downto 0);
-- Signal d'entrée avec les valeurs du registre pointé par l'adresse precedente
signal iowrite :			std_logic_vector (7 downto 0);
-- Signal d'entrée de lecture
signal rd :					std_logic		:= '0';
-- Signal d'entrée d'écriture
signal wr :					std_logic		:= '0';
-- Adresse de base
signal BASE_ADDR : 			integer 		:= 16#19#;

-- Sortie
-- Signal de sortie de la lecture
signal ioread : 			std_logic_vector (7 downto 0);

-- Entrée/sortie
-- Signal d'entrée/sortie du port
signal inoutport :			std_logic_vector (7 downto 0);

-- Definition de la constante de la période de l'horloge clk
constant clk_period : 	time 			:= 20 ns;
 
BEGIN
 
	-- Instantiation du composant ioport
   uut: ioport 
   Generic map (
		  BASE_ADDR 		=> 16#19# )
   PORT MAP (
		  clk 		=> clk,
          Rst 		=> rst,
          addr 		=> addr,
          ioread 	=> ioread,
          iowrite 	=> iowrite,          
		  rd 		=> rd,
          wr		=> wr,
          ioport	=> inoutport
        );

-- Processus de génération de l'horloge
clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
  
-- Processus de test
stim_proc: process
begin	
   
	-- Reset du système
	rst <= '1';
	wait for 100 ns;
	rst <= '0';
	-- activation de l'écriture
	wr <= '1';
	wait for clk_period*1;
	
	-- Ecriture du registre DDR
	iowrite		<= "11111111"; 	-- 0xFF
	addr 		<= "011010";	-- 0x1A
	wait for clk_period*1;
	
	-- Ecriture du registre PORT
	iowrite		<= "00110101"; 	-- 0x35
	addr 		<= "011011";	-- 0x1B
	wait for clk_period*1;
	
	-- Passage du mode écriture au mode lecture
	wr <= '0';
	rd <= '1';
	wait for clk_period*1;
	
	-- -- Lecture du registre PIN
	-- addr 		<= "011001";	-- 0x19
	-- wait for clk_period*1;

	-- Envoie d'une donnée à l'entrée du port
		-- inoutport	<= "11110000";	-- 0xF0
	wait for clk_period*1;
	
	-- Lecture du registre PORT
	addr 		<= "011011";	-- 0x1B
	wait for clk_period*1;
	
	-- -- Lecture du registre PIN
	-- addr 		<= "011001";	-- 0x19
	-- wait for clk_period*1;
	  
      wait;
   end process;
END;
