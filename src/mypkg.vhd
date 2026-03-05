library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mypkg is

    type adder_op_t is (ADDER_ADD, ADDER_SUB);

    type mem_op_t is (MEM_READ, MEM_WRITE);

    type stack_op_t is (STACK_PEEK, STACK_POP, STACK_PUSH);

    subtype instruction_t is std_logic_vector(31 downto 0);
    constant OP_NOP                 : instruction_t := x"00000000";
    constant OP_IPUSH               : instruction_t := x"00000001";
    constant OP_IADD                : instruction_t := x"00000002";
    constant OP_IPRINT              : instruction_t := x"00000003";
    constant OP_BRANCH              : instruction_t := x"00000004";
    constant OP_DUP                 : instruction_t := x"00000005";
    constant OP_BRANCH_IF_EQUAL     : instruction_t := x"00000006";
    constant OP_BRANCH_IF_NOT_EQUAL : instruction_t := x"00000007";
    constant OP_ILOAD               : instruction_t := x"00000008";
    constant OP_ISTORE              : instruction_t := x"00000009";
    constant OP_CALL                : instruction_t := x"0000000A";
    constant OP_RETURN              : instruction_t := x"0000000B";
    constant OP_POP                 : instruction_t := x"0000000C";
    constant OP_ISUB                : instruction_t := x"0000000D";
    constant OP_EXIT                : instruction_t := x"FFFFFFFF";

    type stackmachine_state_t is (
        STATE_INIT,
        STATE_FETCH,
        STATE_DECODE,
        STATE_EXEC1,
        STATE_EXEC2,
        STATE_EXEC3
    );

end package;
