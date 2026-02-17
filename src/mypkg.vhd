library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mypkg is

    -- constant ADDER_ADD : std_logic := '0';
    -- constant ADDER_SUB : std_logic := '1';

    type adder_op_t is (ADDER_ADD, ADDER_SUB);

    type mem_op_t is (MEM_READ, MEM_WRITE);

    type stack_op_t is (STACK_PEEK, STACK_POP, STACK_PUSH);

    subtype instruction_t is std_logic_vector(31 downto 0);
    -- Opcodes (32-bit constants)
    constant OP_IPUSH : instruction_t := x"00000000";
    constant OP_IADD  : instruction_t := x"00000001";

end package;
