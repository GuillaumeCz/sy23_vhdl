library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer_multiplixer is
    Port ( CS : in  STD_LOGIC_VECTOR (3 downto 0);
           N : out  STD_LOGIC_VECTOR (7 downto 0));
end timer_multiplixer;

architecture timer_multiplixer_architecture of timer_multiplixer is

begin
-- Multiplexer to select the correct N=2^CS-1
with CS select
N <= "00000000" when "0000", -- not used
	 "00000000" when "0001", -- no division  
	 "00000001" when "0010", -- division by 2
	 "00000011" when "0011", -- division by 4
	 "00000111" when "0100", -- division by 8
	 "00001111" when "0101", -- division by 16
	 "00011111" when "0110", -- division by 32
	 "00111111" when "0111", -- division by 64
	 "01111111" when "1000", -- division by 128
	 "11111111" when "1001", -- division by 256
	 "11111111" when others; -- The counter is a 8 bit counter, 1001 is the max value that it can handle
	 


end timer_multiplixer_architecture;

