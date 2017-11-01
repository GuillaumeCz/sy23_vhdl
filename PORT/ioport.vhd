----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:38:52 08/26/2014 
-- Design Name: 
-- Module Name:    ioport - ioport_architecture 
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

entity ioport is
	Generic (	PORTX_ADDR :	integer := 16#1B#;
				DDR_ADDR :		integer	:=16#1A#;
				PINX_ADDR :		integer	:=16#19#);
    Port ( clk : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC;
		   PORTX : inout  STD_LOGIC_VECTOR (7 downto 0));
end ioport;

architecture ioport_architecture of ioport is

-- Register.
signal PORTX_register : 					STD_LOGIC_VECTOR(7 downto 0)				:= (others => 'Z');
signal DDRA_register : 						STD_LOGIC_VECTOR(7 downto 0)				:= (others => 'Z');
signal PINX_register : 						STD_LOGIC_VECTOR(7 downto 0)				:= (others => 'Z');

begin

	im : process (clk)
		variable a_int : natural;
		variable rdwr : std_logic_vector(1 downto 0);
	begin
		if (rising_edge(clk)) then
			a_int := CONV_INTEGER(addr);
			rdwr := rd & wr;
			if (a_int = PORTX_ADDR) then
			  case rdwr is
				 when "10" => -- rd
					ioread 				<= PORTX;
				 when "01" => -- wr
					if DDRA_register(0) = '1' then
						PORTX(0) <= 'Z';
					else
						PORTX(0) <= iowrite(0);
					end if;
					if DDRA_register(1) = '1' then
						PORTX(1) <= 'Z';
					else
						PORTX(1) <= iowrite(1);
					end if;
					if DDRA_register(2) = '1' then
						PORTX(2) <= 'Z';
					else
						PORTX(2) <= iowrite(2);
					end if;
					if DDRA_register(3) = '1' then
						PORTX(3) <= 'Z';
					else
						PORTX(3) <= iowrite(3);
					end if;
					if DDRA_register(4) = '1' then
						PORTX(4) <= 'Z';
					else
						PORTX(4) <= iowrite(4);
					end if;
					if DDRA_register(5) = '1' then
						PORTX(5) <= 'Z';
					else
						PORTX(5) <= iowrite(5);
					end if;
					if DDRA_register(6) = '1' then
						PORTX(6) <= 'Z';
					else
						PORTX(6) <= iowrite(6);
					end if;
					if DDRA_register(7) = '1' then
						PORTX(7) <= 'Z';
					else
						PORTX(7) <= iowrite(7);
					end if;
				 when others => NULL; 
			  end case;
			elsif (a_int = DDR_ADDR) then
				case rdwr is
					when "10" => -- rd
						ioread 			<= DDRA_register;
					when "01" => -- wr
						DDRA_register 	<= iowrite;
					when others => NULL; 
				end case;
			elsif (a_int = PINX_ADDR) then
				case rdwr is
					when "10" => -- rd
						ioread 			<= PINX_register;
					when "01" => -- wr
					when others => NULL; 
				end case;
			end if;
		end if;
	end process im;	

	-- read all time the PORT PIN
	PINX_register <= PORTX;
	
end ioport_architecture;

