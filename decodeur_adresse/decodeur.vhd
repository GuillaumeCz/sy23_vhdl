library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decodeur is 
  generic( input_size: integer := 16);
  port ( 
  port_id : in std_logic_vector(input_size-1 downto 0);
  RAM : out std_logic;
  ROM : out std_logic;
  SPI : out std_logic);
end decodeur;

architecture comportement of decodeur is
begin
  RAM <= '1' when (port_id >= x"0000") and (port_id <= x"0FFF") else '0';

  SPI <= '1' when (port_id >= x"4000") and (port_id <= x"4007") else '0';

  ROM <= '1' when (port_id >= x"C000") and (port_id <= x"FFFF") else '0';
end comportement;

