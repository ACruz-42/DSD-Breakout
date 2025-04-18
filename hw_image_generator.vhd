--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------
--
-- Altered 10/13/19 - Tyler McCormick 
-- Test pattern is now 8 equally spaced 
-- different color vertical bars, from black (left) to white (right)



-- Altered by Lauren DeFelice to complete pe2

LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY hw_image_generator IS
 
  PORT(
	
	 pixel_clk_m : in std_logic;
	 led0			: out std_logic;
	 led1			: out std_logic;
	 led2			: out std_logic;
	 channel_a : in std_logic;
	 channel_b : in std_logic;
	 fib_index : inout integer;
	 sw 		  : in std_logic_vector(2 downto 0);
	 max10_clk:  in std_logic; 
    disp_ena :  IN   STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
    red      :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
	 
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS

signal paddle_x 			: integer := 280;
signal ball_x  : INTEGER := 310;
signal channel_a_async 	: std_logic;
signal channel_a_sync 	: std_logic;
signal channel_b_async 	: std_logic;
signal channel_b_sync	: std_logic;
CONSTANT PADDLE_WIDTH 	: INTEGER := 70;
CONSTANT BALL_WIDTH 	: INTEGER := 10;
CONSTANT BALL_HEIGHT 	: INTEGER := 10;
CONSTANT PADDLE_HEIGHT 	: INTEGER := 10;
CONSTANT PADDLE_Y 		: INTEGER := 380;
CONSTANT BALL_Y 		: INTEGER := 190;


------------------------------------------------------------------------------------------------
  SIGNAL A_sync_0, A_sync_1, A_prev : STD_LOGIC := '0';
   SIGNAL B_sync_0, B_sync_1 : STD_LOGIC := '0';
   
   -- Position tracking
   SIGNAL current_pos : INTEGER RANGE 20 TO 610 := 280;  -- Initial centered position CHANGE THIS
SIGNAL currentballx_pos : INTEGER RANGE 20 TO 610 := 310;
SIGNAL currentbally_pos : INTEGER RANGE 20 TO 480 := 190;
SIGNAL ball_right	: STD_LOGIC := '1'; -- 1 is right, 0 is left
SIGNAL ball_up		: STD_LOGIC := '0'; -- 1 is up, 0 is down
--SIGNAL reset_ball 		: std_logic := '0';
   
   -- The clock was too fast as is, so we slow it down
   CONSTANT CLK_DIV : INTEGER := 10000;
   SIGNAL clk_count : INTEGER RANGE 0 TO CLK_DIV-1 := 0;
   SIGNAL slow_clk_enable : STD_LOGIC := '0';
   
   
   -- Encoder state tracking
   SIGNAL prev_AB : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
-----------------------------------------------------------------------------------------------

BEGIN


	
	
		
	process(disp_ena, row, column, fib_index)
	 BEGIN

IF(disp_ena = '1' ) THEN 
 
      IF(column < 20) THEN -- left edge
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
     ELSIF(row < 20) THEN -- top edge
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue	<= (OTHERS => '1');
		  
		  ----------------------- BEGIN BLOCKS ------------------------------------------------------
	----------------------- Middle Two Rows ------------------------------------------------------
		  
	  ELSIF(column < 85 AND column > 45 AND row < 80 AND row > 70 AND fib_index /= 0) THEN --1 ON
		
        red   <= (OTHERS => '1');		-- WHITE
        green <= (OTHERS => '1');
        blue  <= (OTHERS => '1');
		  
		  ELSIF(column < 85 AND column > 45 AND row < 80 AND row > 70 AND fib_index = 0) THEN --1 OFF
		
        red   <= (OTHERS => '0');		-- BLACK
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
    
			
		  
		ELSIF(column < 85 AND column > 45 AND row < 100 AND row > 90 AND fib_index /= 1) THEN --1 ON
		  
        red   <= (OTHERS => '1');
        green <= (OTHERS => '1');
        blue  <= (OTHERS => '1');
		  
		  ELSIF(column < 85 AND column > 45 AND row < 100 AND row > 90 AND fib_index = 1) THEN --1 OFF
		  
        red   <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
  
 
 
	 ELSIF(column < 135 AND column > 95 AND row < 80 AND row > 70 AND fib_index /= 2) THEN --2 ON

        red   <= (OTHERS => '1');
        green <= (OTHERS => '1');
        blue  <= (OTHERS => '1');
		  
		  ELSIF(column < 135 AND column > 95 AND row < 80 AND row > 70 AND fib_index = 2) THEN --2 OFF
		  
        red   <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
    
	 
	 
		ELSIF(column < 135 AND column > 95 AND row < 100 AND row > 90 AND fib_index /= 3) THEN --2 ON 
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 135 AND column > 95 AND row < 100 AND row > 90 AND fib_index = 3) THEN --2 OFF 
		  red   <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
	 
	 
	ELSIF(column < 185 AND column > 145 AND row < 80 AND row > 70 AND fib_index /= 4) THEN --3 ON
       red <= (OTHERS => '1');
       green  <= (OTHERS => '1');
		 blue <= (OTHERS => '1');
		 
		 ELSIF(column < 185 AND column > 145 AND row < 80 AND row > 70 AND fib_index = 4) THEN --3 OFF
       red 		<= (OTHERS => '0');
       green  	<= (OTHERS => '0');
		 blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 185 AND column > 145 AND row < 100 AND row > 90 AND fib_index /= 5) THEN --3 ON
        red		<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 185 AND column > 145 AND row < 100 AND row > 90 AND fib_index = 5) THEN --3 OFF
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	 
	ELSIF(column < 235 AND column > 195 AND row < 80 AND row > 70 AND fib_index /= 6) THEN --4 ON
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 235 AND column > 195 AND row < 80 AND row > 70 AND fib_index = 6) THEN --4 ON
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');

	 
	ELSIF(column < 235 AND column > 195 AND row < 100 AND row > 90 AND fib_index /= 7) THEN --4
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 235 AND column > 195 AND row < 100 AND row > 90 AND fib_index = 7) THEN --4
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 285 AND column > 245 AND row < 80 AND row > 70 AND fib_index /= 8) THEN --5
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 285 AND column > 245 AND row < 80 AND row > 70 AND fib_index = 8) THEN --5
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 285 AND column > 245 AND row < 100 AND row > 90 AND fib_index /= 9) THEN --5
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 285 AND column > 245 AND row < 100 AND row > 90 AND fib_index = 9) THEN --5
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  
		  
		  
	ELSIF(column < 335 AND column > 295 AND row < 80 AND row > 70 AND fib_index /= 10) THEN --6*
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 335 AND column > 295 AND row < 80 AND row > 70 AND fib_index = 10) THEN --6*
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  
		  

	 
	ELSIF(column < 335 AND column > 295 AND row < 100 AND row > 90 AND fib_index /= 11) THEN --6*
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 335 AND column > 295 AND row < 100 AND row > 90 AND fib_index = 11) THEN --6*
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 385 AND column > 345 AND row < 80 AND row > 70 AND fib_index /= 12) THEN --7
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 385 AND column > 345 AND row < 80 AND row > 70 AND fib_index = 12) THEN --7
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 385 AND column > 345 AND row < 100 AND row > 90 AND fib_index /= 13) THEN --7
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 385 AND column > 345 AND row < 100 AND row > 90 AND fib_index = 13) THEN --7
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 435 AND column > 395 AND row < 80 AND row > 70 AND fib_index /= 14) THEN --8
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 435 AND column > 395 AND row < 80 AND row > 70 AND fib_index = 14) THEN --8
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 435 AND column > 395 AND row < 100 AND row > 90 AND fib_index /= 15) THEN --8
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 435 AND column > 395 AND row < 100 AND row > 90 AND fib_index = 15) THEN --8
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 485 AND column > 445 AND row < 80 AND row > 70 AND fib_index /= 16) THEN --9
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 485 AND column > 445 AND row < 80 AND row > 70 AND fib_index = 16) THEN --9
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
  ELSIF(column < 485 AND column > 445 AND row < 100 AND row > 90 AND fib_index /= 17) THEN --9
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 485 AND column > 445 AND row < 100 AND row > 90 AND fib_index = 17) THEN --9
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	 
	ELSIF(column < 535 AND column > 495 AND row < 80 AND row > 70 AND fib_index /= 18) THEN --10
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 535 AND column > 495 AND row < 80 AND row > 70 AND fib_index = 18) THEN --10
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');

	 
	 
	ELSIF(column < 535 AND column > 495 AND row < 100 AND row > 90 AND fib_index /= 19) THEN --10
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 535 AND column > 495 AND row < 100 AND row > 90 AND fib_index = 19) THEN --10
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 585 AND column > 545 AND row < 80 AND row > 70 AND fib_index /= 20) THEN --11
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 585 AND column > 545 AND row < 80 AND row > 70 AND fib_index = 20) THEN --11
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	 
	ELSIF(column < 585 AND column > 545 AND row < 100 AND row > 90 AND fib_index /= 21) THEN --11
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  
		  ELSIF(column < 585 AND column > 545 AND row < 100 AND row > 90 AND fib_index = 21) THEN --11
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  
		  ----------------------- Bottom Two Rows ------------------------------------------------------
		  
		  ELSIF(column < 85 AND column > 45 AND row < 120 AND row > 110 AND fib_index /= 0) THEN --12 ON
		
        red   <= (OTHERS => '1');		-- WHITE
        green <= (OTHERS => '1');
        blue  <= (OTHERS => '1');
		  
		  ELSIF(column < 85 AND column > 45 AND row < 120 AND row > 110 AND fib_index = 0) THEN --12 OFF
		
        red   <= (OTHERS => '0');		-- BLACK
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
    
			
		  
		ELSIF(column < 85 AND column > 45 AND row < 140 AND row > 130 AND fib_index /= 1) THEN --12 ON
		  
        red   <= (OTHERS => '1');
        green <= (OTHERS => '1');
        blue  <= (OTHERS => '1');
		  
		  ELSIF(column < 85 AND column > 45 AND row < 140 AND row > 130 AND fib_index = 1) THEN --12 OFF
		  
        red   <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
		  
		  ELSIF(column < 135 AND column > 95 AND row < 120 AND row > 110 AND fib_index /= 2) THEN --13 ON

        red   <= (OTHERS => '1');
        green <= (OTHERS => '1');
        blue  <= (OTHERS => '1');
		  
		  ELSIF(column < 135 AND column > 95 AND row < 120 AND row > 110 AND fib_index = 2) THEN --13 OFF
		  
        red   <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
    
	 
	 
		ELSIF(column < 135 AND column > 95 AND row < 140 AND row > 130 AND fib_index /= 3) THEN --13 ON 
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 135 AND column > 95 AND row < 140 AND row > 130 AND fib_index = 3) THEN --13 OFF 
		  red   <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
	 
	 
	ELSIF(column < 185 AND column > 145 AND row < 120 AND row > 110 AND fib_index /= 4) THEN --14 ON
       red <= (OTHERS => '1');
       green  <= (OTHERS => '1');
		 blue <= (OTHERS => '1');
		 
		 ELSIF(column < 185 AND column > 145 AND row < 120 AND row > 110 AND fib_index = 4) THEN --14 OFF
       red 		<= (OTHERS => '0');
       green  	<= (OTHERS => '0');
		 blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 185 AND column > 145 AND row < 140 AND row > 130 AND fib_index /= 5) THEN --14 ON
        red		<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 185 AND column > 145 AND row < 140 AND row > 130 AND fib_index = 5) THEN --14 OFF
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	 
	ELSIF(column < 235 AND column > 195 AND row < 120 AND row > 110 AND fib_index /= 6) THEN --15 ON
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 235 AND column > 195 AND row < 120 AND row > 110 AND fib_index = 6) THEN --15 ON
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');

	 
	ELSIF(column < 235 AND column > 195 AND row < 140 AND row > 130 AND fib_index /= 7) THEN --15
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 235 AND column > 195 AND row < 140 AND row > 130 AND fib_index = 7) THEN --15
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 285 AND column > 245 AND row < 120 AND row > 110 AND fib_index /= 8) THEN --16
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 285 AND column > 245 AND row < 120 AND row > 110 AND fib_index = 8) THEN --16
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 285 AND column > 245 AND row < 140 AND row > 130 AND fib_index /= 9) THEN --16
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 285 AND column > 245 AND row < 140 AND row > 130 AND fib_index = 9) THEN --16
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  
		  
		  
	ELSIF(column < 335 AND column > 295 AND row < 120 AND row > 110 AND fib_index /= 10) THEN --17*
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 335 AND column > 295 AND row < 120 AND row > 110 AND fib_index = 10) THEN --17*
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  
		  

	 
	ELSIF(column < 335 AND column > 295 AND row < 140 AND row > 130 AND fib_index /= 11) THEN --17*
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 335 AND column > 295 AND row < 140 AND row > 130 AND fib_index = 11) THEN --17*
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 385 AND column > 345 AND row < 120 AND row > 110 AND fib_index /= 12) THEN --18
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 385 AND column > 345 AND row < 120 AND row > 110 AND fib_index = 12) THEN --18
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 385 AND column > 345 AND row < 140 AND row > 130 AND fib_index /= 13) THEN --18
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 385 AND column > 345 AND row < 140 AND row > 130 AND fib_index = 13) THEN --18
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 435 AND column > 395 AND row < 120 AND row > 110 AND fib_index /= 14) THEN --19
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 435 AND column > 395 AND row < 120 AND row > 110 AND fib_index = 14) THEN --19
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 435 AND column > 395 AND row < 140 AND row > 130 AND fib_index /= 15) THEN --19
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 435 AND column > 395 AND row < 140 AND row > 130 AND fib_index = 15) THEN --19
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 485 AND column > 445 AND row < 120 AND row > 110 AND fib_index /= 16) THEN --20
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 485 AND column > 445 AND row < 120 AND row > 110 AND fib_index = 16) THEN --20
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
  ELSIF(column < 485 AND column > 445 AND row < 140 AND row > 130 AND fib_index /= 17) THEN --20
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 485 AND column > 445 AND row < 140 AND row > 130 AND fib_index = 17) THEN --20
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	 
	ELSIF(column < 535 AND column > 495 AND row < 120 AND row > 110 AND fib_index /= 18) THEN --21
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 535 AND column > 495 AND row < 120 AND row > 110 AND fib_index = 18) THEN --21
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');

	 
	 
	ELSIF(column < 535 AND column > 495 AND row < 140 AND row > 130 AND fib_index /= 19) THEN --21
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 535 AND column > 495 AND row < 140 AND row > 130 AND fib_index = 19) THEN --21
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 585 AND column > 545 AND row < 120 AND row > 110 AND fib_index /= 20) THEN --22
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 585 AND column > 545 AND row < 120 AND row > 110 AND fib_index = 20) THEN --22
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	 
	ELSIF(column < 585 AND column > 545 AND row < 140 AND row > 130 AND fib_index /= 21) THEN --22
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  
		  ELSIF(column < 585 AND column > 545 AND row < 140 AND row > 130 AND fib_index = 21) THEN --22
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  
		  ----------------------- Top Two Two Rows ------------------------------------------------------
		  
		  ELSIF(column < 85 AND column > 45 AND row < 40 AND row > 30 AND fib_index /= 0) THEN --23 ON
		
        red   <= (OTHERS => '1');		-- WHITE
        green <= (OTHERS => '1');
        blue  <= (OTHERS => '1');
		  
		  ELSIF(column < 85 AND column > 45 AND row < 40 AND row > 30 AND fib_index = 0) THEN --23 OFF
		
        red   <= (OTHERS => '0');		-- BLACK
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
    
			
		  
		ELSIF(column < 85 AND column > 45 AND row < 60 AND row > 50 AND fib_index /= 1) THEN --23 ON
		  
        red   <= (OTHERS => '1');
        green <= (OTHERS => '1');
        blue  <= (OTHERS => '1');
		  
		  ELSIF(column < 85 AND column > 45 AND row < 60 AND row > 50 AND fib_index = 1) THEN --23 OFF
		  
        red   <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
  
 
 
	 ELSIF(column < 135 AND column > 95 AND row < 40 AND row > 30 AND fib_index /= 2) THEN --2 ON

        red   <= (OTHERS => '1');
        green <= (OTHERS => '1');
        blue  <= (OTHERS => '1');
		  
		  ELSIF(column < 135 AND column > 95 AND row < 40 AND row > 30 AND fib_index = 2) THEN --2 OFF
		  
        red   <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
    
	 
	 
		ELSIF(column < 135 AND column > 95 AND row < 60 AND row > 50 AND fib_index /= 3) THEN --2 ON 
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 135 AND column > 95 AND row < 60 AND row > 50 AND fib_index = 3) THEN --2 OFF 
		  red   <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue  <= (OTHERS => '0');
	 
	 
	ELSIF(column < 185 AND column > 145 AND row < 40 AND row > 30 AND fib_index /= 4) THEN --3 ON
       red <= (OTHERS => '1');
       green  <= (OTHERS => '1');
		 blue <= (OTHERS => '1');
		 
		 ELSIF(column < 185 AND column > 145 AND row < 40 AND row > 30 AND fib_index = 4) THEN --3 OFF
       red 		<= (OTHERS => '0');
       green  	<= (OTHERS => '0');
		 blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 185 AND column > 145 AND row < 60 AND row > 50 AND fib_index /= 5) THEN --3 ON
        red		<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 185 AND column > 145 AND row < 60 AND row > 50 AND fib_index = 5) THEN --3 OFF
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	 
	ELSIF(column < 235 AND column > 195 AND row < 40 AND row > 30 AND fib_index /= 6) THEN --4 ON
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 235 AND column > 195 AND row < 40 AND row > 30 AND fib_index = 6) THEN --4 ON
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');

	 
	ELSIF(column < 235 AND column > 195 AND row < 60 AND row > 50 AND fib_index /= 7) THEN --4
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 235 AND column > 195 AND row < 60 AND row > 50 AND fib_index = 7) THEN --4
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 285 AND column > 245 AND row < 40 AND row > 30 AND fib_index /= 8) THEN --5
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 285 AND column > 245 AND row < 40 AND row > 30 AND fib_index = 8) THEN --5
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 285 AND column > 245 AND row < 60 AND row > 50 AND fib_index /= 9) THEN --5
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 285 AND column > 245 AND row < 60 AND row > 50 AND fib_index = 9) THEN --5
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  
		  
		  
	ELSIF(column < 335 AND column > 295 AND row < 40 AND row > 30 AND fib_index /= 10) THEN --6*
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 335 AND column > 295 AND row < 40 AND row > 30 AND fib_index = 10) THEN --6*
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  
		  

	 
	ELSIF(column < 335 AND column > 295 AND row < 60 AND row > 50 AND fib_index /= 11) THEN --6*
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 335 AND column > 295 AND row < 60 AND row > 50 AND fib_index = 11) THEN --6*
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 385 AND column > 345 AND row < 40 AND row > 30 AND fib_index /= 12) THEN --7
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 385 AND column > 345 AND row < 40 AND row > 30 AND fib_index = 12) THEN --7
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 385 AND column > 345 AND row < 60 AND row > 50 AND fib_index /= 13) THEN --7
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 385 AND column > 345 AND row < 60 AND row > 50 AND fib_index = 13) THEN --7
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 435 AND column > 395 AND row < 40 AND row > 30 AND fib_index /= 14) THEN --8
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 435 AND column > 395 AND row < 40 AND row > 30 AND fib_index = 14) THEN --8
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 435 AND column > 395 AND row < 60 AND row > 50 AND fib_index /= 15) THEN --8
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 435 AND column > 395 AND row < 60 AND row > 50 AND fib_index = 15) THEN --8
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 485 AND column > 445 AND row < 40 AND row > 30 AND fib_index /= 16) THEN --9
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 485 AND column > 445 AND row < 40 AND row > 30 AND fib_index = 16) THEN --9
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
  ELSIF(column < 485 AND column > 445 AND row < 60 AND row > 50 AND fib_index /= 17) THEN --9
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 485 AND column > 445 AND row < 60 AND row > 50 AND fib_index = 17) THEN --9
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	 
	ELSIF(column < 535 AND column > 495 AND row < 40 AND row > 30 AND fib_index /= 18) THEN --10
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 535 AND column > 495 AND row < 40 AND row > 30 AND fib_index = 18) THEN --10
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');

	 
	 
	ELSIF(column < 535 AND column > 495 AND row < 60 AND row > 50 AND fib_index /= 19) THEN --10
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 535 AND column > 495 AND row < 60 AND row > 50 AND fib_index = 19) THEN --10
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	ELSIF(column < 585 AND column > 545 AND row < 40 AND row > 30 AND fib_index /= 20) THEN --11
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  ELSIF(column < 585 AND column > 545 AND row < 40 AND row > 30 AND fib_index = 20) THEN --11
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	 
	ELSIF(column < 585 AND column > 545 AND row < 60 AND row > 50 AND fib_index /= 21) THEN --11
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
		  
		  ELSIF(column < 585 AND column > 545 AND row < 60 AND row > 50 AND fib_index = 21) THEN --11
        red 	<= (OTHERS => '0');
        green  <= (OTHERS => '0');
        blue 	<= (OTHERS => '0');
		  

	 
	 -----------------------------------------------------------------------------------------------
		  ELSIF(column > ball_x AND column < ball_x + ball_width AND row >= ball_y AND 
row < ball_y + ball_height) THEN --Ball
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
		  
			
			
		
--ELSIF(column < 350 AND column > 280 AND row < 390 AND row > 380) THEN  -- Paddle (before) 

					
	ELSIF(column > paddle_x AND column < paddle_x + paddle_width AND row >= paddle_y AND 
row < paddle_y + paddle_height) THEN --Paddle

        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');

	  ELSIF(column < 640 AND column > 610 ) THEN -- Right edge
        red 	<= (OTHERS => '1');
        green  <= (OTHERS => '1');
        blue 	<= (OTHERS => '1');
	  ELSE 
		red 	<= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue 	<= (OTHERS => '0');
	
      END IF;
    ELSE                           --blanking time
      red 	<= (OTHERS => '0');
      green <= (OTHERS => '0');
      blue 	<= (OTHERS => '0');

		
    END IF;
	end process; 
	
	
	
  main_process: PROCESS(pixel_clk_m)
     VARIABLE hundreds, tens, ones : INTEGER;
