library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;
use ieee.math_real.all;

entity adder_tb is
end;

architecture arch of adder_tb is
    constant WIDTH : positive := 32;
    constant LOOPMAX : positive := 100000;
    signal a : std_logic_vector(WIDTH-1 downto 0);
    signal b : std_logic_vector(WIDTH-1 downto 0);
    signal op : adder_op_t;
    signal s : std_logic_vector(WIDTH-1 downto 0);
    signal cout : std_logic;
begin
    dut: entity work.adder(rca)
        generic map(WIDTH => WIDTH)
        port map (a => a, b => b, op => op, s => s, cout => cout);
    
    stimulus_process: process
        variable var_a : integer;
        variable var_b : integer;
        variable var_expected_sum : integer;
        variable seed1, seed2 : positive := 1;
        variable rand_real : real;
    begin
        report "Simple tests." severity note;

        var_a := 0; 
        var_b := 0;
        a <= std_logic_vector(to_signed(var_a, WIDTH));
        b <= std_logic_vector(to_signed(var_b, WIDTH));
        op <= ADDER_ADD;
        wait for 1 ns;
        if op=ADDER_ADD then var_expected_sum := var_a + var_b; else var_expected_sum := var_a - var_b; end if;
        assert s = std_logic_vector(to_signed(var_expected_sum, WIDTH))
            report "Sum mismatch (" &
                "a=" & integer'image(var_a) & ", " &
                "b=" & integer'image(var_b) & ", " &
                "op=" & adder_op_t'image(op) & ", " &
                "expected sum=" & integer'image(var_expected_sum) & ", " &
                "actual sum=" & integer'image(to_integer(signed(s))) & ", " &
                ")"
            severity failure;
        wait for 1 ns;

        var_a := 1; 
        var_b := 1;
        a <= std_logic_vector(to_signed(var_a, WIDTH));
        b <= std_logic_vector(to_signed(var_b, WIDTH));
        op <= ADDER_ADD;
        wait for 1 ns;
        if op=ADDER_ADD then var_expected_sum := var_a + var_b; else var_expected_sum := var_a - var_b; end if;
        assert s = std_logic_vector(to_signed(var_expected_sum, WIDTH))
            report "Sum mismatch (" &
                "a=" & integer'image(var_a) & ", " &
                "b=" & integer'image(var_b) & ", " &
                "op=" & adder_op_t'image(op) & ", " &
                "expected sum=" & integer'image(var_expected_sum) & ", " &
                "actual sum=" & integer'image(to_integer(signed(s))) & ", " &
                ")"
            severity failure;
        wait for 1 ns;

        var_a := 1; 
        var_b := 1;
        a <= std_logic_vector(to_signed(var_a, WIDTH));
        b <= std_logic_vector(to_signed(var_b, WIDTH));
        op <= ADDER_SUB;
        wait for 1 ns;
        if op=ADDER_ADD then var_expected_sum := var_a + var_b; else var_expected_sum := var_a - var_b; end if;
        assert s = std_logic_vector(to_signed(var_expected_sum, WIDTH))
            report "Sum mismatch (" &
                "a=" & integer'image(var_a) & ", " &
                "b=" & integer'image(var_b) & ", " &
                "op=" & adder_op_t'image(op) & ", " &
                "expected sum=" & integer'image(var_expected_sum) & ", " &
                "actual sum=" & integer'image(to_integer(signed(s))) & ", " &
                ")"
            severity failure;
        wait for 1 ns;

        var_a := 20; 
        var_b := 2;
        a <= std_logic_vector(to_signed(var_a, WIDTH));
        b <= std_logic_vector(to_signed(var_b, WIDTH));
        op <= ADDER_SUB;
        wait for 1 ns;
        if op=ADDER_ADD then var_expected_sum := var_a + var_b; else var_expected_sum := var_a - var_b; end if;
        assert s = std_logic_vector(to_signed(var_expected_sum, WIDTH))
            report "Sum mismatch (" &
                "a=" & integer'image(var_a) & ", " &
                "b=" & integer'image(var_b) & ", " &
                "op=" & adder_op_t'image(op) & ", " &
                "expected sum=" & integer'image(var_expected_sum) & ", " &
                "actual sum=" & integer'image(to_integer(signed(s))) & ", " &
                ")"
            severity failure;
        wait for 1 ns;

        var_a := 0; 
        var_b := 1;
        a <= std_logic_vector(to_signed(var_a, WIDTH));
        b <= std_logic_vector(to_signed(var_b, WIDTH));
        op <= ADDER_SUB;
        wait for 1 ns;
        if op=ADDER_ADD then var_expected_sum := var_a + var_b; else var_expected_sum := var_a - var_b; end if;
        assert s = std_logic_vector(to_signed(var_expected_sum, WIDTH))
            report "Sum mismatch (" &
                "a=" & integer'image(var_a) & ", " &
                "b=" & integer'image(var_b) & ", " &
                "op=" & adder_op_t'image(op) & ", " &
                "expected sum=" & integer'image(var_expected_sum) & ", " &
                "actual sum=" & integer'image(to_integer(signed(s))) & ", " &
                ")"
            severity failure;
        wait for 1 ns;

        report "Randomized testing." severity note;

        for i in 0 to LOOPMAX loop
            uniform(seed1, seed2, rand_real);
            var_a := integer(floor(rand_real * 2.0**31)) - 2**30;
            a <= std_logic_vector(to_signed(var_a, WIDTH));
            uniform(seed1, seed2, rand_real);
            var_b := integer(floor(rand_real * 2.0**31)) - 2**30;
            b <= std_logic_vector(to_signed(var_b, WIDTH));
            uniform(seed1, seed2, rand_real);
            if integer(floor(rand_real * 2.0))=0 then op <= ADDER_ADD; else op <= ADDER_SUB; end if;
            wait for 1 ns;
            if op = ADDER_ADD then
                report "Test " & integer'image(i) & ": "
                    & integer'image(var_a) & "+" & integer'image(var_b) severity note;
            else
                report "Test " & integer'image(i) & ": "
                    & integer'image(var_a) & "+" & integer'image(var_b) severity note;
            end if;
            if op=ADDER_ADD then var_expected_sum := var_a + var_b; else var_expected_sum := var_a - var_b; end if;
            assert s = std_logic_vector(to_signed(var_expected_sum, WIDTH))
                report "Sum mismatch (" &
                    "a=" & integer'image(var_a) & ", " &
                    "b=" & integer'image(var_b) & ", " &
                    "op=" & adder_op_t'image(op) & ", " &
                    "expected sum=" & integer'image(var_expected_sum) & ", " &
                    "actual sum=" & integer'image(to_integer(signed(s))) & ", " &
                    ")"
                severity failure;
            wait for 1 ns;

        end loop;

        report "Simulation finished."
            severity note;
        wait;
    end process;
    


end;
