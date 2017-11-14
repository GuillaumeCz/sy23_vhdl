library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Entité timer
  -- A partir de registres en entrés, définition d'un signal PWM
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
  -- inclusion du diviseur de fréquence programmable pour obtenir une horloge dont la frequence est différente de l'horloge principale
  component diviseur_timer is
      Port ( clk 		: in  STD_LOGIC;
             rst 		: in  STD_LOGIC;
         N 		: in STD_LOGIC_VECTOR(1 downto 0);
             clk_out 	: out  STD_LOGIC);
  end component;

  -- inclusion du multiplexer pour définir le seuil maximum du compteur 
  component timer_multiplixer is
      Port ( CS : in  STD_LOGIC_VECTOR (3 downto 0);
             N : out  STD_LOGIC_VECTOR (7 downto 0));
  end component;

  -- initialisation
    -- Defintion des constantes d'adressage des registres utiles
  constant OCR1A 	 		: integer := BASE_ADDR ;
  constant TCNT1 	 		: integer := BASE_ADDR + 1;
  constant TCCR1B  		: integer := BASE_ADDR + 2;
  constant TCCR1A  		: integer := BASE_ADDR + 3;

    -- registre de comparaison A 
  signal reg_compA 		: STD_LOGIC_VECTOR (7 downto 0);
    -- registre de compage
  signal reg_count 		: STD_LOGIC_VECTOR (7 downto 0);
    -- registre de controle A
  signal reg_ctrlA 		: STD_LOGIC_VECTOR (7 downto 0);
    -- registre de controle B
  signal reg_ctrlB 		: STD_LOGIC_VECTOR (7 downto 0);

    -- Valeurs des elements utiles du registre TCCR1A
      -- Mode de fontionnement du comparateur A  
  signal COM1A	 		: STD_LOGIC_VECTOR (1 downto 0);
      -- Mode de fontionnement du comparateur A  
  signal COM1B	 		: STD_LOGIC_VECTOR (1 downto 0);
      -- Force de la sortie A 
  signal FOC1A	 		: STD_LOGIC;
      -- Force de la sortie B
  signal FOC1B	 		: STD_LOGIC;
      -- PWM A mode actif
  signal PWM1A	 		: STD_LOGIC;
      -- PWM B mode actif
  signal PWM1B	 		: STD_LOGIC;
    
    -- Valeurs des elements utiles du registre TCCR1B
      -- Inversion des sorties OC1x et OC1xbar
  signal PWM1X	 		: STD_LOGIC;
      -- reset du prédiviseur
  signal PSR1		 		: STD_LOGIC;
      -- valeur du diviseur 
  signal DTPS	 	 		: STD_LOGIC_VECTOR (1 downto 0) := "00";
      -- Valeurs permettant de définir la valeur maximum du compteur
  signal CS		 		: STD_LOGIC_VECTOR (3 downto 0);
      -- Signal de sortie du multiplexeur, signal max
  signal N 				: STD_LOGIC_VECTOR (7 downto 0);

    -- buffers des signaux PWM de sortie
  signal OC1A_buffer 		: STD_LOGIC := '1';
  signal OC1Abar_buffer 		: STD_LOGIC := '0';

    -- Signal de reset du prediviseur
  signal Rst_predivisor 	: STD_LOGIC := '0';
    -- Signal de sortie du prédiviseur
  signal predivisor_out 	: STD_LOGIC := '0';

  begin
    -- Mapping du prédiviseur en fonction des variables/signaux locaux
    predivisor: diviseur_timer
      Port map(
        clk 	=> clk,
        rst 	=> Rst_predivisor,
        N 		=> DTPS,
        clk_out	=> predivisor_out
        );
        
    -- Mapping du multipexer 
    CS_converter: timer_multiplixer
      Port map(
        CS 	=> CS,
        N 	=> N
        );
        
  -- Processus  //
  clock_tick: process(clk, predivisor_out, rst)
    -- Variable locale exprimant la valeur de l'adresse du registre pointé
    variable a_int : natural;
    -- Variable local du mode de fonctionnement du timer (lecture / ecriture) 
    variable rdwr : std_logic_vector(1 downto 0);
  begin
    if Rst = '1' then
      -- En cas de reset, remise à 0 du compteur
      reg_count <= (others => '0');
    elsif rising_edge(predivisor_out) then
      -- A chaque periode de l'horloge en sortie du prédiviseur...
      if reg_count < N and PWM1A = '1' then
        -- Dans le cas ou le compteur soit inférieur à la valeur de sortie du multiplexeur et que le mode de PWM A est "actif"
          -- Incrémentation du compteur
        reg_count <= std_logic_vector(unsigned(reg_count) + 1);
      else 
        -- Sinon remise à 0 du compteur
        reg_count <= (others => '0');
      end if;
    elsif rising_edge(clk) then
      -- A chaque période de l'horloge 
      -- Saisie de l'adresse en entré dans la variable local a_int
      a_int := to_integer(unsigned(addr));
      -- Concatenation des signaux d'entrés de lecture et ecriture 
      rdwr  := rd & wr;
      if (a_int = OCR1A) then
        -- Dans le cas où l'adresse en entrée corresponde au registre OCR1A
        case rdwr is
          when "10" => -- rd
            -- si le mode est en ecriture, affectation de la valeur du registre de comparaison A au signal de sortie de lecture
            ioread		<= reg_compA;
          when "01" => -- wr
            -- si le mode est en lecture, saisie du contenu du signal d'ecriture en entré dans la variable du registre de comparaison A
            reg_compA	<= iowrite;
         -- Dans les autres cas, rien n'est fait
         when others => NULL; 
        end case;
      elsif (a_int = TCNT1) then
        -- Cas ou l'adresse en entré correspond au registre TCNT1
        case rdwr is
          when "10" => -- rd
            -- si le mode est en ecriture, affectation de la valeur du registre de comptage au signal de sortie de lecture
            ioread			<= reg_count;
          when "01" => -- wr
            -- si le mode est en lecture, saisie de du contenu du signal d'ecriture en entré dans la variable du registre de compteur
            reg_count		<= iowrite;
          -- Ne rien faire dans les autres cas 
          when others => NULL; 
        end case;
      elsif (a_int = TCCR1B) then
        -- Cas ou l'adresse en entré correponde au registre TCCR1B
        case rdwr is
          when "10" => -- rd
            -- si le mode est en lecture, affectation de la valeur du registre de controle B au signal de sortie en lecture 
            ioread 			<= reg_ctrlB;
          when "01" => -- wr
            -- si le mode est en ecriture, saisie du contenu du signal d'écriture en entré dans la variable du registre de comparaison B 
            reg_ctrlB		<= iowrite;
          -- Ne rien faire dans les autres cas
          when others => NULL; 
        end case;
      elsif (a_int = TCCR1A) then
        -- Cas où l'adresse en entré corresponde au registre TCCR1A
        case rdwr is
          when "10" => -- rd
            -- si le mode est en lecture, affectation de la valeur du registre de controle A au signal de sortie en lecture
            ioread 			<= reg_ctrlA;
          when "01" => -- wr
            -- si le mode est en ecriture, saisie du contenu du signal d'écriture en entré dans la variable du registre de comparaison A
            reg_ctrlA		<= iowrite;
          -- Ne rien faire dans les autres cas 
          when others => Null;
        end case;
      end if;
    end if;
  end process clock_tick;
  
  -- Processus de generation des buffers signaux OC1A et OC1Abar  
  pp : process(reg_count, FOC1A)
  begin 
    if FOC1A = '1' or reg_count'event then
      -- si le mode PWM A est actif ou que la variable du registre de compage est modifiée...
      case COM1A is
        when "00" =>
          -- Si COM1A vaut 0 les signaux OC1A et OC1Abar sont déconnectés
          OC1A_buffer			<= 'Z';
          OC1Abar_buffer			<= 'Z';
        when "01" =>
          -- Si COM1A vaut 1... 
          if reg_count = "00000000" then
            -- Si la variable du registre de compage est à 0, OC1A est connecté et vaut 1
            OC1A_buffer 	<= '1';
          elsif reg_compA < reg_count then
            -- Si la variable du registre de compage est inférieur à sa valeur maximum, OC1A est connecté et vaut 0
            OC1A_buffer		<= '0';
          end if;
          -- Attribution de la valeur de OC1Abar en fonction de la valeur de OC1A
          OC1Abar_buffer 	<= not OC1A_buffer;
        when "10" => -- wr
          -- si COM1A vaut 2... 
          if reg_count = "00000000" then
            -- Si la variable du registre de comptage est à 0, OC1A vaut 1
            OC1A_buffer 	<= '1';
          elsif reg_compA < reg_count then
            -- si la variable du registre de compage est inférieure à son maximum, OC1A vaut 0
            OC1A_buffer		<= '0';
          end if;
          -- Attribution de la valeur de OC1Abar
          OC1Abar_buffer 	<= 'Z';
        when "11" => 
          -- si COM1A vaut 3...
          if reg_count = "00000001" then
            -- si la variable du registre de compage est à 1, OC1A vaut 1
            OC1A_buffer 	<= '1';
          elsif reg_compA < reg_count then
            -- si la variable du registre de comptage est inférieure à son maximum, OC1A vaut 1 aussi
            OC1A_buffer		<= '1';
          end if;
          -- Attribution de la valeur de OC1Abar en fonction de celle de OC1A
          OC1Abar_buffer 	<= not OC1A_buffer;
        -- Ne rien faire dans les autres cas
        when others => NULL;
      end case;
    end if;
  end process pp;
    
  -- Découpage registres en fonction de leurs valeurs utiles
    -- TCCR1A
  COM1A 	<= reg_ctrlA(7 downto 6);
  FOC1A	<= reg_ctrlA(3);
  PWM1A	<= reg_ctrlA(1);

    -- TCCR1B
  PWM1X	<= reg_ctrlB(7);
  PSR1	<= reg_ctrlB(6);
  DTPS 	<= reg_ctrlB(5 downto 4);
  CS		<= reg_ctrlB(3 downto 0);

  -- Lien entre le reset du prédiviseur et de l'element le definissant dans le registre TCCR1B
  Rst_predivisor <= PSR1;
    
  -- Affectation OC1A et OC1Abar en fonction des buffers 
  OC1A	<= not OC1A_buffer 	when PWM1X = '1' else OC1A_buffer;
  OC1Abar <= OC1Abar_buffer  	when PWM1X = '1' else not OC1Abar_buffer;

end timer_architecture;
