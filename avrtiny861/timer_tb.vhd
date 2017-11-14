LIBRARY ieee;
use ieee.std_logic_1164.all;

-- TestBench du timer PWM
entity timer_test is
end timer_test;


architecture behav of timer_test is
  -- inclusion du composant timer
  component timer
  generic( BASE_ADDR : integer := 16#2D# );
  port(
    clk : 		in std_logic;
    rst : 		in std_logic;
    addr : 		in std_logic_vector(5 downto 0);
    ioread : 	out std_logic_vector( 7 downto 0);
    iowrite : 	in  std_logic_vector (7 downto 0);
    rd : 		in  std_logic;
    wr : 		in  std_logic;
	oc1a : 		out  std_logic;
	oc1abar : 	out  std_logic);
  end component;

  -- Inputs
    -- Signal d'entré d'une horloge
  signal clk : 				std_logic 		:= '0';
    -- Signal d'entré de remise à 0
  signal rst : 				std_logic 		:= '0';
    -- Signal d'entré de adresse du registre pointé
  signal addr : 			std_logic_vector (5 downto 0);
    -- Signal d'entré avec les valeurs du registre pointé par l'adresse precedente
  signal iowrite :			std_logic_vector (7 downto 0);
    -- Signal d'entré de lecture
  signal rd :				std_logic		:= '0';
    -- Signal d'entré d'écriture
  signal wr :				std_logic		:= '0';
    -- Adresse de base
  signal BASE_ADDR : 		integer 		:= 16#2D#;
  
  -- Outputs
    -- Signal de sortie de la lecture
  signal ioread : 			std_logic_vector (7 downto 0);
    -- Signal de sortie en mode fastPWM
  signal oc1a : 			std_logic;
    -- Inverse du signal de sortie precedent
  signal oc1abar : 			std_logic;

  -- Definition de la constante de la période de l'horloge clk
  constant clk_period : 	time 			:= 20 ns;

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

  -- Processus d'évolution de la valeur de l'horloge
  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  -- Processus de stimulation, test du composant
  stim_proc : process
  begin 
    -- initialisation du composant avec l'envoi d'un signal de reset pendant 50ns 
    rst 	<= '1';
    wait for 50 ns;

    -- Démarrage du travail du composant 
    rst 	<= '0';
    -- Definition du mode, ici ecriture
    rd 		<= '0';
    wr 		<= '1';

    -- Definition des valeurs utiles du registre TCCR1A
    addr 	<= "110000";
    iowrite <= "01000010";
    wait for 50 ns;

    -- Definition des valeurs utiles du registre TCCR1B
    addr 	<= "101111";
    iowrite <= "00001111";
    wait for 50 ns;

    -- Definition des valeurs utiles du registre TCNT1
    addr 	<= "101110";
    iowrite <= (others => '0');
    wait for 50 ns;

    -- Definition des valeurs utiles du registre OCR1A
    addr 	<= "101101";
    iowrite <= "00001111";
    wait for 50 ns;

    -- Changement de mode, passage en mode lecture
    rd 		<= '1';
    wr 		<= '0';
    wait; 
  end process;
end; 
