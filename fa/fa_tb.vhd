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
        variable expected : integer;
        variable expected_s : std_logic;
        variable expected_cout : std_logic;
    begin
        for i in 0 to 7 loop
            report "test " & integer'image(i) severity note;
            a   <= '1' when 1=((i/4) mod 2) else '0';
            b   <= '1' when 1=((i/2) mod 2) else '0';
            cin <= '1' when 1=(i mod 2) else '0';
            expected := ((i/4) mod 2) + ((i/2) mod 2) + (i mod 2);
            expected_s := '1' when 1=(expected mod 2) else '0';
            expected_cout := '1' when 1=(expected / 2) else '0';
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
