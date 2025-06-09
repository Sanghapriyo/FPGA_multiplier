library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity Radix4_accu8x8 is
    Port (        
        A,B  : in  STD_LOGIC_VECTOR(7 downto 0);
        prod : out STD_LOGIC_VECTOR(15 downto 0) );
end Radix4_accu8x8;


architecture Behavioral of Radix4_accu8x8 is

signal zero_out, plus1_out, minus1_out, plus2_out, minus2_out: STD_LOGIC_VECTOR(3 downto 0);
signal A_comp : STD_LOGIC_VECTOR(7 downto 0);
type pp_array0 is array(3 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
signal gen: pp_array0;
signal newGen: STD_LOGIC_VECTOR(8 downto 0);

signal x1, x2: STD_LOGIC_VECTOR(7 downto 0);
signal sout_carry: STD_LOGIC_VECTOR(7 downto 0);
signal sin_carry: STD_LOGIC_VECTOR(3 downto 0);
signal Carry_chain: STD_LOGIC_VECTOR(17 downto 0);

begin
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

    ----GENERATING PARTIAL PRODUCTS----
    gen(0)(0) <= A(0) when plus1_out(0)='1' else
                 A_comp(0) when minus1_out(0)='1' else '0';
                 
    pp_gen1: for i in 1 to 7 generate
        gen(0)(i) <= A(i-1)       when plus2_out(0)='1' else
                     A_comp(i-1)  when minus2_out(0)='1' else
                     A(i)         when plus1_out(0)='1' else
                     A_comp(i)    when minus1_out(0) = '1' else '0';
    end generate pp_gen1;
    
    gen(0)(8) <= A(7)      when (plus1_out(0) or plus2_out(0)) = '1' else 
                 A_comp(7) when (minus1_out(0) or minus2_out(0)) = '1' else '0';
    gen(0)(9) <= gen(0)(8);                          
    gen(0)(10) <= not(gen(0)(8)); 

             
	all_pp_gen:for j in 1 to 3 generate
	    gen(j)(0) <= A(0) when plus1_out(j)='1' else
                     A_comp(0) when minus1_out(j)='1' else '0';
                     
        pp_gen1: for i in 1 to 7 generate
            gen(j)(i) <= A(i-1)       when plus2_out(j)='1' else
                         A_comp(i-1)  when minus2_out(j)='1' else
                         A(i)         when plus1_out(j)='1' else
                         A_comp(i)    when minus1_out(j) = '1' else '0';
        end generate pp_gen1;
        
        gen(j)(8) <= A_comp(7) when (plus1_out(j) or plus2_out(j)) = '1' else 
                     A(7)      when (minus1_out(j) or minus2_out(j)) = '1' else '1';                     
        gen(j)(9) <= '1';
    end generate all_pp_gen;


    sin_carry(0) <= gen(2)(0);  
    Type_A: for i in 0 to 7 generate 
            lut_C0: LUT6_2 
            generic map(INIT => X"6000000080000000")
            port map(
                I0 => gen(0)(i+4),
                I1 => gen(1)(i+2),
                I2 => '1',
                I3 => '1',
                I4 => '1',
                I5 => '1',
                O5 => x1(i),
                O6 => x2(i) );
    end generate;      
    carry_chain_A: for z in 0 to 1 generate            -- Carry chain implementation
            carry_inst0: CARRY4                                        
            port map (
                DI => x1(z*4+3 downto z*4),                                              
                S  => x2(z*4+3 downto z*4),                                             
                O  => newGen(z*4+3 downto z*4),                                
                CO => sout_carry(z*4+3 downto z*4),                                        
                CI => sin_carry(z),                            
                CYINIT => '0' );
            sin_carry(z+1) <= sout_carry(z*4+3);
    end generate;   
    newGen(8) <= sin_carry(2); 


    prod(1 downto 0) <= gen(0)(1 downto 0); 
    LUT_P_2_3: LUT6_2
        generic map (INIT => X"8778877866666666")  
        port map (
            I0 => gen(0)(2),
            I1 => gen(1)(0),
            I2 => gen(0)(3),
            I3 => gen(1)(1),
            I4 => '0',
            I5 => '1',
            O5 => prod(2),
            O6 => prod(3) );
        
    LUT_P4: LUT6_2
        generic map (INIT => X"F8800000077FF880")  
        port map (
            I0 => gen(0)(2),
            I1 => gen(1)(0),
            I2 => gen(0)(3),
            I3 => gen(1)(1),
            I4 => newGen(0),
            I5 => '1',
            O5 => prod(4),
            O6 => Carry_chain(0) );
        
    LUT_P5: LUT6_2
        generic map (INIT => X"E8E8E8E896969696")  
        port map (
            I0 => newGen(1),
            I1 => gen(2)(1),
            I2 => Carry_chain(0),
            I3 => '0',
            I4 => '0',
            I5 => '1',
            O5 => prod(5),
            O6 => Carry_chain(1) );
		  
    LUT_P6: LUT5
        generic map (INIT => X"96696996")  
        port map (
            I0 => newGen(2),
            I1 => gen(2)(2),
            I2 => gen(3)(0),
            I3 => Carry_chain(1),
            I4 => '0',
            O => prod(6) );
    LUT_C6: LUT6_2
        generic map (INIT => X"80008000FEE8FEE8")  
        port map (
            I0 => newGen(2),
            I1 => gen(2)(2),
            I2 => gen(3)(0),
            I3 => Carry_chain(1),
            I4 => '0',
            I5 => '1',
            O5 => Carry_chain(2),
            O6 => Carry_chain(3) );
            
    LUT_P7: LUT5
        generic map (INIT => X"96696996")  
        port map (
            I0 => newGen(3),
            I1 => gen(2)(3),
            I2 => gen(3)(1),
            I3 => Carry_chain(2),
            I4 => Carry_chain(3),
            O => prod(7) );
    LUT_C7: LUT6_2
        generic map (INIT => X"E8808000FFFEFEE8")  
        port map (
            I0 => newGen(3),
            I1 => gen(2)(3),
            I2 => gen(3)(1),
            I3 => Carry_chain(2),
            I4 => Carry_chain(3),
			I5 => '1',
            O5 => Carry_chain(4),
            O6 => Carry_chain(5) );
	
	LUT_P8: LUT5
        generic map (INIT => X"96696996")  
        port map (
            I0 => newGen(4),
            I1 => gen(2)(4),
            I2 => gen(3)(2),
            I3 => Carry_chain(4),
            I4 => Carry_chain(5),
            O => prod(8) );
    LUT_C8: LUT6_2
        generic map (INIT => X"E8808000FFFEFEE8")  
        port map (
            I0 => newGen(4),
            I1 => gen(2)(4),
            I2 => gen(3)(2),
            I3 => Carry_chain(4),
            I4 => Carry_chain(5),
				I5 => '1',
            O5 => Carry_chain(6),
            O6 => Carry_chain(7) );
		  
	LUT_P9: LUT5
        generic map (INIT => X"96696996")  
        port map (
            I0 => newGen(5),
            I1 => gen(2)(5),
            I2 => gen(3)(3),
            I3 => Carry_chain(6),
            I4 => Carry_chain(7),
            O => prod(9) );
    LUT_C9: LUT6_2
        generic map (INIT => X"E8808000FFFEFEE8")  
        port map (
            I0 => newGen(5),
            I1 => gen(2)(5),
            I2 => gen(3)(3),
            I3 => Carry_chain(6),
            I4 => Carry_chain(7),
				I5 => '1',
            O5 => Carry_chain(8),
            O6 => Carry_chain(9) );
            				
	LUT_P10: LUT5
        generic map (INIT => X"96696996")  
        port map (
            I0 => newGen(6),
            I1 => gen(2)(6),
            I2 => gen(3)(4),
            I3 => Carry_chain(8),
            I4 => Carry_chain(9),
            O => prod(10) );
    LUT_C10: LUT6_2
        generic map (INIT => X"E8808000FFFEFEE8")  
        port map (
            I0 => newGen(6),
            I1 => gen(2)(6),
            I2 => gen(3)(4),
            I3 => Carry_chain(8),
            I4 => Carry_chain(9),
				I5 => '1',
            O5 => Carry_chain(10),
            O6 => Carry_chain(11) );
    LUT_P11: LUT5
        generic map (INIT => X"96696996")  
        port map (
            I0 => newGen(7),
            I1 => gen(2)(7),
            I2 => gen(3)(5),
            I3 => Carry_chain(10),
            I4 => Carry_chain(11),
            O => prod(11) );
    LUT_C11: LUT6_2
        generic map (INIT => X"E8808000FFFEFEE8")  
        port map (
            I0 => newGen(7),
            I1 => gen(2)(7),
            I2 => gen(3)(5),
            I3 => Carry_chain(10),
            I4 => Carry_chain(11),
            I5 => '1',
            O5 => Carry_chain(12),
            O6 => Carry_chain(13) );
    
    LUT_P12: LUT5
        generic map (INIT => X"96696996")  
        port map (
            I0 => newGen(8),
            I1 => gen(2)(8),
            I2 => gen(3)(6),
            I3 => Carry_chain(12),
            I4 => Carry_chain(13),
            O => prod(12) );
    LUT_C12: LUT6_2
        generic map (INIT => X"E8808000FFFEFEE8")  
        port map (
            I0 => newGen(8),
            I1 => gen(2)(8),
            I2 => gen(3)(6),
            I3 => Carry_chain(12),
            I4 => Carry_chain(13),
				I5 => '1',
            O5 => Carry_chain(14),
            O6 => Carry_chain(15) );  	

    LUT_P13: LUT5
        generic map (INIT => X"96696996")  
        port map (
            I0 => '1',
            I1 => gen(3)(7),
            I2 => Carry_chain(14),
            I3 => Carry_chain(15),
            I4 => '0',
            O => prod(13) );
    LUT_C13: LUT6_2
        generic map (INIT => X"E8808000FFFEFEE8")  
        port map (
            I0 => '1',
            I1 => gen(3)(7),
            I2 => Carry_chain(14),
            I3 => Carry_chain(15),
            I4 => '0',
				I5 => '1',
            O5 => Carry_chain(16),
            O6 => Carry_chain(17) );	
            	  
     LUT_P_14_15: LUT6_2
        generic map (INIT => X"1717171796969696")  
        port map (
            I0 => gen(3)(8),
            I1 => Carry_chain(16),
            I2 => Carry_chain(17),
            I3 => '0',
            I4 => '0',
			I5 => '1',
            O5 => prod(14),
            O6 => prod(15) );
end Behavioral;