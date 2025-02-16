library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_comparator is
Port (  
        clk: in std_logic;  
        reset: in std_logic;
        en_btn: in std_logic;                       --up button (pe care tin apasat ca sa afiseze secventa de nr random)
        btn1: in std_logic;                         --left button (validez dupa fiecare nr introdus din kypd)        
        data_in_kypd: in std_logic_vector(3 downto 0);
        valid: out std_logic;                       --semnal care valideaza daca cele 2 secvete sunt egale
        score: out std_logic_vector(3 downto 0);    --semnal care calculeaza scorul (cate numere am introdus corect)
        seq_done: out std_logic;                    --semnal care arata ca secventa de 10 numere a fost afisata
        input_done: out std_logic                   --semnal care arata ca am introdus 10 nr prin kypd
     );
end memory_comparator;

architecture Behavioral of memory_comparator is

type matrix is array(0 to 9) of std_logic_vector(3 downto 0);
signal mem: matrix := (x"0", x"1", x"2", x"3", x"4", x"5", x"6", x"7", x"8", x"9");

signal address: integer := -1;
signal RAM_data: std_logic_vector(3 downto 0) := (others => '0');
signal data_out_wrapper: std_logic_vector(3 downto 0) := (others => '0');

signal led_wrapper: std_logic := '0';
signal clk_div: std_logic := '0';

--bidirectional signal for JA
signal JA_signal: std_logic_vector(7 downto 0);

signal counter: integer range 0 to 10 := 0;    
signal score_signal: integer range 0 to 15 := 0; 
signal speed_signal: std_logic := '0'; 
signal an: std_logic_vector(7 downto 0);
signal cat: std_logic_vector(6 downto 0);


component Wrapper is
    Port ( clk     : in  std_logic;          
           rst     : in  std_logic;          
           en_btn  : in  std_logic;   
           speed   : in  std_logic;       
           cat     : out std_logic_vector(6 downto 0);  
           an      : out std_logic_vector(7 downto 0); 
           led     : out std_logic;           --se aprinde dupa ce se afiseaza 10 nr
           clk_out : out std_logic
           );
end component;

component PmodKYPD is
    Port ( 
        clk : in  STD_LOGIC;    
        JA : inout  STD_LOGIC_VECTOR (7 downto 0); 
        an : out  STD_LOGIC_VECTOR (7 downto 0);   
        cat : out  STD_LOGIC_VECTOR (6 downto 0)
    );
end component;

begin

    Wrapper_inst: Wrapper
        Port map(
            clk     => clk,
            rst     => reset,
            en_btn  => en_btn,
            speed   => speed_signal,
            cat     => cat,
            an      => an,
            led     => led_wrapper,
            clk_out => clk_div
        );

    PmodKYPD_inst: PmodKYPD 
        Port map( 
            clk => clk,    
            JA => JA_signal,  
            an => an, 
            cat => cat
        );
        
    JA_signal(7 downto 4) <= data_in_kypd;

    scriere: process(clk_div)
    begin
        if reset = '1' then
            address <= 0;
        elsif rising_edge(clk_div) and en_btn = '1' then
            address <= address + 1;
            mem(address) <= data_out_wrapper;
        end if;
    end process;
    
--ram_data <= mem(address) when led_wrapper = '1';    --dupa ce se afiseaza 10 nr, pot citi de pe memorie
    
    seq_done <= led_wrapper;
    
    comparator: process(btn1, reset)
    begin
        if reset = '1' then
            input_done <= '0';
            counter <= 0;
            score_signal <= 0; 
        elsif rising_edge(btn1) then
            if counter < 10 then
                if mem(counter) = JA_signal(3 downto 0) then
                    score_signal <= score_signal + 1; 
                end if;
                counter <= counter + 1; 
                if counter = 10 then
                    input_done <= '1'; 
                end if;
            end if;
            if score_signal = 10 then 
                valid <= '1';
            end if;
        end if;
    end process;

score <= std_logic_vector(to_unsigned(score_signal, 4));
    
end Behavioral;
