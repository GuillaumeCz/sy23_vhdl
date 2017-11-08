library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity ioport is
	 Generic (BASE_ADDR	: integer := 16#19#);
    Port ( clk : in  STD_LOGIC;
	       Rst : in  STD_LOGIC;
           addr : in  STD_LOGIC_VECTOR (5 downto 0);
           ioread : out  STD_LOGIC_VECTOR (7 downto 0);
           iowrite : in  STD_LOGIC_VECTOR (7 downto 0);
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC;
		   ioport : inout  STD_LOGIC_VECTOR (7 downto 0));
end ioport;

architecture ioport_architecture of ioport is

constant PORT_ADDR : integer := BASE_ADDR + 2;
constant DDR_ADDR : integer := BASE_ADDR + 1;
constant PIN_ADDR : integer := BASE_ADDR;

-- Register.
signal PORT_register: 						STD_LOGIC_VECTOR(7 downto 0)				:= (others => 'Z');
signal DDR_register : 						STD_LOGIC_VECTOR(7 downto 0)				:= (others => 'Z');
signal PIN_register : 						STD_LOGIC_VECTOR(7 downto 0)				:= (others => 'Z');

begin

im : process (clk, Rst)
		variable a_int : natural;
		variable rdwr : std_logic_vector(1 downto 0);
	begin
		if (Rst = '1') then
			PORT_register	<= (others => 'Z');
			DDR_register 	<= (others => 'Z');
			PIN_register	<= (others => 'Z');
		elsif (rising_edge(clk)) then
			a_int := CONV_INTEGER(addr);
			rdwr  := rd & wr;
			if (a_int = PORT_ADDR) then
			  case rdwr is
				 when "10" => -- rd
					ioread		<= ioport;
				 when "01" => -- wr
					if DDR_register(0) = '1' then
						ioport(0) <= 'Z';
					else
						ioport(0) <= iowrite(0);
					end if;
					if DDR_register(1) = '1' then
						ioport(1) <= 'Z';
					else
						ioport(1) <= iowrite(1);
					end if;
					if DDR_register(2) = '1' then
						ioport(2) <= 'Z';
					else
						ioport(2) <= iowrite(2);
					end if;
					if DDR_register(3) = '1' then
						ioport(3) <= 'Z';
					else
						ioport(3) <= iowrite(3);
					end if;
					if DDR_register(4) = '1' then
						ioport(4) <= 'Z';
					else
						ioport(4) <= iowrite(4);
					end if;
					if DDR_register(5) = '1' then
						ioport(5) <= 'Z';
					else
						ioport(5) <= iowrite(5);
					end if;
					if DDR_register(6) = '1' then
						ioport(6) <= 'Z';
					else
						ioport(6) <= iowrite(6);
					end if;
					if DDR_register(7) = '1' then
						ioport(7) <= 'Z';
					else
						ioport(7) <= iowrite(7);
					end if;
				 when others => NULL; 
			  end case;
			elsif (a_int = DDR_ADDR) then
				case rdwr is
					when "10" => -- rd
						ioread			<= DDR_register;
					when "01" => -- wr
						DDR_register 	<= iowrite;
					when others => NULL; 
				end case;
			elsif (a_int = PIN_ADDR) then
				case rdwr is
					when "10" => -- rd
						ioread 			<= PIN_register;
					when "01" => -- wr
					when others => NULL; 
				end case;
			end if;
		end if;
end process im;	

	-- read all time the PORT PIN
	PIN_register <= ioport;

end ioport_architecture;