VARIABLE ballxy  : INTEGER := 0;
     VARIABLE current_AB : STD_LOGIC_VECTOR(1 DOWNTO 0);
   BEGIN
     IF rising_edge(pixel_clk_m) THEN
       -- Synchronize encoder
       A_sync_0 <= channel_a;
       A_sync_1 <= A_sync_0;
       B_sync_0 <= channel_b;
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


--Ball Movement Test Area
IF rising_edge(pixel_clk_m) THEN
	
	IF (ball_x >= paddle_x AND ball_x < paddle_x + paddle_width AND ball_y + ball_height >= paddle_y ) THEN
        	ball_up <= '1';  -- ball goes up after hitting paddle
		  
  	ELSIF (ball_y <= 10 + ball_height) THEN
       		ball_up <= '0';  -- ball goes down after hitting top edge
		  
	ELSIF (ball_y < 480) THEN -- if ball goes off bottom of screen/misses paddle
    		currentballx_pos <= 320;  -- ball back into center of screen  -- ****THIS IS NOT WORKING YET******
    		currentbally_pos <= 240;  
    		ball_right <= '1';        -- initial direction is right
   		 ball_up <= '0';           -- start in a downward direction
		--reset_ball <= '1';
  	END IF;
	
	
		IF (ball_x >= 610 - ball_width) THEN  -- addressing ball hitting right edge condition
			ball_right <= '0'; -- turn left	  -- if right edge hit, change direction
		ELSIF (ball_x < 11 + ball_width) THEN -- if left edge hit, change direction 
			ball_right <= '1'; -- turn right
		END IF;
		
		
		
	-- horizontal movement left/right
	IF ball_right = '1' THEN
		 currentballx_pos <= currentballx_pos + 5; -- move right
	ELSE
		 currentballx_pos <= currentballx_pos - 5; -- move left
	END IF;

	-- vertical movement up/down
	IF ball_up = '0' THEN
		 currentbally_pos <= currentbally_pos + 5; -- move down
	ELSE
		 currentbally_pos <= currentbally_pos - 5; -- move up
	END IF;
	 
	 
		-- update ball position based on direction
		 IF ball_up = '0' THEN  -- going down
			  currentbally_pos <= currentbally_pos + 5; -- increment to travel down screen
		 ELSE  						-- going up
			  currentbally_pos <= currentbally_pos - 5; -- decrement to travel up screen
		 END IF;

	
	 
