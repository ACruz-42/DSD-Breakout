-- Refactored version using ball_controller and fibonacci_hex_display components
----------------------------------------------
-- Alex Cruz for PE2 (with further modifications)
-- 4/17/2025

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.block_definitions_pkg.ALL;


ENTITY hw_image_generator IS
    GENERIC (
        -- Screen dimensions
        SCREEN_WIDTH  : INTEGER := 640;
        SCREEN_HEIGHT : INTEGER := 480;
        -- Paddle/Border constants
        LEFT_BORDER   : INTEGER := 20;
        RIGHT_BORDER  : INTEGER := 620;
        TOP_BORDER    : INTEGER := 20;
        PADDLE_WIDTH  : INTEGER := 70;
        PADDLE_HEIGHT : INTEGER := 10;
        PADDLE_Y_POS  : INTEGER := 380;
        -- Ball constants (passed to ball_controller)
        BALL_SIZE     : INTEGER := 10;
        BALL_START_X  : INTEGER := 320;
        BALL_START_Y  : INTEGER := 240;
        BALL_START_DX : INTEGER := 3;
        BALL_START_DY : INTEGER := 3;
        -- Block layout constants
        NUM_ROWS        : INTEGER := 2;
        BLOCKS_PER_ROW  : INTEGER := 14;
        BLOCK_WIDTH     : INTEGER := 35;
        BLOCK_HEIGHT    : INTEGER := 10;
        BLOCK_SPACE_X   : INTEGER := 5;
        BLOCK_SPACE_Y   : INTEGER := 5;
        BLOCK_START_X   : INTEGER := 35;
        BLOCK_START_Y   : INTEGER := 50;
        -- Timing constants
        FIB_CLK_DIVIDER : INTEGER := 25000000; -- ~0.5 sec updates @ 50MHz
        BALL_CLK_DIVIDER: INTEGER := 500000;   -- ~100 Hz updates @ 50MHz
        -- Fibonacci constant (passed to fibonacci_hex_display)
        FIB_MAX_VALUE   : INTEGER := 1499999
    );
    PORT (
        -- Inputs
        disp_ena    : IN  STD_LOGIC;
        row         : IN  INTEGER;
        column      : IN  INTEGER;
        paddle_move : IN  INTEGER; -- Center of paddle
        clk         : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC; -- Active-low reset
        -- Outputs
        red         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        green       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        blue        : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
        HEX0        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX1        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX2        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX3        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX4        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        HEX5        : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

    -- Signals for game elements state
    SIGNAL blocks 	: block_array_type(0 TO NUM_ROWS - 1, 0 TO BLOCKS_PER_ROW - 1); -- Holds state of all blocks
    SIGNAL paddle 	: block_type; -- Paddle position and state
    SIGNAL game_over    : STD_LOGIC; -- Fed in from ball controller, alternate reset_sync conditional 

    -- Signals connecting to/from components
    SIGNAL ball_x   : INTEGER; -- Output from ball_controller
    SIGNAL ball_y   : INTEGER; -- Output from ball_controller
    SIGNAL ball_ena : STD_LOGIC; -- Output from ball_controller

    -- Internal timing signals
    SIGNAL fib_clk_counter  : INTEGER := 0;
    SIGNAL fib_update       : STD_LOGIC := '0';
    SIGNAL ball_clk_counter : INTEGER := 0;
    SIGNAL ball_update      : STD_LOGIC := '0';
    SIGNAL reset_sync       : STD_LOGIC := '1'; -- Synchronized reset signal

    -- Internal signal for clamped paddle position
    SIGNAL clamped_paddle_pos : INTEGER;

BEGIN

    -- == Paddle Logic ==
    -- Clamp paddle position
    clamped_paddle_pos <=
        LEFT_BORDER + PADDLE_WIDTH / 2 WHEN paddle_move < LEFT_BORDER + PADDLE_WIDTH / 2 ELSE
        RIGHT_BORDER - PADDLE_WIDTH / 2 WHEN paddle_move > RIGHT_BORDER - PADDLE_WIDTH / 2 ELSE
        paddle_move;

    -- Calculate paddle boundaries
    paddle.x_min <= clamped_paddle_pos - PADDLE_WIDTH / 2;
    paddle.x_max <= clamped_paddle_pos + PADDLE_WIDTH / 2;
    paddle.y_min <= PADDLE_Y_POS;
    paddle.y_max <= PADDLE_Y_POS + PADDLE_HEIGHT;
    paddle.enabled <= '1';

    -- == Timing Logic ==
    -- Process to synchronize reset and generate updates for ball and prng (called fib)
    timing_proc : PROCESS (clk, reset, game_over)
    BEGIN
        IF reset = '0' or game_over = '1' THEN
            fib_clk_counter  <= 0;
            fib_update       <= '0';
            ball_clk_counter <= 0;
            ball_update      <= '0';
            reset_sync       <= '1';
        ELSIF rising_edge(clk) THEN
            reset_sync <= '0';

            -- PRNG Clock Divider (maybe not necessary anymore?)
            IF fib_clk_counter >= FIB_CLK_DIVIDER - 1 THEN
                fib_clk_counter <= 0;
                fib_update      <= '1';
            ELSE
                fib_clk_counter <= fib_clk_counter + 1;
                fib_update      <= '0';
            END IF;

            -- Ball Clock Divider
            IF ball_clk_counter >= BALL_CLK_DIVIDER - 1 THEN
                ball_clk_counter <= 0;
                ball_update      <= '1';
            ELSE
                ball_clk_counter <= ball_clk_counter + 1;
                ball_update      <= '0';
            END IF;
        END IF;
    END PROCESS timing_proc;




    -- == Component Instantiations ==

    -- Instantiate the Ball Controller
    U_Ball_Controller : ENTITY work.ball_controller
        GENERIC MAP (
            LEFT_BORDER   => LEFT_BORDER,
            RIGHT_BORDER  => RIGHT_BORDER,
            TOP_BORDER    => TOP_BORDER,
            BALL_SIZE     => BALL_SIZE,
            BALL_START_X  => BALL_START_X,
            BALL_START_Y  => BALL_START_Y,
            BALL_START_DX => BALL_START_DX,
            BALL_START_DY => BALL_START_DY
        )
        PORT MAP (
            clk         => clk,
            reset_sync  => reset_sync,
            ball_update => ball_update,
            paddle      => paddle,
            blocks      => blocks, -- Connect the main blocks signal (INOUT)
            ball_x      => ball_x, -- Receive ball position
            ball_y      => ball_y, -- Receive ball position
            ball_ena    => ball_ena,  -- Receive ball enable status
				game_over   => game_over,
				HEX0			=> HEX0,
				HEX1			=> HEX1,
				HEX2			=> HEX2,
				HEX3			=> HEX3,
				HEX4			=> HEX4,
				HEX5			=> HEX5
        );

    -- Instantiate the Fibonacci HEX Display Controller
--    U_Fib_Hex_Display : ENTITY work.fibonacci_hex_display
--        GENERIC MAP (
--            FIB_MAX_VALUE => FIB_MAX_VALUE
--        )
--        PORT MAP (
--            clk         => clk,
--            reset_sync  => reset_sync,
--            fib_update  => fib_update,
--            HEX0        => HEX0, -- Connect HEX outputs
--            HEX1        => HEX1,
--            HEX2        => HEX2,
--            HEX3        => HEX3,
--            HEX4        => HEX4,
--            HEX5        => HEX5
--        );

    -- == Drawing Logic ==
    display_proc : PROCESS (disp_ena, row, column, blocks, paddle, ball_x, ball_y, ball_ena)
        VARIABLE pixel_drawn : BOOLEAN := FALSE;
    BEGIN
        IF (disp_ena = '1') THEN
            -- Default background (Black)
            red         <= (OTHERS => '0');
            green       <= (OTHERS => '0');
            blue        <= (OTHERS => '0');
            pixel_drawn := FALSE;

            -- Draw Blocks (White)
            FOR r IN 0 TO NUM_ROWS - 1 LOOP
                FOR c IN 0 TO BLOCKS_PER_ROW - 1 LOOP
                    IF blocks(r, c).enabled = '1' THEN
                        IF column >= blocks(r, c).x_min AND column < blocks(r, c).x_max AND
                           row >= blocks(r, c).y_min AND row < blocks(r, c).y_max THEN
                            red         <= (OTHERS => '1');
                            green       <= (OTHERS => '1');
                            blue        <= (OTHERS => '1');
                            pixel_drawn := TRUE;
                            EXIT;
                        END IF;
                    END IF;
                END LOOP;
                IF pixel_drawn THEN EXIT; END IF;
            END LOOP;

            -- Draw Ball-
          --  IF NOT pixel_drawn AND ball_ena = '1' THEN
                 IF row >= ball_y AND row < ball_y + BALL_SIZE AND
                   column >= ball_x AND column < ball_x + BALL_SIZE THEN
                    red         <= (OTHERS => '1');
                    green       <= (OTHERS => '1');
                    blue        <= (OTHERS => '1');
                    pixel_drawn := TRUE;
                END IF;
           -- END IF;

            -- Draw Paddle
            IF NOT pixel_drawn AND paddle.enabled = '1' THEN
                IF row >= paddle.y_min AND row < paddle.y_max AND
                   column >= paddle.x_min AND column < paddle.x_max THEN
                    red         <= (OTHERS => '0');
                    green       <= (OTHERS => '1');
                    blue        <= (OTHERS => '1');
                    pixel_drawn := TRUE;
                END IF;
            END IF;

            -- Draw Borders
            IF NOT pixel_drawn THEN
                IF column < LEFT_BORDER OR column >= RIGHT_BORDER OR row < TOP_BORDER THEN
                     red   <= (OTHERS => '1');
                     green <= (OTHERS => '1');
                     blue  <= (OTHERS => '1');
                     pixel_drawn := TRUE;
                END IF;
            END IF;

        ELSE
            -- Outside display enable area
            red   <= (OTHERS => '0');
            green <= (OTHERS => '0');
            blue  <= (OTHERS => '0');
        END IF;
    END PROCESS display_proc;

END behavior;
