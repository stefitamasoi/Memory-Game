library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity PmodUSBUART_topModule is
Port (
      clk: in std_logic;
      led: out std_logic_vector(3 downto 0);
      sw: in std_logic_vector(3 downto 0);
      btn: in std_logic_vector(3 downto 0);
      rx: in std_logic;
      tx: out std_logic
      );
end PmodUSBUART_topModule;

architecture Behavioral of PmodUSBUART_topModule is

component MPG is
    Port ( btn : in std_logic;
           clk : in std_logic;
           enable : out std_logic);
end component;

component PmodUSBUART_tx is
Port (
        clk: in std_logic;
        rst: in std_logic;
        baud_en: in std_logic;
        tx_en: in std_logic;
        tx_data: in std_logic_vector(7 downto 0);
        tx: out std_logic;
        tx_rdy: out std_logic
      );
end component;

component PmodUSBUART_rx is
Port(
     clk: in std_logic;
     rst: in std_logic;
     baud_en: in std_logic;
     rx: in std_logic;
     rd_data: out std_logic_vector(7 downto 0);
     rx_rdy: out std_logic
     );
end component;

signal baud_en, baud_en_x16: std_logic;
signal tx_start, tx_en, tx_rdy, tx_rdy1: std_logic;
signal rx_rdy, rx_rdy1:std_logic;
signal cnt: std_logic_vector(13 downto 0) := (others => '0');
signal cnt_x16: std_logic_vector(9 downto 0) := (others => '0');
signal tx_reg, rx_reg: std_logic_vector(23 downto 0);
signal tx_digit, rx_digit: std_logic_vector(5 downto 0);
signal tx_data: std_logic_vector(7 downto 0);
signal rx_data: std_logic_vector(7 downto 0) := (others => '0');
signal tx_digit_cnt: std_logic_vector(1 downto 0);
signal rx_digit_cnt: std_logic_vector(1 downto 0) := (others => '0');
signal en: std_logic;
signal transmitionData: std_logic_vector(23 downto 0);

