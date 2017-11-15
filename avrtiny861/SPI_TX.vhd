library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_TX is
	Generic (N : integer := 8);
    Port ( data_in : 	in  STD_LOGIC_VECTOR (N-1 downto 0);		-- data received from memory
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
		   clk :		in	STD_LOGIC;								-- system clock
           SPI_SCK : 	out  STD_LOGIC;								-- SPI clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
           SPI_MOSI : 	out  STD_LOGIC);						-- data received on N bits
end SPI_TX;

architecture Behavioral of SPI_TX is

-- Déclaration du composant de division de fréquence
component diviseur_generique
	Generic(clkdiv : integer := 2);
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           tc0 : out  STD_LOGIC;
           tc1 : out  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end component;

-- Constante de division de fréquence d'horloge pour se synchroniser à l'horloge SCK
constant bauds : integer := 115200;
constant sysclk : real := 50.0e6 ; -- 50MHz
constant clkdiv : integer := integer(sysclk / real(bauds));

-- Machine à état et son buffer
type T_state is (idle, bitsdata);
signal current_state, next_state : T_state;

-- Compteur de bits envoyés et son buffer
signal spicounter, spicounter_next :	STD_LOGIC_VECTOR(N-1 downto 0)		:= (others => '0');

-- Registre de data qui va être modifié au cours de l'envoie des bits
signal data_buffer : 					STD_LOGIC_VECTOR (N-1 downto 0)		:= (others => '0');

-- Horloge avec fréquence divisée
signal divided_clock :					STD_LOGIC							:= '0';
signal tc0, tc1 :						STD_LOGIC							:= '0'; -- not used

begin

-- Générateur d'horloge SCK
clk_divider: diviseur_generique 
   Generic map (
		  clkdiv	=> clkdiv )
   PORT MAP (
		  clk	=> clk,
          rst 	=> rst,
          tc0	=> tc0,
          tc1 	=> tc1,
		  clk_out  => divided_clock
		  );

-- Processus de modification de la machine à Etat
change_state: process(clk,rst)
begin
	-- Système de reset asynchrone
	if rst = '1' then
		-- Mise à l'état initial de la machine à état
		current_state 	<= idle;
		-- Mise à zéro du compteur
		spicounter 		<= (others => '0');
		-- Mise à zéro du bit de sortie
		SPI_MOSI 		<= '0';
	elsif rising_edge(clk) then
		-- Mise à jour de l'état et du compteur à chaque front montant
		current_state 	<= next_state;
		spicounter 		<= spicounter_next;
		-- Envoie du Most Significant Bit du buffer sur l'esclave
		SPI_MOSI 		<= data_buffer(N-1);
	end if;
end process change_state;

-- Processus d'incrémentation du compteur
counter_increment: process (spi_start, divided_clock)
begin
	-- Assignation des valeurs du compteur et de la machine à état aux buffers
	next_state	 					<= current_state;
	spicounter_next 				<= spicounter;
	case current_state is 
		when idle =>
			-- A l'état initial remise à zéro du compteur
			spicounter_next 		<= (others => '0');
			-- Change d'état si le signal de début de transmission est activé
			if spi_start = '1' then
				-- Sauvegarde la séquence de bit à envoyé dans le buffer
				data_buffer			<= data_in;
				-- Passe à l'état d'envoie de bit
				next_state	 		<= bitsdata;
			end if;
			
		when bitsdata =>
			-- Synchronise l'envoie des bits avec l'horloge SCK
			if divided_clock = '1' then							
				-- Incrémente le compteur
				spicounter_next	 	<= std_logic_vector(unsigned(spicounter) + 1);
				-- Décale le registre pour placer le prochain bit à envoyé à la position du Most Significant Bit.
				data_buffer			<= data_buffer(N-2 downto 0) & '0'; 
			end if;
			-- Si tout les bits ont été envoyés on reviens à l'état initial sinon on reste dans le même état
			if to_integer(unsigned(spicounter_next)) < N then
				next_state	 		<= bitsdata;
			else
				next_state			<= idle;
			end if;
		when others => NULL;
	end case;
end process counter_increment;

-- Signal témoignant de l'activation de la transmission si la machine à état est en mode bitsdata
SPI_CS 			<= '1' when current_state = idle else '0';

-- Envoie de l'horloge divisée SCK afin de synchroniser la réception
SPI_SCK			<= divided_clock;

end Behavioral;