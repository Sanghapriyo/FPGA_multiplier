library ieee;
use ieee.std_logic_1164.all;

entity fulladder is 
	port(
		x,y,c_in : in std_logic; 
		c_out,sum: out std_logic);
end entity fulladder;

architecture arch of fulladder is
begin
	sum <= x xor y xor c_in;
	c_out<= (x and y) or (y and c_in) or (x and c_in);
end architecture arch;