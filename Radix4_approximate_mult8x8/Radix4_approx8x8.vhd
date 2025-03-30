library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity Radix4_approx8x8 is
    Port (
        ------ for testbench ---------
--        Szero_out, Splus1_out, Sminus1_out, Splus2_out, Sminus2_out: out STD_LOGIC_VECTOR(3 downto 0);
--        Sgen0,Sgen1,Sgen2,Sgen3: out STD_LOGIC_VECTOR(15 downto 0);
--        Sa_comp : out STD_LOGIC_VECTOR(7 downto 0);
--        Scomp0, Scomp1, Scomp2, Scomp3, Scomp4, Scomp5, Scomp6, Scomp7: out STD_LOGIC_VECTOR(1 downto 0);
--        Ssum0, Ssum1, Ssum2, Ssum3, Ssum4: out STD_LOGIC_VECTOR(3 downto 0);
--        Scar: out STD_LOGIC_VECTOR(3 downto 0);
--        Stest1, Stest2: out STD_LOGIC_VECTOR(14 downto 0);

        A,B  : in  STD_LOGIC_VECTOR(7 downto 0);
        prod : out STD_LOGIC_VECTOR(15 downto 0)
);
end Radix4_approx8x8;


architecture Behavioral of Radix4_approx8x8 is

signal zero_out, plus1_out, minus1_out, plus2_out, minus2_out: STD_LOGIC_VECTOR(3 downto 0);
signal a_comp : STD_LOGIC_VECTOR(7 downto 0);

