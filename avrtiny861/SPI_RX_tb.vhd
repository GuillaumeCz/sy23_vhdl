LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- TestBench du composant SPI_RX  
ENTITY SPI_RX_tb IS
END SPI_RX_tb;
 
ARCHITECTURE behavior OF SPI_RX_tb IS 
 
-- Inclusion du composant SPI_RX 
COMPONENT SPI_RX
	Generic (N : integer := 8);
	Port ( SPI_MISO : 	in  STD_LOGIC;								-- data received from memory
		   spi_start : 	in  STD_LOGIC;								-- transmission start pulse
		   rst : 		in  STD_LOGIC;								-- reset
		   clk :		in	STD_LOGIC;								-- system clock
		   SPI_SCK : 	out  STD_LOGIC;								-- SPI clock
		   SPI_CS : 	out  STD_LOGIC;								-- select circuit
		   data_out : 	out  STD_LOGIC_VECTOR (N-1 downto 0));		-- data received on N bits
END COMPONENT;

-- Nombre de bits envoyés
constant N : integer := 8;    

-- Constante de division de fréquence d'horloge pour se synchroniser à l'horloge SCK
constant bauds : integer := 115200;
constant sysclk : real := 50.0e6 ; -- 50MHz
constant clkdiv : integer := integer(sysclk / real(bauds));
   
-- Entrées
-- Signal d'entré d'une horloge
signal clk : 				std_logic 							:= '0';
-- Signal d'entré de remise à 0
signal rst : 				std_logic 							:= '0';
-- Signal d'activation de la réception
signal spi_start : 			std_logic  							:= '0';
-- Bit reçu par le composant pour former un octet 
signal RX : 				std_logic  							:= '1';

-- Sorties
-- Données provenant de la concatenation des bits reçu en entrée.
signal data : 				std_logic_vector(N-1 downto 0);
-- Signal témoignant de l'activation de la réception
signal SPI_CS : 			std_logic;
-- Signal de sortie de l'horloge SCK du composant maitre
signal SPI_SCK : 			std_logic;

-- Definition de la constante de la période de l'horloge clk
constant clk_period :		time 								:= 10 ns;
 
BEGIN
 
-- Instantiate the Unit Under Test (UUT)
uut: SPI_RX 
Generic map (
	  N 		=> N )
PORT MAP (
	  SPI_MISO	=> RX,
	  spi_start	=> spi_start,
	  rst 		=> rst,
	  clk		=> clk,
	  SPI_SCK	=> SPI_SCK,
	  SPI_CS 	=> SPI_CS,
	  data_out  => data
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
	wait for 50 ns;
	rst <= '0';

	-- Activation de la séquence de réception
	spi_start <= '1';
	wait for clk_period*1;

	-- Désactivation du signal spi_start qui n'est plus utile pour l'instant
	spi_start <= '0';			--start of the sequence 0011 0101 0x35
	wait for clk_period*1;

	-- Réception d'un bit de l'octet 0x35 chaque période d'horloge SCK
	RX <= '0';
	wait for clk_period*clkdiv;
	RX <= '0';
	wait for clk_period*clkdiv;
	RX <= '1';
	wait for clk_period*clkdiv;
	RX <= '1';
	wait for clk_period*clkdiv;
	RX <= '0';
	wait for clk_period*clkdiv;
	RX <= '1';
	wait for clk_period*clkdiv;
	RX <= '0';
	wait for clk_period*clkdiv;
	RX <= '1';
  
	wait;
end process;

END;
