----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:57:48 08/26/2014 
-- Design Name: 
-- Module Name:    microcontroleur - microcontroleur_architecture 
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

entity microcontroleur is
    Port ( clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC;
			  PORTA : inout STD_LOGIC_VECTOR (7 downto 0);
			  PORTB : inout STD_LOGIC_VECTOR (7 downto 0));
end microcontroleur;

architecture microcontroleur_architecture of microcontroleur is

	component mcu_core is
		Port (
			Clk	: in std_logic;
			Rst	: in std_logic; -- Reset core when Rst='1'
			En		: in std_logic; -- CPU stops when En='0', could be used to slow down cpu to save power
			-- PM
			PM_A		: out std_logic_vector(15 downto 0);
			PM_Drd	: in std_logic_vector(15 downto 0);
			-- DM
			DM_A		: out std_logic_vector(15 downto 0); -- 0x00 - xxxx
			DM_Areal	: out std_logic_vector(15 downto 0); -- 0x60 - xxxx (same as above + io-adr offset)
			DM_Drd	: in std_logic_vector(7 downto 0);
			DM_Dwr	: out std_logic_vector(7 downto 0);
			DM_rd		: out std_logic;
			DM_wr		: out std_logic;
			-- IO
			IO_A		: out std_logic_vector(5 downto 0); -- 0x00 - 0x3F
			IO_Drd	: in std_logic_vector(7 downto 0);
			IO_Dwr	: out std_logic_vector(7 downto 0);
			IO_rd		: out std_logic;
			IO_wr		: out std_logic;
			-- OTHER
		   OT_FeatErr	: out std_logic; -- Feature error! (Unhandled part of instruction)
		   OT_InstrErr	: out std_logic -- Instruction error! (Unknown instruction)
		);
	end component mcu_core;
	--PM
	component pm  is
		Port (
				Clk	: in std_logic;
				rst	: in std_logic; -- Reset when Rst='1'
				-- PM
				PM_A		: in std_logic_vector(15 downto 0);
				PM_Drd	: out std_logic_vector(15 downto 0)
		);
	end component pm;	

  component dm is
    Port ( clk : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (15 downto 0);
           dataread : out  STD_LOGIC_VECTOR (7 downto 0);
           datawrite : in  STD_LOGIC_VECTOR (7 downto 0);
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC);
  end component dm;
  
component ioport is
	 Generic (BASE_ADDR	: integer := 16#1B#);
    Port ( clk : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC;
			  inport : in  STD_LOGIC_VECTOR (7 downto 0);
           outport :	out  STD_LOGIC_VECTOR (7 downto 0));
end component ioport;

	signal PM_A		: std_logic_vector(15 downto 0);
	signal PM_Drd	: std_logic_vector(15 downto 0);
	-- DM
	signal DM_A			: std_logic_vector(15 downto 0); -- 0x00 - xxxx
	signal DM_Areal	: std_logic_vector(15 downto 0); -- 0x60 - xxxx (same as above + io-adr offset)
	signal DM_Drd		: std_logic_vector(7 downto 0);
	signal DM_Dwr		: std_logic_vector(7 downto 0);
	signal DM_rd		: std_logic;
	signal DM_wr		: std_logic;
	-- IO
	signal IO_A		: std_logic_vector(5 downto 0); -- 0x00 - 0x3F
	signal IO_Drd	: std_logic_vector(7 downto 0);
	signal IO_Dwr	: std_logic_vector(7 downto 0);
	signal IO_rd	: std_logic;
	signal IO_wr	: std_logic;

begin

	core : mcu_core Port map (
		Clk	=> clk,
		Rst	=> Rst,
		En		=> '1',
		-- PM
		PM_A		=> PM_A,
		PM_Drd	=> PM_Drd,
		-- DM
		DM_A		=> DM_A,
		DM_Areal	=> DM_Areal,
		DM_Drd	=> DM_Drd,
		DM_Dwr	=> DM_Dwr,
		DM_rd		=> DM_rd,
		DM_wr		=> DM_wr,
		-- IO
		IO_A		=> IO_A,
		IO_Drd	=> IO_Drd,
		IO_Dwr	=> IO_Dwr,
		IO_rd		=> IO_rd,
		IO_wr		=> IO_wr,
		-- OTHER
		OT_FeatErr => open,
		OT_InstrErr	=> open
	);

	prgmem : pm port map (
			Clk	=> clk,
			Rst	=> Rst,
			-- PM
			PM_A		=> PM_A,
			PM_Drd	=> PM_Drd
	);
	
	datamem : dm port map (
           clk => clk,
           addr => DM_A,
           dataread  => DM_Drd,
           datawrite => DM_Dwr,
           rd => DM_rd, 
           wr =>	DM_wr
	);
	
	ioportA : ioport generic map ( BASE_ADDR => 16#1B# )
	        port map (
            clk => clk,
            addr => IO_A,
            ioread  => IO_Drd,
            iowrite => IO_Dwr,
            rd => IO_rd, 
            wr =>	IO_wr,
			   outport => PORTA,
				inport => PORTB
	        );	


end microcontroleur_architecture;

