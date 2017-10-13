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


entity RS232 is
    Port ( clk : in  STD_LOGIC;
      start : in  STD_LOGIC;
  	  rst : in STD_LOGIC;
      datas : in  STD_LOGIC_VECTOR (7 downto 0);
      clk_div : in  STD_LOGIC_VECTOR (7 downto 0);
   	  empty : out  STD_LOGIC;
		  x: out STD_LOGIC_VECTOR (1 downto 0);
		  z: out STD_LOGIC_VECTOR (2 downto 0);
      TX : out  STD_LOGIC);
end RS232;

architecture Behavioral of RS232 is

TYPE State_type IS (idle, bitStart, bitData, bitStop);  --
SIGNAL state : State_Type		 := idle;    -- 
SIGNAl next_state : State_Type := idle;
SIGNAL bitcpt : STD_LOGIC_VECTOR (2 downto 0) := "000";
SIGNAL data : STD_LOGIC_VECTOR (7 downto 0) := datas;

SIGNAL hu: STD_LOGIC := '0';

BEGIN 

clock_tick: PROCESS (clk, rst) 
BEGIN 
  IF (rst = '1') THEN
  	state <= idle;
  ELSIF rising_edge(clk) THEN
  	state <= next_state;
	IF state = idle THEN
		  TX <= '1';
		  bitcpt <= "000";
  	ELSIF state = bitStart THEN
	  	TX <= '0';
  	ELSIF state = bitData THEN
	  	--TX <= datas(bitcpt);
	  	data <= '0' & data (7 downto 1);	
		bitcpt <= std_logic_vector( unsigned(bitcpt) + 1 );
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
			IF bitcpt < "111" THEN 
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

z <= bitcpt;
with State select
x <= "00" when idle,
     "01" when bitStart,
	 "10" when bitData,
	 "11" when bitStop;

end Behavioral;

