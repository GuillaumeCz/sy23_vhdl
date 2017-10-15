library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_RX is
	Generic (N : integer := 8);
    Port ( SPI_MISO : 	in  STD_LOGIC;								-- data received from memory
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
           SPI_SCK : 	in  STD_LOGIC;								-- clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
           data_out : 	out  STD_LOGIC_VECTOR (N-1 downto 0);		-- data received on N bits
		   x: out STD_LOGIC_VECTOR (1 downto 0);
		   y: out STD_LOGIC_VECTOR (N-1 downto 0));
end SPI_RX;

architecture Behavioral of SPI_RX is

--State machine
type T_state is (idle, bitsdata);
signal next_state, current_state : T_state;

--Counter
signal spicounter : 		unsigned (N-1 downto 0) 			:= (others => '0');

--buffer
signal data_buffer : 		STD_LOGIC_VECTOR (N-1 downto 0)		:= (others => '0');		-- Buffer for data
signal spicounter_buff :	unsigned (N-1 downto 0) 			:= (others => '0');		-- Buffer for spicounter

begin

clock_tick: process(SPI_SCK)
begin
	if rst = '1' then
		current_state 	<= idle;
	elsif rising_edge(SPI_SCK) then
		current_state 	<= next_state;
		spicounter 		<= spicounter_buff;
		data_out 		<= data_buffer;
	end if;
end process clock_tick;

change_state: process(spicounter, spi_start)
begin
	next_state 					<= current_state;
	case current_state is
		when idle =>
			if spi_start = '1' then
				next_state 		<= bitsdata;
			end if;
			data_buffer			<= (others => '0');
			spicounter_buff 	<= (others => '0');
			
		when bitsdata =>
			if spicounter < N then
				next_state 		<= bitsdata;
				data_buffer 	<= data_buffer(6 downto 0) & SPI_MISO;
				spicounter_buff	<= spicounter_buff + 1;
			else
				next_state 		<= idle;
			end if;
	end case;
end process change_state;

SPI_CS 	<= '1' when current_state = idle else '0';
		
y <= std_logic_vector(spicounter);
with current_state select
x <= "00" when idle,
	 "10" when bitsdata;

end Behavioral;

