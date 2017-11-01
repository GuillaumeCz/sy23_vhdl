library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity IODrdmux is
	 Generic (ADDR_0	: integer := 16#19#; LG_0 : integer := 2;
	          ADDR_1 : integer := 16#16#;LG_1 : integer := 2;
		       ADDR_2 : integer := 16#2D#; LG_2 : integer := 3;
				 ADDR_3 : integer := 16#0D#; LG_3 : integer := 2);
    Port ( IO_address : in  STD_LOGIC_VECTOR (5 downto 0);
           IO_data0 : in  STD_LOGIC_VECTOR (7 downto 0);
           IO_data1 : in  STD_LOGIC_VECTOR (7 downto 0);
			  IO_data2 : in  STD_LOGIC_VECTOR (7 downto 0);
			  IO_data3 : in  STD_LOGIC_VECTOR (7 downto 0);
           IO_data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end IODrdmux;

architecture IODrdmux_architecture of IODrdmux is

begin

     IO_data_out <= IO_data0 when (IO_address >= std_logic_vector(to_unsigned(ADDR_0,6))) 
	                               and (IO_address <= std_logic_vector(to_unsigned(ADDR_0 + LG_0,6))) 
                    else IO_data1 when (IO_address >= std_logic_vector(to_unsigned(ADDR_1,6)))
						                      and (IO_address <= std_logic_vector(to_unsigned(ADDR_1 + LG_1 ,6)))
					     else IO_data2 when (IO_address >= std_logic_vector(to_unsigned(ADDR_2,6)))
						                      and (IO_address <= std_logic_vector(to_unsigned(ADDR_2 + LG_2 ,6)))
					     else IO_data3 when (IO_address >= std_logic_vector(to_unsigned(ADDR_3,6)))
						                      and (IO_address <= std_logic_vector(to_unsigned(ADDR_3 + LG_3 ,6)))
						  else "XXXXXXXX";	
	
end IODrdmux_architecture;

