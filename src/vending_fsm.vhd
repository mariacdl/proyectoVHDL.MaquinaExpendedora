library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

--------------------------------------------------------------------------------------------
entity vending_fsm is
    Port (
        clk      : in  std_logic; 
        reset    : in  std_logic; 

        coin10   : in  std_logic; 
        coin20   : in  std_logic;
        coin50   : in  std_logic;
        coin100  : in  std_logic;

        prod_sel : in  std_logic_vector(3 downto 0); 

        vend             : out std_logic; 
        error            : out std_logic;
        change_out       : out std_logic;
        product_out      : out std_logic_vector(3 downto 0);
        
        -- SALIDAS AMPLIADAS A 500 (5 Euros)
        current_money    : out integer range 0 to 500;
        
        -- NUEVO PUERTO QUE FALTABA: Mandar el precio al exterior
        price_to_display : out integer range 0 to 500;
        change_value     : out integer range 0 to 500
    );
end vending_fsm;
--------------------------------------------------------------------------------------------

architecture Behavioral of vending_fsm is 
    
    type state_type is (S_IDLE, S_PAY, S_VEND, S_ERR);
    signal state, next_state : state_type; 

    signal product_reg : std_logic_vector(3 downto 0) := (others => '0');
    signal credit      : integer range 0 to 500 := 0;  
    signal change      : integer range 0 to 500 := 0; 
    
    -- El contador para los 2 segundos
    signal timer_wait : integer range 0 to 200000000 := 0;
    
    -- YA NO ES UNA CONSTANTE, AHORA ES UNA SEÑAL QUE CAMBIA
    signal precio_actual : integer range 0 to 500; 

    -- Función: moneda -> valor
    function coin_to_value(c10, c20, c50, c100 : std_logic) return integer is
    begin
        if c10 = '1' then return 10;
        elsif c20 = '1' then return 20;
        elsif c50 = '1' then return 50;
        elsif c100 = '1' then return 100;
        else return 0;
        end if;
    end function;
    
    function valid_product(sel : std_logic_vector(3 downto 0)) return boolean is
    begin
        return (sel = "0001") or (sel = "0010") or (sel = "0100") or (sel = "1000");
    end function;
    
begin

    -- -----------------------------------------------------------
    -- LOGICA DE PRECIOS DINÁMICOS
    -- -----------------------------------------------------------
    process(prod_sel)
    begin
        -- Productos 1, 2 y 3 valen 2,10 EUROS (210 céntimos)
        if prod_sel(0) = '1' then     -- Switch 0
            precio_actual <= 210; 
            
        elsif prod_sel(1) = '1' then  -- Switch 1
            precio_actual <= 210; 
            
        elsif prod_sel(2) = '1' then  -- Switch 2
            precio_actual <= 210; 
            
        -- Producto 4 (Agua) vale 1 EURO (100 céntimos)
        elsif prod_sel(3) = '1' then  -- Switch 3
            precio_actual <= 100; 
            
        else
            -- Precio por defecto (puedes poner 0)
            precio_actual <= 0; 
        end if;
    end process;

    -- Conectamos el precio interno al puerto de salida
    price_to_display <= precio_actual;
    -- -----------------------------------------------------------


    -- PROCESO 1: Lógica Secuencial
    process(clk)
        variable cv : integer;
    begin
        if rising_edge(clk) then
        
            if reset = '1' then
                state       <= S_IDLE;
                product_reg <= (others => '0');
                credit      <= 0;
                change      <= 0;
                timer_wait  <= 0; 
            else
                state <= next_state;
                
                -- Contador del tiempo (Solo cuenta en S_VEND)
                if state = S_VEND then
                    if timer_wait < 200000000 then
                        timer_wait <= timer_wait + 1;
                    end if;
                else
                    timer_wait <= 0; 
                end if;
                
                cv := coin_to_value(coin10, coin20, coin50, coin100);
 
                case state is 
                    when S_IDLE =>
                        credit <= 0; 
                        if valid_product(prod_sel) then
                            product_reg <= prod_sel;
                        end if;

                    when S_PAY =>
                        if cv /= 0 then 
                           credit <= credit + cv; 
                        end if;
                        
                    when S_VEND | S_ERR => 
                        -- AQUI USAMOS "precio_actual" EN VEZ DE LA CONSTANTE
                        if credit > precio_actual then 
                          change <= credit - precio_actual;
                        else 
                          change <= 0;
                        end if;
                        
                        if state = S_ERR then
                             credit <= 0;
                             product_reg <= (others => '0');
                        elsif state = S_VEND and timer_wait = 200000000 then
                             credit <= 0;
                             product_reg <= (others => '0');
                        end if;

                end case;
            end if;
        end if;
    end process;

    -- PROCESO 2: Siguiente Estado
    process(state, prod_sel, credit, coin10, coin20, coin50, coin100, timer_wait, precio_actual) 
        variable cv : integer;
    begin
        next_state <= state;
        cv := coin_to_value(coin10, coin20, coin50, coin100);

        case state is
            when S_IDLE =>
                if valid_product(prod_sel) then
                    next_state <= S_PAY;
                elsif cv /= 0 then
                    next_state <= S_ERR;
                end if;

            when S_PAY =>
                if prod_sel = "0000" then
                    next_state <= S_ERR;
                -- COMPARAMOS CON EL PRECIO DINAMICO
                elsif credit >= precio_actual then
                    next_state <= S_VEND;
                else
                    next_state <= S_PAY;
                end if;

            when S_VEND =>
                -- Esperamos 2 segundos
                if timer_wait < 200000000 then
                    next_state <= S_VEND; 
                else
                    next_state <= S_VEND; -- Se queda congelado (hasta reset)
                end if;

            when S_ERR =>
                next_state <= S_IDLE;
        end case;
    end process;

    -- PROCESO 3: Salidas
    process(state, product_reg, change, timer_wait)
    begin
        vend        <= '0';
        error       <= '0';
        change_out  <= '0';
        product_out <= product_reg;

        case state is
            when S_VEND =>
                -- Parpadeo durante la espera
                if timer_wait < 200000000 then
                    vend <= to_unsigned(timer_wait, 32)(24); 
                else
                    vend <= '1';
                end if;
                
                if change > 0 then
                  change_out <= '1';
                end if;
                
            when S_ERR =>
                error <= '1';
                
            when others =>
                null;
        end case;
    end process;

    current_money <= credit;
    price_to_display <= precio_actual;
    change_value  <= change;

end Behavioral;