library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PmodUSBUART_rx is
Port(
     clk: in std_logic;
     rst: in std_logic;
     baud_en: in std_logic;
     rx: in std_logic;
     rd_data: out std_logic_vector(7 downto 0);
     rx_rdy: out std_logic
     );
end PmodUSBUART_rx;

architecture Behavioral of PmodUSBUART_rx is
type state_type is(idle, start, bits, waitt, stop);
signal state: state_type := idle;
signal next_state: state_type := idle;
signal baud_cnt: std_logic_vector(3 downto 0);
signal bit_cnt:std_logic_vector(2 downto 0);
begin

    process(clk, rst)
    begin
        if rst = '1' then
            state <= idle;
            baud_cnt <= (others => '0');
            bit_cnt <= (others => '0');
        elsif rising_edge(clk) then
            if baud_en = '1' then
                state <= next_state;
                
                --update pt baud_cnt si bit_cnt
                if state = bits or state = stop or state = start then
                    baud_cnt <= baud_cnt + 1;
                else
                    baud_cnt <= (others => '0');
                end if;

                if state = bits and baud_cnt = "1111" then
                    bit_cnt <= bit_cnt + 1;
                end if;
            end if;
        end if;
    end process;

    process(state, rx, baud_cnt, bit_cnt)
    begin
        next_state <= state;
        case state is
            when idle =>
                if rx = '0' then
                    next_state <= start;
                end if;
            when start =>
                if baud_cnt = "0111" then
                    next_state <= bits;
                end if;
            when bits =>
                if bit_cnt = "111" and baud_cnt = "1111" then 
                    next_state <= stop;
                elsif baud_cnt = "1111" then 
                    next_state <= bits;
                end if;
             when stop =>
                if baud_cnt = "1111" then 
                    next_state <= waitt;
                end if;

            when waitt =>
                next_state <= idle; 

            when others =>
                next_state <= idle; 
         end case;        
    end process;
    
    process(state)
    begin
        case state is
            when idle => rx_rdy <= '0';
            when start => rx_rdy <= '0';
            when bits => rx_rdy <= '0';
            when stop => rx_rdy <= '0';
            when waitt => rx_rdy <= '1';
            when others => rx_rdy <= 'X';
         end case;
    end process;
    
end Behavioral;