library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
  port(
    clk : in std_logic;
    adr : in std_logic_vector(3 downto 0);
    data : out std_logic_vector(7 downto 0)
  );
end rom;

architecture behav of rom is
  type T_matrice is Array (0 to 15) of std_logic_vector(7 downto 0);
  constant matrice : T_matrice := (
    x"11", x"f2", x"c3", x"d4", x"e5",
    x"56", x"87", x"98", x"a9", x"1a",
    x"2b", x"cc", x"ed", x"ae", x"5f", x"10"
  );
begin
  acces: process(clk)
  begin
    if rising_edge(clk) then
      data <= matrice(to_integer(unsigned(adr)));
    end if;
  end process acces;
end behav;
