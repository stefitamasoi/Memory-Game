library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity PmodKYPD is
    Port ( 
        clk : in  STD_LOGIC;    
        JA : inout  STD_LOGIC_VECTOR (7 downto 0); 
        an : out  STD_LOGIC_VECTOR (7 downto 0);   
        cat : out  STD_LOGIC_VECTOR (6 downto 0)
    );
end PmodKYPD;

architecture Behavioral of PmodKYPD is

    component PmodKYPD_Decoder is
        Port (
            clk : in  STD_LOGIC;
            Row : in  STD_LOGIC_VECTOR (3 downto 0);
            Col : out  STD_LOGIC_VECTOR (3 downto 0);
            DecodeOut : out  STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    component PmodKYPD_display is
        Port ( 
            DispVal : in  STD_LOGIC_VECTOR (3 downto 0);
            an : out STD_LOGIC_VECTOR (7 downto 0);
            segOut : out  STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;
    


    signal Decode : STD_LOGIC_VECTOR (3 downto 0);


begin

    decoder: PmodKYPD_Decoder 
        port map (
            clk => clk, 
            Row => JA(7 downto 4), 
            Col => JA(3 downto 0), 
            DecodeOut => Decode    
        );

 
    display: PmodKYPD_display 
        port map (
            DispVal => Decode,    
            an => an,         
            segOut => cat        
        );
        

end Behavioral;