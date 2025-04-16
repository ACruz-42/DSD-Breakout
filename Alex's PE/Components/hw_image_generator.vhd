-- I'm not sure if any code from Tyler McCormick remains
-- But either way, the file was adapted extremely heavily from his
-- original code
-- Additionally Lauren and Cooper (classmates) were consulted heavily
-- on the making of this file.
-- Fibonacci logic was inspired by Lauren's.
----------------------------------------------
-- Alex Cruz for PE2
-- 4/13/2025

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hw_image_generator IS
  GENERIC (
    col_a : INTEGER := 80;
    col_b : INTEGER := 160;
    col_c : INTEGER := 240;
    col_d : INTEGER := 320;
    col_e : INTEGER := 400;
    col_f : INTEGER := 480;
    col_g : INTEGER := 560;
    col_h : INTEGER := 640
  );
  PORT (
    disp_ena      : IN  STD_LOGIC;
    row           : IN  INTEGER;
    column        : IN  INTEGER;
    paddle_move   : IN  INTEGER;
    clk           : IN  STD_LOGIC;
    reset         : IN  STD_LOGIC;
    red           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    green         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    blue          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    HEX0          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    HEX1          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    HEX2          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    HEX3          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    HEX4          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    HEX5          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
  );
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
  -- Constant that defines a block
  TYPE block_type IS RECORD
    x_min   : INTEGER;
    x_max   : INTEGER;
    y_min   : INTEGER;
    y_max   : INTEGER;
    enabled : STD_LOGIC;
  END RECORD;
  
  -- Constants to make blocks
  CONSTANT NUM_ROWS       : INTEGER := 2;
  CONSTANT BLOCKS_PER_ROW : INTEGER := 14;
  CONSTANT TOTAL_BLOCKS   : INTEGER := NUM_ROWS * BLOCKS_PER_ROW;
  CONSTANT BLOCK_WIDTH    : INTEGER := 35;
  CONSTANT BLOCK_HEIGHT   : INTEGER := 10;
  CONSTANT BLOCK_SPACE_X  : INTEGER := 5;
  CONSTANT BLOCK_SPACE_Y  : INTEGER := 5;
  CONSTANT START_X        : INTEGER := 35;
  CONSTANT START_Y        : INTEGER := 50;
  
  -- This is the overall block field type
  TYPE block_array_type IS ARRAY (0 TO NUM_ROWS - 1, 0 TO BLOCKS_PER_ROW - 1) OF block_type;
  TYPE rowcol_vector IS ARRAY (0 TO 1) OF INTEGER;
  
  -- These is where we define and initialize the blocks
  SIGNAL blocks : block_array_type := (OTHERS => (OTHERS => (0, 0, 0, 0, '1')));
  
  -- Start flag so we only initialize once
  signal start_flag : STD_LOGIC := '0';

  CONSTANT ball : block_type := (310, 320, 190, 200, '1'); --- We just hardcode the ball for now
  SIGNAL paddle : block_type; -- Paddle logic is mostly in rotaryencoder.vhd
  
  
  -- Define the paddle
  CONSTANT LEFT_BORDER   : INTEGER := 20;
  CONSTANT RIGHT_BORDER  : INTEGER := 610;
  CONSTANT PADDLE_WIDTH  : INTEGER := 70;

  SIGNAL clamped_paddle_pos : INTEGER; -- internal position of paddle. should come clamped, but we clamp again just in case

  -- Fibonacci number state
  SIGNAL fib_current : INTEGER := 1;
  SIGNAL fib_next    : INTEGER := 1;
  SIGNAL fib_index   : INTEGER := 0;

  CONSTANT FIB_MAX_VALUE : INTEGER := 1499999;
  -- This essentially makes a slower clock that we can increment fibonacci on.
  CONSTANT CLOCK_DIVIDER : INTEGER := 25000000; -- I think there might be some timing issues in the associated logic, but it mostly works for now
	
  -- State signals to slow down fibonacci counting
  SIGNAL clk_counter : INTEGER := 0;
  SIGNAL fib_update  : STD_LOGIC := '0';
  SIGNAL reset_sync : STD_LOGIC := '0';
 
  -- Function to convert fibonacci index to rol/column pair
  FUNCTION flat_to_rowcol (
    idx : INTEGER
  ) RETURN rowcol_vector IS
    VARIABLE result : rowcol_vector;
  BEGIN
    result(0) := idx / BLOCKS_PER_ROW;
    result(1) := idx MOD BLOCKS_PER_ROW;
    RETURN result;
  END FUNCTION;
  
  
  -- This was originally just for debugging, but then I moved all the fibonacci code to this file.
  FUNCTION int_to_7seg (
    digit : INTEGER
  ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE seg : STD_LOGIC_VECTOR(6 DOWNTO 0);
  BEGIN
    CASE digit IS
      WHEN 0 => seg := "1000000";
      WHEN 1 => seg := "1111001";
      WHEN 2 => seg := "0100100";
      WHEN 3 => seg := "0110000";
      WHEN 4 => seg := "0011001";
      WHEN 5 => seg := "0010010";
      WHEN 6 => seg := "0000010";
      WHEN 7 => seg := "1111000";
      WHEN 8 => seg := "0000000";
      WHEN 9 => seg := "0010000";
      WHEN OTHERS => seg := "1111111";
    END CASE;
    RETURN seg;
  END FUNCTION;
  
  
  -- Converts fibonacci number to single digits and sends those to above (int_to_7seg) function
  PROCEDURE display_fib_hex (
    fib_val : IN INTEGER;
    SIGNAL hex0_out : OUT STD_LOGIC_VECTOR;
    SIGNAL hex1_out : OUT STD_LOGIC_VECTOR;
    SIGNAL hex2_out : OUT STD_LOGIC_VECTOR;
    SIGNAL hex3_out : OUT STD_LOGIC_VECTOR;
    SIGNAL hex4_out : OUT STD_LOGIC_VECTOR;
    SIGNAL hex5_out : OUT STD_LOGIC_VECTOR
  ) IS
    VARIABLE temp_fib : INTEGER := fib_val;
  BEGIN
    hex0_out <= int_to_7seg(temp_fib MOD 10);
    temp_fib := temp_fib / 10;
    hex1_out <= int_to_7seg(temp_fib MOD 10);
    temp_fib := temp_fib / 10;
    hex2_out <= int_to_7seg(temp_fib MOD 10);
    temp_fib := temp_fib / 10;
    hex3_out <= int_to_7seg(temp_fib MOD 10);
    temp_fib := temp_fib / 10;
    hex4_out <= int_to_7seg(temp_fib MOD 10);
    temp_fib := temp_fib / 10;
    hex5_out <= int_to_7seg(temp_fib MOD 10);
  END PROCEDURE;

BEGIN
	-- Create paddle
  clamped_paddle_pos <=
    LEFT_BORDER + PADDLE_WIDTH / 2 WHEN paddle_move < LEFT_BORDER + PADDLE_WIDTH / 2 ELSE
    RIGHT_BORDER - PADDLE_WIDTH / 2 WHEN paddle_move > RIGHT_BORDER - PADDLE_WIDTH / 2 ELSE
    paddle_move;

  paddle.x_min <= clamped_paddle_pos - PADDLE_WIDTH / 2;
  paddle.x_max <= clamped_paddle_pos + PADDLE_WIDTH / 2;
  paddle.y_min <= 380;
  paddle.y_max <= 390;
  paddle.enabled <= '1';

fib_clk_div: PROCESS(clk, reset)
BEGIN
  IF reset = '0' THEN --reset
    clk_counter <= 0;
    fib_update <= '0';
    reset_sync <= '1';
  ELSIF rising_edge(clk) THEN
    reset_sync <= '0'; -- Normal operation
    
    -- Clock divider
    IF clk_counter >= CLOCK_DIVIDER - 1 THEN
      clk_counter <= 0;
      fib_update <= '1';
    ELSE
      clk_counter <= clk_counter + 1;
      fib_update <= '0';
    END IF;
  END IF;
END PROCESS;

block_ctrl_proc: PROCESS (clk, reset_sync)
  VARIABLE temp : INTEGER;  
  VARIABLE rc_cur : rowcol_vector; -- For current index block
  VARIABLE rc_prev : rowcol_vector; -- For previous index block
  VARIABLE calc_x_min : INTEGER;
  VARIABLE calc_y_min : INTEGER;
BEGIN
  IF reset_sync = '1' THEN
    -- Reset state
    fib_current <= 1;
    fib_next <= 1;
    fib_index <= 0;
    start_flag <= '0';
    
  ELSIF rising_edge(clk) THEN
    IF start_flag = '0' THEN
      -- Initialization here if start flag disabled 
		-- Calculate coords and enable all blocks
      FOR r IN 0 TO NUM_ROWS - 1 LOOP
        FOR c IN 0 TO BLOCKS_PER_ROW - 1 LOOP
          calc_x_min := START_X + c * (BLOCK_WIDTH + BLOCK_SPACE_X);
          calc_y_min := START_Y + r * (BLOCK_HEIGHT + BLOCK_SPACE_Y);
          blocks(r, c).x_min <= calc_x_min;
          blocks(r, c).x_max <= calc_x_min + BLOCK_WIDTH; 
          blocks(r, c).y_min <= calc_y_min;
          blocks(r, c).y_max <= calc_y_min + BLOCK_HEIGHT; 
          blocks(r, c).enabled <= '1'; -- Start all enabled
        END LOOP;
      END LOOP;
      start_flag <= '1'; -- Set start flag to 1 so we don't repeat init.
      
    ELSE --  if start_flag = '1', run normal update logic
      IF fib_update = '1' THEN
        IF fib_current >= FIB_MAX_VALUE THEN
            -- Reset sequence and re-enable all blocks on overflow
            fib_current <= 1;
            fib_next <= 1;
            fib_index <= 0;
            FOR r IN 0 TO NUM_ROWS - 1 LOOP
                FOR c IN 0 TO BLOCKS_PER_ROW - 1 LOOP
                    blocks(r, c).enabled <= '1';
                END LOOP;
            END LOOP;

        -- Sliding window logic based on index
        ELSIF fib_index < TOTAL_BLOCKS THEN
            -- Index is IN BOUNDS: Process the sliding window step

            -- Disable block at the current index
            rc_cur := flat_to_rowcol(fib_index);
            IF rc_cur(0) < NUM_ROWS AND rc_cur(1) < BLOCKS_PER_ROW THEN
                blocks(rc_cur(0), rc_cur(1)).enabled <= '0'; 
            END IF;

            -- Enable block at the previous index (if index > 0)
            IF fib_index > 0 THEN
                rc_prev := flat_to_rowcol(fib_index - 1);
                IF rc_prev(0) < NUM_ROWS AND rc_prev(1) < BLOCKS_PER_ROW THEN
                    blocks(rc_prev(0), rc_prev(1)).enabled <= '1'; 
                END IF;
            END IF;

            -- We Uudate Fibonacci sequence and increment index for the next cycle
            temp := fib_next;
            fib_next <= fib_current + fib_next;
            fib_current <= temp;
            fib_index <= fib_index + 1;

        ELSE
            -- Re-enable the very last block (at index TOTAL_BLOCKS - 1)
            --  Also, we ensure TOTAL_BLOCKS is positive before trying to access index -1
            IF TOTAL_BLOCKS > 0 THEN
                rc_prev := flat_to_rowcol(TOTAL_BLOCKS - 1);
                 IF rc_prev(0) < NUM_ROWS AND rc_prev(1) < BLOCKS_PER_ROW THEN
                    blocks(rc_prev(0), rc_prev(1)).enabled <= '1'; 
                END IF;
            END IF;

            -- Reset Fibonacci number and index
            fib_current <= 1;
            fib_next <= 1;
            fib_index <= 0;

        END IF; -- End (fib_index < TOTAL_BLOCKS)
      END IF; -- End fib_update = '1'
    END IF; -- End start_flag = '0'
  END IF; -- End reset_sync / rising_edge(clk) check
END PROCESS block_ctrl_proc;


  display_proc: PROCESS(disp_ena, row, column, blocks)
    VARIABLE pixel_drawn : BOOLEAN := FALSE;
  BEGIN
    IF (disp_ena = '1') THEN
		-- Default case
      red   <= (OTHERS => '0');
      green <= (OTHERS => '0');
      blue  <= (OTHERS => '0');
      pixel_drawn := FALSE;
		
		-- We acutally draw the blocks here.
      FOR r IN 0 TO NUM_ROWS - 1 LOOP
        FOR c IN 0 TO BLOCKS_PER_ROW - 1 LOOP
          IF (blocks(r, c).enabled = '1' AND column >= blocks(r, c).x_min AND column <= blocks(r, c).x_max AND row >= blocks(r, c).y_min AND row <= blocks(r, c).y_max) THEN
            red         <= "11111111";
            green       <= "11111111";
            blue        <= "11111111";
            pixel_drawn := TRUE;
          END IF;
        END LOOP;
      END LOOP;
		
		-- Draw ball
      IF (NOT pixel_drawn AND ball.enabled = '1' AND row >= ball.y_min AND row <= ball.y_max AND column >= ball.x_min AND column <= ball.x_max) THEN
        red         <= "00000000";
        green       <= "00000000";
        blue        <= "11111111";
        pixel_drawn := TRUE;
      END IF;

		-- Draw paddle
      IF (NOT pixel_drawn AND paddle.enabled = '1' AND row >= paddle.y_min AND row <= paddle.y_max AND column >= paddle.x_min AND column <= paddle.x_max) THEN
        red         <= "00000000";
        green       <= "11111111";
        blue        <= "11111111";
        pixel_drawn := TRUE;
      END IF;

		-- Draw borders
      IF (NOT pixel_drawn AND ((column < 20) OR (row < 20) OR (column > 610))) THEN
        red   <= "11111111";
        green <= "11111111";
        blue  <= "11111111";
      END IF;
    ELSE
      red   <= (OTHERS => '0');
      green <= (OTHERS => '0');
      blue  <= (OTHERS => '0');
    END IF;
  END PROCESS;

  -- Display current Fibonacci number on HEX displays
  display_fib: PROCESS (fib_current)
  BEGIN
    display_fib_hex(fib_current, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
  END PROCESS;

END behavior;