---------------------------------------------------------- 
--	 ** TRIED ADDING RESET_BALL SIGNAL, AND IT JUST MADE THE BALL FREEZE , WILL MOST LIKELY GET RID OF THIS?
-- THIS WAS AN ATTEMPT TO GET BALL TO COME OUT FROM MIDDLE OF SCREEN AFTER IT MISSES THE PADDLE/ EXITS SCREEN BOTTOM
--	 IF reset_ball = '1' THEN 
--    currentballx_pos <= 320;  -- Center horizontally
--    currentbally_pos <= 240;  -- Center vertically (or a bit higher)
--    ball_right <= '1';        -- initial direction is right
--    ball_up <= '0';           -- start in a downward direction
--	 END IF;
-----------------------------------------------

    -- update output signals
    ball_x <= currentballx_pos;
    ball_y <= currentbally_pos;
		
END IF;	



	
         
         -- We detect rotation based on mini-state machine
         CASE prev_AB & current_AB IS
           -- These are clockwise
           WHEN "0001" | "0111" | "1110" | "1000" => 
             IF current_pos > 20 THEN
               current_pos <= current_pos - 10;  --  move left
             END IF;
             
           -- These are counter-clockwise
           WHEN "0010" | "0100" | "1101" | "1011" => 
             IF current_pos < 610 - paddle_width THEN
               current_pos <= current_pos + 10;  -- move right
             END IF;
             
           -- No change
           WHEN OTHERS =>
             current_pos <= current_pos;
 				
         END CASE;
         
         -- Update previous state for next iteration
         prev_AB <= current_AB;
       END IF;
       
       -- Display logic (always runs)
       hundreds := current_pos / 100;
       tens := (current_pos / 10) MOD 10;
       ones := current_pos MOD 10;
       
       
       -- Set paddle position output
       paddle_x <= current_pos;
		 
     END IF;
   END PROCESS;
 

 
end behavior;
