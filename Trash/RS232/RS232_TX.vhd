----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:26:08 09/29/2017 
-- Design Name: 
-- Module Name:    RS232 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity RS232_TX is
    Port ( clk : in  STD_LOGIC;
      start : in  STD_LOGIC;
  	  rst : in STD_LOGIC;
      datas : in  STD_LOGIC_VECTOR (7 downto 0);
   	  empty : out  STD_LOGIC;
      TX : out  STD_LOGIC);
end RS232_TX;

architecture Behavioral of RS232_TX is

TYPE State_type IS (idle, bitStart, bitData, bitStop);  --
SIGNAL state : State_Type		 							:= idle;    -- 
SIGNAl next_state : State_Type 								:= idle;
SIGNAL bitcpt : unsigned (7 downto 0) 						:= (others => '0');
SIGNAL data : STD_LOGIC_VECTOR (7 downto 0) 				:= (others => '0');


BEGIN 

clock_tick: PROCESS (clk, rst) 
BEGIN 
  IF (rst = '1') THEN
  	state <= idle;
	data  <= datas;
  ELSIF rising_edge(clk) THEN
  	state <= next_state;
	IF state = idle THEN
		TX <= '1';
		bitcpt <= (others => '0');
  	ELSIF state = bitStart THEN
	  	TX <= '0';
  	ELSIF state = bitData THEN
	-- Send the MSB
	  	TX <= data(7);
	-- Shift the register to have the next bit to send on the MSB.
	  	data <= data (6 downto 0) & '0';	
		bitcpt <= bitcpt + 1;
	ELSIF state = bitStop THEN
	  	TX <= '1';
	END IF;
  END IF;
END PROCESS clock_tick;
	 
change_state: PROCESS(state, start, bitcpt)
BEGIN
	next_state <= state;
	CASE state IS
		WHEN IDLE =>
			IF (start = '1') THEN 
				next_state <= bitStart;
			END IF; 
			
		WHEN bitStart => 
			next_state <= bitData; 
			
		WHEN bitData => 
			IF bitcpt < 8 THEN 
				next_state <= bitData;
			ELSE
				next_state <= bitStop;
			END IF; 

		WHEN bitStop=> 
				next_state <= idle; 

		WHEN others =>
				report "unreachable" severity failure;
	END CASE; 
END PROCESS change_state;

empty <= '1' WHEN State=idle ELSE '0';

end Behavioral;

