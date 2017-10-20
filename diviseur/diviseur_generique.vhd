library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use work.all; 

entity diviseur_generique is
    Generic(clkdiv : integer := 2);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           tc0 : out  STD_LOGIC;
           tc1 : out  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end diviseur_generique;

architecture architecture_diviseur_generique of diviseur_generique is

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

constant Nbits : natural :=  intlog2(clkdiv);

signal cpt : std_logic_vector(Nbits downto 0);

begin

  comptage: process(clk)
  begin
   if rising_edge(clk) then 
	 if rst = '1' then
	    cpt <= (others => '0');
    elsif cpt < clkdiv-1 then
	    cpt <= cpt + 1;
	 else	
        cpt <= (others => '0');
	 end if;
	end if;
  end process comptage;
  
  retenue: process(cpt)
	begin
		 if cpt=clkdiv-1 then -- tc1 impulsion a N
			tc1 <= '1';
		 else 
			tc1 <= '0';
		 end if;
		 if cpt=(clkdiv-1)/2 then -- tc0 impulsion a N/2
			tc0 <= '1';
		 else 
			tc0 <= '0';
		 end if;		
		if cpt >= 0 and cpt <= (clkdiv-1)/2 then -- clk0  = clk/N
		   clk_out <= '0';
		else
		  clk_out <= '1';
      end if;		
	end process retenue;  


end architecture_diviseur_generique;

