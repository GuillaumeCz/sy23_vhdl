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

constant USIDR : integer := BASE_ADDR ;
constant USISR : integer := BASE_ADDR + 1;
constant USICR : integer := BASE_ADDR + 2;

signal reg_usidr : STD_LOGIC_VECTOR (7 downto 0);
signal reg_usisr : STD_LOGIC_VECTOR (7 downto 0);
signal reg_usicr : STD_LOGIC_VECTOR (7 downto 0);

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


-- constant
constant bauds : integer := 115200;
constant sysclk : real := 50.0e6 ; -- 50MHz
constant clkdiv : integer := integer(sysclk / real(bauds));

-- clock
signal control_clock :						STD_LOGIC							:= '0';
signal activate_clock:						STD_LOGIC							:= '0';


signal SPI_TX_start:  						std_logic := '0';
signal SPI_RX_start:  						std_logic := '0';
signal SPI_TX_SCK:  						std_logic := '0';
signal SPI_RX_SCK:  						std_logic := '0';
signal SPI_TX_CS:  							std_logic := '0';
signal SPI_RX_CS:  							std_logic := '0';

signal RX_out: 								STD_LOGIC_VECTOR (7 downto 0);		-- data transmitted
	
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
		  
		  
-- Modify the state machine
clock_tick: process(clk, SPI_RX_CS)
	variable a_int : 	natural;
	variable rdwr : 	std_logic_vector(1 downto 0);
	variable CS_TXRX : 	std_logic_vector (1 downto 0);
begin
	if (rising_edge(clk)) then		
		a_int 		:= to_integer(unsigned(addr));
		rdwr 		:= rd & wr;
		CS_TXRX		:= SPI_TX_CS & SPI_RX_CS;
		SPI_TX_start <= '0';
		SPI_RX_start <= '0';
		if (a_int = USIDR) then
		  case rdwr is
			 when "10" => -- rd
				ioread <= reg_usidr;
				if (CS_TXRX = "11") then
					SPI_RX_start 	<= '1';
				end if;
			 when "01" => -- wr
				if (CS_TXRX = "11") then
					SPI_TX_start 	<= '1';
				end if;
			 when others => NULL; 
		  end case;
		elsif (a_int = USISR) then
			case rdwr is
				when "10" => -- rd
					ioread 	<= reg_usisr;
				when "01" => NULL;-- wr
				when others => NULL; 
			end case;
		elsif (a_int = USICR) then
			case rdwr is
				when "10" => NULL; -- rd
				when "01" => -- wr
					reg_usicr	<= iowrite;
				when others => NULL; 
			end case;
		end if;
	end if;
end process clock_tick;

-- reg_usidr <= RX_out	when bIOwriteactive = '1' else
			 -- iowrite;

reg_usidr <= RX_out		when rd ='1' and to_integer(unsigned(addr)) = USIDR else
			 iowrite	when wr ='1' and to_integer(unsigned(addr)) = USIDR ;
			 
-- SPI Clock
SCK			<= SPI_TX_SCK when SPI_TX_CS = '0' and SPI_RX_CS = '1' else
			   SPI_RX_SCK when SPI_TX_CS = '1' and SPI_RX_CS = '0' else 
			   '0';


control_clock <= '0' 			when reg_usicr (3 downto 1) = "000" else
				 activate_clock when reg_usicr (3 downto 1) = "001";

activate_clock <= clk 			when reg_usicr(5 downto 4) = "01" else 
				 '0'; 
	

end usi_architecture;

