--Ethan Ashby and Brayden Shampton Project 2 
--Address Unit for MPU

--library declarations
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--Entity Declarations
entity addr_unit is
    port(
        clk, ld_pc, ld_mar, inc_pc, fetch, rst : in std_logic;
        data : in std_logic_vector(7 downto 0);
        addr_out: out std_logic_vector(7 downto 0)
    );
end addr_unit;

--Architecture Declarations
architecture behavioral of addr_unit is
    signal PC_out : std_logic_vector(7 downto 0);
    signal MAR_out : std_logic_vector(7 downto 0);
begin


    process (CLK, rst) is      --sequential operations
    begin
        if rst = '1' then
            PC_out <= (others => '0');
            MAR_out <=(others => '0');
        elsif rising_edge(clk) then
            if ld_mar = '1' then
                mar_out <= data;
            end if;
            if ld_pc = '1' then
                PC_out <= data;
            elsif inc_pc = '1' then
                pc_out<= std_logic_vector(unsigned(pc_out)+to_unsigned(1,pc_out'length));
            end if;
        end if;
    end process;

-- Select the PC during fetch, otherwise select the MAR.
addr_out <= PC_out when fetch = '1' else MAR_out;
    
end behavioral;