library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic; 
        
        coin10      : in  std_logic; 
        coin20      : in  std_logic; 
        coin50      : in  std_logic; 
        coin100     : in  std_logic; 
        
        prod_sel    : in  std_logic_vector(3 downto 0);
        
        led_vend    : out std_logic;
        led_error   : out std_logic;
        led_product : out std_logic_vector(3 downto 0);
        
        an          : out std_logic_vector(7 downto 0);
        seg         : out std_logic_vector(6 downto 0);
        dp          : out std_logic
    );
end top;

architecture Structural of top is

    -- Señales internas
    signal coin10_p  : std_logic;
    signal coin20_p  : std_logic;
    signal coin50_p  : std_logic;
    signal coin100_p : std_logic;

    signal vend_s    : std_logic;
    signal error_s   : std_logic;
    
    signal datos_display : std_logic_vector(31 downto 0);
    
    -- ¡ATENCIÓN! Rangos actualizados a 500 para soportar 2,10€
    signal dinero_actual : integer range 0 to 500;
    signal precio_prod   : integer range 0 to 500;
    
    signal reset_internal : std_logic;

    -- Señales para parpadeo "Add"
    signal blink_timer : integer range 0 to 100000000 := 0;
    signal show_add    : std_logic := '0';

begin

    reset_internal <= reset;

    -- Detectores
    ed_coin10 : entity work.edge_detector
        port map (clk => clk, reset => reset_internal, din => coin10, pulse => coin10_p);
    ed_coin20 : entity work.edge_detector
        port map (clk => clk, reset => reset_internal, din => coin20, pulse => coin20_p);
    ed_coin50 : entity work.edge_detector
        port map (clk => clk, reset => reset_internal, din => coin50, pulse => coin50_p);
    ed_coin100 : entity work.edge_detector
        port map (clk => clk, reset => reset_internal, din => coin100, pulse => coin100_p);

    -- MÁQUINA DE ESTADOS (Conectada con los nuevos puertos)
    vending_inst : entity work.vending_fsm
        port map (
            clk              => clk,
            reset            => reset_internal,
            coin10           => coin10_p,
            coin20           => coin20_p,
            coin50           => coin50_p,
            coin100          => coin100_p,
            prod_sel         => prod_sel,
            vend             => vend_s,
            error            => error_s,
            change_out       => open,
            product_out      => led_product,
            current_money    => dinero_actual,    -- Rango 500
            price_to_display => precio_prod       -- Nuevo cable del precio
        );

    -- Display Controller
    display_inst : entity work.Display_Controller
        port map (
            clk    => clk,
            number => datos_display, 
            an     => an,            
            seg    => seg,      
            dp    => dp      
        );

    -- Generador de parpadeo "Add"
    process(clk)
    begin
        if rising_edge(clk) then
            if blink_timer < 50000000 then 
                blink_timer <= blink_timer + 1;
            else
                blink_timer <= 0;
                show_add <= not show_add; 
            end if;
        end if;
    end process;

    -- MULTIPLEXOR DE PANTALLA (Con precios a la izquierda)
    process(vend_s, error_s, prod_sel, dinero_actual, show_add, precio_prod) 
        -- Variables para separar dígitos
        variable d_cent, d_dec, d_uni : integer; -- Para dinero
        variable p_cent, p_dec, p_uni : integer; -- Para precio
        variable resto : integer;
    begin
        -- 1. Separar dígitos del PRECIO (Izquierda)
        p_cent := precio_prod / 100;
        resto  := precio_prod rem 100;
        p_dec  := resto / 10;
        p_uni  := resto rem 10;
        
        -- 2. Separar dígitos del DINERO ACTUAL (Derecha)
        d_cent := dinero_actual / 100;
        resto  := dinero_actual rem 100;
        d_dec  := resto / 10;
        d_uni  := resto rem 10;

        if error_s = '1' then
            datos_display <= x"EEEEEEEE"; 
            
        elsif vend_s = '1' then
            datos_display <= x"000ACEFB"; -- ACEPT
            
        else
            -- MODO SELECCIÓN (Sin dinero aun)
            if dinero_actual = 0 then
                
                -- Si parpadea: IZQ=Precio, DER="Add"
                if show_add = '1' and prod_sel /= "0000" then
                    datos_display <= std_logic_vector(to_unsigned(p_cent, 4)) &
                                     std_logic_vector(to_unsigned(p_dec, 4)) &
                                     std_logic_vector(to_unsigned(p_uni, 4)) &
                                     x"0" & x"0Add";
                else
                    -- Si no parpadea: IZQ=Precio, DER="P1, P2..."
                     if prod_sel(0) = '1' then
                        datos_display <= std_logic_vector(to_unsigned(p_cent, 4)) &
                                         std_logic_vector(to_unsigned(p_dec, 4)) &
                                         std_logic_vector(to_unsigned(p_uni, 4)) &
                                         x"0" & x"00F1"; 
                     elsif prod_sel(1) = '1' then
                        datos_display <= std_logic_vector(to_unsigned(p_cent, 4)) &
                                         std_logic_vector(to_unsigned(p_dec, 4)) &
                                         std_logic_vector(to_unsigned(p_uni, 4)) &
                                         x"0" & x"00F2";
                     elsif prod_sel(2) = '1' then
                         datos_display <= std_logic_vector(to_unsigned(p_cent, 4)) &
                                          std_logic_vector(to_unsigned(p_dec, 4)) &
                                          std_logic_vector(to_unsigned(p_uni, 4)) &
                                          x"0" & x"00F3";
                     elsif prod_sel(3) = '1' then
                         datos_display <= std_logic_vector(to_unsigned(p_cent, 4)) &
                                          std_logic_vector(to_unsigned(p_dec, 4)) &
                                          std_logic_vector(to_unsigned(p_uni, 4)) &
                                          x"0" & x"00F4";
                     else
                        -- Nada seleccionado
                        datos_display <= x"00000000"; 
                     end if;
                end if;
            
            else
                -- MODO PAGO: IZQ=Precio Fijo, DER=Tu dinero subiendo
                datos_display <= std_logic_vector(to_unsigned(p_cent, 4)) &
                                 std_logic_vector(to_unsigned(p_dec, 4)) &
                                 std_logic_vector(to_unsigned(p_uni, 4)) &
                                 x"0" & x"0" &
                                 std_logic_vector(to_unsigned(d_cent, 4)) &
                                 std_logic_vector(to_unsigned(d_dec, 4)) &
                                 std_logic_vector(to_unsigned(d_uni, 4));
            end if;
        end if;
    end process;

    led_vend  <= vend_s;    
    led_error <= error_s;

end Structural;