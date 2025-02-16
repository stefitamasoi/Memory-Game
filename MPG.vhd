library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MPG is
    Port ( btn : in std_logic;
           clk : in std_logic;
           enable : out std_logic);
end MPG;

architecture Behavioral of MPG is
signal count:std_logic_vector(15 downto 0):=(others=>'0');
signal q1:std_logic:='0';
signal q2:std_logic:='0';
signal q3:std_logic:='0';
signal en:std_logic:='0';
begin

process(clk)
begin
if (rising_edge(clk)) then
    count <= count + 1;
end if;
end process;

process(clk)
begin
if (en='1') then
    if (rising_edge(clk)) then
        q1 <= btn;
    end if;
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
    q2 <= q1;
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
    q3 <= q2;
end if;
end process;

en <= '1' when count = x"FFFF" else '0';
enable <= q2 and not(q3);

end Behavioral;