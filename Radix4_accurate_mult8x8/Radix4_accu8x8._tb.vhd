library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Radix4_accu8x8_tb is
end Radix4_accu8x8_tb;

architecture testbench of Radix4_accu8x8_tb is
    component Radix4_accu8x8
        Port (
            Splus1_out : out STD_LOGIC_VECTOR(3 downto 0);
            Sminus1_out : out STD_LOGIC_VECTOR(3 downto 0);
            Splus2_out : out STD_LOGIC_VECTOR(3 downto 0);
            Sminus2_out : out STD_LOGIC_VECTOR(3 downto 0);
            Sgen0, Sgen1, Sgen2, Sgen3: out STD_LOGIC_VECTOR(15 downto 0);
            Sa_comp: out STD_LOGIC_VECTOR(7 downto 0);
            
            A, B : in STD_LOGIC_VECTOR(7 downto 0);
            prod : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

    signal plus1_out_tb, minus1_out_tb, plus2_out_tb, minus2_out_tb: STD_LOGIC_VECTOR(3 downto 0);
    signal Sgen0_tb, Sgen1_tb, Sgen2_tb, Sgen3_tb: STD_LOGIC_VECTOR(15 downto 0);
   
    signal a_comp_tb: STD_LOGIC_VECTOR(7 downto 0);
    
    signal A_tb, B_tb: STD_LOGIC_VECTOR(7 downto 0);
    signal prod_tb, exact_prod_tb: STD_LOGIC_VECTOR(15 downto 0);

begin
    uut: Radix4_accu8x8
        port map (
            Splus1_out => plus1_out_tb,
            Sminus1_out => minus1_out_tb,
            Splus2_out => plus2_out_tb,
            Sminus2_out => minus2_out_tb,
            Sgen0 => Sgen0_tb,
            Sgen1 => Sgen1_tb,
            Sgen2 => Sgen2_tb,
            Sgen3 => Sgen3_tb,

            Sa_comp => a_comp_tb,
            A => A_tb,
            B => B_tb,
            prod => prod_tb
        );

    -- Process for exact multiplication (ensures correct timing)
    compute_exact_product: process(A_tb, B_tb)
    begin
        exact_prod_tb <= std_logic_vector(to_signed(to_integer(signed(A_tb)) * to_integer(signed(B_tb)), 16));
    end process;

    -- Process for test stimulus
    stim_proc: process
    begin
        for i in 1 to 255 loop
            for j in 1 to 255 loop
                A_tb <= std_logic_vector(to_signed(i - 128, 8));
                B_tb <= std_logic_vector(to_signed(j - 128, 8));
                wait for 1 ns;              -- Wait for both prod_tb and exact_prod_tb to update
            end loop;
        end loop;
        wait;
    end process;
end testbench;