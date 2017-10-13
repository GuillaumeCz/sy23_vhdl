--------------------------------------------------------
-- RS 232  Receiver
--------------------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;			   

entity RS232_receiver is
port( 	clk:		in std_logic;
		rst:		in std_logic;
		RX :		in std_logic;
		data:		out std_logic_vector(7 downto 0);
		rx_done: 	out std_logic;
		x: out std_logic_vector (1 downto 0);
		y: out std_logic_vector (3 downto 0);
		z: out std_logic_vector (3 downto 0)
);
end RS232_receiver;

architecture behavioral of RS232_receiver is

--State
type T_state is (idle,bitstart,bitsdata, bitstop);
signal next_state, current_state : 			T_state;

--Counter
signal clksample: 							std_logic_vector (3 downto 0) 	:= (others => '0');
signal bitcpt: 								std_logic_vector (3 downto 0) 	:= (others => '0');

--Buffer
signal data_buffer:							std_logic_vector(7 downto 0)	:= (others => '0');

begin
	
Clock_tick: process(clk, rst)
begin
	if rst = '1' then
		current_state 			<= idle;
	elsif rising_edge(clk) then
		if next_state = current_state then
			clksample 			<= std_logic_vector( unsigned(clksample) + 1);
		else
			clksample			<= (others => '0');
		end if;
		current_state 			<= next_state;
	end if;
	
end process Clock_tick;

etat_suivant: process(current_state, RX, clksample)
begin
next_state <= current_state;
case current_state is 
	when idle => 
		if RX = '0' then
			next_state 			<= bitstart;
		end if;
		bitcpt 					<= (others => '0');
	when bitstart =>
		if clksample = "0111" then  -- count to 8
			next_state 			<= bitsdata;
		end if;
	when bitsdata =>						-- 1 2 3 4 5 6 7 8
		if bitcpt < "1000" then				-- 0 1 2 3 4 5 6 7
			if clksample = "1111" then --count to 16
				next_state 		<= bitsdata;
				data_buffer 	<= data_buffer(6 downto 0) & RX;
				bitcpt 			<= std_logic_vector( unsigned(bitcpt) + 1);
			end if;
		else 
			next_state 			<= bitstop;
		end if;
	when bitstop =>
		if clksample = "1111" then
			next_state 			<= idle;
		end if;
end case;
end process etat_suivant;

rx_done <= '1' 					when current_state = bitstop else '0';
data	<= data_buffer			when current_state = bitstop else (others => '0');


--test
y <= clksample;
z <= bitcpt;
with current_state select
x <= "00" when idle,
     "01" when bitstart,
	 "10" when bitsdata,
	 "11" when bitstop;

end behavioral;