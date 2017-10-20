library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity ram_tb is
end ram_tb;

architecture behav of ram_tb is
  component ram 
  port( 
    clk : in std_logic;
    wr : in std_logic;
    adr : in std_logic_vector (7 downto 0);
    data_in : in std_logic_vector (7 downto 0);
    data_out : out std_logic_vector (7 downto 0)
  );
  end component;

  -- inputs
  signal clk : std_logic := '0';
  signal wr : std_logic := '0';
  signal adr : std_logic_vector (7 downto 0);
  signal data_in : std_logic_vector (7 downto 0);
  
  -- outputs
  signal data_out : std_logic_vector (7 downto 0);

  -- clock period def
  constant clk_period : time := 10 ns;
  constant clk_div_period : time := 10 ns;
begin

 uut : ram port map(
   clk => clk,
   wr => wr,
   adr => adr, 
   data_in => data_in,
   data_out => data_out
 );

 clk_process : process
 begin 
   clk <= '0';
   wait for clk_period/2;
   clk <= '1';
   wait for clk_period/2;
 end process;

 stim_proc: process 
   -- lire fichier avec data_in
   file stimulis: text open READ_MODE is "stimulis.txt";
   file resultat: text open WRITE_MODE is "results.txt";
   -- variable d'entré
   variable e: std_logic_vector(7 downto 0);
   -- variable d'erreur de lecture
   variable ok: boolean := false;
   --Buffers 
   variable buffer_in, buffer_out : line;
 begin 
   -- definition d'une adresse de test
   adr <= "00000010";
   -- la condition d'ecriture/lecture est remplie
   wr <= '1';
   -- tant qu'on n'est pas à la fin du fichier de stimulis...
   boucle: while not endfile(stimulis) loop
     -- on lit la ligne (si elle n'est pas vide)
     readLine(stimulis, buffer_in);
     next boucle when buffer_in.all'length = 0;

     -- stockage du contenu de la ligne dans e
     read(buffer_in, e, ok);

     assert ok report "Erreur" severity error;
     -- association de ce qui a été lu aux données en entré
     data_in <= e;
     wait for 20 ns;
     write(buffer_out, data_out);
     writeline(resultat, buffer_out);
   end loop;
   wr <= '0';
    
   wait;
 end process stim_proc;
end behav;
