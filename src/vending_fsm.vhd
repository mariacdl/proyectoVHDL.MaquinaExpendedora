library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vending_fsm is
    Port (
        clk      : in  std_logic;
        reset    : in  std_logic;

        coin10   : in  std_logic;
        coin20   : in  std_logic;
        coin50   : in  std_logic;
        coin100  : in  std_logic;

        prod_sel : in  std_logic_vector(3 downto 0);

        vend        : out std_logic;
        error       : out std_logic;
        product_out : out std_logic_vector(3 downto 0)
    );
end vending_fsm;

architecture Behavioral of vending_fsm is

    type state_type is (
        S_IDLE, S_0,
        S_10, S_20, S_30, S_40,
        S_50, S_60, S_70, S_80, S_90,
        S_VEND, S_ERR
    );

    signal current_state, next_state : state_type;
    signal product_reg : std_logic_vector(3 downto 0);
    signal coin_value  : integer range 0 to 100;

begin

    -- Coin decoding
    process(coin10, coin20, coin50, coin100)
    begin
        if coin10 = '1' then
            coin_value <= 10;
        elsif coin20 = '1' then
            coin_value <= 20;
        elsif coin50 = '1' then
            coin_value <= 50;
        elsif coin100 = '1' then
            coin_value <= 100;
        else
            coin_value <= 0;
        end if;
    end process;

    -- State register
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= S_IDLE;
                product_reg   <= (others => '0');
            else
                current_state <= next_state;

                if current_state = S_IDLE and prod_sel /= "0000" then
                    product_reg <= prod_sel;
                end if;

                if current_state = S_VEND or current_state = S_ERR then
                    product_reg <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    -- Next state logic
    process(current_state, coin_value, prod_sel)
    begin
        next_state <= current_state;

        case current_state is

            when S_IDLE =>
                if prod_sel = "0001" or prod_sel = "0010" or
                   prod_sel = "0100" or prod_sel = "1000" then
                    next_state <= S_0;
                elsif coin_value /= 0 then
                    next_state <= S_ERR;
                end if;

            when S_0 =>
                case coin_value is
                    when 10  => next_state <= S_10;
                    when 20  => next_state <= S_20;
                    when 50  => next_state <= S_50;
                    when 100 => next_state <= S_VEND;
                    when others => null;
                end case;

            when S_10 =>
                case coin_value is
                    when 10  => next_state <= S_20;
                    when 20  => next_state <= S_30;
                    when 50  => next_state <= S_60;
                    when others => next_state <= S_ERR;
                end case;

            when S_20 =>
                case coin_value is
                    when 10  => next_state <= S_30;
                    when 20  => next_state <= S_40;
                    when 50  => next_state <= S_70;
                    when others => next_state <= S_ERR;
                end case;

            when S_30 =>
                case coin_value is
                    when 10  => next_state <= S_40;
                    when 20  => next_state <= S_50;
                    when 50  => next_state <= S_80;
                    when others => next_state <= S_ERR;
                end case;

            when S_40 =>
                case coin_value is
                    when 10  => next_state <= S_50;
                    when 20  => next_state <= S_60;
                    when 50  => next_state <= S_90;
                    when others => next_state <= S_ERR;
                end case;

            when S_50 =>
                case coin_value is
                    when 10  => next_state <= S_60;
                    when 20  => next_state <= S_70;
                    when 50  => next_state <= S_VEND;
                    when others => next_state <= S_ERR;
                end case;

            when S_60 =>
                case coin_value is
                    when 10  => next_state <= S_70;
                    when 20  => next_state <= S_80;
                    when others => next_state <= S_ERR;
                end case;

            when S_70 =>
                case coin_value is
                    when 10  => next_state <= S_80;
                    when 20  => next_state <= S_90;
                    when others => next_state <= S_ERR;
                end case;

            when S_80 =>
                case coin_value is
                    when 10  => next_state <= S_90;
                    when 20  => next_state <= S_VEND;
                    when others => next_state <= S_ERR;
                end case;

            when S_90 =>
                if coin_value = 10 then
                    next_state <= S_VEND;
                else
                    next_state <= S_ERR;
                end if;

            when S_VEND =>
                next_state <= S_IDLE;

            when S_ERR =>
                next_state <= S_IDLE;

        end case;
    end process;

    -- Output logic (Moore)
    process(current_state, product_reg)
    begin
        vend        <= '0';
        error       <= '0';
        product_out <= (others => '0');

        case current_state is
            when S_VEND =>
                vend        <= '1';
                product_out <= product_reg;

            when S_ERR =>
                error <= '1';

            when others =>
                null;
        end case;
    end process;

end Behavioral;
