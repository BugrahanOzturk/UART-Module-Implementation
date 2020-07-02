library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity uart_tx is
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
end uart_tx;

architecture Behavioral of uart_tx is

type states_for_uart_tx is
(
tx_idle,
tx_start,
tx_data,
tx_stop
);

signal state                : states_for_uart_tx := tx_idle;
signal timer_en, timer_tick : std_logic := '0';
signal data_buf             : std_logic_vector(7 downto 0) := (others => '0');

component baud_generator is 
  
  Generic( M : integer := 10);
  Port ( en, clk, rst : in std_logic ;
       pulse_o      : out std_logic := '0');
       
end component;

begin

    TM : baud_generator
    generic map(M => M)
    port map
    (
        en => timer_en,
        clk => clock,
        rst => reset,
        pulse_o => timer_tick
    );
 
    data_buf <= data_input;
 
 process(clock)
 variable counter_tx : integer := 0;
 begin
 
    if rising_edge(clock) then
    
        tx_out <= '1';
        tx_done_out <= '0';
    
        case state is
            when tx_idle =>
            
                if start_input = '1' then
                    state <= tx_start;
                    tx_done_out <= '0';
                    timer_en <= '0';
                    counter_tx := 0;
                end if;
            
            when tx_start =>
                tx_out <= '0';
                timer_en <= '1';
                if timer_tick = '1' then
                    state <= tx_data;
                    counter_tx := 0;
                end if;
                
            when tx_data =>
                tx_out <= data_buf(counter_tx);
                if timer_tick = '1' then
                    counter_tx := counter_tx + 1;
                    if counter_tx = 8 then
                        state <= tx_stop;
                        counter_tx := 0;
                    else
                        state <= tx_data;
                    end if;
                end if;
                
            when tx_stop => 
                if timer_tick = '1' then
                    tx_done_out <= '1';
                    tx_out <= '1';
                    state <= tx_idle;
                    timer_en <= '0';
                end if;
        end case;
    end if;
end process;                   

end Behavioral;
