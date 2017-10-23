library ieee;
use ieee.std_logic_1164.all;

entity decodeur_tb is
end decodeur_tb;

architecture comportement of decodeur_tb is
  component decodeur is port(
    port_id : in std_logic_vector(15 downto 0);
    RAM : out std_logic;
    ROM : out std_logic;
    SPI : out std_logic);
  end component decodeur;

  -- Input
  signal port_id : std_logic_vector(15 downto 0);

  -- Output
  signal RAM : std_logic := '0';
  signal ROM : std_logic := '0';
  signal SPI : std_logic := '0';
begin
  uut : decodeur port map(
    port_id => port_id,
    RAM => RAM,
    ROM => ROM,
    SPI => SPI    
  );
  
  stim_proc: process
  begin
    -- $0001
    port_id <= "0000000000000001";
    wait for 10 ns;
    -- $FFFE
    port_id <= "1111111111111110";
    wait for 10 ns;
    -- $4001
    port_id <= "0100000000000011";
    wait for 10 ns;
    wait;
  end process stim_proc;
end comportement;
