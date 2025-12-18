library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Display_Controller is
    Port ( 
           clk    : in  STD_LOGIC;                     -- Reloj de 100MHz de la Nexys
           number : in  STD_LOGIC_VECTOR (31 downto 0); -- El número de 32 bits a mostrar
           an     : out STD_LOGIC_VECTOR (7 downto 0);  -- Ánodos (selección de display)
           seg    : out STD_LOGIC_VECTOR (6 downto 0); -- Segmentos (dibujo del número)
           dp     : out STD_LOGIC
           );
end Display_Controller;

architecture Behavioral of Display_Controller is

    -- Contador para el refresco de pantalla
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');
    
    -- Selector de cuál de los 8 displays está activo
    signal digit_select : std_logic_vector(2 downto 0);
    
    -- El dígito hexadecimal (0-F) que vamos a dibujar
    signal hex_digit : std_logic_vector(3 downto 0);

begin

    process(clk)
    
    begin
        if rising_edge(clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    -- Usamos los bits 19, 18 y 17 para cambiar de dígito a una velocidad visible
    digit_select <= std_logic_vector(refresh_counter(19 downto 17));

    -- 2. CONTROL DE ÁNODOS (Multiplexación)
    -- En la Nexys A7, un 0 activa el display (Lógica Negativa)
    process(digit_select)
    begin
        case digit_select is
            when "000" => an <= "11111110"; -- Display 0 (Derecha)
            when "001" => an <= "11111101"; -- Display 1
            when "010" => an <= "11111011"; -- Display 2
            when "011" => an <= "11110111"; -- Display 3
            when "100" => an <= "11101111"; -- Display 4
            when "101" => an <= "11011111"; -- Display 5
            when "110" => an <= "10111111"; -- Display 6
            when "111" => an <= "01111111"; -- Display 7 (Izquierda)
            when others => an <= "11111111"; -- Todos apagados
        end case;
    end process;

    -- 3. SELECCIÓN DE LOS BITS A MOSTRAR
    -- Elegimos qué trozo del número de 32 bits corresponde al display activo
    process(digit_select, number)
    begin
        case digit_select is
            when "000" => hex_digit <= number(3 downto 0);
            when "001" => hex_digit <= number(7 downto 4);
            when "010" => hex_digit <= number(11 downto 8);
            when "011" => hex_digit <= number(15 downto 12);
            when "100" => hex_digit <= number(19 downto 16);
            when "101" => hex_digit <= number(23 downto 20);
            when "110" => hex_digit <= number(27 downto 24);
            when "111" => hex_digit <= number(31 downto 28);
            when others => hex_digit <= "0000";
        end case;
    end process;

    -- 4. DECODIFICADOR 7 SEGMENTOS
    -- Convierte el valor hex (0-F) en segmentos (a-g). Lógica Negativa (0 enciende).
    process(hex_digit)
    begin
        case hex_digit is
            --                  abcdefg
            when "0000" => seg <= "1000000"; -- 0
            when "0001" => seg <= "1111001"; -- 1
            when "0010" => seg <= "0100100"; -- 2
            when "0011" => seg <= "0110000"; -- 3
            when "0100" => seg <= "0011001"; -- 4
            when "0101" => seg <= "0010010"; -- 5
            when "0110" => seg <= "0000010"; -- 6
            when "0111" => seg <= "1111000"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0010000"; -- 9
            when "1010" => seg <= "0001000"; -- A
            when "1011" => seg <= "0000011"; -- b
            when "1100" => seg <= "1000110"; -- C
            when "1101" => seg <= "0100001"; -- d
            when "1110" => seg <= "0000110"; -- E
            when "1111" => seg <= "0001100"; -- P
            when others => seg <= "1111111"; -- Apagado
        end case;
    end process;

process(digit_select)
    begin
        -- En la Nexys, el punto se enciende con '0'
        
        -- digit_select "111" es el display de la izquierda del todo (El del Precio)
        -- digit_select "010" es el display 2 (El de los Euros de tu dinero)
        
        if digit_select = "111" or digit_select = "010" then
            dp <= '0'; -- ENCENDIDO (Punto visible: 2.10)
        else
            dp <= '1'; -- APAGADO
        end if;
    end process;
end Behavioral;
