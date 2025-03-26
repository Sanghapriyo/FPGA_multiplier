library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Radix4_accu8x8_tb is
end Radix4_accu8x8_tb;

architecture testbench of Radix4_accu8x8_tb is
    component Radix4_accu8x8
        Port (
--            Szero_out: out STD_LOGIC_VECTOR(3 downto 0);
            Splus1_out : out STD_LOGIC_VECTOR(3 downto 0);
            Sminus1_out : out STD_LOGIC_VECTOR(3 downto 0);
            Splus2_out : out STD_LOGIC_VECTOR(3 downto 0);
            Sminus2_out : out STD_LOGIC_VECTOR(3 downto 0);
            Sgen0,Sgen1,Sgen2,Sgen3: out STD_LOGIC_VECTOR(15 downto 0);               
            Sa_comp: out STD_LOGIC_VECTOR(7 downto 0);   
            Ssum0, Ssum1, Ssum2, Ssum3, Ssum4, Ssum5, Ssum6: out STD_LOGIC_VECTOR(3 downto 0);
            Scout: out STD_LOGIC_VECTOR(9 downto 0);

            A,B       : in  STD_LOGIC_VECTOR(7 downto 0);
            prod    : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

--    signal zero_out_tb : STD_LOGIC_VECTOR(3 downto 0);
    signal plus1_out_tb: STD_LOGIC_VECTOR(3 downto 0);
    signal minus1_out_tb: STD_LOGIC_VECTOR(3 downto 0);
    signal plus2_out_tb: STD_LOGIC_VECTOR(3 downto 0);
    signal minus2_out_tb: STD_LOGIC_VECTOR(3 downto 0);
    signal Sgen0_tb,Sgen1_tb,Sgen2_tb,Sgen3_tb: STD_LOGIC_VECTOR(15 downto 0);
    signal Ssum0_tb, Ssum1_tb, Ssum2_tb, Ssum3_tb, Ssum4_tb, Ssum5_tb, Ssum6_tb: STD_LOGIC_VECTOR(3 downto 0);
    signal Scout_tb: STD_LOGIC_VECTOR(9 downto 0);
    signal a_comp_tb: STD_LOGIC_VECTOR(7 downto 0);
    
    signal A_tb       : STD_LOGIC_VECTOR(7 downto 0) := "11001001";
    signal B_tb       : STD_LOGIC_VECTOR(7 downto 0);
    signal prod_tb    : STD_LOGIC_VECTOR(15 downto 0);

begin
    uut: Radix4_accu8x8
        port map (      
--            Szero_out => zero_out_tb,
            Splus1_out => plus1_out_tb,
            Sminus1_out => minus1_out_tb,
            Splus2_out => plus2_out_tb,
            Sminus2_out => minus2_out_tb,
            
            Sgen0 => Sgen0_tb,
            Sgen1 => Sgen1_tb,
            Sgen2 => Sgen2_tb,
            Sgen3 => Sgen3_tb,
            
            Ssum0 => Ssum0_tb,
            Ssum1 => Ssum1_tb,
            Ssum2 => Ssum2_tb,
            Ssum3 => Ssum3_tb,
            Ssum4 => Ssum4_tb,
            Ssum5 => Ssum5_tb,
            Ssum6 => Ssum6_tb,          
            Scout => Scout_tb,    
            Sa_comp => a_comp_tb,
            
            A       => A_tb,
            B       => B_tb,
            prod    => prod_tb
        );

    stim_proc: process
    begin
        for i in 0 to 255 loop
            B_tb <= std_logic_vector(to_unsigned(i, 8));
            wait for 2 ns;
        end loop;
        wait;
    end process;
end testbench;