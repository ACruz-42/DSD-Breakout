-- I'm not sure that this TB works.
-- It was created and used an iteration or two ago
-- It confirmed (more or less) that I was having clock issues
-- Alex Cruz
-- 4/13/2025

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hw_image_generator_tb IS
END ENTITY hw_image_generator_tb;

ARCHITECTURE behavioral OF hw_image_generator_tb IS

  -- Component declaration for the unit under test (UUT)
  COMPONENT hw_image_generator IS
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
      red           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      green         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      blue          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      HEX0          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      HEX1          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      HEX2          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      HEX3          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      HEX4          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
      HEX5          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
  END COMPONENT;

  -- Input signals
  SIGNAL tb_disp_ena      : STD_LOGIC := '0';
  SIGNAL tb_row           : INTEGER := 0;
  SIGNAL tb_column        : INTEGER := 0;
  SIGNAL tb_paddle_move   : INTEGER := 0;
  SIGNAL tb_clk           : STD_LOGIC := '0';
  SIGNAL tb_reset         : STD_LOGIC := '1'; -- Start with reset asserted

  -- Output signals
  SIGNAL tb_red           : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL tb_green         : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL tb_blue          : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL tb_HEX0          : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL tb_HEX1          : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL tb_HEX2          : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL tb_HEX3          : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL tb_HEX4          : STD_LOGIC_VECTOR(6 DOWNTO 0);
  SIGNAL tb_HEX5          : STD_LOGIC_VECTOR(6 DOWNTO 0);

  -- Clock generation constant
  CONSTANT clk_period : TIME := 20 ns; -- Adjust based on your pixel clock frequency

  -- Constant for the reset duration
  CONSTANT reset_duration : TIME := 100 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: hw_image_generator
    PORT MAP (
      disp_ena      => tb_disp_ena,
      row           => tb_row,
      column        => tb_column,
      paddle_move   => tb_paddle_move,
      clk           => tb_clk,
      reset         => tb_reset,
      red           => tb_red,
      green         => tb_green,
      blue          => tb_blue,
      HEX0          => tb_HEX0,
      HEX1          => tb_HEX1,
      HEX2          => tb_HEX2,
      HEX3          => tb_HEX3,
      HEX4          => tb_HEX4,
      HEX5          => tb_HEX5
    );

  -- Clock generation process
  clk_process: PROCESS
  BEGIN
    WHILE NOW < 100 us LOOP -- Run simulation for 100 microseconds
      tb_clk <= '0';
      WAIT FOR clk_period / 2;
      tb_clk <= '1';
      WAIT FOR clk_period / 2;
    END LOOP;
    WAIT; -- Keep the clock process running indefinitely after the loop
  END PROCESS;

  -- Reset generation process
  reset_process: PROCESS
  BEGIN
    tb_reset <= '1';
    WAIT FOR reset_duration;
    tb_reset <= '0';
    WAIT;
  END PROCESS;

  -- Stimulus process 
  stimulus_process: PROCESS
  BEGIN
    -- Apply initial conditions
    WAIT FOR reset_duration + (5 * clk_period); -- Wait for reset to de-assert and a few clock cycles

    WAIT FOR 90 us; -- Let the simulation run for the majority of the time

    REPORT "End of Simulation" SEVERITY FAILURE;
    WAIT; -- Keep the process alive to hold the 'failure' status
  END PROCESS;

END ARCHITECTURE behavioral;