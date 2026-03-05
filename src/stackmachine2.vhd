library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;

entity stackmachine2 is
    generic (
        MEMFILE:                string := "build/pgm.mif";
        INST_ADDR_WIDTH:        natural := 8;
        DATASTACK_ADDR_WIDTH:   natural := 8;
        CALLSTACK_ADDR_WIDTH:   natural := 8;
        DATAMEM_ADDR_WIDTH:     natural := 8;
        DATA_WIDTH:             natural := 32
    );
    port (
        clk                 : in std_logic;
        reset               : in std_logic;
        data_out            : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out_valid      : out std_logic;
        exit_flag           : out std_logic;
        datastack_underflow : out std_logic;
        datastack_overflow  : out std_logic;
        callstack_underflow : out std_logic;
        callstack_overflow  : out std_logic
    );
end;

architecture arch of stackmachine2 is
    -- Internals
    signal pc : std_logic_vector(INST_ADDR_WIDTH-1 downto 0);
    signal state : stackmachine_state_t;
    signal saved_imem_offset0 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal saved_imem_offset1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal saved_imem_offset2 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal saved_imem_offset3 : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal reg0 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg1 : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Stack in
    signal stack_data_in : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal stack_op : stack_op_t;
    signal stack_enable : std_logic;
    -- Stack out
    signal stack_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Callstack in
    signal callstack_data_in : std_logic_vector(INST_ADDR_WIDTH-1 downto 0);
    signal callstack_op : stack_op_t;
    signal callstack_enable : std_logic;
    -- Callstack out
    signal callstack_data_out : std_logic_vector(INST_ADDR_WIDTH-1 downto 0);

    -- Imem in
    signal imem_enable : std_logic;
    -- Imem out
    signal imem_data_out_offset0 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imem_data_out_offset1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imem_data_out_offset2 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imem_data_out_offset3 : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Dmem in
    signal dmem_address : std_logic_vector(DATAMEM_ADDR_WIDTH-1 downto 0);
    signal dmem_data_in : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal dmem_op : mem_op_t;
    signal dmem_enable : std_logic;
    -- Dmem out
    signal dmem_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- main_adder
    signal main_adder_a : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal main_adder_b : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal main_adder_op : adder_op_t;
    signal main_adder_sum : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- pc_adder
    signal pc_adder_in  : std_logic_vector(INST_ADDR_WIDTH-1 downto 0);
    signal pc_adder_sum : std_logic_vector(INST_ADDR_WIDTH-1 downto 0);
