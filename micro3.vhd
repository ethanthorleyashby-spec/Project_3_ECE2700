-- Ethan Ashby and Brayden Shampton Project 2
-- Top-level MPU datapath. The micro3 entity name matches the supplied test bench.

-- Library declarations
library ieee;
use ieee.std_logic_1164.all;

-- Top-level entity used by the professor-provided TestMicro3 bench
entity micro3 is
    port (
        clk    : in    std_logic;
        rst    : in    std_logic;
        rd   : out    std_logic;
        wr   : out   std_logic;
        
        addr   : out   std_logic_vector(7 downto 0);
        data   : inout std_logic_vector(7 downto 0)
    );
end micro3;

architecture behavioral of micro3 is
    -- Operation codes shared with the professor-provided test bench
    constant add  : std_logic_vector(2 downto 0) := "000";
    constant addc : std_logic_vector(2 downto 0) := "001";
    constant exor : std_logic_vector(2 downto 0) := "010";
    constant load : std_logic_vector(2 downto 0) := "011";
    constant hold : std_logic_vector(2 downto 0) := "100";

    signal ld_pc       : std_logic;
    signal ld_mar      : std_logic;
    signal inc_pc      : std_logic;
    signal fetch       : std_logic;
    signal alu_opcode          : std_logic_vector(2 downto 0);
    signal accumulator : std_logic_vector(7 downto 0);
    signal alu_result  : std_logic_vector(7 downto 0);
    signal accumulator_enable : std_logic;
    signal carry_flag  : std_logic := '0';
    signal alu_carry   : std_logic;
begin

    -- Drive the shared data bus only during a memory write.
    data <= accumulator when wr = '1' else (others => 'Z');
    accumulator_enable <= '0' when alu_opcode = alu_hold else '1';

    --Cotroller reads the input bus and then assigns write, fetch, read, and opcode as needed. Declared and instantiated.
    controller : entity work.controller
        port map (
            clk      => clk,
            rst      => rst,
            c_flag   => carry_flag,
            data_bus => data,
            write    => wr,
            fetch    => fetch,
            read     => rd,
            alu_opcode => alu_opcode,
            ld_pc    => ld_pc,
            ld_mar   => ld_mar,
            inc_pc   => inc_pc
        );

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
            op     => alu_opcode,
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
            if alu_opcode = add or alu_opcode = addc then
                carry_flag <= alu_carry;
            end if;
        end if;
    end process;
end behavioral;
