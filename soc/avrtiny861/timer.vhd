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

constant OCR1A : integer := BASE_ADDR ;
constant TCNT1 : integer := BASE_ADDR + 1;
constant TCCR1B : integer := BASE_ADDR + 2;
constant TCCR1A : integer := BASE_ADDR + 3;

constant bauds : integer := 115200;
constant sysclk : real := 50.0e6;
constant clkdiv : integer := integer(sysclk/ real(bauds));

signal divided_clock : STD_LOGIC := '0';
signal control_clock : STD_LOGIC := '0';
signal tc0, tc1 : STD_LOGIC := '0';

signal rst_div : STD_LOGIC := '0';

signal reg_compA : STD_LOGIC_VECTOR (7 downto 0);
signal reg_count : STD_LOGIC_VECTOR (7 downto 0);
signal reg_ctrlA : STD_LOGIC_VECTOR (7 downto 0);
signal reg_ctrlB : STD_LOGIC_VECTOR (7 downto 0);

component diviseur_generique
  Generic( clkdiv : integer 2);
  Port(
        clk : in STD_LOGIC;
        rst_div : in STD_LOGIC;
        tc0 : out STD_LOGIC;
        tc1 : out STD_LOGIC;
        clk_out : out STD_LOGIC);

begin

  clk_divider: diviseur_generique
  Generic map(
    clkdiv => clkdiv)
  Port map(
    clk => control_clock,
    rst_div => rst,
    tc0 => tc0,
    tc1 => tc1,
    clk_out => divided_clock
  );

  clock_tick : process(control_clock)
    variable a_int : natural;
    variable rdwr : std_logic_vector(1 downto 0);
  begin
    if rst = '1' then
      reg_count <= (others => '0');
      OC1A <= '1';
      OC1Abar <= '0';
      reg_compA <= (others => 'Z');
    elsif rising_edge(control_clock) then
      a_int := to_integer(unsigned(addr));
      rdwr <= rd & wr;
      
      if a_int = TCCR1A and TCCR1A(1) = '1' then
        case rdwr is 
          when "10" => 
            ioread <= reg_compA;
          when "01" => 
            reg_compA = iowrite;

        end case;
        reg_compA <= TCCR1A(7) & TCCR1A(6);
      end if;

      if a_int = TCCR1B then
        case rdwr is 
          when "10" => NULL;
          when "01" => reg
        end case;
        rst_div <= TCCR1B(6);

      end if;

      if to_integer(unsigned(reg_count)) >= OCR1A then
        OC1A <= '0';
        OC1Abar <= '1';
      else
        OC1A <= '1';
        OC1Abar <= '0';
      end if;
      reg_count <= std_logic_vector(unsigned(reg_count)+1 );
    end if;
  end process clock_tick;
  
  comparateur : process(reg_compA)
  begin
    case reg_compA is
      when "00" =>
        OC1A <= '0';
        OC1Abar <= '0';
      when "01" =>
        OC1A <= '1';
        OC1Abar <= '1';
      when "10" =>
        OC1A <= '1';
        OC1Abar <= '0';
      when "11" => 
        OC1A <= '1';
        OC1Abar <= '1';
      when others => NULL;
  end process comparateur;

end timer_architecture;

