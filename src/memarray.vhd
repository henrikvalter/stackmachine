
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;

entity memarray is
    generic (
        ADDR_WIDTH: natural := 8;
        DATA_WIDTH: natural := 32
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        op : in mem_op_t;
        enable : in std_logic;
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end;

architecture arch of memarray is
    constant MEM_DEPTH : natural := 2**ADDR_WIDTH;
    type memory_array_t is array (0 to MEM_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal memory: memory_array_t;
begin
    process (clk)
        begin
        if rising_edge(clk) then
            if reset = '1' then
                memory <= (others => (others => '0'));
                data_out <= (others => '0');
            elsif enable='1' and op=MEM_READ then
                data_out <= memory(to_integer(unsigned(address)));
            elsif enable='1' and op=MEM_WRITE then
                memory(to_integer(unsigned(address))) <= data_in;
                data_out <= (others => '0');
            else
                data_out <= (others => '0');
            end if;
        end if;
    end process;
end;


