-- Ethan Ashby and Brayden Shampton Project 2
-- Test bench for the ALU

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;

-- Test bench entity declaration
entity tb_ALU is
end tb_ALU;

-- Test bench architecture
architecture behavioral of tb_ALU is
    signal A      : std_logic_vector(7 downto 0) := (others => '0');
    signal B      : std_logic_vector(7 downto 0) := (others => '0');
    signal Cin    : std_logic := '0';
    signal Op     : std_logic_vector(2 downto 0) := (others => '0');
    signal Result : std_logic_vector(7 downto 0);
    signal Cout   : std_logic;
begin
    -- Instantiate the ALU under test.
    uut : entity work.ALU
        port map (
            A      => A,
            B      => B,
            Cin    => Cin,
            Op     => Op,
            Result => Result,
            Cout   => Cout
        );

    -- Exercise every supported operation and check result and carry behavior.
    stimulus_process : process
    begin
        -- ADD: check a normal sum and a sum that produces carry out.
        A <= x"12";
        B <= x"23";
        Cin <= '1';
        Op <= "000";
        wait for 1 ns;
        assert Result = x"35" and Cout = '0'
            report "ADD normal-sum test failed" severity error;

        A <= x"FF";
        B <= x"01";
        wait for 1 ns;
        assert Result = x"00" and Cout = '1'
            report "ADD carry-out test failed" severity error;

        -- ADDC: check carry-in both clear and set, including overflow.
        A <= x"FE";
        B <= x"01";
        Cin <= '0';
        Op <= "001";
        wait for 1 ns;
        assert Result = x"FF" and Cout = '0'
            report "ADDC with carry-in clear failed" severity error;

        Cin <= '1';
        wait for 1 ns;
        assert Result = x"00" and Cout = '1'
            report "ADDC with carry-in set failed" severity error;

        -- XOR: verify the bitwise result and preservation of carry-in.
        A <= x"5A";
        B <= x"A5";
        Cin <= '1';
        Op <= "010";
        wait for 1 ns;
        assert Result = x"FF" and Cout = '1'
            report "XOR test failed" severity error;

        -- LOAD: verify B is selected and carry-in is preserved.
        A <= x"12";
        B <= x"34";
        Cin <= '0';
        Op <= "011";
        wait for 1 ns;
        assert Result = x"34" and Cout = '0'
            report "LOAD test failed" severity error;

        -- HOLD: verify A is selected and carry-in is preserved.
        A <= x"87";
        B <= x"34";
        Cin <= '1';
        Op <= "100";
        wait for 1 ns;
        assert Result = x"87" and Cout = '1'
            report "HOLD test failed" severity error;

        -- Invalid operation codes must produce zero result and carry.
        Op <= "111";
        wait for 1 ns;
        assert Result = x"00" and Cout = '0'
            report "Invalid-operation test failed" severity error;

        report "ALU tests completed successfully" severity note;
        wait;
    end process;
end behavioral;
