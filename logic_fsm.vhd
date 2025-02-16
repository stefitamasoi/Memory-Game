library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Logic_FSM is
Port ( clk: in std_logic;
       reset: in std_logic;
       start_btn: in std_logic;
       input_done: in std_logic;
       valid: in std_logic;
       sequence_done: in std_logic; 
       ok: out std_logic
       );
end Logic_FSM;

architecture Behavioral of Logic_FSM is

type state_type is (IDLE, SHOW, INPUT, VALIDATE, NEXT_LEVEL);

signal current_state, next_state: state_type;
signal current_level: INTEGER range 0 to 1;

begin

process(clk, reset)
begin
    if reset = '1' then
        current_state <= IDLE;
        current_level <= 0;
    elsif rising_edge(clk) then
        current_state <= next_state;
    end if;
end process;

process(current_state, start_btn, input_done, valid, sequence_done)
begin
    case current_state is
        when IDLE =>
            if start_btn = '1' then
                next_state <= SHOW;
            end if;
        
        when SHOW =>
            if sequence_done = '1' then
                next_state <= INPUT;
            end if;
        
       when INPUT =>
            if input_done = '1' then
                next_state <= VALIDATE;
            end if;
     
       when VALIDATE =>
            if valid = '1' then
                next_state <= NEXT_LEVEL;
            end if;
            
        when NEXT_LEVEL =>
            if current_level < 1 then
                next_state <= SHOW; 
            else
                next_state <= IDLE; 
            end if;
            
       when others =>
            next_state <= IDLE;
            
    end case;
end process;

process(current_state)
begin
    ok <= '0';
    
    case current_state is
        when IDLE =>
            ok <= '0';
            
        when SHOW =>
            ok <= '0';
            
        when INPUT =>
            ok <= '0';
            
        when VALIDATE =>
            if valid = '1' then   
                ok <= '1';
            else
                ok <= '0';
            end if;
        
        when NEXT_LEVEL =>
            current_level <= current_level + 1; 
               
        when others => null;
        
    end case;
    
    
end process;



end Behavioral;
