library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity uart_top is
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
end uart_top;

architecture Behavioral of uart_top is

    component uart_tx is
      Generic
    (
      D : integer := 8; -- data bits
      P : integer := 0; -- parity, 0 for disable, 1 for enable
      S : integer := 1; -- stop bit
      M : integer := 125 * 1000000 / 9600 --timer count value for a given baudrate
    );
    Port ( 
          clock, reset               : in std_logic := '0';
          start_input                : in std_logic; -- start transmission
          data_input                 : in std_logic_vector(7 downto 0); -- data to be sent
          tx_out                     : out std_logic := '0'; -- transmission out
          tx_done_out                : out std_logic := '0' -- transmission done
          );
    end component;
    
    component uart_rx is
      Generic
        (
        D : integer := 8;
        P : integer := 0;
        S : integer := 1;
        M : integer := 125 * 1000000 / 9600 
        );
        
      Port 
        ( 
        clock, reset : in std_logic;
        rx_input     : in std_logic;
        data_out     : out std_logic_vector(D-1 downto 0); --received data
        rx_ready_out : out std_logic --received bufer ready
        );
    end component;

signal tx_done_o, rx_ready_o : std_logic := '0';
signal data: std_logic_vector(7 downto 0) := (others => '0');        

begin

    tx:uart_tx generic map (D=>D1, P=>P1, S=>S1, M=>M1)
               port map (clock=>clk, reset=>rst, start_input=>rx_ready_o, data_input=>data,
                         tx_out=>tx_o, tx_done_out=>tx_done_o);
    rx:uart_rx generic map (D=>D1, P=>P1, S=>S1, M=>M1)
               port map (clock=>clk, reset=>rst, rx_input=>rx_i, data_out=>data,
                         rx_ready_out=>rx_ready_o);
                         
end Behavioral;
