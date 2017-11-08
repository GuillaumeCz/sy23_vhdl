library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
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
end timer;

architecture timer_architecture of timer is

component diviseur_timer is
    Port ( clk 		: in  STD_LOGIC;
           rst 		: in  STD_LOGIC;
		   N 		: in STD_LOGIC_VECTOR(3 downto 0);
           clk_out 	: out  STD_LOGIC);
end component;

component timer_multiplixer is
    Port ( CS : in  STD_LOGIC_VECTOR (3 downto 0);
           N : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

constant OCR1A 	 		: integer := BASE_ADDR ;
constant TCNT1 	 		: integer := BASE_ADDR + 1;
constant TCCR1B  		: integer := BASE_ADDR + 2;
constant TCCR1A  		: integer := BASE_ADDR + 3;

signal reg_compA 		: STD_LOGIC_VECTOR (7 downto 0);
signal reg_count 		: STD_LOGIC_VECTOR (7 downto 0);
signal reg_ctrlA 		: STD_LOGIC_VECTOR (7 downto 0);
signal reg_ctrlB 		: STD_LOGIC_VECTOR (7 downto 0);

signal COM1A	 		: STD_LOGIC_VECTOR (1 downto 0);
signal COM1B	 		: STD_LOGIC_VECTOR (1 downto 0);
signal FOC1A	 		: STD_LOGIC;
signal FOC1B	 		: STD_LOGIC;
signal PWM1A	 		: STD_LOGIC;
signal PWM1B	 		: STD_LOGIC;

signal PWM1X	 		: STD_LOGIC;
signal PSR1		 		: STD_LOGIC;
signal DTPS	 	 		: STD_LOGIC_VECTOR (3 downto 0);
signal CS		 		: STD_LOGIC_VECTOR (3 downto 0);
signal N 				: STD_LOGIC_VECTOR (7 downto 0);

signal OC1A_buffer 		: STD_LOGIC := '1';

signal Rst_predivisor 	: STD_LOGIC := '0';
signal predivisor_out 	: STD_LOGIC := '0';


begin

	predivisor: diviseur_timer
    Port map(
			clk 	=> clk,
			rst 	=> Rst_predivisor,
			N 		=> DTPS,
			clk_out	=> predivisor_out
			);
			
	CS_converter: timer_multiplixer
    Port map(
			CS 	=> CS,
			N 	=> N
			);
			
clock_tick: process(predivisor_out, rst)
variable a_int : natural;
variable rdwr : std_logic_vector(1 downto 0);
begin
	if Rst = '1' then
	  reg_count <= (others => '0');
	elsif rising_edge(predivisor_out) then
		if reg_count < N and PWM1A = '1' then
			reg_count <= std_logic_vector(unsigned(reg_count) + 1);
		else 
			reg_count <= (others => '0');
		end if;
		
		a_int := to_integer(unsigned(addr));
		rdwr  := rd & wr;
		if (a_int = OCR1A) then
		  case rdwr is
			 when "10" => -- rd
				ioread		<= reg_compA;
			 when "01" => -- wr
				reg_compA	<= iowrite;
			 when others => NULL; 
		  end case;
		elsif (a_int = TCNT1) then
			case rdwr is
				when "10" => -- rd
					ioread			<= reg_count;
				when "01" => -- wr
					reg_count		<= iowrite;
				when others => NULL; 
			end case;
		elsif (a_int = TCCR1B) then
			case rdwr is
				when "10" => -- rd
					ioread 			<= reg_ctrlB;
				when "01" => -- wr
					reg_ctrlB		<= iowrite;
				when others => NULL; 
			end case;
		elsif (a_int = TCCR1A) then
			case rdwr is
				when "10" => -- rd
					ioread 			<= reg_ctrlA;
				when "01" => -- wr
					reg_ctrlA		<= iowrite;
				when others => NULL; 
			end case;
		end if;
	end if;
end process clock_tick;

pp : process(reg_count, FOC1A)
begin 
	if FOC1A = '1' or reg_count'event then
		case COM1A is
			when "00" =>
				OC1A_buffer			<= 'Z';
			when "01" =>
				if reg_count = "00000000" then
					OC1A_buffer 	<= '1';
				elsif reg_compA < reg_count then
					OC1A_buffer		<= '0';
				end if;
			when "10" => -- wr
				if reg_count = "00000000" then
					OC1A_buffer 	<= '1';
				elsif reg_compA < reg_count then
					OC1A_buffer		<= '0';
				end if;
			when "11" => 
				if reg_count = "00000001" then
					OC1A_buffer 	<= '1';
				elsif reg_compA < reg_count then
					OC1A_buffer		<= '1';
				end if;
			when others => NULL;
		end case;
	end if;
end process pp;
  
COM1A 	<= reg_ctrlA(7 downto 6);
FOC1A	<= reg_ctrlA(3);
PWM1A	<= reg_ctrlA(1);

PWM1X	<= reg_ctrlB(7);
PSR1	<= reg_ctrlB(6);
DTPS 	<= "00" & reg_ctrlB(5 downto 4);
CS		<= reg_ctrlB(3 downto 0);


Rst_predivisor <= PSR1;
  
OC1A	<= not OC1A_buffer 	when PWM1X = '1' else OC1A_buffer;
OC1Abar <= OC1A_buffer  	when PWM1X = '1' else OC1A_buffer;

end timer_architecture;

