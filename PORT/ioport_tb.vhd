LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE ieee.numeric_std.ALL;
 
ENTITY ioport_tb IS
END ioport_tb;
 
ARCHITECTURE behavior OF ioport_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ioport
	Generic (	PORTX_ADDR : 	integer := 16#1B#;
				DDR_ADDR :		integer	:=16#1A#;
				PINX_ADDR :		integer	:=16#19#);
    Port ( clk : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC;
		   PORTX : inout  STD_LOGIC_VECTOR (7 downto 0));
    END COMPONENT;
    
   --Constant
	constant N : integer := 8;
	constant PORTX_ADDR :						STD_LOGIC_VECTOR (5 downto 0)			:= "011011"; --16#1B#
	constant DDRA_ADDR :						STD_LOGIC_VECTOR (5 downto 0)			:= "011010"; --16#1A#
	constant PINX_ADDR :						STD_LOGIC_VECTOR (5 downto 0)			:= "011001"; --16#19#
   
   --Inputs
   signal clk 		: std_logic 							:= '0';
   signal rst 		: std_logic 							:= '0';
   signal address_in :STD_LOGIC_VECTOR (5 downto 0)			:= (others => '0'); -- address
   signal read_r	: std_logic 							:= '0';
   signal write_r	: std_logic 							:= '0';
   signal iowrite	: STD_LOGIC_VECTOR (7 downto 0)  		:= (others => '0');
	  
	  
   -- Out
   signal ioread	: STD_LOGIC_VECTOR (7 downto 0);
   -- in/out
   signal PORTA 	: STD_LOGIC_VECTOR (7 downto 0)  		:= (others => '0');

   
   
   signal x: STD_LOGIC_VECTOR (7 downto 0);
   signal y: STD_LOGIC_VECTOR (7 downto 0);
   signal z: STD_LOGIC_VECTOR (7 downto 0);
   
   
   

   -- Clock period definitions
   constant clk_period : 		time := 10 ns;
   constant clk_div_period : 	time := 115200 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ioport 
   Generic map (PORTX_ADDR 	=> 16#1B#,
				DDR_ADDR 	=> 16#1A#,
				PINX_ADDR 	=> 16#19#)
   PORT MAP (
			clk 	=> clk,
			addr 	=> address_in,
			ioread 	=> ioread,
			iowrite => iowrite,
			rd 		=> read_r,
			wr 		=> write_r,
			PORTX 	=> PORTA);

			
			
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
		read_r 		<= '0';
		write_r 	<= '1';
		iowrite		<= "00110101";	-- Polarize the PORT A PIN 0011 0101 0x35	
		wait for clk_period *10;
		address_in 	<=  DDRA_ADDR;
		wait for clk_period*10;
		
		read_r 		<= '1';
		write_r 	<= '0';
		wait for clk_period *10;
		address_in 	<=  DDRA_ADDR;
		wait for clk_period*10;
		address_in 	<=  "000000";
		
		read_r 		<= '0';
		write_r 	<= '1';
		iowrite		<= "11110000";	-- Polarize the PORT A PIN 0011 0101 0x35	
		wait for clk_period *10;
		address_in 	<=  PORTX_ADDR;
		wait for clk_period*10;
		
		read_r 		<= '1';
		write_r 	<= '0';
		wait for clk_period *10;
		address_in 	<=  PORTX_ADDR;
		wait for clk_period*10;
				
		wait for clk_period*10;
		read_r 		<= '1';
		write_r 	<= '0';
		wait for clk_period *10;
		address_in 	<=  PINX_ADDR;
		wait for clk_period*10;

		wait;
   end process;

END;
