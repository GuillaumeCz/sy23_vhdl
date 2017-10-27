library ieee;
use ieee.std_logic_1164.all;

entity pwm2_tb is
end pwm2_tb;

architecture behav of pwm2_tb is
  component pwm2 
    generic( 
    sys_clk : integer := 50_000_000;
    pwm_freq : integer := 100_000;
    bits_resolution : integer := 8;
    phases : integer := 3
    );
    port(
    clk : in std_logic;
    reset_n : in std_logic;
    ena : in std_logic;
    duty : in std_logic_vector(bits_resolution-1 downto 0);
    pwm_n_out : out std_logic_vector(phases-1 downto 0);
    pwm_out : out std_logic_vector(phases-1 downto 0));
  end component;

  -- Constant
  constant bits_resolution : integer := 8;
  constant sys_clk : integer := 50_000_000;
  constant pwm_freq : integer := 100_000;
  constant phases : integer := 3;  

  -- Inputs
  signal clk : std_logic := '0';
  signal reset_n : std_logic := '0';
  signal ena : std_logic := '0';
  signal duty : std_logic_vector(bits_resolution-1 downto 0) := (others => '0');

  -- Output
  signal pwm_out : std_logic_vector(phases-1 downto 0);
  signal pwm_n_out : std_logic_vector(phases-1 downto 0);

  -- Clock period definitions 
  constant clk_period : time := 10 ns;
  constant clk_div_period : time := 10 ns;

begin
  uut : pwm2
  generic map ( 
    sys_clk => sys_clk,
    pwm_freq => pwm_freq,
    bits_resolution => bits_resolution,
    phases => phases 
  )
  port map (
    clk => clk,
    reset_n => reset_n,
    ena => ena,
    duty => duty,
    pwm_n_out => pwm_n_out,
    pwm_out => pwm_out);


  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc : process
  begin
    reset_n <= '0';
    wait for 50 ns;
    reset_n <= '1';
    wait for 20 ns;
    duty <= "10000000";
    ena <= '1';
    wait for 100 ns;
    duty <= "01000000";
    wait for 100 ns;
    wait for 100 ns;
  end process;
end;
