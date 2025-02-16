library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity SSD is
Port (  digit0: in std_logic_vector(3 downto 0);
        digit1: in std_logic_vector(3 downto 0);
        digit2: in std_logic_vector(3 downto 0);
        digit3: in std_logic_vector(3 downto 0);
        digit4: in std_logic_vector(3 downto 0);
        digit5: in std_logic_vector(3 downto 0);
        digit6: in std_logic_vector(3 downto 0);
        digit7: in std_logic_vector(3 downto 0);
        cat: out std_logic_vector(6 downto 0);
        an: out std_logic_vector(7 downto 0);
        clk: in std_logic);
end SSD;

architecture Behavioral of SSD is
signal count:std_logic_vector(16 downto 0):=(others=>'0');
signal mux1:std_logic_vector(3 downto 0):=(others=>'0');
signal mux2:std_logic_vector(7 downto 0):=(others=>'0');
begin

process(clk)
begin
    if(rising_edge(clk)) then
        count <= count + 1 ;
    end if;
end process;

process
begin
    case count(16 downto 14) is
        when "000" => mux1 <= digit0;
        when "001" => mux1 <= digit1;
        when "010" => mux1 <= digit2;
        when "011" => mux1 <= digit3;
        when "100" => mux1 <= digit4;
        when "101" => mux1 <= digit5;
        when "110" => mux1 <= digit6;
        when others => mux1 <= digit7;
    end case;
end process;

process
begin
    case count(16 downto 14) is
        when "000" => an<= "11111110";
        when "001" => an<= "11111101";
        when "010" => an<= "11111011";
        when "011" => an<= "11110111";
        when "100" => an<= "11101111";
        when "101" => an<= "11011111";
        when "110" => an<= "10111111";
        when "111" =>an <= "01111111";
        when others => an <= "XXXXXXXX";
    end case;
end process;

with mux1 select
   cat<= "1111001" when "0001",   --1
         "0100100" when "0010",   --2
         "0110000" when "0011",   --3
         "0011001" when "0100",   --4
         "0010010" when "0101",   --5
         "0000010" when "0110",   --6
         "1111000" when "0111",   --7
         "0000000" when "1000",   --8
         "0010000" when "1001",   --9
         "0001000" when "1010",   --A
         "0000011" when "1011",   --b
         "1000110" when "1100",   --C
         "0100001" when "1101",   --d
         "0000110" when "1110",   --E
         "0001110" when "1111",   --F
         "1000000" when others;   --0

--an <= mux2;

end Behavioral;
