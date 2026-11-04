-- Ethan Ashby and Brayden Shampton Project 2
-- Test bench for the MPU address unit

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;

-- Test bench entity declaration
entity tb_addr_unit is
end tb_addr_unit;

-- Test bench architecture
architecture behavioral of tb_addr_unit is
    constant clk_time : time := 20 ns;

    signal clk      : std_logic := '0';
    signal ld_pc    : std_logic := '0';
    signal ld_mar   : std_logic := '0';
    signal inc_pc   : std_logic := '0';
    signal fetch    : std_logic := '0';
    signal rst      : std_logic := '0';
    signal data     : std_logic_vector(7 downto 0) := (others => '0');
    signal addr_out : std_logic_vector(7 downto 0);
begin
    -- Generate the clock used by the address-unit registers.
    clk_process : process
    begin
        clk <= '0';
        wait for clk_time / 2;
        clk <= '1';
        wait for clk_time / 2;
    end process;

    -- Instantiate the address unit under test.
    uut : entity work.addr_unit
        port map (
            clk      => clk,
            ld_pc    => ld_pc,
            ld_mar   => ld_mar,
            inc_pc   => inc_pc,
            fetch    => fetch,
            rst      => rst,
            data     => data,
            addr_out => addr_out
        );

    -- Apply register-control inputs and check the selected address output.
    stimulus_process : process
    begin
        -- Assert reset and verify that the selected register is cleared.
        rst <= '1';
        fetch <= '1';
        wait for 1 ns;
        assert addr_out = x"00"
            report "Reset did not clear the PC output" severity error;

        rst <= '0';
        wait for 1 ns;
        fetch <= '0';
        wait for 1 ns;
        assert addr_out = x"00"
            report "Reset did not clear the MAR output" severity error;

        -- Load the MAR and verify it appears when MAR is selected.
        data <= x"5A";
        ld_mar <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert addr_out = x"5A"
            report "Loading the MAR failed" severity error;
        ld_mar <= '0';

        -- Load the PC while confirming MAR remains independently stored.
        data <= x"AB";
        ld_pc <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert addr_out = x"5A"
            report "Loading the PC changed the MAR output" severity error;
        ld_pc <= '0';
        fetch <= '1';
        wait for 1 ns;
        assert addr_out = x"AB"
            report "Loading or selecting the PC failed" severity error;

        -- Increment the PC and verify the address output updates.
        inc_pc <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert addr_out = x"AC"
            report "Incrementing the PC failed" severity error;
        inc_pc <= '0';

        -- Verify that the PC holds its value when no PC control is active.
        wait until rising_edge(clk);
        wait for 1 ns;
        assert addr_out = x"AC"
            report "The PC changed while idle" severity error;

        -- Verify PC load has priority over simultaneous increment.
        data <= x"10";
        ld_pc <= '1';
        inc_pc <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert addr_out = x"10"
            report "PC load did not take priority over increment" severity error;
        ld_pc <= '0';
        inc_pc <= '0';

        -- Load MAR while PC is selected, then verify both stored values.
        data <= x"37";
        ld_mar <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert addr_out = x"10"
            report "Loading the MAR changed the selected PC output" severity error;
        ld_mar <= '0';
        fetch <= '0';
        wait for 1 ns;
        assert addr_out = x"37"
            report "Selecting the MAR output failed" severity error;

        -- Verify that incrementing 0xFF wraps around to 0x00.
        fetch <= '1';
        data <= x"FF";
        ld_pc <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        ld_pc <= '0';
        inc_pc <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        assert addr_out = x"00"
            report "PC increment overflow did not wrap to zero" severity error;
        inc_pc <= '0';

        -- Verify reset clears both registers after they contain nonzero data.
        rst <= '1';
        wait for 1 ns;
        assert addr_out = x"00"
            report "Reset did not clear the PC after loading" severity error;
        fetch <= '0';
        wait for 1 ns;
        assert addr_out = x"00"
            report "Reset did not clear the MAR after loading" severity error;

        report "Address-unit tests completed successfully" severity note;
        wait;
    end process;
end behavioral;
