library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;
use ieee.math_real.all;

entity stackmachine2_tb is
end;

architecture arch of stackmachine2_tb is
    constant MEMFILE: string := "build/pgm.mif";
    constant INST_ADDR_WIDTH: natural := 8;
    constant DATA_ADDR_WIDTH: natural := 12;
    constant DATA_WIDTH: natural := 32;

    signal clk: std_logic;
    signal reset: std_logic;
    signal data_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_out_valid: std_logic;
    signal exit_flag: std_logic;
begin
    dut: entity work.stackmachine2
    generic map (
        MEMFILE => MEMFILE,
        DATA_ADDR_WIDTH => DATA_ADDR_WIDTH,
        INST_ADDR_WIDTH => INST_ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        data_out => data_out,
        data_out_valid => data_out_valid,
        exit_flag => exit_flag
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
                -- report "Exit signal detected. Simulation finished."
                -- severity note;
                wait;
            end if;

        end loop;
        -- report "Simulation timeout."
        --     severity failure;
        report "timeout" severity failure;
        wait;
    end process;
end;