begin 

    monopulse: MPG port map(btn(0),clk, en);
    
    --UART TX
    process(clk)
    begin   
        if rising_edge(clk) then
            tx_start <= en;
        end if; 
    end process;
    
    process(clk)
    begin
        --100.000.000 / 9600
        if rising_edge(clk) then
            if cnt = 10416  then
                baud_en <= '1';
                cnt <= (others => '0');
            else
                baud_en <= '0';
                cnt <= cnt + 1;
            end if;
        end if;
     end process;
     
     process(clk)
     begin
        if rising_edge(clk) then
            if tx_start = '1' then
                tx_en <= '1';
            elsif baud_en = '1' and tx_digit_cnt = 3 then
                tx_en <= '0';
            end if;
        end if;
     end process;
     
     process(clk)
     begin
        if rising_edge(clk) then
            tx_rdy1 <= tx_rdy;
            if tx_start = '1' then
                tx_digit_Cnt <= (others => '0');
            elsif tx_rdy = '1' and tx_rdy1 = '0' then
                tx_digit_cnt <= tx_digit_cnt + 1;
            end if;
        end if;
     end process;
    
     process(clk)
     begin
        if rising_edge(clk) then
            if tx_start = '1' then
                tx_reg <= transmitionData;
            end if;
       end if;
    end process;
    
    with tx_digit_cnt select
        tx_digit <= tx_reg(23 downto 18) when "00",
                    tx_reg(17 downto 12) when "01",
                    tx_reg(11 downto 6) when "10",
                    tx_reg(5 downto 0) when "11",
                    (others => 'X') when others;
    
    with tx_digit select
        tx_data <= x"30" when "000000", -- '0'
                   x"31" when "000001", -- '1'
                   x"32" when "000010", -- '2'
                   x"33" when "000011", -- '3'
                   x"34" when "000100", -- '4'
                   x"35" when "000101", -- '5'
                   x"36" when "000110", -- '6'
                   x"37" when "000111", -- '7'
                   x"38" when "001000", -- '8'
                   x"39" when "001001", -- '9'
                   x"41" when "001010", -- 'A'
                   x"42" when "001011", -- 'B'
                   x"43" when "001100", -- 'C'
                   x"44" when "001101", -- 'D'
                   x"45" when "001110", -- 'E'
                   x"46" when "001111", -- 'F'
                   x"47" when "010000", -- 'G'
                   x"48" when "010001", -- 'H'
                   x"49" when "010010", -- 'I'
                   x"4A" when "010011", -- 'J'
                   x"4B" when "010100", -- 'K'
                   x"4C" when "010101", -- 'L'
                   x"4D" when "010110", -- 'M'
                   x"4E" when "010111", -- 'N'
                   x"4F" when "011000", -- 'O'
                   x"50" when "011001", -- 'P'
                   x"51" when "011010", -- 'Q'
                   x"52" when "011011", -- 'R'
                   x"53" when "011100", -- 'S'
                   x"54" when "011101", -- 'T'
                   x"55" when "011110", -- 'U'
                   x"56" when "011111", -- 'V'
                   x"57" when "100000", -- 'W'
                   x"58" when "100001", -- 'X'
                   x"59" when "100010", -- 'Y'
                   x"5A" when "100011", -- 'Z'
                   (others => 'X') when others;

              
    transmit: PmodUSBUART_tx port map(clk, '0', baud_en, tx_en, tx_data, tx, tx_rdy); 
     
     
     
     --UART RX
     
    receive: PmodUSBUART_rx port map(clk, '0', baud_en_x16, rx, rx_data, rx_rdy); 
    process(clk) 
    begin 
        if rising_edge(clk) then
            --100.000.000 / (16 * 9600)
            if cnt_x16 = 651 then 
                baud_en_x16 <= '1'; 
                cnt_x16 <= (others => '0'); 
            else 
                baud_en_x16 <= '0'; 
                cnt_x16 <= cnt_x16 + 1; 
            end if; 
        end if; 
    end process; 
    
   with rx_data select
        rx_digit <= "000000" when x"30", -- '0'
                "000001" when x"31", -- '1'
                "000010" when x"32", -- '2'
                "000011" when x"33", -- '3'
                "000100" when x"34", -- '4'
                "000101" when x"35", -- '5'
                "000110" when x"36", -- '6'
                "000111" when x"37", -- '7'
                "001000" when x"38", -- '8'
                "001001" when x"39", -- '9'
                "001010" when x"41", -- 'A'
                "001011" when x"42", -- 'B'
                "001100" when x"43", -- 'C'
                "001101" when x"44", -- 'D'
                "001110" when x"45", -- 'E'
                "001111" when x"46", -- 'F'
                "010000" when x"47", -- 'G'
                "010001" when x"48", -- 'H'
                "010010" when x"49", -- 'I'
                "010011" when x"4A", -- 'J'
                "010100" when x"4B", -- 'K'
                "010101" when x"4C", -- 'L'
                "010110" when x"4D", -- 'M'
                "010111" when x"4E", -- 'N'
                "011000" when x"4F", -- 'O'
                "011001" when x"50", -- 'P'
                "011010" when x"51", -- 'Q'
                "011011" when x"52", -- 'R'
                "011100" when x"53", -- 'S'
                "011101" when x"54", -- 'T'
                "011110" when x"55", -- 'U'
                "011111" when x"56", -- 'V'
                "100000" when x"57", -- 'W'
                "100001" when x"58", -- 'X'
                "100010" when x"59", -- 'Y'
                "100011" when x"5A", -- 'Z'
                (others => 'X') when others;

    transmitionData <= B"010110_010110_011001_000001" when sw(1) = '1' else rx_reg; 

    process(clk) 
    begin 
        if rising_edge(clk) then 
            rx_rdy1 <= rx_rdy;  
            if rx_rdy = '1' and rx_rdy1 = '0' then 
               case rx_digit_cnt is 
                    when "00" => rx_reg(23 downto 18) <= rx_digit; 
                    when "01" => rx_reg(17 downto 12) <= rx_digit;  
                    when "10" => rx_reg(11 downto 6)  <= rx_digit;  
                    when "11" => rx_reg(5 downto 0)   <= rx_digit;  
                    when others => rx_reg(5 downto 0) <= (others => 'X'); 
                end case; 

                     rx_digit_cnt <= rx_digit_cnt + 1; 
            end if; 
        end if; 
    end process; 
end Behavioral;
