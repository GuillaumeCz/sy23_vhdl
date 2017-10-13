----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:59:03 10/04/2017 
-- Design Name: 
-- Module Name:    SPI_RW - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
-- 16Mbits Flash memory 
-- 25MHz fequency
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_RW is
	 Generic (N : integer := 8;
				 M : integer := 8);
    Port ( data_in : in  STD_LOGIC_VECTOR (N-1 downto 0);	-- data transmitted on N bits
           SPI_MISO : in  STD_LOGIC;								-- data received from memory
           spi_start : in  STD_LOGIC;								-- transmission start pulse
           rst : in  STD_LOGIC;										-- reset
           clk : in  STD_LOGIC;										-- clock
           SPI_CS : out  STD_LOGIC;									-- select circuit
           SPI_SCK : out  STD_LOGIC;								-- clock
           SPI_MOSI : out  STD_LOGIC;								-- data transmitted to memory
           data_out : out  STD_LOGIC_VECTOR (M-1 downto 0));-- data received on M bits
end SPI_RW;

architecture Behavioral of SPI_RW is

type T_state is (idle, bitswrite ,bitsread);
signal next_state, current_state : T_state;

signal wcounter : integer range 0 to N+1 := 0;
signal rcounter : integer range 0 to M+1 := 0;

signal cmd_in : std_logic_vector (7 downto 0);

begin

clock_tick: process(clk)
begin
	if rising_edge(clk) then
		if rst = '1' then
			current_state <= idle;
		else
			current_state <= next_state;
			if(SPI_SCK = '1') then
				wcounter <= wcounter+1;
				rcounter <= rcounter+1;
			end if;
		end if;
	end if;
end process clock_tick;

change_state: process(current_state, spi_start)
begin
	next_state <= current_state;
	case current_state is
		when idle =>
			if spi_start = '1' then
				next_state <= bitswrite;
			end if;
			
		when bitswrite =>
			if wcounter <= N-1 then
				next_state <= bitswrite;
			else
				next_state <= bitsread;
			end if;
			
		when bitsread =>
			if rcounter <= M-1 then
				next_state <= bitsread;
			else
				next_state <= idle;
			end if;
	end case;
end process change_state;

SPI_CS 	<= '1' when current_state = idle else '0';

SPI_MOSI <= '0' when current_state = idle;
SPI_MOSI <= cmd_in(wcounter) when current_state = bitswrite;

data_out(rcounter) <= SPI_MISO when current_state = idle;
rcounter <= '0' when current_state = idle;



end Behavioral;

