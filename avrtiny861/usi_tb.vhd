LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- TestBench du composant usi
ENTITY usi_tb IS
END usi_tb;

ARCHITECTURE behavior OF usi_tb IS

-- Inclusion du composant usi
COMPONENT usi
	Generic (BASE_ADDR	: integer := 16#0D#);
    Port ( clk : 		in  STD_LOGIC;
           Rst : 		in  STD_LOGIC;
           addr : 		in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : 	out STD_LOGIC_VECTOR (7 downto 0);
           iowrite : 	in  STD_LOGIC_VECTOR (7 downto 0);
           wr : 		in  STD_LOGIC;
           rd : 		in  STD_LOGIC;
           SCK : 		out STD_LOGIC;
           MOSI : 		out STD_LOGIC;
           MISO : 		in  STD_LOGIC);
END COMPONENT;

-- Constante de division de fréquence d'horloge pour se synchroniser à l'horloge SCK
constant bauds 	: integer := 115200;
constant sysclk : real := 50.0e6 ; -- 50MHz
constant clkdiv : integer := integer(sysclk / real(bauds));

--Entrées
-- Signal d'entré d'une horloge
signal clk : 				std_logic 							:= '0';
-- Signal d'entré de remise à 0
signal rst : 				std_logic 							:= '0';
-- Signal d'entré de adresse du registre pointé
signal addr :				std_logic_vector (5 downto 0)		:= (others=> '0');
-- Signal d'entré avec les valeurs du registre pointé par l'adresse precedente
signal iowrite :			std_logic_vector (7 downto 0) 		:= (others=> '0');
-- Signal d'entré de lecture
signal rd :					std_logic							:= '0';
-- Signal d'entré d'écriture
signal wr :					std_logic							:= '0';
-- Signal d'envoie de bit du maitre à l'esclave
signal MISO		: std_logic								:= '0';

--Sorties
-- Signal de sortie de la lecture
signal ioread	: std_logic_vector(7 downto 0);
-- Signal de sortie de l'horloge SCK du composant maitre
signal SCK		: std_logic;
-- Signal d'envoie de bit par le maitre à l'esclave
signal MOSI		: std_logic;

-- Définition de la période d'horloge
constant clk_period : 		time := 10 ns;

BEGIN

	-- Instantiation du composant
   uut: usi
   Generic map (
		  BASE_ADDR 		=> 16#0D# )
   PORT MAP (
		  clk 		=> clk,
          Rst 		=> rst,
          addr 		=> addr,
          ioread 	=> ioread,
          iowrite 	=> iowrite,
          wr		=> wr,
          rd 		=> rd,
          SCK 		=> SCK,
          MOSI 		=> MOSI,
          MISO 		=> MISO
        );

-- Processus d'évolution de la valeur de l'horloge
clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

-- Processus de stimulation, test du composant
stim_proc: process
begin

	-- initialisation du composant avec l'envoi d'un signal de reset pendant 50ns
	rst <= '1';
	-- wait for 50 ns;
	rst <= '0';

	-- Activation du mode écriture
	wr <= '1';
	wait for clk_period*1;

	-- Ecriture du registre de contrôle USICR
	addr 		<= "001101";  -- 0x0F
	iowrite 	<= "11010011";
	wait for clk_period*1;

	-- Ecriture du registre de données USIDR et par conséquent envoi de l'octet 0x35 sur le pin MOSI
	addr 		<= "001111";	-- 0x0D
	iowrite 	<= "00110101";
	wait for clk_period*1;
	wr 		<= '1';
	wait for clk_period*1;
	wr 		<= '0';
	wait for clk_period*1;

	-- Désactivation du mode écriture
	wr 		<= '0';

	-- Attente de 20 fois la période d'horloge SCK
	wait for clk_period*clkdiv*20;

	-- Mise à l'addresse du port USIDR et activation du mode lecture
	addr 		<= "001111";	-- 0x0D
	wait for clk_period*1;
	rd 		<= '1';
	wait for clk_period*1;
	rd 		<= '0';
	-- Envoie d'un bit de l'octet 0x35 chaque période d'horloge SCK
	MISO <= '0';
	wait for clk_period*clkdiv;
	MISO <= '0';
	wait for clk_period*clkdiv;
	MISO <= '1';
	wait for clk_period*clkdiv;
	MISO <= '1';
	wait for clk_period*clkdiv;
	MISO <= '0';
	wait for clk_period*clkdiv;
	MISO <= '1';
	wait for clk_period*clkdiv;
	MISO <= '0';
	wait for clk_period*clkdiv;
	MISO <= '1';

	-- Désactivation du mode lecture
	wait for clk_period*clkdiv;
	rd 		<= '0';


	wait;
end process;
END;
