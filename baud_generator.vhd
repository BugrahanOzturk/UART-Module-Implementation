library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baud_generator is
  Generic( M : integer := 10);
  Port ( en, clk, rst : in std_logic ;
         pulse_o      : out std_logic := '0');
end baud_generator;

architecture Behavioral of baud_generator is
    signal counter : natural := 0;
begin
    process(clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter <= 0;
            elsif en = '1' then
                pulse_o <= '0'; -- Assign default value for pulse_o. Next values will overwrite this
                if counter = M-1 then
                    pulse_o <= '1';
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
