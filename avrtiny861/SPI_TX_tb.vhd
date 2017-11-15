LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- TestBench du composant SPI_TX   
ENTITY SPI_TX_tb IS
END SPI_TX_tb;
 
ARCHITECTURE behavior OF SPI_TX_tb IS 
 
-- Inclusion du composant SPI_TX 
COMPONENT SPI_TX
Generic (N : integer := 8);
Port ( data_in : 	in  STD_LOGIC_VECTOR (N-1 downto 0);		-- data received from memory
	   spi_start : 	in  STD_LOGIC;								-- transmission start pulse
	   rst : 		in  STD_LOGIC;								-- reset
	   clk :		in	STD_LOGIC;								-- system clock
	   SPI_SCK : 	out  STD_LOGIC;								-- clock
	   SPI_CS : 	out  STD_LOGIC;								-- select circuit
	   SPI_MOSI : 	out  STD_LOGIC								-- data received on N bits
	   );
END COMPONENT;
   
-- Nombre de bits envoyés
constant N : integer := 8;    
   
-- Entrées
-- Signal d'entré d'une horloge
signal clk : 				std_logic 							:= '0';
-- Signal d'entré de remise à 0
signal rst : 				std_logic 							:= '0';
-- Signal d'activation de la réception
signal spi_start : 			std_logic  							:= '0';
-- Données qui vont être transmise par le composant
signal data : 				std_logic_vector(N-1 downto 0)		:= (others => '0');

-- Sorties
-- Bit de sortie qui va correpondre à la séquence de données data
signal TX : 				std_logic;
-- Signal témoignant de l'activation de la réception
signal SPI_CS : 			std_logic;
-- Signal de sortie de l'horloge SCK du composant maitre
signal SPI_SCK : 			std_logic;

-- Definition de la constante de la période de l'horloge clk
constant clk_period :		time 								:= 10 ns;
 
BEGIN
 
-- Instantiate the Unit Under Test (UUT)
uut: SPI_TX 
Generic map (
	  N 		=> N )
PORT MAP (
	  data_in	=> data,
	  spi_start	=> spi_start,
	  rst 		=> rst,
	  clk		=> clk,
	  SPI_SCK	=> SPI_SCK,
	  SPI_CS 	=> SPI_CS,
	  SPI_MOSI  => TX
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
	rst 			<= '1';
	wait for 50 ns;
	rst 			<= '0';
	
	-- Ecriture des données à envoyer 
	data		 	<= "00110101";	-- Envoie de la séquence 0011 0101 0x35
	wait for clk_period*1;
	
	-- Activation de la séquence d'envoie
	spi_start 	<= '1';
	wait for clk_period*1;
	
	-- Désactivation du signal spi_start qui n'est plus utile pour l'instant
	spi_start 	<= '0';

	wait;
end process;

END;
