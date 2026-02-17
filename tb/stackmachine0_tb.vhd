library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;
use ieee.math_real.all;

entity stackmachine0_tb is
end;

architecture arch of stackmachine0_tb is
    constant MEMFILE: string := "programs/simple.mif";
    constant ADDR_WIDTH: natural := 8;
    constant DATA_WIDTH: natural := 32;

    signal clk: std_logic;
    signal reset: std_logic;
    signal data_out: std_logic_vector(DATA_WIDTH-1 downto 0);
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
        data_out => data_out
    );
    stimulus_process: process
    begin
        report "Simulation finished."
            severity note;
        wait;
    end process;
end;
