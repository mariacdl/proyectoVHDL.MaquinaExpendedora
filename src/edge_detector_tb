----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.12.2025 11:42:25
-- Design Name: 
-- Module Name: edge_detector_tb - Behavioral
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

entity edge_detector_tb is
--  Port ( );
end edge_detector_tb;

architecture Behavioral of edge_detector_tb is

component edge_detector
    Port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        din    : in  std_logic;
        pulse  : out std_logic
    );
end component;

signal clk    :   std_logic := '0';
signal        reset  :  std_logic;
signal        din    :   std_logic := '0';
signal       pulse  :  std_logic;

begin
uut: edge_detector port map(clk => clk,
                            reset => reset,
                            din => din,
                            pulse => pulse);
     
     clk <= not clk after 5 ns;
     reset <= '1', '0' after 100 ns;
     din <= not din after 60 ns;

end Behavioral;
