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
           SPI_MOSI : 	out  STD_LOGIC);						-- data received on N bits
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
signal current_state, next_state : T_state;

-- Number of bits send counters.
signal spicounter, spicounter_next :	STD_LOGIC_VECTOR(N-1 downto 0)		:= (others => '0');

-- data_in buffer that can be modified at will. 
signal data_buffer : 					STD_LOGIC_VECTOR (N-1 downto 0)		:= (others => '0');

-- Bit that will be send on the SPI_MOSI pin.
signal data_out	:						STD_LOGIC							:=	'0';

-- clock
signal divided_clock :					STD_LOGIC							:= '0';
signal tc0, tc1 :						STD_LOGIC							:= '0';
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
clock_tick: process(clk,rst)
begin
	if rst = '1' then
	-- asynchrone reset system
		current_state 	<= idle;
	-- current_state on idle
		spicounter 		<= (others => '0');
		SPI_MOSI 		<= '0';
	-- counter reset
	elsif rising_edge(clk) then
		-- update counter and state on clock rising_edge
		current_state 	<= next_state;
		spicounter 		<= spicounter_next;
		SPI_MOSI 		<= data_out;
	end if;
end process clock_tick;

-- Calculate the next step
change_state: process (current_state, spi_start, spicounter, divided_clock)
begin
	-- set the next state and counter on the current state and counter
	next_state	 				<= current_state;
	spicounter_next 			<= spicounter;
	case current_state is 
		when idle =>
			-- When idle the system send a null bit and reset the counter to 0.
			spicounter_next 	<= (others => '0');
			-- data_out 			<= '0';
			
			-- Change the next state if the start of a transmission is on '1'
			if spi_start = '1' then
				data_buffer		<= data_in;
				next_state	 	<= bitsdata;
			end if;
			
		when bitsdata =>
			if rising_edge(divided_clock) then							-- Synchronize the reception of data on the SPI clock 
				-- Add one to the counter
				spicounter_next	 	<= std_logic_vector(unsigned(spicounter) + 1);
				data_buffer			<= data_buffer(N-2 downto 0) & '0'; 
			end if;
			if to_integer(unsigned(spicounter)) < N then
					-- If the number of bits send is lower than the number bits to send the state machine stay in sending mode
					next_state	 	<= bitsdata;
					-- send the next bit
				else
					next_state		<= idle;
				end if;
		when others =>
			-- autre cas : valeur par defaut
	end case;
end process change_state;

-- Circuit select 
SPI_CS 			<= '1' when current_state = idle else '0';
SPI_SCK			<= divided_clock;
data_out	 	<= data_buffer(N-1);

end Behavioral;