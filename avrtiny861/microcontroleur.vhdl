library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity microcontroleur is
    Port ( clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC;
			  PORTA : inout STD_LOGIC_VECTOR (7 downto 0);
			  PORTB : inout STD_LOGIC_VECTOR (7 downto 0);
			  OC1A : out STD_LOGIC;
			  OC1Abar : out STD_LOGIC;
			  SCK : out STD_LOGIC;
			  MOSI : out STD_LOGIC;
			  MISO : in STD_LOGIC);
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
	        Rst : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC;
			  ioport : inout  STD_LOGIC_VECTOR (7 downto 0));
end component ioport;

component timer is
	 Generic (BASE_ADDR	: integer := 16#2D#);
    Port ( clk : in  STD_LOGIC;
	        Rst : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC;
			  OC1A : out  STD_LOGIC;
			  OC1Abar : out  STD_LOGIC);
end component timer;

component usi is
	 Generic (BASE_ADDR	: integer := 16#0D#);
    Port ( clk : in  STD_LOGIC;
           Rst : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           wr : in  STD_LOGIC;
           rd : in  STD_LOGIC;
           SCK : out  STD_LOGIC;
           MOSI : out  STD_LOGIC;
           MISO : in  STD_LOGIC);
end component usi;

component IODrdmux is
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
end component IODrdmux;


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
	-- mux
	signal IO_Drd_mux_A	: std_logic_vector(7 downto 0);
	signal IO_Drd_mux_B	: std_logic_vector(7 downto 0);
	signal IO_Drd_mux_TIMER	: std_logic_vector(7 downto 0);
	signal IO_Drd_mux_USI	: std_logic_vector(7 downto 0);

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
	
	ioportA : ioport generic map ( BASE_ADDR => 16#19# )
	        port map (
            clk => clk,
				Rst => Rst,
            addr => IO_A,
            ioread  => IO_Drd_mux_A,
            iowrite => IO_Dwr,
            rd => IO_rd, 
            wr =>	IO_wr,
			   ioport => PORTA
	        );	
			  
	ioportB : ioport generic map ( BASE_ADDR => 16#16# )
	        port map (
            clk => clk,
				Rst => Rst,
            addr => IO_A,
            ioread  => IO_Drd_mux_B,
            iowrite => IO_Dwr,
            rd => IO_rd, 
            wr =>	IO_wr,
			   ioport => PORTB
	        );	
			  
	timerA : timer generic map ( BASE_ADDR => 16#2D# )
	        port map (
            clk => clk,
				Rst => Rst,
            addr => IO_A,
            ioread  => IO_Drd_mux_TIMER,
            iowrite => IO_Dwr,
            rd => IO_rd, 
            wr =>	IO_wr,
			   OC1A => OC1A,
				OC1Abar => OC1Abar
	        );		

	usispi : usi generic map ( BASE_ADDR => 16#0D# )
	        port map (
            clk => clk,
				Rst => Rst,
            addr => IO_A,
            ioread  => IO_Drd_mux_USI,
            iowrite => IO_Dwr,
            rd => IO_rd, 
            wr =>	IO_wr,
            SCK => SCK,
            MOSI => MOSI,
            MISO => MISO
	        );				  
			  
	datamux: IODrdmux generic map (ADDR_0 => 16#19#,LG_0 => 2,
                                  ADDR_1 => 16#16#, LG_1 => 2,
											 ADDR_2 => 16#2D#, LG_2 => 3,
											 ADDR_3 => 16#0D#, LG_3 => 2)
	           port map (
				    IO_address => IO_A,
					 IO_data0 => IO_Drd_mux_A,
					 IO_data1 => IO_Drd_mux_B,
					 IO_data2 => IO_Drd_mux_TIMER,
					 IO_data3 => IO_Drd_mux_USI,
					 IO_data_out => IO_Drd
				  );


end microcontroleur_architecture;

