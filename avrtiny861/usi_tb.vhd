LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.numeric_std.ALL;
 
ENTITY usi_tb IS
END usi_tb;
 
ARCHITECTURE behavior OF usi_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT usi
	Generic (BASE_ADDR	: integer := 16#0D#);
    Port ( clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           wr : in  STD_LOGIC;
           rd : in  STD_LOGIC;
           SCK : out  STD_LOGIC;
           MOSI : out  STD_LOGIC;
           MISO : in  STD_LOGIC);
    END COMPONENT;
    
   --Constant
	constant N 		: integer := 8;
	constant bauds 	: integer := 115200;
	constant sysclk : real := 50.0e6 ; -- 50MHz
	constant clkdiv : integer := integer(sysclk / real(bauds));
   
   --Inputs
   signal clk 		: std_logic 							:= '0';
   signal rst 		: std_logic 							:= '0';
   signal addr		: std_logic_vector(5 downto 0)			:= (others=> '0');
   signal iowrite	: std_logic_vector(7 downto 0)			:= (others=> '0');
   signal wr 		: std_logic 							:= '0';
   signal rd 		: std_logic 							:= '0';
   signal MISO 		: std_logic 							:= '0';

 	--Outputs
   signal ioread	: std_logic_vector(7 downto 0);
   signal SCK		: std_logic;
   signal MOSI		: std_logic;

   -- Clock period definitions
   constant clk_period : 		time := 10 ns;
   constant clk_div_period : 	time := 115200 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: usi 
   Generic map (
		  BASE_ADDR 		=> 16#0D# )
   PORT MAP (
		  clk 		=> clk,
          Rst 		=> rst,
          addr 		=> addr,
          ioread 	=> ioread,
          iowrite 	=> iowrite,
          wr		=> wr,
          rd 		=> rd,
          SCK 		=> SCK,
          MOSI 		=> MOSI,
          MISO 		=> MISO
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
      -- hold reset state for 100 ns.
		-- rst <= '1';
      -- wait for 100 ns;
		-- rst <= '0';
		wr <= '1';
		

	  
	  -- wait for clk_period*1;
	  -- addr 		<= "001110";	-- 0x0E
	  -- iowrite 	<= "11111111";
	  -- wait for clk_period*1;
	  


	  wait for clk_period*1;
	  addr 		<= "001111";  -- 0x0F
	  iowrite 	<= "11010011";
	  wait for clk_period*1;
	  
	  
	  wait for clk_period*1;
	  addr 		<= "001101";	-- 0x0D
	  iowrite 	<= "00110101";
	  wait for clk_period*1;
	  
	  
	  wait for clk_period*clkdiv*20;
	  wr 		<= '0';
	  wait for clk_period*clkdiv*20;
	  
	  wait for clk_period*1;
	  addr 		<= "001101";	-- 0x0D
	  wait for clk_period*1;
	  rd 		<= '1';	  
	  wait for clk_period*1;
	  MISO <= '0';
	  wait for clk_period*clkdiv;
	  MISO <= '0';
	  wait for clk_period*clkdiv;
	  MISO <= '1';
	  wait for clk_period*clkdiv;
	  MISO <= '1';
	  wait for clk_period*clkdiv;
	  MISO <= '0';
	  wait for clk_period*clkdiv;
	  MISO <= '1';
	  wait for clk_period*clkdiv;
	  MISO <= '0';
	  wait for clk_period*clkdiv;
	  MISO <= '1';
	  
	  wait for clk_period*clkdiv;
		rd 		<= '0';
	  
	  
      wait;
   end process;
END;
