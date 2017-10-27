library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity pwm is 
  generic ( 
    N : integer := 8
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    data_in : in std_logic_vector(N-1 downto 0);
    oc1 : out std_logic;
    oc1_n : out std_logic;
    cc : out std_logic_vector(N-1 downto 0)
  );
end pwm;

architecture behavior of pwm is
  signal cpt : std_logic_vector(N-1 downto 0);
  signal b : std_logic := '1';
  signal seuil : integer := 7;
begin

  clock_tick: process(clk, rst)
  begin
    if rst = '1' then
      cpt <= (others => '0');
    elsif rising_edge(clk) then
      if to_integer(unsigned(cpt)) < N then
        cpt <= std_logic_vector(unsigned(cpt) + 1);
      else 
        cpt <= (others => '0');
      end if;
    end if;
  end process clock_tick;

  pp : process(cpt)
  begin 
    if to_integer(unsigned(cpt)) >= seuil then
      b <= not b;
    end if;
  end process pp;
  cc <= cpt;
  oc1 <= b;
  oc1_n <= not b;
end behavior;
