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

type pp_comp_array is array(7 downto 0) of STD_LOGIC_VECTOR(1 downto 0);
signal comp: pp_comp_array;

signal s1, s2: STD_LOGIC_VECTOR(11 downto 0);
signal sum: STD_LOGIC_VECTOR(11 downto 0);
signal carries: STD_LOGIC_VECTOR(11 downto 0);

signal x1, x2: STD_LOGIC_VECTOR(7 downto 0);
signal x_carry: STD_LOGIC_VECTOR(7 downto 0);
signal z1, z2: STD_LOGIC_VECTOR(3 downto 0);

signal HA_result: STD_LOGIC_VECTOR(1 downto 0);
signal car: STD_LOGIC_VECTOR(3 downto 0);
signal car2: STD_LOGIC_VECTOR(1 downto 0);


-- Optimized Approximate Half Adder (HA)
function approx_HA(a, b : std_logic) return std_logic_vector is
    variable result : std_logic_vector(1 downto 0);
begin
    result := (a and b) & (a or b);  -- Concatenation avoids extra logic
    return result;
end approx_HA;

-- Optimized Approximate 3:2 Compressor
function approx_32(P0, P1, P2: std_logic) return std_logic_vector is
    variable result: std_logic_vector(1 downto 0);
begin
    result := ((P0 or P1) and P2) & (P0 or P1);  -- Less AND/OR usage
    return result;
end approx_32;

-- Optimized Approximate 4:2 Compressor
function approx_42(P0, P1, P2, P3: std_logic) return std_logic_vector is
    variable result: std_logic_vector(1 downto 0);
begin
    result := ((P0 or P1) or P2 or P3) & (P0 or P1 or (P2 and P3));
    return result;
end approx_42;


begin
--    -- determining the position of 0 in the recoded booth value
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
    A_comp <= STD_LOGIC_VECTOR(-SIGNED(A)); 
    
    
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
    HA_result <= approx_HA(gen(0)(2), gen(1)(0));
        prod(2) <= HA_result(0);
        car(0) <= HA_result(1);
 

    comp(0) <= gen(1)(1) & gen(0)(3);
      
    --using 32 compressor
    comp(1) <= approx_32(gen(0)(4), gen(1)(2), gen(2)(0));
    comp(2) <= approx_32(gen(0)(5), gen(1)(3), gen(2)(1));   
    
    -- using 42 compressor
    pp_gen1: for i in 3 to 7 generate
        comp(i) <= approx_42(gen(0)(i+3), gen(1)(i+1), gen(2)(i-1), gen(3)(i-3));
    end generate;
 
   
    car2(0) <= gen(0)(10) and gen(1)(8) and gen(2)(6);  -- -- previously it was car2(0)<='0'; car2(1)<='0';
    car2(1) <= gen(1)(8) and gen(2)(6) and gen(3)(4);

    Type_A: for i in 0 to 7 generate 
        lut_inst0: LUT6_2 
        generic map(INIT => X"6000000080000000")
        port map(
            I0 => comp(i)(0),
            I1 => comp(i)(1),
            I2 => '1',
            I3 => '1',
            I4 => '1',
            I5 => '1',
            O5 => s1(i),
            O6 => s2(i)
        );
    end generate Type_A; 
    
    Type_B: for i in 0 to 3 generate 
        lut_inst1: LUT6_2 
        generic map(INIT => X"6000000080000000")
        port map(
            I0 => gen(0)(i+11),
            I1 => gen(1)(i+9),
            I2 => '1',
            I3 => '1',
            I4 => '1',
            I5 => '1',
            O5 => x1(i),
            O6 => x2(i));
    end generate Type_B;
	carry_inst1: CARRY4                                        
        port map (
            DI => x1(3 downto 0),                                              
            S  => x2(3 downto 0),                                             
            O  => z1,                                
            CO => x_carry(3 downto 0),                                        
            CI => car2(0),                            
            CYINIT => '0');
           	
    Type_C: for i in 0 to 3 generate 
        lut_inst2: LUT6_2 
        generic map(INIT => X"6000000080000000")
        port map(
            I0 => gen(2)(i+7),
            I1 => gen(3)(i+5),
            I2 => '1',
            I3 => '1',
            I4 => '1',
            I5 => '1',
            O5 => x1(i+4),
            O6 => x2(i+4)
        );
    end generate Type_C;	
	carry_inst2: CARRY4                                        
        port map (
            DI => x1(7 downto 4),                                              
            S  => x2(7 downto 4),                                             
            O  => z2,                                
            CO => x_carry(7 downto 4),                                        
            CI => car2(1),                            
            CYINIT => '0'); 
                       
    Type_D: for i in 0 to 3 generate 
        lut_inst3: LUT6_2 
        generic map(INIT => X"6000000080000000")
        port map(
            I0 => z1(i),
            I1 => z2(i),
            I2 => '1',
            I3 => '1',
            I4 => '1',
            I5 => '1',
            O5 => s1(i+8),
            O6 => s2(i+8)
        );
    end generate Type_D;         
            
   
    -- Carry chain implementation
    carry_chain_A: for z in 0 to 2 generate            
        carry_inst0: CARRY4                                        
        port map (
            DI => s1(z*4+3 downto z*4),                                              
            S  => s2(z*4+3 downto z*4),                                             
            O  => sum(z*4+3 downto z*4),                                
            CO => carries(z*4+3 downto z*4),                                        
            CI => car(z),                            
            CYINIT => '0'
        );
        car(z+1) <= carries(z*4+3);
    end generate carry_chain_A;
    
    prod(14 downto 3) <= sum;
    prod(15) <= A(7) xor B(7);



	
    ----------- for testbench ------------

--    -- 2nd step binary
--    Stest1(2 downto 0) <= gen(0)(2 downto 0);
--	test1: for i in 0 to 7 generate       
--        Stest1(i+3) <= comp(i)(0);
--    end generate;
--    Stest1(14 downto 11) <= z1;
  
--    Stest2(1 downto 0) <= (others => '0');
--    Stest2(2) <= gen(1)(0);
--	test3: for i in 0 to 7 generate       
--        Stest2(i+3) <= comp(i)(1);
--    end generate;
--    Stest2(14 downto 11) <= z2;
	
--	  Scomp0 <= comp(0);
--    Scomp1 <= comp(1);
--    Scomp2 <= comp(2);
--    Scomp3 <= comp(3);
--    Scomp4 <= comp(4);
--    Scomp5 <= comp(5);
--    Scomp6 <= comp(6);
--    Scomp7 <= comp(7);
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