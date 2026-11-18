--Ethan Ashby and Brayden Shampton Project 2 
--ALU for Project 2 MPu

--library declarations
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Entity Declarations
entity ALU is
    port(
        A      : in  std_logic_vector(7 downto 0); -- accumulator
        B      : in  std_logic_vector(7 downto 0); -- memory/immediate
        Cin    : in  std_logic;                    -- carry in
        Op     : in  std_logic_vector(2 downto 0);

        Result : out std_logic_vector(7 downto 0);
        Cout   : out std_logic 
    );
end ALU;

architecture behavioral of ALU is

    constant alu_add : std_logic_vector(2 downto 0) := "000";
    constant alu_addc : std_logic_vector(2 downto 0) := "001";
    constant alu_xor : std_logic_vector(2 downto 0) := "010";
    constant alu_load : std_logic_vector(2 downto 0) := "011";
    constant alu_hold : std_logic_vector(2 downto 0) := "100";

begin

process(A, B, Cin, Op)
    variable temp : unsigned(8 downto 0);
begin

    case Op is

        when alu_add =>     -- ADD
            temp := ('0' & unsigned(A))
                  + ('0' & unsigned(B));

            Result <= std_logic_vector(temp(7 downto 0));
            Cout   <= temp(8);

        when alu_addc =>     -- ADDC
            temp := ('0' & unsigned(A))
                  + ('0' & unsigned(B));

            if Cin = '1' then
                temp := temp + 1;
            end if;

            Result <= std_logic_vector(temp(7 downto 0));
            Cout   <= temp(8);

        when alu_xor =>     -- XOR
            Result <= A xor B;
            Cout   <= Cin;   -- carry unchanged

        when alu_load =>     -- LOAD
            Result <= B;
            Cout   <= Cin;   -- carry unchanged

        when alu_hold =>     -- HOLD
            Result <= A;
            Cout   <= Cin;   -- carry unchanged

        when others =>
            Result <= (others => '0');
            Cout   <= '0';

    end case;

end process;

end behavioral;