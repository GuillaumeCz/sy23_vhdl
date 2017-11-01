library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ioport is
	 Generic (BASE_ADDR	: integer := 16#19#);
    Port ( clk : in  STD_LOGIC;
	       Rst : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC;
		   ioport : inout  STD_LOGIC_VECTOR (7 downto 0));
end ioport;

architecture ioport_architecture of ioport is

constant PORT_ADDR : integer := BASE_ADDR + 2;
constant DDR_ADDR : integer := BASE_ADDR + 1;
constant PIN_ADDR : integer := BASE_ADDR;


begin


end ioport_architecture;

