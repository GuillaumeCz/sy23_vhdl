LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.numeric_std.ALL;
 
ENTITY SPI_TX_tb IS
END SPI_TX_tb;
 
ARCHITECTURE behavior OF SPI_TX_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPI_TX
	Generic (N : integer := 8);
    Port ( data_in : 	in  STD_LOGIC_VECTOR (N-1 downto 0);		-- data received from memory
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
           SPI_SCK : 	in  STD_LOGIC;								-- clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
           SPI_MOSI : 	out  STD_LOGIC;								-- data received on N bits
		   x: out STD_LOGIC_VECTOR (1 downto 0);
		   y: out STD_LOGIC_VECTOR (N-1 downto 0);
		   z: out STD_LOGIC_VECTOR (N-1 downto 0));
    END COMPONENT;
    
   --Constant
	constant N : integer := 8;
   
   --Inputs
   signal clk 		: std_logic 							:= '0';
   signal rst 		: std_logic 							:= '0';
   signal spi_start	: std_logic  							:= '0';
   signal data 		: std_logic_vector(N-1 downto 0)		:= (others => '0');

 	--Outputs
   signal TX 		: std_logic;
   signal SPI_CS	: std_logic;
   
   
   signal x: STD_LOGIC_VECTOR (1 downto 0);
   signal y: STD_LOGIC_VECTOR (N-1 downto 0);
   signal z: STD_LOGIC_VECTOR (N-1 downto 0);

   -- Clock period definitions
   constant clk_period : 		time := 10 ns;
   constant clk_div_period : 	time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPI_TX 
   Generic map (
		  N 		=> N )
   PORT MAP (
		  data_in	=> data,
          spi_start	=> spi_start,
          rst 		=> rst,
          SPI_SCK	=> clk,
          SPI_CS 	=> SPI_CS,
		  SPI_MOSI  => TX,
		  x => x,
		  y => y,
		  z => z
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
	  rst 			<= '1';
      wait for 100 ns;
	  rst 			<= '0';
	  data		 	<= "00110101";	--start of the sequence 0011 0101 0x35
	  wait for 100 ns;
	  spi_start 	<= '1';
      wait for clk_period*1;
	  spi_start 	<= '0';			--start of the sequence 0011 0101 0x35

      wait;
   end process;

END;
