library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.all; 

-- TestBench du diviseur programmable du timer PWM
ENTITY diviseur_timer_tb IS
END diviseur_timer_tb;
 
ARCHITECTURE behavior OF diviseur_timer_tb IS 
 
   component diviseur_timer is
     Port ( clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
			N : in STD_LOGIC_VECTOR(3 downto 0);
            clk_out : out  STD_LOGIC);
   end component diviseur_timer;

   -- Initialisation
     -- Inputs
       -- Le signal d'entré d'une horloge
   signal clk : std_logic := '0';
       -- Le signal d'entré du reset
   signal rst : std_logic := '0';
       -- Le signal d'entré de la valeur de la division de l'horloge 
   signal clk_div : STD_LOGIC_VECTOR(3 downto 0);
   
 	   -- Outputs
       -- Le signal de sortie de l'horloge divisée
   signal clk_out : std_logic;

     -- Clock period definitions
       -- Constante definissant la période de l'horloge en entrée
   constant clk_period : time := 20 ns;
       -- Constante définissant la période de l'horloge du test
       -- // ? 
   constant clk_te_period : time := 40 ns;
       -- Signal d'horloge du test 
   signal clk_te : STD_LOGIC;
 
     -- Simulation definitions
       -- constante d'évolution du temps 
   constant dT : real := 1.0; -- ns

BEGIN
  -- Mapping des ports avec le composant à tester 
  uut : diviseur_timer     port map (rst => rst,clk => clk, N => clk_div, clk_out => clk_out); 

   -- Clock process : simulation du comportement d'une horloge en fonction de la période prédefinie 
   clk_process :process
   begin
	   clk <= '0';
		 wait for clk_period/2;
		 clk <= '1';
		 wait for clk_period/2;
   end process;
 
   -- Clock sample  // par rapport à clk ? 
   clk_te_process :process
   begin
		 clk_te <= '0';
		 wait for clk_te_period/2;
		 clk_te <= '1';
		 wait for clk_te_period/2;
   end process; 

   -- Stimulus process : processus de test du composant
   stim_proc: process
   begin		
     -- Attribution de la valeur de division de frequence
     -- // pourquoi 4bits alors que dans le diviseur il est de 2 bits ?
	   clk_div <= "0010";	
     -- Maintient du reset pendant 35ns pour initialiser le composant  
     rst <= '1';
     wait for 35 ns;
     -- Passage du reset à '0' le composant se met à fonctionner normalement
     rst <= '0';
     wait;
   end process;
  
  -- Enregistrement des resultats echantillonné avec Te dans un fichier texte
  resultats: process(clk_te)
    -- ouverture / création du fichier où seront ecris les résultats
    file filedatas: text open WRITE_MODE is "diviseur_generique_resultats.txt";
    -- initialisation d'une variable de type Ligne
    variable s : line;
    -- Initialisation de l'horodatage, pour inclure une empreinte du temps de traitement
    variable temps :  real := 0.0;
  begin 
    if rising_edge(clk_te) then
      -- A chaque periode de clk_te est ecrite une ligne avec :
        -- le temps 
      write(s, temps);write(s, string'("    "));
        -- la valeur de l'horloge en entrée
      write(s, clk);write(s, string'("    "));
        -- la valeur du reset
      write(s, rst);write(s, string'("    "));
        -- la valeur de l'horloge en sortie
      write(s, clk_out);write(s, string'("    "));
        -- ecriture de la ligne s dans le fichier
      writeline(filedatas,s);          
      -- evolution de l'horodatage
      temps := temps + dT;
    end if;
  end process resultats; 
END;
