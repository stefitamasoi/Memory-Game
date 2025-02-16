library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Wrapper is
    Port ( clk     : in  std_logic;          
           rst     : in  std_logic;          
           en_btn  : in  std_logic;         
           speed   : in  std_logic; 
           cat     : out std_logic_vector(6 downto 0);  
           an      : out std_logic_vector(7 downto 0); 
           led     : out std_logic;           --se aprinde dupa ce se afiseaza 10 nr
           clk_out : out std_logic
           );
end Wrapper;

architecture Behavioral of Wrapper is

    signal clk_internal : std_logic; 
    signal counter : std_logic_vector(3 downto 0) := (others => '0');
    signal completed : std_logic := '0';
    signal reg : std_logic_vector(7 downto 0) := "10001111"; 
    signal random_number: std_logic_vector(7 downto 0); 
    signal clk_1, clk_05: std_logic;

    component ClkDivider_1sec is
        Port ( clk     : in  std_logic;
               rst     : in  std_logic;
               clk_div : out std_logic);
    end component;
    
    component ClkDivider_05sec is
        Port ( clk     : in  STD_LOGIC;
               rst     : in  STD_LOGIC;
               clk_div : out STD_LOGIC);
    end component;


    component SSD is
        Port (  digit0 : in std_logic_vector(3 downto 0);
                digit1 : in std_logic_vector(3 downto 0);
                digit2 : in std_logic_vector(3 downto 0);
                digit3 : in std_logic_vector(3 downto 0);
                digit4 : in std_logic_vector(3 downto 0);
                digit5 : in std_logic_vector(3 downto 0);
                digit6 : in std_logic_vector(3 downto 0);
                digit7 : in std_logic_vector(3 downto 0);
                cat    : out std_logic_vector(6 downto 0);
                an     : out std_logic_vector(7 downto 0);
                clk    : in std_logic);
    end component;

begin

  
     Clk1: ClkDivider_1sec
            Port map (
                clk     => clk,
                rst     => rst,
                clk_div => clk_1
            );
    
    Clk05: ClkDivider_05sec
            Port map (
                clk     => clk,
                rst     => rst,
                clk_div => clk_05
            );
     
    clk_out <= clk_1 when speed = '0' else clk_05; 
    clk_internal <= clk_1 when speed = '0' else clk_05; 

    SSD_inst : SSD
        Port map (
            digit0 => random_number(3 downto 0), 
            digit1 => "0000", 
            digit2 => "0000",                   
            digit3 => "0000",                   
            digit4 => "0000",                   
            digit5 => "0000",                   
            digit6 => "0000",                   
            digit7 => "0000",                   
            cat    => cat,                      
            an     => an,                       
            clk    => clk_internal              
        );   
        
    process(clk_internal, rst, en_btn)
    begin
        if rst = '1' then
            reg <= "10001111";
            counter <= (others => '0');  
            completed <= '0';            
            led <= '0';                  
        elsif rising_edge(clk_internal) then
            if en_btn = '1' and completed = '0' then
                if counter = "1010" then  
                    completed <= '1';      
                    led <= '1';            
                else
                    reg <= reg(6 downto 0) & (reg(7) xor reg(5) xor reg(4) xor reg(0));
                    counter <= counter + 1;  
                end if;
            end if;
        end if;
    end process;

    random_number <= reg;
    
    clk_out <= clk_internal;


end Behavioral;
