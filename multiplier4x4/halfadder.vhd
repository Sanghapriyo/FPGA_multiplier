library ieee;
use ieee.std_logic_1164.all;

entity halfadder is
	port(
		x,y      : in std_logic;
		c_out,sum: out std_logic);
end halfadder;

architecture arch of halfadder is
begin
	sum <= x xor y; 
	c_out <= x and y;
end architecture arch;