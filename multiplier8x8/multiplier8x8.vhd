library ieee;
use ieee.std_logic_1164.all;

entity multiplier8x8 is
    port(
        x,y : in  std_logic_vector(7 downto 0);
        p   : out std_logic_vector(15 downto 0) := (others => '0') );
end entity multiplier8x8;

architecture arch of multiplier8x8 is
    type stage_array is array(1 to 7) of std_logic_vector(7 downto 0);
    type carry_array is array(1 to 7) of std_logic;

    signal part_a, part_b, part_c : stage_array;
    signal carry_out : carry_array;

    component adder_8bit is
        port(
            x     : in  std_logic_vector(7 downto 0);
            y     : in  std_logic_vector(7 downto 0);
            c_in  : in  std_logic;
            sum   : out std_logic_vector(7 downto 0);
            c_out : out std_logic );
    end component adder_8bit;

begin
    p(0) <= x(0) and y(0);

    ab1: for i in 0 to 6 generate
        part_a(1)(i) <= x(i+1) and y(0);
        part_b(1)(i) <= x(i) and y(1);
    end generate;
    part_a(1)(7) <= '0';  
    part_b(1)(7) <= x(7) and y(1);

    adder1: adder_8bit port map(
        x     => part_a(1),
        y     => part_b(1),
        c_in  => '0',
        sum   => part_c(1),
        c_out => carry_out(1) );
		
    p(1) <= part_c(1)(0);


    adder_gen: for stage in 2 to 7 generate
        ab: for i in 0 to 6 generate
            part_a(stage)(i) <= part_c(stage-1)(i+1);
            part_b(stage)(i) <= x(i) and y(stage);
        end generate;
        part_a(stage)(7) <= carry_out(stage-1);
        part_b(stage)(7) <= x(7) and y(stage);

        adder: adder_8bit port map(
            x     => part_a(stage),
            y     => part_b(stage),
            c_in  => '0',
            sum   => part_c(stage),
            c_out => carry_out(stage) );

        p(stage) <= part_c(stage)(0);
    end generate;


    p_gen: for i in 0 to 7 generate
        p(i+7) <= part_c(7)(i);
    end generate;
    p(15) <= carry_out(7);
end architecture arch;