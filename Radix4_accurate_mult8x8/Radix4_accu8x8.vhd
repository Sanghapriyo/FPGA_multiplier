library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity Radix4_accu8x8 is
    Port (
        ----------- for testbench ------------
        -- Szero_out, Splus1_out, Sminus1_out, Splus2_out, Sminus2_out: out STD_LOGIC_VECTOR(3 downto 0);
        -- Sgen0,Sgen1,Sgen2,Sgen3: out STD_LOGIC_VECTOR(15 downto 0);
        -- Sa_comp : out STD_LOGIC_VECTOR(7 downto 0);
        
        A,B  : in  STD_LOGIC_VECTOR(7 downto 0);
        prod : out STD_LOGIC_VECTOR(15 downto 0) );
end Radix4_accu8x8;


architecture Behavioral of Radix4_accu8x8 is

signal zero_out, plus1_out, minus1_out, plus2_out, minus2_out: STD_LOGIC_VECTOR(3 downto 0);
signal A_comp : STD_LOGIC_VECTOR(7 downto 0);

type pp_array0 is array(3 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
signal gen: pp_array0;


signal x1, x2: STD_LOGIC_VECTOR(15 downto 0);
signal xout_carryA: STD_LOGIC_VECTOR(15 downto 0);
signal xin_carryA: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

signal x3, x4: STD_LOGIC_VECTOR(11 downto 0);
signal xout_carryB: STD_LOGIC_VECTOR(11 downto 0);
signal xin_carryB: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

signal s1, s2: STD_LOGIC_VECTOR(11 downto 0);
signal sout_carry: STD_LOGIC_VECTOR(11 downto 0);
signal sin_carry: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

signal stageA: STD_LOGIC_VECTOR(15 downto 0);
signal stageB: STD_LOGIC_VECTOR(11 downto 0);



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


    ----GENERATING PARTIAL PRODUCTS----
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
--        gen(j)((14-j*2) downto 9) <= (others => gen(j)(8));
    end generate all_pp_gen;

    
    ----GENERATING stageA----
    x1(1 downto 0) <= (others => '0');            -- since '_' and '0' = '0'
    lut_inst01: LUT6_2 
    generic map(INIT => X"0FF0000066660000")      -- applying xor gate
    port map(
        I0 => gen(0)(0),
        I1 => '0',
        I2 => gen(0)(1),
        I3 => '0',
        I4 => '1',
        I5 => '1',
        O5 => x2(0),
        O6 => x2(1) ); 
--    Type_A1: for i in 0 to 1 generate 
--            lut_inst0: LUT6_2 
--            generic map(INIT => X"6000000080000000")
--            port map(
--                I0 => gen(0)(i),
--                I1 => '0',
--                I2 => '1',
--                I3 => '1',
--                I4 => '1',
--                I5 => '1',
--                O5 => x1(i),
--                O6 => x2(i) );
--        end generate;	
    Type_A2: for i in 2 to 15 generate 
            lut_inst1: LUT6_2 
            generic map(INIT => X"6000000080000000")
            port map(
                I0 => gen(0)(i),
                I1 => gen(1)(i-2),
                I2 => '1',
                I3 => '1',
                I4 => '1',
                I5 => '1',
                O5 => x1(i),
                O6 => x2(i) );
    end generate;       
    carry_chain_A: for z in 0 to 3 generate            -- Carry chain implementation
            carry_inst0: CARRY4                                        
            port map (
                DI => x1(z*4+3 downto z*4),                                              
                S  => x2(z*4+3 downto z*4),                                             
                O  => stageA(z*4+3 downto z*4),                                
                CO => xout_carryA(z*4+3 downto z*4),                                        
                CI => xin_carryA(z),                            
                CYINIT => '0' );
            xin_carryA(z+1) <= xout_carryA(z*4+3);
    end generate;        
    prod(3 downto 0) <= stageA(3 downto 0);   
    
    
    ----GENERATING stageB---- 
    x3(1 downto 0) <= (others => '0');            -- since '_' and '0' = '0'
    lut_inst02: LUT6_2 
    generic map(INIT => X"0FF0000066660000")      -- applying xor gate
    port map(
        I0 => gen(2)(0),
        I1 => '0',
        I2 => gen(2)(1),
        I3 => '0',
        I4 => '1',
        I5 => '1',
        O5 => x4(0),
        O6 => x4(1) );           
--    Type_B1: for i in 0 to 1 generate 
--            lut_inst2: LUT6_2 
--            generic map(INIT => X"6000000080000000")
--            port map(
--                I0 => gen(2)(i),
--                I1 => '0',
--                I2 => '1',
--                I3 => '1',
--                I4 => '1',
--                I5 => '1',
--                O5 => x3(i),
--                O6 => x4(i) );
--        end generate;       
    Type_B2: for i in 2 to 11 generate 
            lut_inst3: LUT6_2 
            generic map(INIT => X"6000000080000000")
            port map(
                I0 => gen(2)(i),
                I1 => gen(3)(i-2),
                I2 => '1',
                I3 => '1',
                I4 => '1',
                I5 => '1',
                O5 => x3(i),
                O6 => x4(i) );
    end generate;       
    carry_chain_B: for z in 0 to 2 generate            -- Carry chain implementation
            carry_inst1: CARRY4                                        
            port map (
                DI => x3(z*4+3 downto z*4),                                              
                S  => x4(z*4+3 downto z*4),                                             
                O  => stageB(z*4+3 downto z*4),                                
                CO => xout_carryB(z*4+3 downto z*4),                                        
                CI => xin_carryB(z),                            
                CYINIT => '0' );
            xin_carryB(z+1) <= xout_carryB(z*4+3);
    end generate;	    
        
        
    ----GENERATING prod(15 downto 4) FROM THE FAST ADDITION OF stageA & stageB---- 
    Type_C: for i in 0 to 11 generate 
            lut_inst3: LUT6_2 
            generic map(INIT => X"6000000080000000")
            port map(
                I0 => stageA(i+4),
                I1 => stageB(i),
                I2 => '1',
                I3 => '1',
                I4 => '1',
                I5 => '1',
                O5 => s1(i),
                O6 => s2(i) );
    end generate;      
    carry_chain_C: for z in 0 to 2 generate            -- Carry chain implementation
            carry_inst1: CARRY4                                        
            port map (
                DI => s1(z*4+3 downto z*4),                                              
                S  => s2(z*4+3 downto z*4),                                             
                O  => prod(z*4+7 downto z*4+4),                                
                CO => sout_carry(z*4+3 downto z*4),                                        
                CI => sin_carry(z),                            
                CYINIT => '0' );
            sin_carry(z+1) <= sout_carry(z*4+3);
    end generate;	  
        


	------ for testbench ------- 
--     SA_comp <= A_comp;
-- --    Szero_out <= zero_out; 
--     Splus1_out <= plus1_out; 
--     Sminus1_out <= minus1_out;
--     Splus2_out <= plus2_out;
--     Sminus2_out <= minus2_out;
--     Sgen0 <= gen(0);
--     Sgen1 <= gen(1);
--     Sgen2 <= gen(2);
--     Sgen3 <= gen(3);
    
end Behavioral;