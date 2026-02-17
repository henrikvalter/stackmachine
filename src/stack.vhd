
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;

entity stack is
    generic (
        ADDR_WIDTH: natural := 8;
        DATA_WIDTH: natural := 32
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        op : in stack_op_t;
        enable : in std_logic;
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        stack_error : out std_logic
    );
end;

architecture arch of stack is
    constant MEM_DEPTH : natural := 2**ADDR_WIDTH;
    type stack_memory_array_t is array (0 to MEM_DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal memory: stack_memory_array_t;

    signal head : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal head_m1 : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal head_p1 : std_logic_vector(ADDR_WIDTH-1 downto 0);
begin
    p1_adder: entity work.adder(rca)
        generic map(WIDTH => ADDR_WIDTH)
        port map (a => head,
                  b => std_logic_vector(to_signed(1, ADDR_WIDTH)),
                  op => ADDER_ADD,
                  s => head_p1,
                  cout => open);
    m1_adder: entity work.adder(rca)
        generic map(WIDTH => ADDR_WIDTH)
        port map (a => head,
                  b => std_logic_vector(to_signed(1, ADDR_WIDTH)),
                  op => ADDER_SUB,
                  s => head_m1,
                  cout => open);

    process (clk)
        begin
        if rising_edge(clk) then
            if reset = '1' then
                head <= (others => '0');
                data_out <= (others => '0');
                stack_error <= '0';
            elsif enable='0' then
                head <= head;
                data_out <= (others => '0');
                stack_error <= '0';
            -- Trying to peek when head is 0 ==> Error
            elsif op=STACK_PEEK and ((or head)='0') then
                head <= head;
                data_out <= (others => '0');
                stack_error <= '1';
            elsif op=STACK_PEEK then
                head <= head;
                data_out <= memory(to_integer(unsigned(head_m1)));
                stack_error <= '0';
            -- Trying to pop when head is 0 ==> Error
            elsif op=STACK_POP and ((or head)='0') then
                head <= head;
                data_out <= (others => '0');
                stack_error <= '1';
            elsif op=STACK_POP then
                head <= head_m1;
                data_out <= memory(to_integer(unsigned(head_m1)));
                stack_error <= '0';
            -- Trying to push when head is max ==> Error
            elsif op=STACK_PUSH and ((and head)='1') then
                head <= head;
                data_out <= (others => '0');
                stack_error <= '1';
            elsif op=STACK_PUSH then
                head <= head_p1;
                data_out <= (others => '0');
                memory(to_integer(unsigned(head))) <= data_in;
                stack_error <= '0';
            -- Should never be reached
            else
                head <= head;
                data_out <= (others => '0');
                stack_error <= '1';
            end if;
        end if;
    end process;
end;

