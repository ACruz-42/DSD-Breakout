LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.block_definitions_pkg.ALL;

ENTITY ball_controller IS
    GENERIC (
        -- Screen/Border Dimensions
        LEFT_BORDER   : INTEGER := 20;
        RIGHT_BORDER  : INTEGER := 620;
        TOP_BORDER    : INTEGER := 20;
        BOTTOM_BORDER : INTEGER := 460;

        -- Ball Properties
        BALL_SIZE     : INTEGER := 10;
        BALL_START_X  : INTEGER := 320;
        BALL_START_Y  : INTEGER := 100;
        BALL_START_DX : INTEGER := 3;
        BALL_START_DY : INTEGER := 3;

        -- Block Layout
        BLOCK_WIDTH     : INTEGER := 35;
        BLOCK_HEIGHT    : INTEGER := 10;
        BLOCK_SPACE_X   : INTEGER := 5;
        BLOCK_SPACE_Y   : INTEGER := 5;
        BLOCK_START_X   : INTEGER := 35;
        BLOCK_START_Y   : INTEGER := 50
    );
    PORT (
        clk         : IN  STD_LOGIC;
        reset_sync  : IN  STD_LOGIC;
        ball_update : IN  STD_LOGIC;
        paddle      : IN  block_type;
        blocks      : INOUT block_array_type;
        ball_x      : OUT INTEGER;
        ball_y      : OUT INTEGER;
        ball_ena    : OUT STD_LOGIC;
		  game_over	  : OUT STD_LOGIC;
		  HEX0		  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); 
		  HEX1		  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX2		  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX3		  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX4		  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		  HEX5	     : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		  
    );
END ENTITY ball_controller;

ARCHITECTURE Behavioral OF ball_controller IS
	 
	 -- Internal signals
    SIGNAL current_ball_x   : INTEGER := BALL_START_X;
    SIGNAL current_ball_y   : INTEGER := BALL_START_Y;
    SIGNAL current_ball_dx  : INTEGER := BALL_START_DX;
    SIGNAL current_ball_dy  : INTEGER := BALL_START_DY;
    SIGNAL current_ball_ena : STD_LOGIC := '1';
	 
	 -- This is the amount of balls remaining ** For ball counting
	 SIGNAL ball_count		 : INTEGER := 3;
	 SIGNAL block_count		 : INTEGER := 0;
	 
    -- 7-segment encoding function (active low)
  function bcd_to_7seg(bcd : std_logic_vector(3 downto 0)) return std_logic_vector is
    variable seg : std_logic_vector(6 downto 0);
  begin
    case bcd is
      when "0000" => seg := "1000000"; -- 0
      when "0001" => seg := "1111001"; -- 1
      when "0010" => seg := "0100100"; -- 2
      when "0011" => seg := "0110000"; -- 3
      when "0100" => seg := "0011001"; -- 4
      when "0101" => seg := "0010010"; -- 5
      when "0110" => seg := "0000010"; -- 6
      when "0111" => seg := "1111000"; -- 7
      when "1000" => seg := "0000000"; -- 8
      when "1001" => seg := "0010000"; -- 9
      when others => seg := "1111111"; -- blank
    end case;
	 
    return seg;
	 
  end function;
  
  
  


