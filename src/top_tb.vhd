library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_tb is
end top_tb;

architecture tb of top_tb is

    -- DUT ports
    signal clk        : std_logic := '0';
    signal reset      : std_logic := '0';

    signal coin10_raw  : std_logic := '0';
    signal coin20_raw  : std_logic := '0';
    signal coin50_raw  : std_logic := '0';
    signal coin100_raw : std_logic := '0';

    signal prod_sel    : std_logic_vector(3 downto 0) := (others => '0');

    signal led_vend    : std_logic;
    signal led_error   : std_logic;
    signal led_product : std_logic_vector(3 downto 0);

    constant Tclk : time := 10 ns;

begin

    -- Clock generator
    clk <= not clk after Tclk/2;

    -- DUT instantiation
    dut : entity work.top
        port map (
            clk        => clk,
            reset      => reset,

            coin10_raw  => coin10_raw,
            coin20_raw  => coin20_raw,
            coin50_raw  => coin50_raw,
            coin100_raw => coin100_raw,

            prod_sel    => prod_sel,

            led_vend    => led_vend,
            led_error   => led_error,
            led_product => led_product
        );

    -- Stimulus
    process
        procedure press(signal s : out std_logic; t : time := 30 ns) is
        begin
            s <= '1';
            wait for t;      -- simulate button held
            s <= '0';
            wait for 50 ns;  -- gap
        end procedure;
    begin
        -- reset
        reset <= '1';
        wait for 50 ns;
        reset <= '0';
        wait for 50 ns;

        -- Case 1: choose product 1, pay 50+50 => vend, product_out=0001
        prod_sel <= "0001";
        wait for 50 ns;

        press(coin50_raw);
        press(coin50_raw);

        prod_sel <= "0000";
        wait for 200 ns;

        -- Case 2: no product selected, insert 10 => error
        press(coin10_raw);
        wait for 200 ns;

        -- Case 3: choose product 3, insert 1€ => vend, product_out=0100
        prod_sel <= "0100";
        wait for 50 ns;

        press(coin100_raw);

        prod_sel <= "0000";
        wait for 200 ns;

        -- Case 4: choose product 2, insert 50+50+10 => error (overpay)
        prod_sel <= "0010";
        wait for 50 ns;

        press(coin50_raw);
        press(coin50_raw);
        press(coin10_raw);

        wait for 300 ns;

        -- stop
        wait;
    end process;

end tb;

