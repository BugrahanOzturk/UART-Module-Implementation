library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity uart_rx is

    generic
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
    
end uart_rx;

architecture Behavioral of uart_rx is

    type state_of_uart_rx is
    (
    rx_idle,
    rx_start,
    rx_data,
    rx_stop
    );
    
    signal state                : state_of_uart_rx := rx_idle;
    signal timer_en, timer_tick : std_logic := '0';
    signal rx_data_buffer       : std_logic_vector(0 to D-1) := (others => '0');
    
    component baud_generator is
        Generic( M : integer := 10);
        Port( 
        en, clk, rst : in std_logic ;
        pulse_o      : out std_logic := '0');
    end component;
    
begin
    TM : baud_generator
    generic map(M=>M)
    port map
    (
    en      => timer_en,
    clk     => clock,
    rst     => reset,
    pulse_o => timer_tick
    );
    
process(clock,reset)
variable counter_tick, counter_rx : integer := 0;
begin
    if reset = '1' then
        state <= rx_idle;
        rx_ready_out <= '0';
        data_out <= (others => '0');
        counter_tick := 0;
        counter_rx := 0;
    end if;
    
    if rising_edge(clock) then
        
        case state is    
            
            when rx_idle =>
                timer_en <= '0';
                rx_ready_out <= '0';
                if rx_input = '0' then
                    timer_en <= '1';
                    state <= rx_start;
                    counter_tick := 0;
                    counter_rx := 0;
                else
                    state <= rx_idle;
                    counter_tick := 0;
                    counter_rx := 0;
                end if;
                
            when rx_start =>
                if(timer_tick = '1') then
                    data_out <= (others => '0');
                    state <= rx_data;
                    counter_rx := 0;
                    counter_tick := 0;
                end if;
                
            when rx_data =>
                if timer_tick = '1' then
                    counter_tick := counter_tick + 1;
                    if (counter_tick mod 2 = 0) then
                        rx_data_buffer <= rx_input & rx_data_buffer(0 to D - 2);
                        if counter_rx = D-1 then
                            state <= rx_stop;
                            counter_rx := 0;
                            counter_tick := 0;
                        else
                            counter_rx := counter_rx + 1;
                        end if;
                    end if;
                end if;
                
            when rx_stop =>
            if timer_tick = '1' then
                counter_tick := counter_tick + 1;
                if counter_tick mod 2 = 0 then
                    if rx_input = '1' then
                        rx_ready_out <= '1';
                        state <= rx_idle;
                        counter_tick := 0;
                    else
                        rx_ready_out <= '0';
                        state <= rx_idle;
                        counter_tick := 0;
                    end if;
                    timer_en <= '0';
                end if;
            end if;
        end case;
    end if;
    data_out <= rx_data_buffer;
end process;    
end Behavioral;
