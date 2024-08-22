library ieee;
use ieee.std_logic_1164.all;

entity multiplier8x8_tb is
end entity multiplier8x8_tb;

architecture testbench of multiplier8x8_tb is
    signal x_tb, y_tb : std_logic_vector(7 downto 0);
    signal p_tb       : std_logic_vector(15 downto 0);
    
    component multiplier8x8 is
        port(
            x : in  std_logic_vector(7 downto 0);
            y : in  std_logic_vector(7 downto 0);
            p : out std_logic_vector(15 downto 0) );
    end component multiplier8x8;

begin
    uut: multiplier8x8 port map(
        x => x_tb,
        y => y_tb,
        p => p_tb );

    stim_proc: process
    begin
        -- Test1
        x_tb <= "00000010";  -- 2
        y_tb <= "00000010";  -- 2
        wait for 10 ns;
        assert p_tb = "0000000000000100" report "Test1 failed" severity error;
        
        -- Test2
        x_tb <= "00001101";  -- 13
        y_tb <= "00001011";  -- 11
        wait for 10 ns;
        assert p_tb = "0000000010001111" report "Test2 failed" severity error;

        -- Test3
        x_tb <= "10000001";  -- 129
        y_tb <= "00011001";  -- 25
        wait for 10 ns;
        assert p_tb = "0000110010011001" report "Test3 failed" severity error;
     
        -- Test4
        x_tb <= "01001100";  -- 76
        y_tb <= "11101011";  -- 235
        wait for 10 ns;
        assert p_tb = "0100010111000100" report "Test4 failed" severity error;

        -- Test5
        x_tb <= "11111111";  -- 255
        y_tb <= "11111111";  -- 255
        wait for 10 ns;
        assert p_tb = "1111111000000001" report "Test5 failed" severity error;
        wait;
    end process stim_proc;
end architecture testbench;
