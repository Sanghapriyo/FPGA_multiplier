library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Radix4_approx8x8_tb is
end Radix4_approx8x8_tb;

architecture testbench of Radix4_approx8x8_tb is
    component Radix4_approx8x8
        Port (      
--            Szero_out: out STD_LOGIC_VECTOR(3 downto 0);
            Splus1_out : out STD_LOGIC_VECTOR(3 downto 0);
            Sminus1_out : out STD_LOGIC_VECTOR(3 downto 0);
            Splus2_out : out STD_LOGIC_VECTOR(3 downto 0);
            Sminus2_out : out STD_LOGIC_VECTOR(3 downto 0);

            Sgen0,Sgen1,Sgen2,Sgen3: out STD_LOGIC_VECTOR(15 downto 0);    
            Sa_comp: out STD_LOGIC_VECTOR(7 downto 0);

            Scomp0, Scomp1, Scomp2, Scomp3, Scomp4, Scomp5, Scomp6, Scomp7: out STD_LOGIC_VECTOR(1 downto 0);
            Scar: out STD_LOGIC_VECTOR(3 downto 0);
            Stest1, Stest2: out STD_LOGIC_VECTOR(14 downto 0);
      
            A       : in  STD_LOGIC_VECTOR(7 downto 0);
            B       : in  STD_LOGIC_VECTOR(7 downto 0);
            prod    : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

--    signal zero_out_tb : STD_LOGIC_VECTOR(3 downto 0);
    signal plus1_out_tb: STD_LOGIC_VECTOR(3 downto 0);
    signal minus1_out_tb: STD_LOGIC_VECTOR(3 downto 0);
    signal plus2_out_tb: STD_LOGIC_VECTOR(3 downto 0);
    signal minus2_out_tb: STD_LOGIC_VECTOR(3 downto 0);

    signal Sgen0_tb,Sgen1_tb,Sgen2_tb,Sgen3_tb: STD_LOGIC_VECTOR(15 downto 0);
    signal A_comp_tb: STD_LOGIC_VECTOR(7 downto 0);
    
    signal Scomp0_tb, Scomp1_tb, Scomp2_tb, Scomp3_tb, Scomp4_tb, Scomp5_tb, Scomp6_tb, Scomp7_tb: STD_LOGIC_VECTOR(1 downto 0);
    signal Scar_tb: STD_LOGIC_VECTOR(3 downto 0);
    signal Stest1_tb, Stest2_tb: STD_LOGIC_VECTOR(14 downto 0);

    signal A_tb       : STD_LOGIC_VECTOR(7 downto 0) := "11001001";
    signal B_tb       : STD_LOGIC_VECTOR(7 downto 0);
    signal prod_tb    : STD_LOGIC_VECTOR(15 downto 0);
    signal exact_prod_tb : STD_LOGIC_VECTOR(15 downto 0);

begin
    uut: Radix4_approx8x8
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
            
            Sa_comp => A_comp_tb,       
            
            Scomp0 => Scomp0_tb,
            Scomp1 => Scomp1_tb,
            Scomp2 => Scomp2_tb,
            Scomp3 => Scomp3_tb,
            Scomp4 => Scomp4_tb,
            Scomp5 => Scomp5_tb,
            Scomp6 => Scomp6_tb,
            Scomp7 => Scomp7_tb,
            
            Scar => Scar_tb,
            Stest1 => Stest1_tb,
            Stest2 => Stest2_tb,

            A       => A_tb,
            B       => B_tb,
            prod    => prod_tb
        );

    -- Process for exact multiplication 
    compute_exact_product: process(A_tb, B_tb)
    begin
        exact_prod_tb <= std_logic_vector(to_signed(to_integer(signed(A_tb)) * to_integer(signed(B_tb)), 16));
    end process;

    -- Process for test stimulus
    stim_proc: process
    begin
        for i in 0 to 255 loop
            B_tb <= std_logic_vector(to_signed(i, 8));
            wait for 2 ns;
        end loop;
        wait;
    end process;
    
end testbench;