BEGIN

    ball_x <= current_ball_x;
    ball_y <= current_ball_y;
    ball_ena <= current_ball_ena;
	 
	 -- We determine what the ball does here
    ball_proc : PROCESS (clk)
		  -- Internal variables for determining collision/storing temporary values
        VARIABLE next_ball_x : INTEGER;
        VARIABLE next_ball_y : INTEGER;
        VARIABLE next_dx     : INTEGER;
        VARIABLE next_dy     : INTEGER;
        VARIABLE block_hit   : BOOLEAN := FALSE;
        VARIABLE blocks_temp : block_array_type(blocks'RANGE(1), blocks'RANGE(2));
        VARIABLE pen_x1, pen_x2, pen_y1, pen_y2, min_pen_x, min_pen_y : INTEGER;
        VARIABLE calc_x_min, calc_y_min : INTEGER;
    BEGIN
        IF rising_edge(clk) THEN
            blocks_temp := blocks;
				
				-- This is both initialization and reset, reset sync comes from hw_image_generator. It means we're restarting
            IF reset_sync = '1' THEN
                current_ball_x  <= BALL_START_X;
                current_ball_y  <= BALL_START_Y;
                current_ball_dx <= BALL_START_DX;
                current_ball_dy <= BALL_START_DY;
                current_ball_ena <= '1';
					 ball_count <= 3;
					 game_over <= '0';
					 block_count <= 0;

                -- Initialize all blocks
                FOR r IN blocks_temp'RANGE(1) LOOP
                    FOR c IN blocks_temp'RANGE(2) LOOP
                        calc_x_min := BLOCK_START_X + c * (BLOCK_WIDTH + BLOCK_SPACE_X);
                        calc_y_min := BLOCK_START_Y + r * (BLOCK_HEIGHT + BLOCK_SPACE_Y);
                        blocks_temp(r,c).x_min   := calc_x_min;
                        blocks_temp(r,c).x_max   := calc_x_min + BLOCK_WIDTH;
                        blocks_temp(r,c).y_min   := calc_y_min;
                        blocks_temp(r,c).y_max   := calc_y_min + BLOCK_HEIGHT;
                        blocks_temp(r,c).enabled := '1';
                    END LOOP;
                END LOOP;
                blocks <= blocks_temp;
					 
					 
				
				-- If the game is going, we calculate the next position and check for collisions
            ELSIF ball_update = '1' AND current_ball_ena = '1' THEN -- CURR BALL ENABLE = 1 WAS HERE
                next_ball_x := current_ball_x + current_ball_dx;
                next_ball_y := current_ball_y + current_ball_dy;
                next_dx := current_ball_dx;
                next_dy := current_ball_dy;
                block_hit := FALSE;

		

                -- Wall Collisions
                IF (next_ball_x <= LEFT_BORDER) OR (next_ball_x + BALL_SIZE >= RIGHT_BORDER) THEN
                    next_dx := -current_ball_dx;
                    next_ball_x := current_ball_x + next_dx;
                END IF;

                IF (next_ball_y <= TOP_BORDER) THEN
                    next_dy := -current_ball_dy;
                    next_ball_y := current_ball_y + next_dy;
                END IF;
					 
					 -- Ball Falls Out
                IF (next_ball_y + BALL_SIZE >= BOTTOM_BORDER) THEN
                    next_ball_x := BALL_START_X;
                    next_ball_y := BALL_START_Y;
                    next_dx := BALL_START_DX;
                    next_dy := BALL_START_DY;

						  
						  IF (ball_count = 0) THEN 
						  
								game_over <= '1';
								

						  ELSE
								ball_count <= ball_count - 1;
						  END IF;
								
						  -- Check for game over/loss of ball ** This is related to ball counting
                    FOR r IN blocks_temp'RANGE(1) LOOP
                        FOR c IN blocks_temp'RANGE(2) LOOP
                            blocks_temp(r,c).enabled := '1';
                        END LOOP;
                    END LOOP;
                  --  block_hit := TRUE;
                END IF;

                -- Paddle Collision
                IF (next_ball_x + BALL_SIZE > paddle.x_min AND next_ball_x < paddle.x_max) AND
                   (next_ball_y + BALL_SIZE > paddle.y_min AND next_ball_y < paddle.y_max) THEN
                    IF current_ball_dy > 0 THEN
                        next_dy := -ABS(current_ball_dy);
                        next_ball_y := paddle.y_min - BALL_SIZE - 1;
                    END IF;
                END IF;

                -- Block Collision
                FOR r IN blocks_temp'RANGE(1) LOOP
                    FOR c IN blocks_temp'RANGE(2) LOOP
                        IF blocks_temp(r, c).enabled = '1' THEN
                            IF (next_ball_x + BALL_SIZE > blocks_temp(r, c).x_min AND next_ball_x < blocks_temp(r, c).x_max) AND
                               (next_ball_y + BALL_SIZE > blocks_temp(r, c).y_min AND next_ball_y < blocks_temp(r, c).y_max) THEN

                                blocks_temp(r, c).enabled := '0';
                                block_hit := TRUE;

                                pen_x1 := blocks_temp(r,c).x_max - next_ball_x;
                                pen_x2 := (next_ball_x + BALL_SIZE) - blocks_temp(r,c).x_min;
                                pen_y1 := blocks_temp(r,c).y_max - next_ball_y;
                                pen_y2 := (next_ball_y + BALL_SIZE) - blocks_temp(r,c).y_min;

                                min_pen_x := pen_x1;
                                IF pen_x2 < min_pen_x THEN min_pen_x := pen_x2; END IF;
                                min_pen_y := pen_y1;
                                IF pen_y2 < min_pen_y THEN min_pen_y := pen_y2; END IF;

                                IF min_pen_y < min_pen_x THEN
                                    IF current_ball_dy > 0 THEN
                                        next_dy := -ABS(current_ball_dy);
                                        next_ball_y := blocks_temp(r,c).y_min - BALL_SIZE - 1;
                                    ELSE
                                        next_dy := ABS(current_ball_dy);
                                        next_ball_y := blocks_temp(r,c).y_max + 1;
                                    END IF;
                                ELSE
                                    IF current_ball_dx > 0 THEN
                                        next_dx := -ABS(current_ball_dx);
                                        next_ball_x := blocks_temp(r,c).x_min - BALL_SIZE - 1;
                                    ELSE
                                        next_dx := ABS(current_ball_dx);
                                        next_ball_x := blocks_temp(r,c).x_max + 1;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END LOOP;
                END LOOP;

                current_ball_x  <= next_ball_x;
                current_ball_y  <= next_ball_y;
                current_ball_dx <= next_dx;
                current_ball_dy <= next_dy;
					

	
					 -- If we've hit a block, return new blocks state.
                IF block_hit THEN
                    blocks <= blocks_temp;
						  IF current_ball_y < 450 THEN
						  
								block_count <= block_count + 1;
						  
								IF block_count + 1 > 9 THEN -- FROZE SCREEN, MADE BLOCK COUNT WEIRD
						 
										game_over <= '1';
			
								END IF;
						 
						END IF;
					 END IF;
            END IF;
        END IF;
    END PROCESS ball_proc;
	 
	 process(block_count, ball_count)
    variable tens_digit_block : std_logic_vector(3 downto 0);
    variable ones_digit_block : std_logic_vector(3 downto 0);
	 variable tens_digit_ball : std_logic_vector(3 downto 0);
    variable ones_digit_ball : std_logic_vector(3 downto 0);
begin

    tens_digit_block := std_logic_vector(to_unsigned(block_count / 10, 4));
    ones_digit_block := std_logic_vector(to_unsigned(block_count mod 10, 4));
	 
	 tens_digit_ball := std_logic_vector(to_unsigned(ball_count / 10, 4));
    ones_digit_ball := std_logic_vector(to_unsigned(ball_count mod 10, 4));

    hex0 <= bcd_to_7seg(ones_digit_block);
    hex1 <= bcd_to_7seg(tens_digit_block);
	 
	 hex4 <= bcd_to_7seg(ones_digit_ball);
	 hex5 <= bcd_to_7seg(tens_digit_ball);
	 
	 hex2 <= "1111111"; 
	 hex3 <= "1111111";
	 
--	 IF block_count > 13 THEN  -- if blocks are all gone
--		CURRENT_ball_ena <= '0';
--	 END IF;
		
	 
end process;

END ARCHITECTURE Behavioral;
