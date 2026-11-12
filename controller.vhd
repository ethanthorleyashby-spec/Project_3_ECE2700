-- Ethan Ashby and Brayden Shampton
-- Project 3 | MPU with Controller
--  11/12/26



--Library Declarations
library ieee.std_logic_1164.all;
use iee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

--entity Declarations
entity controller is 
    port map(data_bus : in  std_logic_vector(7 downto 0);
        opcode : out std_logic_vector(2 downto 0);
        write, fetch, read : out std_logic;
    );

-- Behavior Declarations

architecture behavioral of controller is
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



begin
case data_bus is
    when op_halt =>

    when op_jmp => 

    when

end behavioral;
