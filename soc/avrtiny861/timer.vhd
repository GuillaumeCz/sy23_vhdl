library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity timer is
	 Generic (BASE_ADDR	: integer := 16#2D#);
    Port ( clk : in  STD_LOGIC;
	       Rst : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC;
		   OC1A : out  STD_LOGIC;
		   OC1Abar : out  STD_LOGIC);
end timer;

architecture timer_architecture of timer is



constant OCR1A : integer := BASE_ADDR ;
constant TCNT1 : integer := BASE_ADDR + 1;
constant TCCR1B : integer := BASE_ADDR + 2;
constant TCCR1A : integer := BASE_ADDR + 3;

signal reg_compA : STD_LOGIC_VECTOR (7 downto 0);
signal reg_count : STD_LOGIC_VECTOR (7 downto 0);
signal reg_ctrlA : STD_LOGIC_VECTOR (7 downto 0);
signal reg_ctrlB : STD_LOGIC_VECTOR (7 downto 0);





begin


	

end timer_architecture;

