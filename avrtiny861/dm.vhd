----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:15:55 08/26/2014 
-- Design Name: 
-- Module Name:    dm - dm_architecture 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dm is
    Port ( clk : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
           dataread : out  STD_LOGIC_VECTOR (7 downto 0);
           datawrite : in  STD_LOGIC_VECTOR (7 downto 0);
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC);
end dm;

architecture dm_architecture of dm is

type mem_type	is array(0 to 511) of std_logic_vector(7 downto 0);
signal mem : mem_type;

begin
	dmproc : process (clk)
		variable a_int : natural;
		variable rdwr : std_logic_vector(1 downto 0);
	begin
		if (clk'event and clk='1') then
			a_int := CONV_INTEGER(addr);
			rdwr := rd & wr;
			dataread <= (others => '0');
			case rdwr is
				when "10" => -- rd
					dataread <= mem(a_int);
				when "01" => -- wr
					mem(a_int) <= datawrite;
				when others => NULL;	
			end case;
		end if;
	end process dmproc;

end dm_architecture;