type pp_array0 is array(3 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
signal gen: pp_array0;

type pp_array1 is array(7 downto 0) of STD_LOGIC_VECTOR(3 downto 0);
signal s1, s2: pp_array1;
signal sum: pp_array1;
signal carries : pp_array1;
signal cout: STD_LOGIC_VECTOR (9 downto 0):= (others=>'0');

type pp_array2 is array(2 downto 0) of STD_LOGIC_VECTOR(3 downto 0);
signal x1, x2: pp_array2;
signal sum_final: pp_array2;
signal carries_final : pp_array2;
signal cout_final: STD_LOGIC_VECTOR (4 downto 0):= (others=>'0');


type pp_comp_array is array(7 downto 0) of STD_LOGIC_VECTOR(1 downto 0);
signal comp: pp_comp_array;

signal Adder_results1, Adder_results2: STD_LOGIC_VECTOR(1 downto 0);
signal car: STD_LOGIC_VECTOR(3 downto 0);
signal car2: STD_LOGIC_VECTOR(1 downto 0);------------------------------------------experiment

function approx_HA(a, b : std_logic) return std_logic_vector is
    variable result : std_logic_vector(1 downto 0);
    begin
    result(0) := a or b;  -- Sum
    result(1) := a and b;  -- Carry
    return result;
end approx_HA;

function exact_FA(a, b, c : std_logic) return std_logic_vector is
    variable result : std_logic_vector(1 downto 0);
    begin
    result(0) := a xor b xor c;  -- Sum
    result(1) := (a and b) or (c and b) or (a and c);  -- Carry
    return result;
end exact_FA;
    
-- approximate 3:2 compressor
function approx_32(P0, P1, P2: std_logic) return std_logic_vector is
    variable result: std_logic_vector(1 downto 0);
    begin
    result(1) := (P0 and P1) or P2;  -- First output
    result(0) := P0 or P1;           -- Second output
    return result;
end approx_32;

-- approximate 4:2 compressor
function approx_42(P0, P1, P2, P3: std_logic) return std_logic_vector is
    variable result: std_logic_vector(1 downto 0);
    begin
    result(1) := (P0 and P1) or P2 or P3;  -- First output
    result(0) := P0 or P1 or (P2 and P3);  -- Second output
    return result;
end approx_42;

begin
--    -- determining the position of +1 in the recoded booth value
--    lut_inst0: LUT6_2
--        generic map(INIT => X"F000000F81818181") 
--        port map(
--            I0 => '0', 
--            I1 => B(0),  
--            I2 => B(1), 
--            I3 => B(2),  
--            I4 => B(3), 
--            I5 => '1', 
--            O5 => zero_out(0), 
--            O6 => zero_out(1));
--	lut_inst1: LUT6_2
--        generic map(INIT => X"F000000F81818181") 
--        port map(
--            I0 => B(3), 
--            I1 => B(4),  
--            I2 => B(5), 
--            I3 => B(6),  
--            I4 => B(7), 
--            I5 => '1', 
--            O5 => zero_out(2), 
--            O6 => zero_out(3));

	-- determining the position of +1 in the recoded booth value
	lut_inst2: LUT6_2
        generic map(INIT => X"00000FF006060606") 
        port map(
            I0 => '0', 
            I1 => B(0),  
            I2 => B(1), 
            I3 => B(2),  
            I4 => B(3), 
            I5 => '1', 
            O5 => plus1_out(0), 
            O6 => plus1_out(1));
	lut_inst3: LUT6_2
        generic map(INIT => X"00000FF006060606") 
        port map(
            I0 => B(3), 
            I1 => B(4),  
            I2 => B(5), 
            I3 => B(6),  
            I4 => B(7), 
            I5 => '1', 
            O5 => plus1_out(2), 
            O6 => plus1_out(3));
			
	-- determining the position of -1 in the recoded booth value		
	lut_inst4: LUT6_2
        generic map(INIT => X"0FF0000060606060") 
        port map(
            I0 => '0', 
            I1 => B(0),  
            I2 => B(1), 
            I3 => B(2),  
            I4 => B(3), 
            I5 => '1', 
            O5 => minus1_out(0), 
            O6 => minus1_out(1));
	lut_inst5: LUT6_2
        generic map(INIT => X"0FF0000060606060") 
        port map(
            I0 => B(3), 
            I1 => B(4),  
            I2 => B(5), 
            I3 => B(6),  
            I4 => B(7), 
            I5 => '1', 
            O5 => minus1_out(2), 
            O6 => minus1_out(3));
			
	-- determining the position of +2 in the recoded booth value
	lut_inst6: LUT6_2
        generic map(INIT => X"0000F00008080808") 
        port map(
            I0 => '0', 
            I1 => B(0),  
            I2 => B(1), 
            I3 => B(2),  
            I4 => B(3), 
            I5 => '1', 
            O5 => plus2_out(0), 
            O6 => plus2_out(1));
	lut_inst7: LUT6_2
        generic map(INIT => X"0000F00008080808") 
        port map(
            I0 => B(3), 
            I1 => B(4),  
            I2 => B(5), 
            I3 => B(6),  
            I4 => B(7), 
            I5 => '1', 
            O5 => plus2_out(2), 
            O6 => plus2_out(3));
			
	-- determining the position of -2 in the recoded booth value		
	lut_inst8: LUT6_2
        generic map(INIT => X"000F000010101010") 
        port map(
            I0 => '0', 
            I1 => B(0),  
            I2 => B(1), 
            I3 => B(2),  
            I4 => B(3), 
            I5 => '1', 
            O5 => minus2_out(0), 
            O6 => minus2_out(1));
	lut_inst9: LUT6_2
        generic map(INIT => X"000F000010101010") 
        port map(
            I0 => B(3), 
            I1 => B(4),  
            I2 => B(5), 
            I3 => B(6),  
            I4 => B(7), 
            I5 => '1', 
            O5 => minus2_out(2), 
            O6 => minus2_out(3));
            
            
    -- 2's complement of 'A'
    A_comp <= STD_LOGIC_VECTOR(not UNSIGNED(A) + 1);
    
    
    -- generating partial products
	all_pp_gen:for j in 0 to 3 generate
	    gen(j)(0) <= A(0) when plus1_out(j)='1' else
                     A_comp(0) when minus1_out(j)='1' else '0';
                     
        pp_gen1: for i in 1 to 7 generate
            gen(j)(i) <= A(i-1)       when plus2_out(j)='1' else
                         A_comp(i-1)  when minus2_out(j)='1' else
                         A(i)         when plus1_out(j)='1' else
                         A_comp(i)    when minus1_out(j) = '1' else '0';
        end generate pp_gen1;
        
        gen(j)(8) <= A(7)      when (plus1_out(j) or plus2_out(j)) = '1' else 
                     A_comp(7) when (minus1_out(j) or minus2_out(j)) = '1' else '0';
        gen(j)(15 downto 9) <= (others => gen(j)(8));
    end generate all_pp_gen;
    
    
    --generating product P(0) to P(2)
    prod(0) <= gen(0)(0);
    prod(1) <= gen(0)(1);
    Adder_results1 <= approx_HA(gen(0)(2), gen(1)(0));
        prod(2) <= Adder_results1(0);
        car(0) <= Adder_results1(1);
 
   
    comp(0) <= gen(1)(1) & gen(0)(3);
          
    --using 32 compressor
    comp(1) <= approx_32(gen(0)(4), gen(1)(2), gen(2)(0));
    comp(2) <= approx_32(gen(0)(5), gen(1)(3), gen(2)(1));   
    
    -- using 42 compressor
    pp_gen1: for i in 3 to 7 generate
        comp(i) <= approx_42(gen(0)(i+3), gen(1)(i+1), gen(2)(i-1), gen(3)(i-3));
    end generate;
   
   
    --generating product P(3) to P(10)
    comp0: for j in 0 to 1 generate  
        GEN_SUM0: for i in 0 to 3 generate       
            s1(j)(i) <= comp(i+j*4)(0) and comp(i+j*4)(1);
            s2(j)(i) <= comp(i+j*4)(0) xor comp(i+j*4)(1);
        end generate;
        carry_inst0: CARRY4
        port map (
            DI      => s1(j),        
            S       => s2(j),        
            O       => sum(j),       
            CO      => carries(j),   
            CI      => car(j),  
            CYINIT  => '0'        
        );
        car(j+1) <= carries(j)(3);         --Final carry-out
        
        prod0: for i in 0 to 3 generate       
            prod(i+3+j*4) <= sum(j)(i);
        end generate;
    end generate;


    car2(0) <= gen(0)(10) and gen(1)(8) and gen(2)(6);  -- for better accuracy
    car2(1) <= gen(1)(8) and gen(2)(6) and gen(3)(4);

    --generating product P(12) to P(15)
    GEN_SUM1: for i in 0 to 3 generate       
        s1(2)(i) <= gen(0)(i+11) and gen(1)(i+9);
        s2(2)(i) <= gen(0)(i+11) xor gen(1)(i+9);
    end generate;
    GEN_SUM2: for i in 0 to 3 generate       
        s1(3)(i) <= gen(2)(i+7) and gen(3)(i+5);
        s2(3)(i) <= gen(2)(i+7) xor gen(3)(i+5);
    end generate;
    comp1: for j in 2 to 3 generate 
        carry_inst1: CARRY4
        port map (
            DI      => s1(j),        
            S       => s2(j),        
            O       => sum(j),       
            CO      => carries(j),   
            CI      => car2(j-2),       
            CYINIT  => '0'        
        );  
    end generate;
    
    GEN_SUM3: for i in 0 to 3 generate       
        s1(4)(i) <= sum(2)(i) and sum(3)(i);
        s2(4)(i) <= sum(2)(i) xor sum(3)(i);
    end generate;
    carry_inst2: CARRY4
        port map (
            DI      => s1(4),        
            S       => s2(4),        
            O       => sum(4),       
            CO      => carries(4),   
            CI      => car(2),       
            CYINIT  => '0');
    prod1: for i in 0 to 3 generate       
        prod(i+11) <= sum(4)(i);
    end generate;

    prod(15) <= A(7) xor B(7);
    

	
	----------- for testbench ------------
--	  Scomp0 <= comp(0);
--    Scomp1 <= comp(1);
--    Scomp2 <= comp(2);
--    Scomp3 <= comp(3);
--    Scomp4 <= comp(4);
--    Scomp5 <= comp(5);
--    Scomp6 <= comp(6);
--    Scomp7 <= comp(7);
--    Ssum0<= sum(0);
--    Ssum1<= sum(1);
--    Ssum2<= sum(2);
--    Ssum3<= sum(3);
--    Ssum4<= sum(4);
--    Scar<=car;  
--    Sa_comp <= a_comp;
----    Szero_out <= zero_out; 
--    Splus1_out <= plus1_out; 
--    Sminus1_out <= minus1_out;
--    Splus2_out <= plus2_out;
--    Sminus2_out <= minus2_out;
--    Sgen0 <= gen(0);
--    Sgen1 <= gen(1);
--    Sgen2 <= gen(2);
--    Sgen3 <= gen(3);
end Behavioral;