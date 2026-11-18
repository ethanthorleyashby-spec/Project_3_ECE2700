----------------------------------------------------------------------------------
-- Company: Weber State University
-- Engineer: Fon Brown
-- 
-- Create Date: 08/02/2023 02:43:25 PM
-- Module Name: TestMicro3 - Behavioral
-- Description: Simple microprocessor test bench for Project 3

-- Revision:
-- Revision 0.01 - File Created
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TestMicro3 is
--  Port ( );
end TestMicro3;

architecture Behavioral of TestMicro3 is
    component micro3 is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rd  : out STD_LOGIC;
           wr  : out STD_LOGIC;
           addr : out STD_LOGIC_VECTOR (7 downto 0);
           data : inout STD_LOGIC_VECTOR (7 downto 0));
    end component;

    constant op_halt:  std_logic_vector(7 downto 0) := X"00";
	constant op_jmp:   std_logic_vector(7 downto 0) := X"01";
	constant op_jc:    std_logic_vector(7 downto 0) := X"02";
	constant op_jnc:   std_logic_vector(7 downto 0) := X"03";
	constant op_ldi:   std_logic_vector(7 downto 0) := X"10";
	constant op_addi:  std_logic_vector(7 downto 0) := X"11";
	constant op_adci:  std_logic_vector(7 downto 0) := X"12";
	constant op_xori:  std_logic_vector(7 downto 0) := X"13";
	constant op_ldm:   std_logic_vector(7 downto 0) := X"20";
	constant op_addm:  std_logic_vector(7 downto 0) := X"21";
	constant op_adcm:  std_logic_vector(7 downto 0) := X"22";
	constant op_xorm:  std_logic_vector(7 downto 0) := X"23";
	constant op_stm:   std_logic_vector(7 downto 0) := X"30";

	type ram_type is array (0 to 255) of STD_LOGIC_VECTOR (7 downto 0);
	signal ram: ram_type := (
	op_ldi,  X"9E", -- 00 LDI  9E
	op_addi, X"AA", -- 02 ADDI AA (A = 48, C=1)
	op_stm,  X"3F", -- 04 STM  3F
	op_adcm, X"3F", -- 06 ADCM 3F (A = 91, C = 0)
	op_stm,  X"3F", -- 08 STM  3F
	op_adci, X"7B", -- 0A ADCI 7B (A = 0C, C = 1)
	op_xorm, X"3F", -- 0C XORM 3F (A = 9D, C = 1)
	op_adci, X"4A", -- 0E ADCI 4A (A = E8, C = 0)
	op_stm,  X"3E", -- 10 STM  3E
	op_ldm,  X"3F", -- 12 LDM  3F
	op_xori, X"FF", -- 14 XORI FF
	op_addm, X"3E", -- 16 ADDM 3E (C if [3E]>[3F])
	op_jc,   X"28", -- 18 JC   28
	op_ldm,  X"3E", -- 1A LDM  3E
	op_xori, X"FF", -- 1C XORI FF
	op_addm, X"3F", -- 1E ADDM 3F (C if [3F]>[3E])
	op_jnc,  X"2E", -- 20 JNC  2E (done)
	op_addi, X"01", -- 22 ADDI 01
	op_stm,  X"3F", -- 24 STM  3F
	op_jmp,  X"12", -- 26 JMP  12 (top of loop)
	op_addi, X"01", -- 28 ADDI 01
	op_stm,  X"3E", -- 2A STM  3E
	op_jmp,  X"12", -- 2C JMP  12 (top of loop)
	op_halt,        -- 2E HALT
	others=>X"FF" );
	
	signal rd, wr, rst, clk: std_logic;
	signal addr, data: std_logic_vector(7 downto 0);

begin
    -- unit under test
    uut: micro3 port map(clk=>clk, rst=>rst, rd=>rd, wr=>wr, addr=>addr, data=>data);
    
    -- model memory
	process (clk)
	begin
	  if rising_edge(clk) then
	    if wr = '1' then
	      ram(to_integer(unsigned(addr)))<=data;
	    end if;
	  end if;
	end process;

	data <= ram(to_integer(unsigned(addr))) when rd = '1' else "ZZZZZZZZ";
	
	-- clock and reset stimulus
	process
	begin
	  rst<='1'; clk<='0';
	  wait for 2ns;
	  rst<='0';
	  for i in 1 to 135 loop
	    wait for 3 ns;
	    clk <= '1';
	    wait for 2 ns;
	    clk <= '0';
	  end loop;
	  wait;
	end process;

end Behavioral;
