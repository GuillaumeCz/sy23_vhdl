library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity diviseur_timer is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
		   N : in STD_LOGIC_VECTOR(1 downto 0);
           clk_out : out  STD_LOGIC);
end diviseur_timer;

architecture architecture_diviseur_timer of diviseur_timer is
-- Generated clock signal
signal divided_clk : 			std_logic 						:= '0';
-- Counter
signal cpt : 					std_logic_vector(2 downto 0)	:= (others => '0');
-- Max Counter value
signal max_cpt : 				std_logic_vector(2 downto 0) 	:= (others => '0');

begin

  comptage: process(clk, rst)
  begin
	-- asynchronous reset
	if rst = '1' then
		-- reset counter
	    cpt 				<= (others => '0');
		-- reset generated clock
		divided_clk			<= '0';
    elsif rising_edge(clk) then 
		if cpt < max_cpt then
			-- increase the counter when the max counter value is not reached
			cpt 			<= std_logic_vector(unsigned(cpt) + 1);
		else
			-- reset the counter when the max value is reached
			cpt 			<= (others => '0');
			-- Invert the generated clock to create a raising/falling edge signal 
			divided_clk 	<= not(divided_clk);
		end if;
	end if;
  end process comptage;

  -- assign the output to the generated clock
  clk_out <= divided_clk;
  
  -- select the max value of the counter depending of the number of bit that must be counted
  with N select
  max_cpt <= 	"000" when "00", -- divide by 1
				"001" when "01", -- divide by 2
				"011" when "10", -- divide by 4
				"111" when "11", -- divide by 8
				"111" when others;  -- max divison is 8
				
end architecture_diviseur_timer;

