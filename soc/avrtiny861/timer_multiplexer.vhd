library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer_multiplixer is
    Port ( CS : in  STD_LOGIC_VECTOR (3 downto 0);
           N : out  STD_LOGIC_VECTOR (7 downto 0));
end timer_multiplixer;

architecture timer_multiplixer_architecture of timer_multiplixer is

begin

with CS select
N <= "00000000" when "0000",
	 "00000000" when "0001",
	 "00000001" when "0010",
	 "00000011" when "0011",
	 "00000111" when "0100",
	 "00001111" when "0101",
	 "00011111" when "0110",
	 "00111111" when "0111",
	 "01111111" when "1000",
	 "11111111" when "1001",
	 "11111111" when others;
	 


end timer_multiplixer_architecture;
