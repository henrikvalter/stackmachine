library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fa_tb is
end;

architecture behavioral of fa_tb is
    signal a    : std_logic := '0';
    signal b    : std_logic := '0';
    signal cin  : std_logic := '0';
    signal s    : std_logic;
    signal cout : std_logic;
begin
    dut: entity work.fa
    port map (
        a    => a,
        b    => b,
        cin  => cin,
        s  => s,
        cout => cout
    );

    stimulus_process: process
        variable inputs : unsigned(2 downto 0);
        variable expected_i : integer;
        variable expected_vec : unsigned(1 downto 0);
        variable expected_s : std_logic;
        variable expected_cout : std_logic;
    begin
        for i in 0 to 7 loop
            report "test " & integer'image(i) severity note;
            inputs := to_unsigned(i, 3);
            a <= inputs(2);
            b <= inputs(1);
            cin <= inputs(0);
            expected_i := ((i/4) mod 2) + ((i/2) mod 2) + (i mod 2);
            expected_vec := to_unsigned(expected_i, 2);
            expected_cout := expected_vec(1);
            expected_s := expected_vec(0);
            wait for 1 ns;
            assert s = expected_s
                report "Sum mismatch (" &
                    "a=" & std_logic'image(a) & ", " &
                    "b=" & std_logic'image(b) & ", " &
                    "cin=" & std_logic'image(cin) & ")"
                severity failure;
            assert cout = expected_cout
                report "Carry mismatch (" &
                    "a=" & std_logic'image(a) & ", " &
                    "b=" & std_logic'image(b) & ", " &
                    "cin=" & std_logic'image(cin) & ")"
                severity failure;
            wait for 1 ns;
        end loop;

        report "Simulation finished."
            severity note;

        wait;
    end process;
end;
