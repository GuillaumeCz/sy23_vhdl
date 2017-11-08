LIBRARY ieee;
use ieee.std_logic_1164.all;

entity timer_test is
end timer_test;

architecture behav of timer_test is
  component timer
  generic( BASE_ADDR : integer := 16#2D# );
  port(
    clk : in std_logic;
    rst : in std_logic;
    addr : in std_logic_vector(5 downto 0);
    ioread : out std_logic_vector( 7 downto 0);
    iowrite : in  std_logic_vector (7 downto 0);
    rd : in  std_logic;
    wr : in  std_logic;
		oc1a : out  std_logic;
		oc1abar : out  std_logic);
  end component;

  -- Inputs
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal addr : std_logic_vector (5 downto 0);
  signal iowrite : std_logic_vector (7 downto 0);
  signal rd : std_logic;
  signal wr : std_logic;
  signal BASE_ADDR : integer := 16#2D#;
  
  -- Outputs
  signal ioread : std_logic_vector (7 downto 0);
  signal oc1a : std_logic;
  signal oc1abar : std_logic;

  constant clk_period : time := 20 ns;

begin
  uut: timer 
  generic map(
    BASE_ADDR => BASE_ADDR )
  port map (
    clk => clk,
    rst => rst,
    addr => addr,
    ioread => ioread,
    iowrite => iowrite,
    rd => rd,
    wr => wr,
    oc1a => oc1a,
    oc1abar => oc1abar  
  );

  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc : process
  begin 
    rst <= '1';
    wait for 50 ns;
    rst <= '0';
    rd <= '0';
    wr <= '1';
    -- TCCR1A
    addr <= "110000";
    iowrite <= "01000010";
    wait for 50 ns;
    -- TCCR1B
    addr <= "101111";
    iowrite <= "00001111";
    -- iowrite <= "00100111";
    wait for 50 ns;
    -- TCNT1
    addr <= "101110";
    iowrite <= (others => '0');
    wait for 50 ns;
    -- OCR1A
    addr <= "101101";
    iowrite <= "00001111";
    wait for 50 ns;
    rd <= '1';
    wr <= '0';
    wait; 
  end process;

end; 



