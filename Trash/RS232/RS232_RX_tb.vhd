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
 
ENTITY RS232_RX_tb IS
END RS232_RX_tb;
 
ARCHITECTURE behavior OF RS232_RX_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RS232_RX
    PORT(
        clk:		in std_logic;
		rst:		in std_logic;
		RX :		in std_logic;
		data:		out std_logic_vector(7 downto 0);
		rx_done: 	out std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk 		: std_logic 							:= '0';
   signal rst 		: std_logic 							:= '0';
   signal RX 		: std_logic  							:= '1';

 	--Outputs
   signal data 		: std_logic_vector(7 downto 0);
   signal rx_done	: std_logic;
   
   
   signal x: STD_LOGIC_VECTOR (1 downto 0);
   signal y: STD_LOGIC_VECTOR (3 downto 0);
   signal z : STD_LOGIC_VECTOR (3 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant clk_div_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RS232_RX PORT MAP (
          clk 		=> clk,
          rst 		=> rst,
		  RX  		=> RX,
          data 		=> data,
          rx_done 	=> rx_done
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


      wait for clk_period*10;
	  wait for clk_period/2;
	  RX <= '0';
	  wait for clk_period*1;
	  RX <= '1';
	  wait for clk_period*8;
	  RX <= '1';
	  wait for clk_period*16;
	  RX <= '1';
	  wait for clk_period*16;
	  RX <= '0';
	  wait for clk_period*16;
	  RX <= '1';
	  wait for clk_period*16;
	  RX <= '0';
	  wait for clk_period*16;
	  RX <= '0';
	  wait for clk_period*16;
	  RX <= '0';
	  wait for clk_period*16;
	  RX <= '1';
	  wait for clk_period*8;
	  RX <= '1';
	  wait for clk_period*16;
      wait;
   end process;

END;
