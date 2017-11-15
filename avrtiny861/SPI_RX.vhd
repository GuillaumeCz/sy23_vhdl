library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_RX is
	Generic (N : integer := 8);
    Port ( SPI_MISO : 	in  STD_LOGIC;								-- data received from memory
           spi_start : 	in  STD_LOGIC;								-- transmission start pulse
           rst : 		in  STD_LOGIC;								-- reset
		   clk :		in	STD_LOGIC;								-- system clock
           SPI_SCK : 	out  STD_LOGIC;								-- SPI clock
           SPI_CS : 	out  STD_LOGIC;								-- select circuit
           data_out : 	out  STD_LOGIC_VECTOR (N-1 downto 0));		-- data received on N bits
end SPI_RX;

architecture Behavioral of SPI_RX is

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
signal state_next, current_state : T_state;

-- Compteur de bits envoyés et son buffer
signal spicounter, spicounter_next : 		UNSIGNED (N-1 downto 0) 			:= (others => '0');		-- Number of bit received counter

-- Registre de data reçu
signal data :								STD_LOGIC_VECTOR (N-1 downto 0)		:= (others => '0');		-- data received

-- Horloge avec fréquence divisée
signal divided_clock : 						STD_LOGIC							:= '0';
signal tc0, tc1 :							STD_LOGIC							:= '0';  -- not used

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
clock_tick: process(clk)
begin
	if rst = '1' then
		-- Mise à l'état initial de la machine à état
		current_state 	<= idle;
		-- Mise à zéro du compteur
		spicounter		<= (others => '0');
	elsif rising_edge(clk) then
		-- Mise à jour de l'état et du compteur à chaque front montant
		current_state 			<= state_next;
		spicounter 		<= spicounter_next;
	end if;
end process clock_tick;

-- Processus d'incrémentation du compteur
change_state: process(spi_start, divided_clock, current_state)
begin
	-- Assignation des valeurs du compteur et de la machine à état aux buffers
	state_next 							<= current_state;
	spicounter_next						<= spicounter;
	
	case current_state is
		when idle =>
			-- Change d'état si le signal de début de transmission est activé
			if spi_start = '1' then
				-- Mise à l'état de réception des données
				state_next 				<= bitsdata;
				-- Mise à zéro des données reçu
				data					<= (others => '0');	
			end if;
			-- Mise à zéro du compteur
			spicounter_next 			<= (others => '0');
			
		when bitsdata =>
			-- Si l'horloge divisée à un front descendant, on synchronise la réception avec les données transmisent sur un front montant
			if divided_clock = '0' then				
				-- On décale vers la gauche le registre des données reçu et on ajoute le bit reçu à l'instant
				data 					<= data(6 downto 0) & SPI_MISO; -- Add on the LSB the received bit.
				-- On incrémente le compteur de bit
				spicounter_next			<= spicounter + 1;	
				
				-- Si le compteur de bit reçu est supérieur au nombre de bit max on reviens à l'état initial sinon on reste au même état
				if spicounter_next < N then
					state_next			<= bitsdata;
				else
					state_next			<= idle;
				end if;
			end if;
	end case;
	-- Envoie de la valeur de données sur la sortie des données
	data_out			<= data;
end process change_state;

-- Signal témoignant de l'activation de la réception si la machine à état est en mode bitsdata
SPI_CS 			<= '1' when state_next = idle else '0';

-- Envoie de l'horloge divisée SCK afin de synchroniser la transmission
SPI_SCK <= divided_clock when current_state = bitsdata else '1';


end Behavioral;

