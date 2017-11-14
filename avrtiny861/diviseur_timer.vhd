library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

-- Entité diviseur du timer PWM
  -- Sous la forme d'un diviseur de fréquence programmable
  -- Permet de diviser la frequence d'une horloge en fonction des valeurs DTPS11 et DTPS10 du registre TCCR1B
entity diviseur_timer is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
		   N : in STD_LOGIC_VECTOR(1 downto 0);
           clk_out : out  STD_LOGIC);
end diviseur_timer;

architecture architecture_diviseur_timer of diviseur_timer is

-- Initialisations
  -- l'horloge divisée  
signal divided_clk : std_logic := '0';
  -- Compteur pour la division
signal cpt : std_logic_vector(2 downto 0) := "000";
  -- valeur maximum du compteur
signal max_cpt : std_logic_vector(2 downto 0) := "000";

begin
  
  -- Processus de comptage
  comptage: process(clk)
  begin
   if rising_edge(clk) then 
     -- Cas où l'horloge est en front montant
	   if rst = '1' then
       -- En cas de reset, remise du compteur à 0
	     cpt <= (others => '0');
     elsif cpt < max_cpt then
       -- Incrementation du compteur si il est inferieur à la valeur maximum
	     cpt <= std_logic_vector(unsigned(cpt) + 1);
	   else	
       -- Remise du compteur à 0 
       cpt <= (others => '0');
       -- Le contraire de sa valeur est affectée à l'horloge divisée 
       divided_clk <= not(divided_clk);
	   end if;
	 end if;
  end process comptage;

  -- Affectation de la valeur de l'horloge divisée à l'horloge de sortie
  clk_out <= divided_clk;
  
  -- Determination de la valeur du maximum du compteur en fonction de la valeur N d'entrée
    -- / Même usage qu'un multiplexeur ? 
  with N select
    -- si N vaut 0 le maximum vaut 0
    max_cpt <= "000" when "00",
    -- si N vaut 1 le maximum vaut 0
	    "000" when "01",
    -- si N vaut 2 le maximum vaut 3
      "011" when "10",
    -- si N vaut 3 le maximum vaut 7
      "111" when "11",
    -- dans tous les autres cas le maximum vaut 7
      "111" when others;
	
end architecture_diviseur_timer;
