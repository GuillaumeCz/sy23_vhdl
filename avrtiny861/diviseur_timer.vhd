library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity diviseur_timer is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
		   N : in STD_LOGIC_VECTOR(3 downto 0);
           clk_out : out  STD_LOGIC);
end diviseur_timer;

architecture architecture_diviseur_timer of diviseur_timer is

-- calcul du nombre de bits en fonction de la valeur maximale
function intlog2 (x : natural) return natural is
 variable temp : natural := x ;
 variable n : natural := 0 ;
 begin
    while temp > 1 loop
        temp := temp / 2 ;
        n := n + 1 ;
    end loop ;
    return n ;
end function intlog2 ;

signal cpt : unsigned(7 downto 0);

begin

  comptage: process(clk)
  begin
   if rising_edge(clk) then 
	 if rst = '1' then
	    cpt <= (others => '0');
    elsif cpt < unsigned(N)-1 then
	    cpt <= cpt + 1;
	 else	
        cpt <= (others => '0');
	 end if;
	end if;
  end process comptage;
  
  retenue: process(cpt)
	begin	
		if cpt >= 0 and cpt <= (unsigned(N)-1)/2 then -- clk0  = clk/N
		   clk_out <= '1';
		else
		  clk_out <= '0';
      end if;		
	end process retenue; 
	
end architecture_diviseur_timer;

