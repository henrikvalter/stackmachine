library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;
use ieee.math_real.all;

entity mem_tb is
end;

architecture arch of mem_tb is
    constant ADDR_WIDTH: natural := 8;
    constant DATA_WIDTH: natural := 32;
    signal clk : std_logic;
    signal reset : std_logic;
    signal address : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data_in : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal op : mem_op_t;
    signal enable : std_logic;
    signal data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    dut: entity work.mem
    generic map (
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        address => address,
        data_in => data_in,
        op => op,
        enable => enable,
        data_out => data_out
    );
    stimulus_process: process
        variable written_data : integer;
        variable used_address : integer;
    begin
        -- t=0
        clk <= '0'; 
        reset <= '1';
        wait for 1 ns;
        -- Rising edge
        clk <= '1'; 
        wait for 1 ns;
        -- Falling edge
        clk <= '0'; 
        reset <= '0';
        enable <= '1';

        -- Each loop iteration starts on the falling edge
        for i in 0 to 20 loop
            written_data := i+12;
            used_address := i+2;
            data_in <= std_logic_vector(to_unsigned(written_data, DATA_WIDTH));
            address <= std_logic_vector(to_unsigned(used_address, ADDR_WIDTH));
            op <= MEM_WRITE;

            wait for 1 ns;
            clk <= '1';
            wait for 1 ns;
            clk <= '0';

            address <= std_logic_vector(to_unsigned(used_address, ADDR_WIDTH));
            op <= MEM_READ;

            wait for 1 ns;
            clk <= '1';
            wait for 1 ns;
            clk <= '0';

            assert data_out = std_logic_vector(to_unsigned(written_data, DATA_WIDTH))
                report "?"
            severity failure;

        end loop;

        report "Simulation finished."
            severity note;
        wait;
    end process;
end;
