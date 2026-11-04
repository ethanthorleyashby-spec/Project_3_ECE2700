-- Ethan Ashby and Brayden Shampton Project 2
-- Top-level MPU datapath. The micro2 entity name matches the supplied test bench.

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;

-- Top-level entity used by the professor-provided TestMicro2 bench
entity micro2 is
    port (
        clk    : in    std_logic;
        rst    : in    std_logic;
        rd     : in    std_logic;
        wr     : in    std_logic;
        fetch  : in    std_logic;
        ld_pc  : in    std_logic;
        ld_mar : in    std_logic;
        inc_pc : in    std_logic;
        op     : in    std_logic_vector(2 downto 0);
        addr   : out   std_logic_vector(7 downto 0);
        data   : inout std_logic_vector(7 downto 0)
    );
end micro2;

architecture behavioral of micro2 is
    -- Operation codes shared with the professor-provided test bench
    constant add  : std_logic_vector(2 downto 0) := "000";
    constant addc : std_logic_vector(2 downto 0) := "001";
    constant exor : std_logic_vector(2 downto 0) := "010";
    constant load : std_logic_vector(2 downto 0) := "011";
    constant hold : std_logic_vector(2 downto 0) := "100";

    signal accumulator : std_logic_vector(7 downto 0);
    signal alu_result  : std_logic_vector(7 downto 0);
    signal accumulator_enable : std_logic;
    signal carry_flag  : std_logic := '0';
    signal alu_carry   : std_logic;
begin
    -- Drive the shared data bus only during a memory write.
    data <= accumulator when wr = '1' else (others => 'Z');
    accumulator_enable <= '0' when op = hold else '1';

    -- The address unit selects the PC or MAR and manages both registers.
    address_unit : entity work.addr_unit
        port map (
            clk      => clk,
            ld_pc    => ld_pc,
            ld_mar   => ld_mar,
            inc_pc   => inc_pc,
            fetch    => fetch,
            rst      => rst,
            data     => data,
            addr_out => addr
        );

    -- The ALU combines the accumulator with the value on the memory data bus.
    arithmetic_unit : entity work.ALU
        port map (
            A      => accumulator,
            B      => data,
            Cin    => carry_flag,
            Op     => op,
            Result => alu_result,
            Cout   => alu_carry
        );

    -- Update the accumulator for every operation except HOLD.
    accumulator_register : entity work.dFF_8
        port map (
            clk => clk,
            rst => rst,
            ce  => accumulator_enable,
            d   => alu_result,
            q   => accumulator
        );

    -- Addition operations update carry; all other operations preserve it.
    carry_register : process (clk, rst)
    begin
        if rst = '1' then
            carry_flag <= '0';
        elsif rising_edge(clk) then
            if op = add or op = addc then
                carry_flag <= alu_carry;
            end if;
        end if;
    end process;
end behavioral;

-- Keep the MPU entity available as an alias for projects using that name.
library ieee;
use ieee.std_logic_1164.all;

entity MPU is
    port (
        clk    : in    std_logic;
        rst    : in    std_logic;
        rd     : in    std_logic;
        wr     : in    std_logic;
        fetch  : in    std_logic;
        ld_pc  : in    std_logic;
        ld_mar : in    std_logic;
        inc_pc : in    std_logic;
        op     : in    std_logic_vector(2 downto 0);
        addr   : out   std_logic_vector(7 downto 0);
        data   : inout std_logic_vector(7 downto 0)
    );
end MPU;

architecture compatibility of MPU is
begin
    datapath : entity work.micro2
        port map (
            clk    => clk,
            rst    => rst,
            rd     => rd,
            wr     => wr,
            fetch  => fetch,
            ld_pc  => ld_pc,
            ld_mar => ld_mar,
            inc_pc => inc_pc,
            op     => op,
            addr   => addr,
            data   => data
        );
end compatibility;
