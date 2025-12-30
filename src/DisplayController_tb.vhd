----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.12.2025 11:24:38
-- Design Name: 
-- Module Name: DisplayController_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DisplayController_tb is
--  Port ( );
end DisplayController_tb;

architecture Behavioral of DisplayController_tb is

component Display_Controller
    Port ( 
           clk    : in  STD_LOGIC;                     -- Reloj de 100MHz de la Nexys
           number : in  STD_LOGIC_VECTOR (31 downto 0); -- El número de 32 bits a mostrar
           an     : out STD_LOGIC_VECTOR (7 downto 0);  -- Ánodos (selección de display)
           seg    : out STD_LOGIC_VECTOR (6 downto 0); -- Segmentos (dibujo del número)
           dp     : out STD_LOGIC
           );
end component;

signal clk    :  STD_LOGIC := '0';                     -- Reloj de 100MHz de la Nexys
signal number :  STD_LOGIC_VECTOR (31 downto 0) := (others => '0'); -- El número de 32 bits a mostrar
signal an     :  STD_LOGIC_VECTOR (7 downto 0);  -- Ánodos (selección de display)
signal seg    :  STD_LOGIC_VECTOR (6 downto 0); -- Segmentos (dibujo del número)
signal dp     :  STD_LOGIC;

begin
uut: Display_Controller port map(clk => clk,
                                 number => number,
                                 an => an,
                                 seg => seg,
                                 dp => dp);

clk <= not clk after 20 ns;
number <= "00000000000000000000000000010100", "10100000001000000000000001001011" after 100 ns;

end Behavioral;
