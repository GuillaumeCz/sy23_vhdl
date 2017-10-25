LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE ieee.numeric_std.ALL;
 
ENTITY SPI_tb IS
END SPI_tb;
 
ARCHITECTURE behavior OF SPI_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPI
	Generic (N : integer := 8;
			 M : integer := 8);
    Port ( data_in : 	in  STD_LOGIC_VECTOR (N-1 downto 0);		-- data received from memory
		   SPI_MISO : 	in  STD_LOGIC;								-- data received from memory
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
		   clk :		in	STD_LOGIC;								-- system clock
           SPI_SCK : 	out  STD_LOGIC;								-- SPI clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
		   data_out : 	out  STD_LOGIC_VECTOR (M-1 downto 0);		-- data received on N bits
           SPI_MOSI : 	out  STD_LOGIC;		-- data received on N bits
		   x: out STD_LOGIC_VECTOR (1 downto 0);
		   y: out STD_LOGIC_VECTOR (N-1 downto 0);
		   z: out STD_LOGIC_VECTOR (N-1 downto 0));
    END COMPONENT;
    
   --Constant
	constant N : integer := 8;
	constant M : integer := 8;
	constant bauds : integer := 115200;
	constant sysclk : real := 50.0e6 ; -- 50MHz
	constant clkdiv : integer := integer(sysclk / real(bauds));
   
   --Inputs
   signal clk 		: std_logic 							:= '0';
   signal rst 		: std_logic 							:= '0';
   signal spi_start	: std_logic  							:= '0';
   signal RX 		: std_logic  							:= '1';
   signal data_in	: std_logic_vector(N-1 downto 0)		:= (others => '0');

 	--Outputs
   signal data_out	: std_logic_vector(M-1 downto 0);
   signal TX 		: std_logic;
   signal SPI_CS	: std_logic;
   signal SPI_SCK	: std_logic;
   
   
   signal x: STD_LOGIC_VECTOR (1 downto 0);
   signal y: STD_LOGIC_VECTOR (N-1 downto 0);
   signal z: STD_LOGIC_VECTOR (N-1 downto 0);
   
   
   

   -- Clock period definitions
   constant clk_period : 		time := 10 ns;
   constant clk_div_period : 	time := 115200 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPI 
   Generic map (
			N 		=> N, 
			M		=> M)
   PORT MAP (
			data_in		=> data_in,
			SPI_MISO	=> RX,
			spi_start	=> spi_start,
			rst 		=> rst,
			clk			=> clk,
			SPI_SCK		=> SPI_SCK,
			SPI_CS 		=> SPI_CS,
			data_out  	=> data_out,
			SPI_MOSI  	=> TX,
			x => x,
			y => y,
			z => z);

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
		rst <= '1';
      wait for 100 ns;
		rst <= '0';
		data_in		<= "00110101";	--start of the received data sequence 0011 0101 0x35
	  wait for 100 ns;
	  spi_start 	<= '1';
      wait for clk_period*clkdiv*N;
	  spi_start 	<= '0';				--start of the sequence 0011 0101 0x35
	  RX <= '0';
	  wait for clk_period*clkdiv;
	  RX <= '0';
	  wait for clk_period*clkdiv;
	  RX <= '1';
	  wait for clk_period*clkdiv;
	  RX <= '1';
	  wait for clk_period*clkdiv;
	  RX <= '0';
	  wait for clk_period*clkdiv;
	  RX <= '1';
	  wait for clk_period*clkdiv;
	  RX <= '0';
	  wait for clk_period*clkdiv;
	  RX <= '1';
      wait;
   end process;

END;
