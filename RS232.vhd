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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RS232 is
    Port ( clk : in  STD_LOGIC;
           start : in  STD_LOGIC;
			  rst : in STD_LOGIC;
           datas : in  STD_LOGIC_VECTOR (7 downto 0);
           clk_div : in  STD_LOGIC_VECTOR (7 downto 0);
			  empty : out  STD_LOGIC;
			  x: out integer range 0 to 4;
			  y: out STD_LOGIC;
			  z: out STD_LOGIC;
           TX : out  STD_LOGIC);
end RS232;

architecture Behavioral of RS232 is

TYPE State_type IS (idle, bitStart, bitData, bitStop);  --
SIGNAL state : State_Type		 := idle;    -- 
SIGNAl next_state : State_Type := idle;
SIGNAL bitcpt : integer range 0 to 7; --STD_LOGIC_VECTOR (2 downto 0);
SIGNAL data : STD_LOGIC_VECTOR (7 downto 0) := datas;
BEGIN 

clock_tick: PROCESS (clk, rst) 
BEGIN 
	y <= '0';
    IF (rst = '1') THEN
		state <= idle;
    ELSIF rising_edge(clk) THEN
		y <= '1';
		state <= next_state;
		IF state = idle THEN
			TX <= '1';
			bitcpt <= 0;
		ELSIF state = bitStart THEN
			TX <= '0';
		ELSIF state = bitData THEN
			TX <= datas(0);
			data <= '0' & data (7 downto 1);	
			bitcpt <= bitcpt + 1;--std_logic_vector( unsigned(bitcpt) + 1 );
		ELSIF state = bitStop THEN
			TX <= '1';
		END IF;
	 END IF;
END PROCESS clock_tick;
	 
change_state: PROCESS(state)
BEGIN
	z <= '0';
	CASE state IS
		WHEN IDLE => 
			IF start= '1' THEN 
				next_state <= bitStart; 
				z <= '1';
			END IF; 
			
		WHEN bitStart => 
			next_state <= bitData; 
			
		WHEN bitData => 
			IF bitcpt <= 7 THEN 
				next_state <= bitData;
			ELSE
				next_state <= bitStop;
			END IF; 

		WHEN bitStop=> 
				next_state <= idle; 

		WHEN others =>
			next_state <= idle;
	END CASE; 
END PROCESS change_state;

empty <= '1' WHEN State=idle ELSE '0';

with State select
x <= 0 when idle,
     1 when bitStart,
	  2 when bitData,
	  3 when bitStop;

end Behavioral;

