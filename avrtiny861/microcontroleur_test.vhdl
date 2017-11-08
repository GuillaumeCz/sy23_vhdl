LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
 
ENTITY microcontroleur_test IS
END microcontroleur_test;
 
ARCHITECTURE behavior OF microcontroleur_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT microcontroleur
    PORT(
         clk : IN  std_logic;
         Rst : IN  std_logic;
         PORTA : INOUT  std_logic_vector(7 downto 0);
         PORTB : INOUT  std_logic_vector(7 downto 0);
			OC1A : out STD_LOGIC;
			OC1Abar : out STD_LOGIC;
			SCK : out STD_LOGIC;
			MOSI : out STD_LOGIC;
			MISO : in STD_LOGIC			
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal Rst : std_logic := '0';
	signal MISO : std_logic := '0';

	--BiDirs
   signal PORTA : std_logic_vector(7 downto 0);
   signal PORTB : std_logic_vector(7 downto 0);
	
	-- Outputs
	signal OC1A : std_logic;
	signal OC1Abar : std_logic;
	signal MOSI : std_logic;
	signal SCK : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: microcontroleur PORT MAP (
          clk => clk,
          Rst => Rst,
          PORTA => PORTA,
          PORTB => PORTB,
			 OC1A => OC1A,
			 OC1Abar => OC1Abar,
			 SCK => SCK,
			 MOSI => MOSI,
			 MISO => MISO
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
		Rst <= '1';	
		MISO <= '0';
		PORTB <= x"55";
		wait for 200 ns;
		Rst <= '0';
      wait;
   end process;

END;
