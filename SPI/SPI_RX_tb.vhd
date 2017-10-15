--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:01:25 10/04/2017
-- Design Name:   
-- Module Name:   /home/uvs/Documents/Menard_Zeissloff/TP2_liaison_serie/RS232_tb.vhd
-- Project Name:  TP2_liaison_serie
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RS232
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY SPI_RX_tb IS
END SPI_RX_tb;
 
ARCHITECTURE behavior OF SPI_RX_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
 
    COMPONENT SPI_RX
    Generic (N : integer := 8);
    Port ( SPI_MISO : 	in  STD_LOGIC;								-- data received from memory
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
           SPI_SCK : 	in  STD_LOGIC;								-- clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
           data_out : 	out  STD_LOGIC_VECTOR (N-1 downto 0);		-- data received on N bits
			x: out STD_LOGIC_VECTOR (1 downto 0);
			y: out STD_LOGIC_VECTOR (N-1 downto 0)
			--z: out STD_LOGIC_VECTOR (3 downto 0)
        );
    END COMPONENT;
    
   --Constant
	constant N : integer := 8;
   
   --Inputs
   signal clk 		: std_logic 							:= '0';
   signal rst 		: std_logic 							:= '0';
   signal spi_start	: std_logic  							:= '0';
   signal RX 		: std_logic  							:= '1';

 	--Outputs
   signal data 		: std_logic_vector(N-1 downto 0);
   signal SPI_CS	: std_logic;
   
   
   signal x: STD_LOGIC_VECTOR (1 downto 0);
   signal y: STD_LOGIC_VECTOR (N-1 downto 0);
   signal z : STD_LOGIC_VECTOR(3 downto 0);

   -- Clock period definitions
   constant clk_period : 		time := 10 ns;
   constant clk_div_period : 	time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPI_RX 
   Generic map (
		  N 		=> N )
   PORT MAP (
		  SPI_MISO	=> RX,
          spi_start	=> spi_start,
          rst 		=> rst,
          SPI_SCK	=> clk,
          SPI_CS 	=> SPI_CS,
		  data_out  => data,
		  x => x,
		  y => y
		  --z => z
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
		rst <= '1';
      wait for 100 ns;
		rst <= '0';
	
	  spi_start <= '1';
      wait for clk_period*1;
	  spi_start <= '0';			--start of the sequence 0111 0100 0x74
	  RX <= '0';
	  wait for clk_period*1;
	  RX <= '0';
	  wait for clk_period*1;
	  RX <= '1';
	  wait for clk_period*1;
	  RX <= '1';
	  wait for clk_period*1;
	  RX <= '0';
	  wait for clk_period*1;
	  RX <= '1';
	  wait for clk_period*1;
	  RX <= '0';
	  wait for clk_period*1;
	  RX <= '1';
      wait;
   end process;

END;
