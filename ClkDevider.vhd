library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClkDivider_1sec is
    Port ( clk     : in  STD_LOGIC;
           rst     : in  STD_LOGIC;
           clk_div : out STD_LOGIC);
end ClkDivider_1sec;

architecture Behavioral of ClkDivider_1sec is
    constant constantNumber : integer := 50000000; --1 sec
    signal count           : integer range 0 to constantNumber-1 := 0;
    signal clk_div_reg     : STD_LOGIC := '0'; -- internal signal to hold the clk_div state
begin

    process(clk, rst)
    begin
        if rst = '1' then
            count <= 0;
        elsif rising_edge(clk) then
            if count = constantNumber - 1 then
                count <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            clk_div_reg <= '0';  -- Reset the internal signal when rst is active
        elsif rising_edge(clk) then
            if count = constantNumber - 1 then
                clk_div_reg <= not clk_div_reg;  -- Toggle the internal signal
            end if;
        end if;
    end process;

    clk_div <= clk_div_reg;  -- Assign the internal signal to the output port

end Behavioral;
