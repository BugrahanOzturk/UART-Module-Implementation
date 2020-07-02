library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity uart_top_sim is
end uart_top_sim;

architecture Behavioral of uart_top_sim is

component uart_top is
  Generic (
      D1 : integer := 8;
      P1 : integer := 0;
      S1 : integer := 1;
      M1 : integer := 125000000/9600
        );
Port ( 
      clk, rst : in std_logic := '0';
      rx_i     : in std_logic := '1';
      tx_o     : out std_logic := '1'
     );
end component;

signal clk,rst : std_logic := '0';
signal rx_i    : std_logic := '1';
signal tx_o    : std_logic := '0';

begin

h3 : uart_top port map (clk=>clk, rst=>rst, rx_i=>rx_i, tx_o=>tx_o);

clk_process:process
            begin
            clk <= not clk;
            wait for 4 ns;
            end process;

process
begin

rst <= '1';
rx_i <= '1';
wait for 105000 ns;
rst  <= '0';
wait for 105000 ns;
rx_i <= '0';
wait for 105000 ns;
rx_i <= '1';
wait for 105000 ns;
rx_i <= '0';
wait for 105000 ns;
rx_i <= '1';
wait for 105000 ns;
rx_i <= '0';
wait for 105000 ns;
rx_i <= '0';
wait for 105000 ns;
rx_i <= '1';
wait for 105000 ns;
rx_i <= '0';
wait for 105000 ns;
rx_i <= '1';
wait for 105000 ns;
rx_i <= '1';
wait for 105000 ns;   

wait;
end process;

end Behavioral;
