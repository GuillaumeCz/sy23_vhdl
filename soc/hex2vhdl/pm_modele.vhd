library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pm is
	Port (
           clk    : in std_logic;
           PM_A   : in std_logic_vector(15 downto 0);
           PM_Drd : out std_logic_vector(15 downto 0));
end pm;

architecture Arch of pm is

-- datas

begin

   pmproc : process (clk)
     variable a_int : natural;
   begin
     if (clk'event and clk='1') then
        a_int := CONV_INTEGER(PM_A);
        PM_Drd <= PM_mem(a_int);
     end if;
  end process pmproc;

end architecture Arch;
