library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mypkg is

    -- constant ADDER_ADD : std_logic := '0';
    -- constant ADDER_SUB : std_logic := '1';

    type adder_op_t is (ADDER_ADD, ADDER_SUB);
    type mem_op_t is (MEM_READ, MEM_WRITE);


end package;
