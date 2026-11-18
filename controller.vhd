-- Ethan Ashby and Brayden Shampton
-- Project 3 | MPU with Controller
--  11/12/26



--Library Declarations
library ieee;
use ieee.std_logic_1164.all;

--entity Declarations
entity controller is 
    port(
        --Inputs
        clk      : in std_logic;
        rst      : in std_logic;
        c_flag   : in std_logic;
        data_bus : in  std_logic_vector(7 downto 0);
        --Outputs
        write  : out std_logic;
        fetch  : out std_logic;
        read   : out std_logic;
        alu_opcode : out std_logic_vector(2 downto 0);
        ld_pc  : out std_logic;
        ld_mar : out std_logic;
        inc_pc : out std_logic

    );
end controller;

-- Behavior Declarations

architecture behavioral of controller is
--Define MPU States
type state_type is (
    ST_FETCH, ST_DECODE, ST_HALT,
    ST_JMP, ST_JC, ST_JNC,
    ST_LDI, ST_ADDI, ST_ADCI, ST_XORI,
    ST_LDM1, ST_LDM2,  
    ST_ADDM1, ST_ADDM2, 
    ST_ADCM1, ST_ADCM2, 
    ST_XORM1, ST_XORM2,
    ST_STM1, ST_STM2
);
signal current_state, next_state : state_type;

-- Op Contstants
constant op_halt: std_logic_vector(7 downto 0) := X"00";
constant op_jmp: std_logic_vector(7 downto 0) := X"01";
constant op_jc: std_logic_vector(7 downto 0) := X"02";
constant op_jnc: std_logic_vector(7 downto 0) := X"03";
constant op_ldi: std_logic_vector(7 downto 0) := X"10";
constant op_addi: std_logic_vector(7 downto 0) := X"11";
constant op_adci: std_logic_vector(7 downto 0) := X"12";
constant op_xori: std_logic_vector(7 downto 0) := X"13";
constant op_ldm: std_logic_vector(7 downto 0) := X"20";
constant op_addm: std_logic_vector(7 downto 0) := X"21";
constant op_adcm: std_logic_vector(7 downto 0) := X"22";
constant op_xorm: std_logic_vector(7 downto 0) := X"23";
constant op_stm: std_logic_vector(7 downto 0) := X"30";
constant alu_add : std_logic_vector(2 downto 0) := "000";
constant alu_addc : std_logic_vector(2 downto 0) := "001";
constant alu_xor : std_logic_vector(2 downto 0) := "010";
constant alu_load : std_logic_vector(2 downto 0) := "011";
constant alu_hold : std_logic_vector(2 downto 0) := "100";



begin

--State register
    process (clk, rst)
    begin
        if rst = '1' then
            current_state<=ST_FETCH;
        elsif rising_edge(clk) then
            current_state<=next_state;
        end if;
    end process;

