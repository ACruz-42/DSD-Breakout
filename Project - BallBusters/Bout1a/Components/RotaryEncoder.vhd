-- Sean Borchers was consulted (multiple times) as he
-- did the encoder programming for our capstone project.
-- He doesn't know VHDL, but was very helpful in generally
-- designing the logic.

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY joystick_controller IS
  PORT(
    clk         : IN  STD_LOGIC;     -- System clock
    encoder_A   : IN  STD_LOGIC;     -- Encoder channel A
    encoder_B   : IN  STD_LOGIC;     -- Encoder channel B
    paddle_pos : OUT INTEGER        -- Output paddle position
  );
END ENTITY joystick_controller;

ARCHITECTURE behavior OF joystick_controller IS
  -- Synchronization signals
  SIGNAL A_sync_0, A_sync_1, A_prev : STD_LOGIC := '0';
  SIGNAL B_sync_0, B_sync_1 : STD_LOGIC := '0';
  
  -- Position tracking
  SIGNAL current_pos : INTEGER RANGE 0 TO 999 := 320;  -- Initial centered position
  
  -- This is for debouncing
  CONSTANT CLK_DIV : INTEGER := 100000;
  SIGNAL clk_count : INTEGER RANGE 0 TO CLK_DIV-1 := 0;
  SIGNAL slow_clk_enable : STD_LOGIC := '0';
  
  
  -- Encoder state tracking
  SIGNAL prev_AB : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
  
  -- Hex-to-7-segment mapping function [left over from debugging]
  FUNCTION int_to_7seg(hex_digit : INTEGER) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    CASE hex_digit IS
      WHEN 0 => RETURN "0000001"; -- 0
      WHEN 1 => RETURN "1001111"; -- 1
      WHEN 2 => RETURN "0010010"; -- 2
      WHEN 3 => RETURN "0000110"; -- 3
      WHEN 4 => RETURN "1001100"; -- 4
      WHEN 5 => RETURN "0100100"; -- 5
      WHEN 6 => RETURN "0100000"; -- 6
      WHEN 7 => RETURN "0001111"; -- 7
      WHEN 8 => RETURN "0000000"; -- 8
      WHEN 9 => RETURN "0000100"; -- 9
      WHEN 10 => RETURN "0000010"; -- A
      WHEN 11 => RETURN "1100000"; -- b
      WHEN 12 => RETURN "0110001"; -- C
      WHEN 13 => RETURN "1000010"; -- d
      WHEN 14 => RETURN "0110000"; -- E
      WHEN 15 => RETURN "0111000"; -- F
      WHEN OTHERS => RETURN "1111111"; -- default (blank/error)
    END CASE;
  END FUNCTION;

BEGIN
  main_process: PROCESS(clk)
    --VARIABLE hundreds, tens, ones : INTEGER; -- For debug
    VARIABLE current_AB : STD_LOGIC_VECTOR(1 DOWNTO 0);
  BEGIN
    IF rising_edge(clk) THEN
      -- Synchronize encoder
      A_sync_0 <= encoder_A;
      A_sync_1 <= A_sync_0;
      B_sync_0 <= encoder_B;
      B_sync_1 <= B_sync_0;
      
      -- Clock divider for debouncing. I'm not sure if it works, but I saw
		-- A bunch of similar project onlines used debouncers, so I made one myself
      IF clk_count = CLK_DIV-1 THEN
        clk_count <= 0;
        slow_clk_enable <= '1';
      ELSE
        clk_count <= clk_count + 1;
        slow_clk_enable <= '0';
      END IF;
      
      -- Only process encoder on the slow clock to debounce
      IF slow_clk_enable = '1' THEN
        -- Make encoder state
        current_AB := A_sync_1 & B_sync_1;
        
        -- We detect rotation based on mini-state machine
        CASE prev_AB & current_AB IS
          -- These are clockwise
          WHEN "0001" | "0111" | "1110" | "1000" => 
            IF current_pos > 10 THEN
              current_pos <= current_pos - 10;  --  move left
            END IF;
            
          -- These are counter-clockwise
          WHEN "0010" | "0100" | "1101" | "1011" => 
            IF current_pos < 990 THEN
              current_pos <= current_pos + 10;  -- move right
            END IF;
            
          -- No change
          WHEN OTHERS =>
            current_pos <= current_pos;
				
        END CASE;
        
        -- Update previous state for next iteration
        prev_AB <= current_AB;
      END IF;
      
      -- Debugging artifacts
      --hundreds := current_pos / 100;
      --tens := (current_pos / 10) MOD 10;
      --ones := current_pos MOD 10;
      
      
      -- Set paddle position output
      paddle_pos <= current_pos;
    END IF;
  END PROCESS;
  
END ARCHITECTURE behavior;