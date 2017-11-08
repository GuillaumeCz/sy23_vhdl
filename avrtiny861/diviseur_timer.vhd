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

signal divided_clk : std_logic := '0';
signal cpt : std_logic_vector(2 downto 0) := "000";
signal max_cpt : std_logic_vector(2 downto 0) := "000";

begin

  comptage: process(clk)
  begin
   if rising_edge(clk) then 
	 if rst = '1' then
	    cpt <= (others => '0');
    elsif cpt < max_cpt then
	    cpt <= std_logic_vector(unsigned(cpt) + 1);
	 else	
        cpt <= (others => '0');
        divided_clk <= not(divided_clk);
	 end if;
	end if;
  end process comptage;

  clk_out <= divided_clk;
  
  with N select
  max_cpt <= "000" when "00",
	   "000" when "01",
     "011" when "10",
     "111" when "11",
     "111" when others;
	
end architecture_diviseur_timer;