--Next State decoder
    process(current_state, data_bus, c_flag)
    begin
        --default assignments
        read  <= '0';
        write <= '0';
        fetch <= '0';
        ld_pc <= '0';
        ld_mar <= '0';
        inc_pc <= '0';
        alu_opcode <= alu_hold;
        next_state <= ST_FETCH;

        --Fetch Stage!!!
        case current_state is
            when ST_FETCH =>
                read <= '1';
                fetch <= '1';
                next_state <= ST_DECODE;

            -- Decode Stage!!!
            when ST_DECODE =>
                read   <= '1';
                fetch  <= '1';
                inc_pc <= '1';
                case data_bus is
                    when op_halt => next_state <= ST_HALT;

                    when op_jmp => next_state <= ST_JMP;
                    when op_jc => next_state <= ST_JC;
                    when op_jnc =>next_state <= ST_JNC;

                    when op_ldi => next_state <= ST_LDI;

                    when op_stm => next_state <= ST_STM1;

                    when op_addi => next_state <= ST_ADDI;
                    when op_adci => next_state <= ST_ADCI;
                    when op_xori => next_state <= ST_XORI;
                    when op_ldm => next_state <= ST_LDM1;
                    when op_addm => next_state <= ST_ADDM1;
                    when op_adcm => next_state <= ST_ADCM1;
                    when op_xorm => next_state <= ST_XORM1;
                    when others => next_state <= ST_FETCH;

                end case;
            
            --Execute Stage!!!
            when ST_HALT => 
                next_state <= ST_HALT;
                alu_opcode <= alu_hold;
            when ST_JMP => 
                read <= '1';
                fetch <='1';
                ld_pc <= '1';
                inc_pc <= '0';
                alu_opcode <= alu_hold;
                next_state <= ST_FETCH;
            when ST_JC  =>
                if c_flag = '1' then 
                    read <= '1';
                    fetch <='1';
                    ld_pc <= '1'; 
                else
                    inc_pc <='1';
                end if;
                alu_opcode <= alu_hold;
                next_state <= ST_FETCH;
            when ST_JNC =>
                if c_flag = '0' then 
                    read <= '1';
                    fetch <= '1';
                    ld_pc <= '1';
                else
                    inc_pc <='1'; 
                end if;
                alu_opcode <= alu_hold;
                next_state <= ST_FETCH;
            when ST_LDI =>
                read       <= '1';
                fetch      <= '1';
                inc_pc     <= '1';
                alu_opcode  <= alu_load;
                next_state <= ST_FETCH;
            when ST_ADDI =>
                read <= '1';
                fetch <= '1';
                inc_pc <= '1';
                alu_opcode <= alu_add;
                next_state <= ST_FETCH;
            when ST_ADCI =>
                read <= '1';
                fetch <= '1';
                inc_pc <= '1';
                alu_opcode <= alu_addc;
                next_state <= ST_FETCH;
            when ST_XORI =>
                read <= '1';
                fetch <= '1';
                inc_pc <= '1';
                alu_opcode <= alu_xor;
                next_state <= ST_FETCH;
            when ST_LDM1  =>
                read <= '1';
                fetch <= '1';
                ld_mar <= '1';
                inc_pc <= '1';
                next_state <=   ST_LDM2;
                alu_opcode <= alu_hold;
            when ST_LDM2 =>
                read <= '1';
                fetch <= '0';
                alu_opcode <= alu_load;
                next_state <= ST_FETCH;
            when ST_ADDM1 =>
                read <= '1';
                fetch <= '1';
                ld_mar <= '1';
                inc_pc <= '1';
                alu_opcode <= alu_hold;
                next_state <= ST_ADDM2;
            when ST_ADDM2 =>
                read <= '1';
                fetch <= '0';
                next_state <= ST_FETCH;
                alu_opcode <= alu_add;
            when ST_ADCM1 => 
                read <= '1';
                fetch <= '1';
                ld_mar <= '1';
                inc_pc <= '1';
                alu_opcode <= alu_hold;
                next_state <= ST_ADCM2;
            when ST_ADCM2 =>
                read <= '1';
                fetch <= '0';
                next_state <= ST_FETCH;
                alu_opcode <= alu_addc;
            when ST_XORM1 =>
                read <= '1';
                fetch <= '1';
                ld_mar <= '1';
                inc_pc <= '1';
                alu_opcode <= alu_hold;
                next_state <= ST_XORM2;
            when ST_XORM2 =>
                read <= '1';
                fetch <= '0';
                next_state <= ST_FETCH;
                alu_opcode <= alu_xor;
            when ST_STM1 =>
                read <= '1';
                fetch <= '1';
                ld_mar <= '1';
                inc_pc <= '1';
                next_state <= ST_STM2;
            when ST_STM2 =>
                write <= '1';
                fetch <= '0';
                alu_opcode <= alu_hold;
                next_state <= ST_FETCH;
            when others =>
                next_state <= ST_FETCH;

        end case;
    end process;
end behavioral;
