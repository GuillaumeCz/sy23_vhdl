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
 
ENTITY RS232_tb IS
END RS232_tb;
 
ARCHITECTURE behavior OF RS232_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RS232
    PORT(
         clk : IN  std_logic;
         start : IN  std_logic;
         rst : IN  std_logic;
         datas : IN  std_logic_vector(7 downto 0);
         clk_div : IN  std_logic_vector(7 downto 0);
         empty : OUT  std_logic;
			x: out integer range 0 to 4;
			y: out STD_LOGIC;
			z: out STD_LOGIC;
         TX : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal start : std_logic := '0';
   signal rst : std_logic := '0';
   signal datas : std_logic_vector(7 downto 0) := (others => '0');
   signal clk_div : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal empty : std_logic;
   signal TX : std_logic;
	signal x: integer range 0 to 4;
	signal y : std_logic;
	signal z : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant clk_div_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RS232 PORT MAP (
          clk => clk,
          start => start,
          rst => rst,
          datas => datas,
          clk_div => clk_div,
          empty => empty,
			 x => x,
			 y => y,
			 z => z,
          TX => TX
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
	clk_div <= "00000000";
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		datas <= "10101100";
		rst <= '1';
      wait for 100 ns;
		rst <= '0';


      wait for clk_period*10;
		
		
		
		start <= '1';
   -- insert stimulus here 

      wait;
   end process;

END;