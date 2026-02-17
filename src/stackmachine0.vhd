library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;

entity stackmachine0 is
    generic (
        MEMFILE: string := "programs/simple.mif";
        ADDR_WIDTH: natural := 8;
        DATA_WIDTH: natural := 32
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end;

architecture arch of stackmachine0 is
    -- Stack in
    signal stack_data_in : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal stack_op : stack_op_t;
    signal stack_enable : std_logic;
    -- Stack out
    signal stack_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal stack_error : std_logic;

    -- Imem in
    signal imem_address : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal imem_enable : std_logic;
    -- Imem out
    signal imem_data_out_offset0 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imem_data_out_offset1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imem_data_out_offset2 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imem_data_out_offset3 : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal pc : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal curr_instruction : std_logic_vector(31 downto 0);
    signal state : stackmachine_state_t := STATE_INIT;
begin
    stack: entity work.stack
    generic map (
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        data_in => stack_data_in,
        op => stack_op,
        enable => stack_enable,
        data_out => stack_data_out,
        stack_error => stack_error
    );
    imem: entity work.imem
    generic map (
        MEMFILE => MEMFILE,
        ADDR_WIDTH => ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        address => imem_address,
        enable => imem_enable,
        data_out_offset0 => imem_data_out_offset0,
        data_out_offset1 => imem_data_out_offset1,
        data_out_offset2 => imem_data_out_offset2,
        data_out_offset3 => imem_data_out_offset3
    );

    process (clk)
        begin
        if rising_edge(clk) then
            -- if reset = '1' then
            --     data_out <= (others => '0');
            --     pc <= (others => '0');
            --     curr_instruction <= (others => '0');
            --     state <= state_init;
            -- end if;

            -- else
            --     data_out <= (others => '0');
            -- end if;
        end if;
    end process;
end;


