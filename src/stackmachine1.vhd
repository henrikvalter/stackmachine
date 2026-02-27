library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypkg.all;

entity stackmachine1 is
    generic (
        MEMFILE: string := "build/pgm.mif";
        ADDR_WIDTH: natural := 12;
        DATA_WIDTH: natural := 32
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out_valid : out std_logic;
        exit_flag : out std_logic
    );
end;

architecture arch of stackmachine1 is
    -- Internals
    signal pc : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal state : stackmachine_state_t;
    signal saved_imem_offset0 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal saved_imem_offset1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal saved_imem_offset2 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal saved_imem_offset3 : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal reg0 : std_logic_vector(31 downto 0);
    signal reg1 : std_logic_vector(31 downto 0);

    -- Stack in
    signal stack_data_in : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal stack_op : stack_op_t;
    signal stack_enable : std_logic;
    -- Stack out
    signal stack_data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal stack_error : std_logic;

    -- Imem in
    signal imem_enable : std_logic;
    -- Imem out
    signal imem_data_out_offset0 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imem_data_out_offset1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imem_data_out_offset2 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imem_data_out_offset3 : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- main_adder
    signal main_adder_a : std_logic_vector(31 downto 0);
    signal main_adder_b : std_logic_vector(31 downto 0);
    signal main_adder_op : adder_op_t;
    signal main_adder_sum : std_logic_vector(31 downto 0);

    -- pc_adder
    signal pc_adder_in  : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal pc_adder_sum : std_logic_vector(ADDR_WIDTH-1 downto 0);
begin
    main_adder: entity work.adder(rca)
        generic map(WIDTH => 32)
        port map (a => main_adder_a, b => main_adder_b, op => main_adder_op, s => main_adder_sum, cout => open);

    pc_adder: entity work.adder(rca)
        generic map(WIDTH => ADDR_WIDTH)
        port map (a => pc, b => pc_adder_in, op => ADDER_ADD, s => pc_adder_sum, cout => open);

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
        address => pc,
        enable => imem_enable,
        data_out_offset0 => imem_data_out_offset0,
        data_out_offset1 => imem_data_out_offset1,
        data_out_offset2 => imem_data_out_offset2,
        data_out_offset3 => imem_data_out_offset3
    );

    process (all) begin
        if state = STATE_INIT then
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            imem_enable <= '1';
            pc_adder_in <= (others => '0');
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_FETCH then
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '1';
            imem_enable <= '1';
            pc_adder_in <= (others => '0');
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_NOP
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_NOP then
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(1,ADDR_WIDTH));
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_IPUSH
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_IPUSH then
            stack_data_in <= imem_data_out_offset1;
            stack_op <= STACK_PUSH;
            stack_enable <= '1';
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(2,ADDR_WIDTH));
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- -- OP_IADD
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_IADD then
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- pop and store in reg0
            stack_enable <= '1';
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_IADD then
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- pop and use immediately in exec3
            stack_enable <= '1';
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_IADD then
            stack_data_in <= main_adder_sum;
            stack_op <= STACK_PUSH;
            stack_enable <= '1';
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(1,ADDR_WIDTH));
            main_adder_a <= reg0;
            main_adder_b <= stack_data_out;
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_IPRINT
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_IPRINT then
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP;
            stack_enable <= '1';
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(1,ADDR_WIDTH));
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_BRANCH
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_BRANCH then
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            imem_enable <= '0';
            pc_adder_in <= imem_data_out_offset1(ADDR_WIDTH-1 downto 0);
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_DUP
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_DUP then
            stack_data_in <= stack_data_out;
            stack_op <= STACK_PUSH;
            stack_enable <= '1';
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(1,ADDR_WIDTH));
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        -- OP_BRANCH_IF_EQUAL
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_BRANCH_IF_EQUAL then
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- value peeked and stored in reg0
            stack_enable <= '1';
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_BRANCH_IF_EQUAL then
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- pop and use immediately in exec3
            stack_enable <= '1';
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(2,ADDR_WIDTH)); -- store in reg1
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_BRANCH_IF_EQUAL then
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            imem_enable <= '1';
            pc_adder_in <= saved_imem_offset1(ADDR_WIDTH-1 downto 0);
            main_adder_a <= reg0;
            main_adder_b <= stack_data_out;
            main_adder_op <= ADDER_SUB;
            exit_flag <= '0';
        -- OP_BRANCH_IF_NOT_EQUAL
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_BRANCH_IF_NOT_EQUAL then
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- value peeked and stored in reg0
            stack_enable <= '1';
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC2 and saved_imem_offset0 = OP_BRANCH_IF_NOT_EQUAL then
            stack_data_in <= (others => '0');
            stack_op <= STACK_POP; -- pop and use immediately in exec3
            stack_enable <= '1';
            imem_enable <= '0';
            pc_adder_in <= std_logic_vector(to_unsigned(2,ADDR_WIDTH)); -- store in reg1
            main_adder_a <= (others => '0');
            main_adder_b <= (others => '0');
            main_adder_op <= ADDER_ADD;
            exit_flag <= '0';
        elsif state = STATE_EXEC3 and saved_imem_offset0 = OP_BRANCH_IF_NOT_EQUAL then
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            imem_enable <= '1';
            pc_adder_in <= saved_imem_offset1(ADDR_WIDTH-1 downto 0);
            main_adder_a <= reg0;
            main_adder_b <= stack_data_out;
            main_adder_op <= ADDER_SUB;
            exit_flag <= '0';
        -- OP_EXIT
        elsif state = STATE_EXEC1 and imem_data_out_offset0 = OP_EXIT then
            stack_data_in <= (others => '0');
            stack_op <= STACK_PEEK;
            stack_enable <= '0';
            imem_enable <= '0';
            pc_adder_in <= (others => '0');
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
            -- -- OP_IADD
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
                      else reg1(ADDR_WIDTH-1 downto 0);
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
                      else reg1(ADDR_WIDTH-1 downto 0);
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
            end if;
        end if;
    end process;
end;