begin
    main_adder: entity work.adder(rca)
        generic map(WIDTH => DATA_WIDTH)
        port map (a => main_adder_a, b => main_adder_b, op => main_adder_op, s => main_adder_sum, cout => open);

    pc_adder: entity work.adder(rca)
        generic map(WIDTH => INST_ADDR_WIDTH)
        port map (a => pc, b => pc_adder_in, op => ADDER_ADD, s => pc_adder_sum, cout => open);

    stack: entity work.stack
    generic map (
        ADDR_WIDTH => DATASTACK_ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        data_in => stack_data_in,
        op => stack_op,
        enable => stack_enable,
        data_out => stack_data_out,
        underflow => datastack_underflow,
        overflow => datastack_overflow
    );

    callstack: entity work.stack
    generic map (
        ADDR_WIDTH => CALLSTACK_ADDR_WIDTH,
        DATA_WIDTH => INST_ADDR_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        data_in => callstack_data_in,
        op => callstack_op,
        enable => callstack_enable,
        data_out => callstack_data_out,
        underflow => callstack_underflow,
        overflow => callstack_overflow
    );

    imem: entity work.imem
    generic map (
        MEMFILE => MEMFILE,
        ADDR_WIDTH => INST_ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        address => pc,
        enable => imem_enable,
        data_out_offset0 => imem_data_out_offset0,
        data_out_offset1 => imem_data_out_offset1,
        data_out_offset2 => imem_data_out_offset2,
        data_out_offset3 => imem_data_out_offset3
    );

    dmem: entity work.memarray
    generic map (
        ADDR_WIDTH => DATAMEM_ADDR_WIDTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        address => dmem_address,
        data_in => dmem_data_in,
        op => dmem_op,
        enable => dmem_enable,
        data_out => dmem_data_out
    );

    process (all) begin
        if state = STATE_INIT then
            imem_enable <= '1';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_FETCH then
            imem_enable <= '1';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '1';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_NOP
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_NOP then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(1,INST_ADDR_WIDTH));
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_IPUSH
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_IPUSH then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(2,INST_ADDR_WIDTH));
            stack_data_in <= imem_data_out_offset1;
            stack_op <= STACK_PUSH;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_IADD
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_IADD then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- pop and store in reg0
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_IADD then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- pop and use immediately in exec3
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_IADD then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(1,INST_ADDR_WIDTH));
            stack_data_in <= main_adder_sum;
            stack_op <= STACK_PUSH;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= stack_data_out;
            main_adder_b <= reg0;
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_IPRINT
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_IPRINT then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(1,INST_ADDR_WIDTH));
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_BRANCH
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_BRANCH then
            imem_enable <= '0';
            pc_adder_in <= imem_data_out_offset1(INST_ADDR_WIDTH-1 downto 0);
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_DUP
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_DUP then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(1,INST_ADDR_WIDTH));
            stack_data_in <= stack_data_out;
            stack_op <= STACK_PUSH;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_BRANCH_IF_EQUAL
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_BRANCH_IF_EQUAL then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- value peeked and stored in reg0
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_BRANCH_IF_EQUAL then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(2,INST_ADDR_WIDTH)); -- store in reg1
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- pop and use immediately in exec3
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_BRANCH_IF_EQUAL then
            imem_enable <= '0';
            pc_adder_in <= saved_imem_offset1(INST_ADDR_WIDTH-1 downto 0);
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= reg0;
            main_adder_b <= stack_data_out;
            main_adder_op <= ADDER_SUB;
            exit_flag <= '0';
        -- OP_BRANCH_IF_NOT_EQUAL
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_BRANCH_IF_NOT_EQUAL then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- value peeked and stored in reg0
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_BRANCH_IF_NOT_EQUAL then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(2,INST_ADDR_WIDTH)); -- store in reg1
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- pop and use immediately in exec3
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_BRANCH_IF_NOT_EQUAL then
            imem_enable <= '0';
            pc_adder_in <= saved_imem_offset1(INST_ADDR_WIDTH-1 downto 0);
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= reg0;
            main_adder_b <= stack_data_out;
            main_adder_op <= ADDER_SUB;
            exit_flag <= '0';
        -- OP_ILOAD
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_ILOAD then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= std_logic_vector(resize(unsigned(imem_data_out_offset1),DATAMEM_ADDR_WIDTH));
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '1';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_ILOAD then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(2,INST_ADDR_WIDTH));
            stack_data_in <= dmem_data_out;
            stack_op <= STACK_PUSH;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_ISTORE
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_ISTORE then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(2,INST_ADDR_WIDTH));
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= std_logic_vector(resize(unsigned(imem_data_out_offset1),DATAMEM_ADDR_WIDTH));
            dmem_data_in <= stack_data_out;     -- peeked in fetch
            dmem_op <= MEM_WRITE;
            dmem_enable <= '1';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_CALL
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_CALL then
            imem_enable <= '0';
            -- pc adder computes return address
            pc_adder_in <= std_logic_vector(to_unsigned(2,INST_ADDR_WIDTH));
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            callstack_data_in <= pc_adder_sum;
            callstack_op <= STACK_PUSH;
            callstack_enable <= '1';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            -- main adder computes function address
            main_adder_a <= imem_data_out_offset1;
            main_adder_b <= std_logic_vector(resize(unsigned(pc), DATA_WIDTH));
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_RETURN
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_RETURN then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_POP;
            callstack_enable <= '1';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= imem_data_out_offset1;
            main_adder_b <= std_logic_vector(resize(unsigned(pc), DATA_WIDTH));
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_POP
        -- Special case: for some reason we are popping zero elements.
        -- Just compute next pc, otherwise do nothing.
        -- elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_POP
        --       and (imem_data_out_offset1 = std_logic_vector(to_unsigned(0, DATA_WIDTH))) then
        --     imem_enable <= '0';
        --     pc_adder_in <= std_logic_vector(to_unsigned(2,INST_ADDR_WIDTH));
        --     stack_data_in <= (others => '0');
        --     stack_op <= STACK_PEEK;
        --     stack_enable <= '0';
        --     callstack_data_in <= (others => '0');
        --     callstack_op <= STACK_PEEK;
        --     callstack_enable <= '0';
        --     dmem_address <= (others => '0');
        --     dmem_data_in <= (others => '0');
        --     dmem_op <= MEM_READ;
        --     dmem_enable <= '0';
        --     main_adder_a <= (others => '0');
        --     main_adder_b <= (others => '0');
        --     main_adder_op <= ADDER_ADD;
        --     exit_flag <= '0';
        -- Special case: We are popping one element.
        -- Pop that and compute the next pc, otherwise do nothing.
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_POP
              and (imem_data_out_offset1 = std_logic_vector(to_unsigned(1, DATA_WIDTH))) then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(2,INST_ADDR_WIDTH));
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- General case: save pop amount in reg0, minus one since we pop in this cycle as well.
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_POP then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= imem_data_out_offset1;
            main_adder_b <= std_logic_vector(to_signed(1, DATA_WIDTH));
            main_adder_op <= ADDER_SUB;
            exit_flag <= '0';
        -- Base case of the general case.
        elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_POP
              and (reg0 = std_logic_vector(to_unsigned(1, DATA_WIDTH))) then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(2,INST_ADDR_WIDTH));
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- Recursive step of the general case.
        elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_POP then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= reg0;
            main_adder_b <= std_logic_vector(to_signed(1, DATA_WIDTH));
            main_adder_op <= ADDER_SUB;
            exit_flag <= '0';
        -- OP_ISUB
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_ISUB then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- pop and store in reg0
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_ISUB then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- pop and use immediately in exec3
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_ISUB then
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(1,INST_ADDR_WIDTH));
            stack_data_in <= main_adder_sum;
            stack_op <= STACK_PUSH;
            stack_enable <= '1';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= stack_data_out;
            main_adder_b <= reg0;
            main_adder_op <= ADDER_SUB;
            exit_flag <= '0';
        -- OP_EXIT
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_EXIT then
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            callstack_data_in <= (others => '0');
            callstack_op <= STACK_PEEK;
            callstack_enable <= '0';
            dmem_address <= (others => '0');
            dmem_data_in <= (others => '0');
            dmem_op <= MEM_READ;
            dmem_enable <= '0';
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '1';
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if reset = '1' then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= (others => '0');
                state <= STATE_INIT;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            elsif state = STATE_INIT then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= (others => '0');
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            elsif state = STATE_FETCH then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC1;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_NOP
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_NOP then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_IPUSH
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_IPUSH then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_IADD
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_IADD then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC2;
                saved_imem_offset0 <= imem_data_out_offset0;
                saved_imem_offset1 <= imem_data_out_offset1;
                saved_imem_offset2 <= imem_data_out_offset2;
                saved_imem_offset3 <= imem_data_out_offset3;
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_IADD then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC3;
                saved_imem_offset0 <= saved_imem_offset0;
                saved_imem_offset1 <= saved_imem_offset1;
                saved_imem_offset2 <= saved_imem_offset2;
                saved_imem_offset3 <= saved_imem_offset3;
                reg0 <= stack_data_out;
                reg1 <= (others => '0');
            elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_IADD then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_IPRINT
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_IPRINT then
                report integer'image(to_integer(signed(stack_data_out))) severity note;
                data_out <= stack_data_out;
                data_out_valid <= '1';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- -- OP_BRANCH
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_BRANCH then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_DUP
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_DUP then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_BRANCH_IF_EQUAL
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_BRANCH_IF_EQUAL then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC2;
                saved_imem_offset0 <= imem_data_out_offset0;
                saved_imem_offset1 <= imem_data_out_offset1;
                saved_imem_offset2 <= imem_data_out_offset2;
                saved_imem_offset3 <= imem_data_out_offset3;
                reg0 <= stack_data_out;
                reg1 <= (others => '0');
            elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_BRANCH_IF_EQUAL then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC3;
                saved_imem_offset0 <= saved_imem_offset0;
                saved_imem_offset1 <= saved_imem_offset1;
                saved_imem_offset2 <= saved_imem_offset2;
                saved_imem_offset3 <= saved_imem_offset3;
                reg0 <= reg0;
                reg1 <= std_logic_vector(resize(unsigned(pc_adder_sum), 32));
            elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_BRANCH_IF_EQUAL then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= -- taken
                      pc_adder_sum when main_adder_sum = std_logic_vector(to_unsigned(0,32))
                      -- untaken
                      else reg1(INST_ADDR_WIDTH-1 downto 0);
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_BRANCH_IF_NOT_EQUAL
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_BRANCH_IF_NOT_EQUAL then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC2;
                saved_imem_offset0 <= imem_data_out_offset0;
                saved_imem_offset1 <= imem_data_out_offset1;
                saved_imem_offset2 <= imem_data_out_offset2;
                saved_imem_offset3 <= imem_data_out_offset3;
                reg0 <= stack_data_out;
                reg1 <= (others => '0');
            elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_BRANCH_IF_NOT_EQUAL then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC3;
                saved_imem_offset0 <= saved_imem_offset0;
                saved_imem_offset1 <= saved_imem_offset1;
                saved_imem_offset2 <= saved_imem_offset2;
                saved_imem_offset3 <= saved_imem_offset3;
                reg0 <= reg0;
                reg1 <= std_logic_vector(resize(unsigned(pc_adder_sum), 32));
            elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_BRANCH_IF_NOT_EQUAL then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= -- taken
                      pc_adder_sum when main_adder_sum /= std_logic_vector(to_unsigned(0,32))
                      -- untaken
                      else reg1(INST_ADDR_WIDTH-1 downto 0);
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_ILOAD
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_ILOAD then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC2;
                saved_imem_offset0 <= imem_data_out_offset0;
                saved_imem_offset1 <= imem_data_out_offset1;
                saved_imem_offset2 <= imem_data_out_offset2;
                saved_imem_offset3 <= imem_data_out_offset3;
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_ILOAD then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_ISTORE
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_ISTORE then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_CALL
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_CALL then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= main_adder_sum(INST_ADDR_WIDTH-1 downto 0);
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_RETURN
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_RETURN then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= callstack_data_out;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_POP
            -- Special case: for some reason we are popping zero elements.
            -- Just compute next pc, otherwise do nothing.
            -- elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_POP
            --       and (imem_data_out_offset1 = std_logic_vector(to_unsigned(0, DATA_WIDTH))) then
            --     data_out <= (others => '0');
            --     data_out_valid <= '0';
            --     pc <= pc_adder_sum;
            --     state <= STATE_FETCH;
            --     saved_imem_offset0 <= (others => '0');
            --     saved_imem_offset1 <= (others => '0');
            --     saved_imem_offset2 <= (others => '0');
            --     saved_imem_offset3 <= (others => '0');
            --     reg0 <= (others => '0');
            --     reg1 <= (others => '0');
            -- Special case: We are popping one element.
            -- Pop that and compute the next pc, otherwise do nothing.
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_POP
                  and (imem_data_out_offset1 = std_logic_vector(to_unsigned(1, DATA_WIDTH))) then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- General case: save pop amount in reg0, minus one since we pop in this cycle as well.
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_POP then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC2;
                saved_imem_offset0 <= imem_data_out_offset0;
                saved_imem_offset1 <= imem_data_out_offset1;
                saved_imem_offset2 <= imem_data_out_offset2;
                saved_imem_offset3 <= imem_data_out_offset3;
                reg0 <= main_adder_sum;
                reg1 <= (others => '0');
            -- Base case of the general case.
            elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_POP
                  and (reg0 = std_logic_vector(to_unsigned(1, DATA_WIDTH))) then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- Recursive step of the general case.
            elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_POP then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC2;
                saved_imem_offset0 <= saved_imem_offset0;
                saved_imem_offset1 <= saved_imem_offset1;
                saved_imem_offset2 <= saved_imem_offset2;
                saved_imem_offset3 <= saved_imem_offset3;
                reg0 <= main_adder_sum;
                reg1 <= (others => '0');
            -- OP_ISUB
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_ISUB then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC2;
                saved_imem_offset0 <= imem_data_out_offset0;
                saved_imem_offset1 <= imem_data_out_offset1;
                saved_imem_offset2 <= imem_data_out_offset2;
                saved_imem_offset3 <= imem_data_out_offset3;
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_ISUB then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC3;
                saved_imem_offset0 <= saved_imem_offset0;
                saved_imem_offset1 <= saved_imem_offset1;
                saved_imem_offset2 <= saved_imem_offset2;
                saved_imem_offset3 <= saved_imem_offset3;
                reg0 <= stack_data_out;
                reg1 <= (others => '0');
            elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_ISUB then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc_adder_sum;
                state <= STATE_FETCH;
                saved_imem_offset0 <= (others => '0');
                saved_imem_offset1 <= (others => '0');
                saved_imem_offset2 <= (others => '0');
                saved_imem_offset3 <= (others => '0');
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            -- OP_EXIT
            elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_EXIT then
                data_out <= (others => '0');
                data_out_valid <= '0';
                pc <= pc;
                state <= STATE_EXEC1;
                saved_imem_offset0 <= imem_data_out_offset0;
                saved_imem_offset1 <= imem_data_out_offset1;
                saved_imem_offset2 <= imem_data_out_offset2;
                saved_imem_offset3 <= imem_data_out_offset3;
                reg0 <= (others => '0');
                reg1 <= (others => '0');
            else
                report "Something has gone horribly wrong." severity failure;
            end if;
        end if;
    end process;
end;
