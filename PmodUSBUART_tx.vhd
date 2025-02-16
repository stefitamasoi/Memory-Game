library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PmodUSBUART_tx is
Port (
        clk: in std_logic;
        rst: in std_logic;
        baud_en: in std_logic;
        tx_en: in std_logic;
        tx_data: in std_logic_vector(7 downto 0);
        tx: out std_logic;
        tx_rdy: out std_logic
      );
end PmodUSBUART_tx;

architecture Behavioral of PmodUSBUART_tx is

type state_type is(idle, start, bits, stop);

signal state: state_type := idle;
signal next_state: state_type := idle;
signal bit_cnt: std_logic_vector(2 downto 0);

begin

--process pt state, next_state
    process(clk, rst)
    begin
        if rst = '1' then
            state <= idle;
            bit_cnt <= (others => '0');
        elsif rising_edge(clk) then
            if baud_en = '1' then   
                state <= next_state;
                
                if state = bits then    
                    if bit_cnt < "111" then
                        bit_cnt <= bit_cnt + 1;
                    else
                        bit_cnt <= (others => '0');
                    end if;
                end if;
            end if;
       end if;
    end process;
   
   --process pt outputs
    process(state, tx_en, bit_cnt)
    begin
        next_state <= state;
        
        case state is
            when idle => 
                if tx_en = '1' then 
                    next_state <= start;
                end if;
            when start => 
                next_state <= bits;
            when bits =>
                if bit_cnt < "111" then
                    next_state <= bits;
                else
                    next_state <= stop;
                end if;
            when stop =>
                next_state <= idle;
            when others =>
                next_state <= idle;
          end case;
    end process;
    
    --process pt iputs
    process(state, tx_data, bit_cnt)
    begin
        case state is
            when idle => tx <= '1'; tx_rdy <= '1';
            when start => tx <= '0'; tx_rdy <= '0';
            when bits => tx <= tx_data(conv_integer(bit_cnt)); tx_rdy <= '0';
            when stop => tx <= '1'; tx_rdy <= '0';
            when others => tx <= 'X'; tx_rdy <= 'X';
        end case;
    end process;
    
end Behavioral;
