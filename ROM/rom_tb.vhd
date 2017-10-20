library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_tb is 
end rom_tb;

architecture behav of rom_tb is
  component rom port(
    clk: in std_logic;
    adr: in std_logic_vector(3 downto 0);
    data: out std_logic_vector(7 downto 0)
  );
  end component;

  -- inputs
  signal clk : std_logic := '0';
  signal adr : std_logic_vector(3 downto 0);

  -- outpus
  signal data: std_logic_vector(7 downto 0);

  -- clk period def
  constant clk_period : time := 10 ns;
  constant clk_div_period : time := 10 ns;
begin
  uut : rom port map(
    clk => clk,
    adr => adr,
    data => data
  );

  clk_process : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc: process
  begin
    adr <= "1111";
    
    wait for 20 ns;

    wait;
  end process stim_proc;
end behav;
  
