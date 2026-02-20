library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;
use ieee.math_real.all;

entity stackmachine0_tb is
end;

architecture arch of stackmachine0_tb is
    constant MEMFILE: string := "programs/branch.mif";
    constant ADDR_WIDTH: natural := 8;
    constant DATA_WIDTH: natural := 32;

    signal clk: std_logic;
    signal reset: std_logic;
    signal data_out: std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_out_valid: std_logic;
    signal state_o: stackmachine_state_t;
begin
    dut: entity work.stackmachine0
    generic map (
        MEMFILE => MEMFILE,
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        data_out => data_out,
        data_out_valid => data_out_valid,
        state_o => state_o
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

        for i in 1 to 100 loop

            wait for 1 ns;
            clk <= '1';
            wait for 1 ns;
            clk <= '0';

        end loop;
        report "Simulation finished."
            severity note;
        wait;
    end process;
end;
