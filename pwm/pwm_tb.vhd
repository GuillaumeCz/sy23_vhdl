library ieee;
use ieee.std_logic_1164.all;

entity pwm_tb is
end pwm_tb;

architecture behav of pwm_tb is
  component pwm 
    generic( N : integer := 8);
    port(
    clk : in std_logic;
    rst : in std_logic;
    data_in : in std_logic_vector(N-1 downto 0);
    oc1 : out std_logic;
    oc1_n : out std_logic;
    cc : out std_logic_vector(N-1 downto 0));
  end component;

  -- Constant
  constant N : integer := 8;

  -- Inputs
  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal data_in : std_logic_vector(N-1 downto 0) := (others => '0');

  -- Output
  signal oc1 : std_logic;
  signal oc1_n : std_logic;
  signal cc : std_logic_vector(N-1 downto 0) := (others => '0');

  -- Clock period definitions 
  constant clk_period : time := 10 ns;
  constant clk_div_period : time := 10 ns;

begin
  uut : pwm
  generic map ( N => N )
  port map (
    clk => clk,
    rst => rst,
    data_in => data_in,
    oc1 => oc1,
    oc1_n => oc1_n,
    cc => cc);


  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc : process
  begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    data_in <= "00110101";
    wait for 100 ns;
    data_in <= "11110101";
    wait for 100 ns;
    wait for 100 ns;
  end process;
end;
