-- Librerías VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
---------------------------------------------------------------------------------------------

entity edge_detector is
    Port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        din    : in  std_logic;
        pulse  : out std_logic
    );
end edge_detector;

---------------------------------------------------------------------------------------------

architecture Behavioral of edge_detector is
    
    constant DEBOUNCE_LIMIT : integer := 2_000_000; 
    signal counter : integer range 0 to DEBOUNCE_LIMIT := 0; -- contador
    
    signal button_sync_0 : std_logic := '0'; -- para que la señal entre de manera segura (variables internas, usa la FPGA de manera interna)
    signal button_sync_1 : std_logic := '0'; 
    signal button_clean  : std_logic := '0'; -- estado del boton 'limpio'
    signal button_last   : std_logic := '0'; -- estado del boton 'anterior'

begin
    process(clk)
    
    begin
        
        if rising_edge(clk) then
        
            if reset = '1' then
                counter <= 0;
                button_clean <= '0';
                button_last <= '0';
                button_sync_0 <= '0';
                button_sync_1 <= '0';
                pulse <= '0';
            else
    -- Sincronizar la entrada (evita errores eléctricos)
                button_sync_0 <= din;
                button_sync_1 <= button_sync_0;

    -- Filtro Anti-Rebote (Debounce)
            if (button_sync_1 /= button_clean) then
                counter <= counter + 1;
                
            if counter = DEBOUNCE_LIMIT then
                button_clean <= button_sync_1;
                counter <= 0;
                
            end if;
            else
                counter <= 0;
            end if;

    -- Detector de flanco (Detecta cuando el botón pasa de 0 a 1)
            if (button_clean = '1' and button_last = '0') then
                 pulse <= '1';
            else
                 pulse <= '0';
            end if;
                
                button_last <= button_clean;
            end if;
        end if;
    end process;

end Behavioral;
