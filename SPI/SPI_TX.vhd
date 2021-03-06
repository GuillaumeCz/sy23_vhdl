library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_TX is
	Generic (N : integer := 8);
    Port ( data_in : 	in  STD_LOGIC_VECTOR (N-1 downto 0);		-- data received from memory
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
		   clk :		in	STD_LOGIC;								-- system clock
           SPI_SCK : 	out  STD_LOGIC;								-- SPI clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
           SPI_MOSI : 	out  STD_LOGIC;		-- data received on N bits
		   x: out STD_LOGIC_VECTOR (1 downto 0);
		   y: out STD_LOGIC_VECTOR (N-1 downto 0);
		   z: out STD_LOGIC_VECTOR (N-1 downto 0));
end SPI_TX;

architecture Behavioral of SPI_TX is

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
	
-- Machine State
type T_state is (idle, bitsdata);
signal state, state_next : T_state;

-- Number of bits send counters.
signal spicounter, spicounter_next : unsigned(N-1 downto 0)		:= (others => '0');

-- data_in buffer that can be modified at will. 
signal data_buffer : 		STD_LOGIC_VECTOR (N-1 downto 0)		:= (others => '0');

-- Bit that will be send on the SPI_MOSI pin.
signal data_out	:			STD_LOGIC							:=	'0';

-- clock
signal divided_clock : 						STD_LOGIC			:= '0';
signal tc0, tc1 :							STD_LOGIC			:= '0';

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

-- Modify the state machine
clock_tick: process(clk, rst)
begin
	if rst = '1' then
	-- asynchrone reset system
		state 			<= idle;
	-- state on idle
		spicounter 		<= (others => '0');
		SPI_MOSI 		<= '0';
	-- counter reset
	elsif rising_edge(clk) then
		-- update counter and state on clock rising_edge
		state 			<= state_next;
		spicounter 		<= spicounter_next;
		SPI_MOSI 		<= data_out;
	end if;
end process clock_tick;

-- Calculate the next step
change_state: process (state, spi_start, spicounter, divided_clock)
begin
	-- set the next state and counter on the current state and counter
	state_next	 						<= state;
	spicounter_next 					<= spicounter;
	case state is 
		when idle =>			
			-- Change the next state if the start of a transmission is on '1'
			if spi_start = '1' then
				state_next	 			<= bitsdata;
			end if;
			-- When idle the system send a null bit and reset the counter to 0.
			spicounter_next 			<= (others => '0');
			data_out 					<= '0';
			data_buffer					<= data_in;

			
		when bitsdata =>
			if rising_edge(divided_clock) then							
				spicounter_next			<= spicounter + 1;				-- Add one to the counter of bit received
				-- send the next bit
				data_out	 			<= data_buffer(N-1);
				-- update the list of bit to send
				data_buffer				<= data_buffer(N-2 downto 0) & '0'; 
				
			end if;
			if spicounter <= N then
				state_next 				<= bitsdata;
			else
				state_next 				<= idle;
			end if;
	end case;
end process change_state;

-- Circuit select 
SPI_CS 			<= '1' when state = idle else '0';

-- SPI Clock
SPI_SCK <= divided_clock;

-- Data out

y <= std_logic_vector(spicounter);
z <= data_buffer;
with state select
x <= "00" when idle,
	 "10" when bitsdata;
end Behavioral;