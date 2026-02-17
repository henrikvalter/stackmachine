library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;
use ieee.math_real.all;

entity stack_tb is
end;

architecture arch of stack_tb is
    constant ADDR_WIDTH: natural := 8;
    constant DATA_WIDTH: natural := 32;
    signal clk : std_logic;
    signal reset : std_logic;
    signal data_in : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal op : stack_op_t;
    signal enable : std_logic;
    signal data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal stack_error : std_logic;
begin
    dut: entity work.stack
    generic map (
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        data_in => data_in,
        op => op,
        enable => enable,
        data_out => data_out,
        stack_error => stack_error
    );
    stimulus_process: process
        variable write_data : integer;
    begin
        clk <= '0'; 
        reset <= '1';
        wait for 1 ns;
        -- Rising edge
        clk <= '1'; 
        wait for 1 ns;
        -- Falling edge
        clk <= '0'; 
        reset <= '0';

        for i in 1 to 10 loop
            write_data := i+4;
            enable <= '1';
            data_in <= std_logic_vector(to_signed(write_data, DATA_WIDTH));
            op <= STACK_PUSH;

            wait for 1 ns;
            clk <= '1';
            wait for 1 ns;
            clk <= '0';

            enable <= '1';
            op <= STACK_PEEK;

            wait for 1 ns;
            clk <= '1';
            wait for 1 ns;
            clk <= '0';

            assert data_out = std_logic_vector(to_signed(write_data, DATA_WIDTH))
                report "LHS=" & integer'image(to_integer(signed(data_out))) & ", "
                     & "RHS=" & integer'image(write_data)
                severity failure;
        end loop;

        for i in 10 downto 1 loop
            write_data := i+4;
            enable <= '1';
            op <= STACK_POP;

            wait for 1 ns;
            clk <= '1';
            wait for 1 ns;
            clk <= '0';

            assert data_out = std_logic_vector(to_signed(write_data, DATA_WIDTH))
                report "LHS=" & integer'image(to_integer(signed(data_out))) & ", "
                     & "RHS=" & integer'image(write_data)
                severity failure;
        end loop;

        enable <= '1';
        op <= STACK_PEEK;

        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
        clk <= '0';

        assert stack_error = '1'
            report "Should result in a stack error."
            severity failure;

        report "Simulation finished."
            severity note;
        wait;
    end process;
end;
