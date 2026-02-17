
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;

entity adder is
    generic (
        WIDTH : positive := 32
    );
    port (
        a    : in std_logic_vector(WIDTH-1 downto 0);
        b    : in std_logic_vector(WIDTH-1 downto 0);
        op   : in adder_op_t;
        s    : out std_logic_vector(WIDTH-1 downto 0);
        cout : out std_logic
    );
end;

architecture rca of adder is
    signal b_in : std_logic_vector(WIDTH-1 downto 0);
    signal carry_vec : std_logic_vector(WIDTH downto 0);
begin
    b_in <= b when op=ADDER_ADD else not b;
    -- fa[i] reads from carry_vec[i] and writes to carry_vec[j]
    carry_vec(0) <= '0' when op=ADDER_ADD else '1';
    cout <= carry_vec(WIDTH);
    gen_fa_i: for i in 0 to WIDTH-1 generate
        fa_i: entity work.fa port map(
            a => a(i),
            b => b_in(i),
            cin => carry_vec(i),
            s => s(i),
            cout => carry_vec(i+1)
        );
    end generate gen_fa_i;
end;