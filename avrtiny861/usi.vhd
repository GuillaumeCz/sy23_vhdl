library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity usi is
	 Generic (BASE_ADDR	: integer := 16#0D#);
    Port ( clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           wr : in  STD_LOGIC;
           rd : in  STD_LOGIC;
           SCK : out  STD_LOGIC;
           MOSI : out  STD_LOGIC;
           MISO : in  STD_LOGIC);
end usi;

architecture usi_architecture of usi is

constant USICR : integer := BASE_ADDR ;
constant USISR : integer := BASE_ADDR + 1;
constant USIDR : integer := BASE_ADDR + 2;

signal reg_usidr : STD_LOGIC_VECTOR (7 downto 0);
signal reg_usisr : STD_LOGIC_VECTOR (7 downto 0);
signal reg_usicr : STD_LOGIC_VECTOR (7 downto 0);

-- Déclaration du composant récepteur SPI
component SPI_RX
	Generic (N : integer := 8);
    Port ( SPI_MISO : 	in  STD_LOGIC;								-- data received
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
		   clk :		in	STD_LOGIC;								-- system clock
           SPI_SCK : 	out  STD_LOGIC;								-- SPI clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
           data_out : 	out  STD_LOGIC_VECTOR (N-1 downto 0));		-- data received on N bits
end component;

-- Déclaration du composant transmetteur SPI
component SPI_TX
	Generic (N : integer := 8);
    Port ( data_in : 	in  STD_LOGIC_VECTOR (N-1 downto 0);		-- data transmitted
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
		   clk :		in	STD_LOGIC;								-- system clock
           SPI_SCK : 	out  STD_LOGIC;								-- spi clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
           SPI_MOSI : 	out  STD_LOGIC);							-- data transmitted
end component;

-- Signaux permettant d'activer l'horloge
signal control_clock :						STD_LOGIC							:= '0';
signal activate_clock:						STD_LOGIC							:= '0';

-- Signal d'activation de la transmission
signal SPI_TX_start:  						std_logic := '0';
-- Signal d'activation de la réception
signal SPI_RX_start:  						std_logic := '0';
-- Signal d'horloge de la transmission
signal SPI_TX_SCK:  						std_logic := '0';
-- Signal d'horloge de la réception
signal SPI_RX_SCK:  						std_logic := '0';
-- Signal témoignant de l'activation de la transmission
signal SPI_TX_CS:  							std_logic := '0';
-- Signal témoignant de l'activation de la réception
signal SPI_RX_CS:  							std_logic := '0';


-- Signal de sortie du composant de réception. Correspond à l'octet reçu
signal RX_out: 								STD_LOGIC_VECTOR (7 downto 0);

begin
	Receiver: SPI_RX
	Generic map (
			N => 8 )
    Port map(
			SPI_MISO 	=> MISO,
			spi_start 	=> SPI_RX_start,
			rst 		=> rst,
			clk 		=> control_clock,
			SPI_SCK 	=> SPI_RX_SCK,
			SPI_CS 		=> SPI_RX_CS,
			data_out 	=> RX_out
			);

	Transmitter: SPI_TX
	Generic map (
			N => 8 )
    Port map(
			data_in 	=> reg_usidr,
			spi_start 	=> SPI_TX_start,
			rst 		=> rst,
			clk 		=> control_clock,
			SPI_SCK 	=> SPI_TX_SCK,
			SPI_CS 		=> SPI_TX_CS,
			SPI_MOSI 	=> MOSI
			);


-- Processus de changement d'état
clock_tick: process(clk)
-- Variable locale exprimant la valeur de l'adresse du registre pointé
variable a_int : natural;
-- Variable local du mode de fonctionnement du timer (lecture / ecriture)
variable rdwr : 	std_logic_vector(1 downto 0);
-- Variable local du composant en cours de traitement (transmission/réception)
variable CS_TXRX : 	std_logic_vector (1 downto 0);
begin
	if (rising_edge(clk)) then
		-- A chaque période de l'horloge
		-- Saisie de l'adresse en entré dans la variable local a_int
		a_int := to_integer(unsigned(addr));
		-- Concatenation des signaux d'entrés de lecture et ecriture
		rdwr  := rd & wr;
		-- Concatenation des signaux témoins de traitement
		CS_TXRX		:= SPI_TX_CS & SPI_RX_CS;
		-- Mise à 0 des signaux d'activation des composants
		SPI_TX_start <= '0';
		SPI_RX_start <= '0';
		if (a_int = USIDR) then
		-- Dans le cas où l'adresse en entrée corresponde au registre USIDR
		  case rdwr is
			 when "10" => -- rd
				-- Lecture du registre de données à chaque signal d'horloge 
				ioread <= reg_usidr;
				if (CS_TXRX = "11") then
					-- Si le composant de réception n'est pas activé, le composant est activé
					SPI_RX_start 	<= '1';
				end if;
			 when "01" => -- wr
				if (CS_TXRX = "11") then
				-- Si le composant de transmission n'est pas activé, le composant est activé
					SPI_TX_start 	<= '1';
				end if;
			 when others => NULL;
		  end case;
		elsif (a_int = USISR) then
		-- Dans le cas où l'adresse en entrée corresponde au registre USISR
			case rdwr is
				when "10" => -- rd
					-- Lecture du registre d'interruption
					ioread 	<= reg_usisr;
				when "01" => NULL;
				-- On ne peut pas écrire dans le registre des flags d'interruption
				when others => NULL;
			end case;
		elsif (a_int = USICR) then
		-- Dans le cas où l'adresse en entrée corresponde au registre USICR
			case rdwr is
				when "10" => NULL; -- rd
					-- Lecture du registre de contrôle dans ioread
					ioread	<= reg_usicr;
				when "01" => -- wr
					-- Ecriture du registre de contrôle avec la valeur de iowrite
					reg_usicr	<= iowrite;
				when others => NULL;
			end case;
		end if;
	end if;
end process clock_tick;

-- Ecrit reg_usidr avec la valeur d'entrée du composant USI quand celui-ci est en mode écriture et l'adresse correspond à l'addresse du registre de données
-- Dans le cas contraire : ecrit reg_usidr avec la valeur de sortie du recepteur RX_out
reg_usidr <= iowrite	when  wr ='1' and to_integer(unsigned(addr)) = USIDR else
			 RX_out;

-- Affecte la valeur de l'horloge SPI en fonction du composant qui est utilisé sinon mets à 0 l'horloge SCK
SCK			<= SPI_TX_SCK when SPI_TX_CS = '0' and SPI_RX_CS = '1' else
			   SPI_RX_SCK when SPI_TX_CS = '1' and SPI_RX_CS = '0' else
			   '0';

-- Selection de l'horloge en fonction des bits USICS du registre USICR 
  -- horloge interne si 
control_clock <= '0' 			when reg_usicr (3 downto 1) = "000" else
				 activate_clock when reg_usicr (3 downto 1) = "001";
-- Definition de la valeur de l'horloge d'activation en fonction du nombre de fils de la transmission
activate_clock <= clk 			when reg_usicr(5 downto 4) = "01" else
				 '0';


end usi_architecture;
