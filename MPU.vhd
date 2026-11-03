--Ethan Ashby and Brayden Shampton Project 2 
--Top level MPU

--library Declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



--entity declarations
entity MPU is
    port( 
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        rd : in STD_LOGIC;
        wr : in STD_LOGIC;
        fetch : in STD_LOGIC;
        ld_pc : in STD_LOGIC;
        ld_mar : in STD_LOGIC;
        inc_pc : in STD_LOGIC;
        op : in STD_LOGIC_VECTOR (2 downto 0);
        addr : out STD_LOGIC_VECTOR (7 downto 0);
        data : inout STD_LOGIC_VECTOR (7 downto 0));
    end mpu;


--Architecture Declarations
architecture behavioral of MPU is
    constant add: std_logic_vector(2 downto 0) := "000";
    constant addc: std_logic_vector(2 downto 0) := "001";
    constant exor: std_logic_vector(2 downto 0) := "010";
    constant load: std_logic_vector(2 downto 0) := "011";
    constant hold: std_logic_vector(2 downto 0) := "100";

    component addr_unit is
        port (clk, ld_pc, inc_pc : in std_logic;
            data : in std_logic_vector(7 downto 0);
            pc_out : out std_logic_vector(7 downto 0));
    end component;

    component ALU is 
        port(
            A      : in  std_logic_vector(7 downto 0); -- accumulator
            B      : in  std_logic_vector(7 downto 0); -- memory/immediate
            Cin    : in  std_logic;                    -- carry in
            Op     : in  std_logic_vector(2 downto 0);
            Result : out std_logic_vector(7 downto 0);
            Cout   : out std_logic 
        );
    end component;
    component dFF_8 is
        port (
            clk, rst, ce : in std_logic;
            d : in std_logic_vector (7 downto 0);
            q : out std_logic_vector(7 downto 0)
        );
    end component;
    signal internal_data : std_logic_vector(7 downto 0);
    signal result_ALU : std_logic_vector(7 downto 0);
    signal result_Acc : std_logic_vector(7 downto 0);
    signal load_signal: std_logic;
    signal Ci_MPU: std_logic;

begin

    process (CLK, rst)
    begin 
        if rising_edge(CLK) then
            u_ALU : ALU port map (
                A => result,
                B => internal_data,
                Cin => Ci_MPU,
                Op => Op,
                Result => result_ALU,
                Cout =>
            );

            addr_unit : addr_unit port map ();
            accumulator : dFF_8 port map ();


        
        end if;
    end process;

end behavioral;