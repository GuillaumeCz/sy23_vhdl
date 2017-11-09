library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_RX is
	Generic (N : integer := 8);
    Port ( SPI_MISO : 	in  STD_LOGIC;								-- data received from memory
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
		   clk :		in	STD_LOGIC;								-- system clock
           SPI_SCK : 	out  STD_LOGIC;								-- SPI clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
           data_out : 	out  STD_LOGIC_VECTOR (N-1 downto 0));		-- data received on N bits
end SPI_RX;

architecture Behavioral of SPI_RX is

	component diviseur_generique
	Generic(clkdiv : integer := 2);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           tc0 : out  STD_LOGIC;
           tc1 : out  STD_LOGIC;
           clk_out : out  STD_LOGIC);
	end component;

-- constant
constant bauds : integer := 115200;
constant sysclk : real := 50.0e6 ; -- 50MHz
constant clkdiv : integer := integer(sysclk / real(bauds));
	
--state_next machine
type T_state is (idle, bitsdata);
signal state_next, state : T_state;

-- Counter
signal spicounter, spicounter_next : 		unsigned (N-1 downto 0) 			:= (others => '0');		-- Number of bit received counter

-- data buffer
signal data, data_next :					STD_LOGIC_VECTOR (N-1 downto 0)		:= (others => '0');		-- data received

-- clock
signal divided_clock : 						STD_LOGIC							:= '0';
signal tc0, tc1 :							STD_LOGIC							:= '0';

begin

-- Clock divider
   clk_divider: diviseur_generique 
   Generic map (
		  clkdiv	=> clkdiv )
   PORT MAP (
		  clk	=> clk,
          rst 	=> rst,
          tc0	=> tc0,
          tc1 	=> tc1,
		  clk_out  => divided_clock
		  );

-- Update the state
clock_tick: process(clk)
begin
	if rst = '1' then
		state 			<= idle;
	elsif rising_edge(clk) then
		state 			<= state_next;
		data			<= data_next;
		spicounter 		<= spicounter_next;
	end if;
end process clock_tick;

-- Calculate the next step
change_state: process(state, spicounter, spi_start, divided_clock)
begin
	state_next 							<= state;
	spicounter_next						<= spicounter;
	data_next							<= data;
	
	case state is
		when idle =>
			if spi_start = '1' then
				state_next 				<= bitsdata;
			end if;
			data_next					<= (others => '0');	-- reset counter 
			spicounter_next 			<= (others => '0');
			
		when bitsdata =>
			if falling_edge(divided_clock) then							-- Synchronize the reception of data on the SPI clock 
				data_next 				<= data(6 downto 0) & SPI_MISO; -- Add on the LSB the received bit.
				spicounter_next			<= spicounter + 1;				-- Add one to the counter of bit received
			end if;
			if spicounter <= N then
				state_next 				<= bitsdata;
			else
				state_next 				<= idle;
			end if;
	end case;
end process change_state;

-- Circuit select 
SPI_CS 			<= '1' when state_next = idle else '0';

-- Data out
data_out 		<= data_next;

-- SPI Clock
SPI_SCK <= divided_clock;

end Behavioral;

