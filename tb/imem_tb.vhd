library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;
use ieee.math_real.all;

entity imem_tb is
end;

architecture arch of imem_tb is
    constant ADDR_WIDTH: natural := 8;
    constant DATA_WIDTH: natural := 32;
    signal clk : std_logic;
    signal reset : std_logic;
    signal address : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal enable : std_logic;
    signal data_out_offset0 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_out_offset1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_out_offset2 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_out_offset3 : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    dut: entity work.imem
    generic map (
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk,
        reset,
        address,
        enable,
        data_out_offset0,
        data_out_offset1,
        data_out_offset2,
        data_out_offset3
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

        for i in 0 to 10 loop
            enable <= '1';
            address <= std_logic_vector(to_unsigned(i,ADDR_WIDTH));

            wait for 1 ns;
            clk <= '1';
            wait for 1 ns;
            clk <= '0';

            report "mem [" & integer'image(i) & "] = " & to_hstring(data_out_offset0);

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
