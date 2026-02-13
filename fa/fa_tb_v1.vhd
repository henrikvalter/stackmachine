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
        variable test_nr : integer := 0;
        variable expected_s : std_logic;
        variable expected_cout : std_logic;
    begin
        -- <0>
        report "test " & integer'image(test_nr) severity note;
        a <= '0';
        b <= '0';
        cin <= '0';
        expected_s := '0';
        expected_cout := '0';
        wait for 2 ns;
        assert s = expected_s 
            report "Sum mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        assert cout = expected_cout
            report "Carry mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        test_nr := test_nr + 1;

        -- <1>
        report "test " & integer'image(test_nr) severity note;
        a <= '0';
        b <= '0';
        cin <= '1';
        expected_s := '1';
        expected_cout := '0';
        wait for 2 ns;
        assert s = expected_s 
            report "Sum mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        assert cout = expected_cout
            report "Carry mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        test_nr := test_nr + 1;

        -- <2>
        report "test " & integer'image(test_nr) severity note;
        a <= '0';
        b <= '1';
        cin <= '0';
        expected_s := '1';
        expected_cout := '0';
        wait for 2 ns;
        assert s = expected_s 
            report "Sum mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        assert cout = expected_cout
            report "Carry mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        test_nr := test_nr + 1;

        -- <3>
        report "test " & integer'image(test_nr) severity note;
        a <= '0';
        b <= '1';
        cin <= '1';
        expected_s := '0';
        expected_cout := '1';
        wait for 2 ns;
        assert s = expected_s 
            report "Sum mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        assert cout = expected_cout
            report "Carry mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        test_nr := test_nr + 1;

        -- <4>
        report "test " & integer'image(test_nr) severity note;
        a <= '1';
        b <= '0';
        cin <= '0';
        expected_s := '1';
        expected_cout := '0';
        wait for 2 ns;
        assert s = expected_s 
            report "Sum mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        assert cout = expected_cout
            report "Carry mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        test_nr := test_nr + 1;

        -- <5>
        report "test " & integer'image(test_nr) severity note;
        a <= '1';
        b <= '0';
        cin <= '1';
        expected_s := '0';
        expected_cout := '1';
        wait for 2 ns;
        assert s = expected_s 
            report "Sum mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        assert cout = expected_cout
            report "Carry mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        test_nr := test_nr + 1;

        -- <6>
        report "test " & integer'image(test_nr) severity note;
        a <= '1';
        b <= '1';
        cin <= '0';
        expected_s := '0';
        expected_cout := '1';
        wait for 2 ns;
        assert s = expected_s 
            report "Sum mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        assert cout = expected_cout
            report "Carry mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        test_nr := test_nr + 1;

        -- <7>
        report "test " & integer'image(test_nr) severity note;
        a <= '1';
        b <= '1';
        cin <= '1';
        expected_s := '1';
        expected_cout := '1';
        wait for 2 ns;
        assert s = expected_s 
            report "Sum mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        assert cout = expected_cout
            report "Carry mismatch (a=" & std_logic'image(a) & ", b=" &
                    std_logic'image(b) & ", cin=" & std_logic'image(cin) &
                    ", s=" & std_logic'image(s) & ", cout=" & std_logic'image(cout) & ")"
            severity failure;
        test_nr := test_nr + 1;
        
        report "Simulation finished."
            severity note;
        wait;
    end process;
end;
