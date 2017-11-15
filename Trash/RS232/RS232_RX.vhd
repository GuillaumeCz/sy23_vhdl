--------------------------------------------------------
-- RS 232  Receiver
--------------------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;			   

entity RS232_RX is
port( 	clk:		in std_logic;
		rst:		in std_logic;
		RX :		in std_logic;
		data:		out std_logic_vector(7 downto 0);
		rx_done: 	out std_logic
);
end RS232_RX;

architecture behavioral of RS232_RX is

--State
type T_state is (idle,bitstart,bitsdata, bitstop);
signal next_state, current_state : 			T_state;

--Counter
signal clksample, clksample_next:			unsigned (3 downto 0) 			:= (others => '0');
signal bitcpt: 								unsigned (3 downto 0) 			:= (others => '0');

--Buffer
signal data_buffer:							std_logic_vector(7 downto 0)	:= (others => '0');

begin
	
Clock_tick: process(clk, rst)
begin
	if rst = '1' then
		current_state 			<= idle;
	elsif rising_edge(clk) then
		clksample 			<= clksample_next;
		current_state 			<= next_state;
	end if;
	
end process Clock_tick;

etat_suivant: process(current_state, RX, clksample)
begin
next_state <= current_state;
clksample_next <= clksample;
case current_state is 
	when idle => 
		if RX = '0' then
			next_state 			<= bitstart;
		end if;
		bitcpt 					<= (others => '0');
		clksample_next			<= (others => '0');
	when bitstart =>
		clksample_next		<= clksample + 1;
		if clksample = 8 then  -- count to 8
			next_state 			<= bitsdata;
			clksample_next		<= (others => '0');
		end if;
	when bitsdata =>						-- 1 2 3 4 5 6 7 8
		if bitcpt < 8 then				-- 0 1 2 3 4 5 6 7
			if clksample = 15 then 		--count to 16
				next_state 		<= bitsdata;
				data_buffer 	<= data_buffer(6 downto 0) & RX;
				bitcpt 			<= bitcpt + 1;
			end if;
			clksample_next		<= clksample + 1;
		else 
			next_state 			<= bitstop;
		end if;
	when bitstop =>
		if clksample = 15 then
			next_state 			<= idle;
		end if;
		clksample_next			<= clksample + 1;
end case;
end process etat_suivant;

rx_done <= '1' 					when current_state = bitstop else '0';
data	<= data_buffer			when current_state = bitstop else (others => '0');


end behavioral;