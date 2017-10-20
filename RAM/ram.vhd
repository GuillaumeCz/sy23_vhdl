library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
  port( 
    clk : in std_logic;
    wr  : in std_logic;
    adr : in std_logic_vector (7 downto 0);
    data_in : in std_logic_vector (7 downto 0);
    data_out : out std_logic_vector (7 downto 0)
  );
end ram;

architecture arch_ram of ram is
  
  -- Type de registre : sous forme de matrice (16 x 8)
  type T_matrice is array (0 to 15) of std_logic_vector(7 downto 0);
  -- Registre
  signal matrice : T_matrice;
  begin 
    -- Process d'ecriture du vecteur dans le registre
    ramwrite: process(clk)
    begin 
      if rising_edge(clk) then
        if wr = '1' then
          -- ecriture des données dans le registre
          matrice(to_integer(unsigned(adr))) <= data_in;
        end if;
      end if;
    end process ramwrite;
    -- Transmission du registre à la sortie
    data_out <= matrice(to_integer(unsigned(adr)));
  end arch_ram;
