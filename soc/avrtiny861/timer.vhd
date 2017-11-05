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
  clock_tick : process(clk)
    variable a_int : natural;
  begin
    if rst = '1' then
      reg_count <= (others => '0');
      OC1A <= '1';
      OC1Abar <= '0';
    elsif rising_edge(clk) then
      a_int := to_integer(unsigned(addr));
      if to_integer(unsigned(reg_count)) >= OCR1A then
        OC1A <= '0';
        OC1Abar <= '1';
      else
        OC1A <= '1';
        OC1Abar <= '0';
      end if;
      reg_count <= std_logic_vector(unsigned(reg_count)+1 );
    end if;
  end process clock_tick;


	

end timer_architecture;

