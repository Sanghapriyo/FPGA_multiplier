library ieee;
use ieee.std_logic_1164.all;

entity multiplier4x4_tb is
end entity multiplier4x4_tb;

architecture testbench of multiplier4x4_tb is
    signal x_tb, y_tb : std_logic_vector(3 downto 0);
    signal p_tb       : std_logic_vector(7 downto 0);
    
    component multiplier4x4 is
        port (
            x : in  std_logic_vector(3 downto 0);
            y : in  std_logic_vector(3 downto 0);
            p : out std_logic_vector(7 downto 0) );
    end component multiplier4x4;

begin
    uut: multiplier4x4 port map(
        x => x_tb,
        y => y_tb,
        p => p_tb );

    stim_proc: process
    begin
        -- Test1
        x_tb <= "0010";  -- 2
        y_tb <= "0010";  -- 3
        wait for 10 ns;
        assert p_tb = "00000100" report "Test1 failed" severity error;

        -- Test2
        x_tb <= "0101";  -- 5
        y_tb <= "0011";  -- 3
        wait for 10 ns;
        assert p_tb = "00001111" report "Test2 failed" severity error;

        -- Test4
        x_tb <= "1011";  -- 11
        y_tb <= "0111";  -- 7
        wait for 10 ns;
        assert p_tb = "01001101" report "Test3 failed" severity error;

        -- Test5
        x_tb <= "1111";  -- 15
        y_tb <= "1111";  -- 15
        wait for 10 ns;
        assert p_tb = "11100001" report "Test4 failed" severity error;
        wait;
    end process stim_proc;
end architecture testbench;