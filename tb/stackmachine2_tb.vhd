library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;
use ieee.math_real.all;

entity stackmachine2_tb is
end;

architecture arch of stackmachine2_tb is
    constant MEMFILE:               string := "build/pgm.mif";
    constant INST_ADDR_WIDTH:       natural := 8;
    constant DATASTACK_ADDR_WIDTH:  natural := 8;
    constant CALLSTACK_ADDR_WIDTH:  natural := 8;
    constant DATAMEM_ADDR_WIDTH:    natural := 8;
    constant DATA_WIDTH:            natural := 32;

    signal clk                  : std_logic;
    signal reset                : std_logic;
    signal data_out             : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_out_valid       : std_logic;
    signal exit_flag            : std_logic;
    signal datastack_underflow  : std_logic;
    signal datastack_overflow   : std_logic;
    signal callstack_underflow  : std_logic;
    signal callstack_overflow   : std_logic;
begin
    dut: entity work.stackmachine2
    generic map (
        MEMFILE => MEMFILE,
        INST_ADDR_WIDTH => INST_ADDR_WIDTH,
        DATASTACK_ADDR_WIDTH => DATASTACK_ADDR_WIDTH,
        CALLSTACK_ADDR_WIDTH => CALLSTACK_ADDR_WIDTH,
        DATAMEM_ADDR_WIDTH => DATAMEM_ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        data_out => data_out,
        data_out_valid => data_out_valid,
        exit_flag => exit_flag,
        datastack_underflow => datastack_underflow,
        datastack_overflow  => datastack_overflow,
        callstack_underflow => callstack_underflow,
        callstack_overflow  => callstack_overflow
    );
    stimulus_process: process
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

        for i in 1 to 10000 loop

            wait for 1 ns;
            clk <= '1';
            wait for 1 ns;
            clk <= '0';

            if exit_flag = '1' then
                report "Exit signal detected. Simulation finished."
                severity note;
                wait;
            elsif datastack_underflow = '1' then
                report "Datastack underflow. Simulation aborted."
                severity note;
                wait;
            elsif datastack_overflow = '1' then
                report "Datastack overflow. Simulation aborted."
                severity note;
                wait;
            elsif callstack_underflow = '1' then
                report "Callstack underflow. Simulation aborted."
                severity note;
                wait;
            elsif callstack_overflow = '1' then
                report "Callstack overflow. Simulation aborted."
                severity note;
                wait;
            end if;
        end loop;
        report "Simulation timeout." severity note;
        wait;
    end process;
end;
