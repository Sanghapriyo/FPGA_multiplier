library ieee;
use ieee.std_logic_1164.all;

entity adder_8bit is
	port(
		x    : in std_logic_vector(7 downto 0);
		y    : in std_logic_vector(7 downto 0);
		c_in : in std_logic;
		sum  : out std_logic_vector (7 downto 0);
		c_out: out std_logic );
end entity adder_8bit;

architecture arch of adder_8bit is
    signal c1,c2,c3,c4,c5,c6,c7: std_logic;
    
    component fulladder is 
        port( 
            x    : in std_logic;
            y    : in std_logic;
            c_in : in std_logic;
            sum  : out std_logic;
            c_out: out std_logic);
    end component fulladder;

begin
	FA1:  fulladder port map(x(0), y(0), c_in, sum(0), c1);
	FA2:  fulladder port map(x(1), y(1), c1, sum(1), c2);
	FA3:  fulladder port map(x(2), y(2), c2, sum(2), c3);
	FA4:  fulladder port map(x(3), y(3), c3, sum(3), c4);
	FA5:  fulladder port map(x(4), y(4), c4, sum(4), c5);
	FA6:  fulladder port map(x(5), y(5), c5, sum(5), c6);
	FA7:  fulladder port map(x(6), y(6), c6, sum(6), c7);
	FA8:  fulladder port map(x(7), y(7), c7, sum(7), c_out);
end architecture arch;