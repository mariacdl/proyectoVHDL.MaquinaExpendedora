library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;

        coin10_raw  : in  std_logic;
        coin20_raw  : in  std_logic;
        coin50_raw  : in  std_logic;
        coin100_raw : in  std_logic;

        prod_sel    : in  std_logic_vector(3 downto 0);

        led_vend    : out std_logic;
        led_error   : out std_logic;
        led_product : out std_logic_vector(3 downto 0)
    );
end top;

architecture Structural of top is

    signal coin10_p  : std_logic;
    signal coin20_p  : std_logic;
    signal coin50_p  : std_logic;
    signal coin100_p : std_logic;

begin

    ed_coin10 : entity work.edge_detector
        port map (
            clk   => clk,
            reset => reset,
            din   => coin10_raw,
            pulse => coin10_p
        );

    ed_coin20 : entity work.edge_detector
        port map (
            clk   => clk,
            reset => reset,
            din   => coin20_raw,
            pulse => coin20_p
        );

    ed_coin50 : entity work.edge_detector
        port map (
            clk   => clk,
            reset => reset,
            din   => coin50_raw,
            pulse => coin50_p
        );

    ed_coin100 : entity work.edge_detector
        port map (
            clk   => clk,
            reset => reset,
            din   => coin100_raw,
            pulse => coin100_p
        );

    vending_inst : entity work.vending_fsm
        port map (
            clk        => clk,
            reset      => reset,

            coin10     => coin10_p,
            coin20     => coin20_p,
            coin50     => coin50_p,
            coin100    => coin100_p,

            prod_sel   => prod_sel,

            vend        => led_vend,
            error       => led_error,
            product_out => led_product
        );

end Structural;
