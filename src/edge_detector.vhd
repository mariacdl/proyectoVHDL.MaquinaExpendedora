library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity edge_detector is
    Port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        din    : in  std_logic;
        pulse  : out std_logic
    );
end edge_detector;

architecture Behavioral of edge_detector is
    signal din_d : std_logic;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                din_d <= '0';
            else
                din_d <= din;
            end if;
        end if;
    end process;

    pulse <= din and not din_d;

end Behavioral;
