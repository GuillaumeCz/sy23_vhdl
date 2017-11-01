library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity usi is
	 Generic (BASE_ADDR	: integer := 16#0D#);
    Port ( clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           wr : in  STD_LOGIC;
           rd : in  STD_LOGIC;
           SCK : out  STD_LOGIC;
           MOSI : out  STD_LOGIC;
           MISO : in  STD_LOGIC);
end usi;

architecture usi_architecture of usi is

constant USIDR : integer := BASE_ADDR ;
constant USISR : integer := BASE_ADDR + 1;
constant USICR : integer := BASE_ADDR + 2;

signal reg_usidr : STD_LOGIC_VECTOR (7 downto 0);
signal reg_usisr : STD_LOGIC_VECTOR (7 downto 0);
signal reg_usicr : STD_LOGIC_VECTOR (7 downto 0);

begin


	

end usi_architecture;

