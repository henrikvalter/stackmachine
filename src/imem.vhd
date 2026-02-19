
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;

use std.textio.all;
use ieee.std_logic_textio.all;


entity imem is
    generic (
        MEMFILE: string := "programs/simple.mif";
        ADDR_WIDTH: natural := 8;
        DATA_WIDTH: natural := 32
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        enable : in std_logic;
        data_out_offset0 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out_offset1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out_offset2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out_offset3 : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end;

architecture arch of imem is
    constant MEM_DEPTH : natural := 2**ADDR_WIDTH;
    type memory_array_t is array (0 to MEM_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

    impure function init_memory_wfile(mif_file_name : in string) return memory_array_t is
        file mif_file      : text open read_mode is mif_file_name;
        variable mif_line  : line;
        variable temp_bv   : bit_vector(data_width-1 downto 0);
        variable temp_mem  : memory_array_t := (others => (others => '0')); -- fill with zeros
        variable idx       : integer := 0;
    begin
        while not endfile(mif_file) and idx < memory_array_t'length loop
            readline(mif_file, mif_line);
            if mif_line'length = 0 then
                next;
            elsif mif_line.all(1) = '-' then
                next;
            end if;
            read(mif_line, temp_bv);
            temp_mem(idx) := to_stdlogicvector(temp_bv);
            idx := idx + 1;
        end loop;
    return temp_mem;
    end function;

    signal memory: memory_array_t := init_memory_wfile(MEMFILE);
begin
    process (clk)
        begin
        if rising_edge(clk) then
            if reset = '1' then
                memory <= init_memory_wfile(MEMFILE);
                -- memory <= (others => (others => '0'));
                data_out_offset0 <= (others => '0');
                data_out_offset1 <= (others => '0');
                data_out_offset2 <= (others => '0');
                data_out_offset3 <= (others => '0');
            elsif enable='0' then
                data_out_offset0 <= (others => '0');
                data_out_offset1 <= (others => '0');
                data_out_offset2 <= (others => '0');
                data_out_offset3 <= (others => '0');
            else
                data_out_offset0 <= memory(0+to_integer(unsigned(address)));
                data_out_offset1 <= memory(1+to_integer(unsigned(address)));
                data_out_offset2 <= memory(2+to_integer(unsigned(address)));
                data_out_offset3 <= memory(3+to_integer(unsigned(address)));
            end if;
        end if;
    end process;
end;




