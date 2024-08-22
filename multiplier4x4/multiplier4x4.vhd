library ieee;
use ieee.std_logic_1164.all;

entity multiplier4x4 is
	port (
		x,y: in  std_logic_vector(3 downto 0); 
		p  : out std_logic_vector(7 downto 0));
end entity multiplier4x4;

architecture arch of multiplier4x4 is 
	signal c1, c2, c3: std_logic_vector (3 downto 0);
	signal s1, s2, s3: std_logic_vector (3 downto 0);
	signal xy0, xy1, xy2, xy3: std_logic_vector (3 downto 0);
	
    component fulladder
        port(
            x,y,c_in : in std_logic;
            c_out,sum: out std_logic); 
    end component; 
    
    component halfadder 
        port(
            x,y      : in std_logic; 
            c_out,sum: out std_logic); 
    end component;

begin
	xy0(0) <= x(0) and y(0);
	xy0(1) <= x(1) and y(0);
	xy0(2) <= x(2) and y(0);
	xy0(3) <= x(3) and y(0);

	xy1(0) <= x(0) and y(1);
	xy1(1) <= x(1) and y(1);
	xy1(2) <= x(2) and y(1);
	xy1(3) <= x(3) and y(1);

	xy2(0) <= x(0) and y(2);
	xy2(1) <= x(1) and y(2);
	xy2(2) <= x(2) and y(2);
	xy2(3) <= x(3) and y(2);

	xy3(0) <= x(0) and y(3);
	xy3(1) <= x(1) and y(3);
	xy3(2) <= x(2) and y(3);
	xy3(3) <= x(3) and y(3);

	FA1: fulladder port map (xy0(2), xy1(1), c1(0), c1(1), s1(1)); 
	FA2: fulladder port map (xy0(3), xy1(2), c1(1), c1(2), s1(2)); 
	FA3: fulladder port map (s1(2) , xy2(1), c2(0), c2(1), s2(1)); 
	FA4: fulladder port map (s1(3) , xy2(2), c2(1), c2(2), s2(2)); 
	FA5: fulladder port map (c1(3) , xy2(3), c2(2), c2(3), s2(3)); 
	FA6: fulladder port map (s2(2) , xy3(1), c3(0), c3(1), s3(1)); 
	FA7: fulladder port map (s2(3) , xy3(2), c3(1), c3(2), s3(2)); 
	FA8: fulladder port map (c2(3) , xy3(3), c3(2), c3(3), s3(3)); 
	
	HA1: halfadder port map (xy0(1), xy1(0), c1(0), s1(0)); 
	HA2: halfadder port map (xy1(3), c1(2) , c1(3), s1(3)); 
	HA3: halfadder port map (s1(1) , xy2(0), c2(0), s2(0)); 
	HA4: halfadder port map (s2(1) , xy3(0), c3(0), s3(0));

	p(0) <= xy0(0); 
	p(1) <= s1(0); 
	p(2) <= s2(0);
	p(3) <= s3(0);
	p(4) <= s3(1);
	p(5) <= s3(2);
	p(6) <= s3(3);
	p(7) <= c3(3);
end architecture arch;
