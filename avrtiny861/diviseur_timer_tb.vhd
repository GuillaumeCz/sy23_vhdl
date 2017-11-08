library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.all; 
 
ENTITY diviseur_timer_tb IS
END diviseur_timer_tb;
 
ARCHITECTURE behavior OF diviseur_timer_tb IS 
 
   component diviseur_timer is
     Port ( clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
			N : in STD_LOGIC_VECTOR(3 downto 0);
            clk_out : out  STD_LOGIC);
   end component diviseur_timer;

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal clk_div : STD_LOGIC_VECTOR(3 downto 0);
   
 	--Outputs
   signal clk_out : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
   constant clk_te_period : time := 40 ns;
   signal clk_te : STD_LOGIC;
 
   -- Simulation definitions
   constant dT : real := 1.0; -- ns

BEGIN
 
  uut : diviseur_timer     port map (rst => rst,clk => clk, N => clk_div, clk_out => clk_out); 

   -- Clock process 
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
    -- Clock sample
   clk_te_process :process
   begin
		clk_te <= '0';
		wait for clk_te_period/2;
		clk_te <= '1';
		wait for clk_te_period/2;
   end process; 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      -- wait for 100ms;	  
	  clk_div <= "0010";	
      rst <= '1';
      wait for 35 ns;
      rst <= '0';

	  
      -- insert stimulus here 
      wait;
   end process;
  
  -- enregistrement des resultats echantillonne avec Te dans un fichier texte
  resultats: process(clk_te)
    file filedatas: text open WRITE_MODE is "diviseur_generique_resultats.txt";
    variable s : line;
    variable temps :  real := 0.0;
  begin 
    if rising_edge(clk_te) then
      write(s, temps);write(s, string'("    "));
      write(s, clk);write(s, string'("    "));
      write(s, rst);write(s, string'("    "));
      write(s, clk_out);write(s, string'("    "));
      writeline(filedatas,s);          
      temps := temps + dT;
    end if;
  end process resultats; 
   

END;
