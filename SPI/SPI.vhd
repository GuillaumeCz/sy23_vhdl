library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI is
	Generic (N : integer := 8;
			 M : integer := 8);
    Port ( data_in : 	in  STD_LOGIC_VECTOR (N-1 downto 0);		-- data received from memory
		   SPI_MISO : 	in  STD_LOGIC;								-- data received from memory
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
		   clk :		in	STD_LOGIC;								-- system clock
           SPI_SCK : 	out  STD_LOGIC;								-- SPI clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
		   data_out : 	out  STD_LOGIC_VECTOR (M-1 downto 0);		-- data received on N bits
           SPI_MOSI : 	out  STD_LOGIC;		-- data received on N bits
		   x: out STD_LOGIC_VECTOR (1 downto 0);
		   y: out STD_LOGIC_VECTOR (N-1 downto 0);
		   z: out STD_LOGIC_VECTOR (N-1 downto 0));
end SPI;

architecture Behavioral of SPI is

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
type T_state is (idle, bitswrite, bitsread);
signal state, state_next : T_state;

-- Number of bits send counters.
signal rcounter, rcounter_next : 			unsigned(N-1 downto 0)				:= (others => '0');
signal wcounter, wcounter_next : 			unsigned(N-1 downto 0)				:= (others => '0');

-- data_in buffer that can be modified at will. 
signal data_in_buffer : 					STD_LOGIC_VECTOR (N-1 downto 0)		:= (others => '0');

-- Bit that will be send on the SPI_MOSI pin.
signal data_to_MOSI	:						STD_LOGIC							:=	'0';

-- data buffer
signal MISO_to_data, MISO_to_data_next :	STD_LOGIC_VECTOR (M-1 downto 0)		:= (others => '0');		-- data received

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

-- Modify the state machine
clock_tick: process(clk, rst)
begin
	if rst = '1' then
	-- asynchrone reset system
		state 	<= idle;
	-- state on idle
		rcounter 		<= (others => '0');
		wcounter 		<= (others => '0');
		SPI_MOSI 		<= '0';
	-- counter reset
	elsif rising_edge(clk) then
		-- update counter and state on clock rising_edge
		state 			<= state_next;
		rcounter 		<= rcounter_next;
		wcounter		<= wcounter_next;
		SPI_MOSI 		<= data_to_MOSI;
		MISO_to_data	<= MISO_to_data_next;
	end if;
end process clock_tick;

-- Calculate the next step
change_state: process (state, spi_start, rcounter, wcounter, divided_clock)
begin
	-- set the next state and counter on the current state and counter
	state_next	 				<= state;
	rcounter_next 				<= rcounter;
	wcounter_next				<= wcounter;
	MISO_to_data_next			<= MISO_to_data;
	
	case state is 
		when idle =>			
			-- Change the next state if the start of a transmission is on '1'
			if spi_start = '1' then
				state_next	 			<= bitswrite;
			end if;
			-- When idle the system send a null bit and reset the counter to 0.
			rcounter_next 				<= (others => '0');
			wcounter_next				<= (others => '0');
			data_to_MOSI 				<= '0';
			data_in_buffer				<= data_in;

		when bitswrite =>
			if rising_edge(divided_clock) then							
				wcounter_next			<= wcounter + 1;				-- Add one to the counter of bit received
				-- send the next bit
				data_to_MOSI	 		<= data_in_buffer(N-1);
				-- update the list of bit to send
				data_in_buffer			<= data_in_buffer(N-2 downto 0) & '0'; 
				
			end if;
			if wcounter <= N then
				state_next 				<= bitswrite;
			else
				state_next 				<= bitsread;
			end if;
			
		when bitsread =>
			if falling_edge(divided_clock) then							-- Synchronize the reception of data on the SPI clock 
				MISO_to_data_next 		<= MISO_to_data(M-2 downto 0) & SPI_MISO; -- Add on the LSB the received bit.
				rcounter_next			<= rcounter + 1;				-- Add one to the counter of bit received
			end if;
			if rcounter < M then
				state_next 				<= bitsread;
			else
				state_next 				<= idle;
			end if;
			
	end case;
end process change_state;

-- Circuit select 
SPI_CS 			<= '1' when state = idle else '0';

-- SPI Clock
SPI_SCK 		<= divided_clock;

-- Data out
data_out 		<= MISO_to_data;



y <= std_logic_vector(wcounter);
z <= std_logic_vector(rcounter);
with state select
x <= "00" when idle,
	 "01" when bitswrite,
	 "10" when bitsread;
end Behavioral;