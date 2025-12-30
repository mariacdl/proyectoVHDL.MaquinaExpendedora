library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vending_fsm_tb is
--  Port ( );
end vending_fsm_tb;

architecture Behavioral of vending_fsm_tb is

component vending_fsm
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
        product_out : out std_logic_vector(3 downto 0);
        
        current_money    : out integer range 0 to 500;
        price_to_display : out integer range 0 to 500;
        change_value     : out integer range 0 to 500
    );
end component;

signal       clk      :   std_logic := '0';
signal       reset    :   std_logic;
        
signal        coin10   :   std_logic;
signal        coin20   :   std_logic;
signal        coin50   :   std_logic;
signal        coin100  :   std_logic;

signal        prod_sel :   std_logic_vector(3 downto 0);

signal        vend        :  std_logic;
signal        error       :  std_logic;
signal        product_out :  std_logic_vector(3 downto 0);

signal        current_money    :  integer range 0 to 500;
signal        price_to_display :  integer range 0 to 500;
signal        change_value     :  integer range 0 to 500;

begin
uut: vending_fsm port map(clk => clk,
                          reset => reset,
                          coin10 => coin10,
                          coin20 => coin20,
                          coin50 => coin50,
                          coin100 => coin100,
                          prod_sel => prod_sel,
                          vend => vend,
                          error => error,
                          product_out => product_out,
                          current_money => current_money,
                          price_to_display => price_to_display,
                          change_value => change_value);


 clk <= not clk after 10 ns;
 --Primer 1 para quedarse a S_IDLE, segundo 1 para ir a S_IDLE después la venta
 reset <= '1', '0' after 100 ns, '1' after 360 ns;
 --Coin error
 coin10 <= '0', '1' after 20 ns, '0' after 20 ns;
 --Seleccion producto 3
 prod_sel <= "0000", "0010" after 200 ns;
 --2.20 euros introducido, 10 cents demasiados
 coin100 <= '0', '1' after 220 ns, '0' after 20 ns, '1' after 20 ns, '0' after 20 ns;
 coin20 <= '0', '1' after 300 ns, '0' after 20 ns;
 
 
end Behavioral;
