library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_TX is
	Generic (N : integer := 8);
    Port ( data_in : 	in  STD_LOGIC_VECTOR (N-1 downto 0);;		-- data received from memory
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
           SPI_SCK : 	in  STD_LOGIC;								-- clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
           SPI_MOSI : 	out  STD_LOGIC;		-- data received on N bits
		   x: out STD_LOGIC_VECTOR (1 downto 0);
		   y: out STD_LOGIC_VECTOR (N-1 downto 0));
end SPI_TX;

architecture Behavioral of SPI_TX is

type T_state is (idle, bitsdata);
signal current_state, etat_suivant : T_state;

-- compteur delai
signal spicounter, cpt_suivant : unsigned(N-1 downto 0);

signal data_buffer : 		STD_LOGIC_VECTOR (N-1 downto 0)		:= (others => '0');		-- Buffer for data

begin

registre_etat: process(clk,rst)
begin
	if rst = '1' then
	-- reset systeme asynchrone
		current_state <= etat0;
	-- current_state repos
		spicounter <= (others => '0');
	--raz compteur delai
	elsif rising_edge(clk) then
		current_state <= etat_suivant;
		spicounter <= cpt_suivant;
	end if;
end process registre_etat;

calcul_etat_suivant: process (current_state,BP,spicounter)
begin
	etat_suivant 				<= current_state;
	cpt_suivant 				<= spicounter;
	case current_state is 
		when idle =>
			cpt_suivant 		<= (others => '0');
			SPI_MOSI 			<= '0';
			-- raz compteur delai
			if spi_start = '1' then
				etat_suivant 	<= bitsdata;
			end if;
		when bitsdata =>
			-- premier current_state 1 detecte
			cpt_suivant <= spicounter + 1;
			if spicounter < N then
				etat_suivant <= bitsdata;
				data_buffer	 <= data_in(N-1 downto N-1);
				data_in		 <= data_in(N-2 downto 0) & '0'; 
			else
				etat_suivant <= idle;
			end if;
		when others =>
			-- autre cas : valeur par defaut
	end case;
end process calcul_etat_suivant;

-- Circuit select 
SPI_CS 			<= '1' when current_state = idle else '0';

-- Data out
data_out 		<= data_buffer;

y <= std_logic_vector(spicounter);
with current_state select
x <= "00" when idle,
	 "10" when bitsdata;
end Behavioral;