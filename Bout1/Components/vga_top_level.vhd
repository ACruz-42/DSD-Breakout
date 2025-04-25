-- ECE 4110 VGA example
--
-- This code is the top level structural file for code that can
-- generate an image on a VGA display. The default mode is 640x480 at 60 Hz
--
-- Note: This file is not where the pattern/image is produced
--
-- Tyler McCormick 
-- 10/13/2019
---------------------------------
-- Adjusted slightly by Alex Cruz for PE2
-- 4/13/2025
-- Main changes: adjusted ports to better suit hw_image_generator

library   ieee;
use       ieee.std_logic_1164.all;

entity vga_top_level is
	
	port(
	

		-- Inputs for image generation
		
		pixel_clk_m		:	IN	STD_LOGIC;     -- pixel clock for VGA mode being used 
		reset_n_m		:	IN	STD_LOGIC; --active low asycnchronous reset
		paddle_move    :  IN integer;
		key0				: IN  STD_LOGIC;
		
	
		-- Outputs for image generation 
		
		h_sync_m		:	OUT	STD_LOGIC;	--horiztonal sync pulse
		v_sync_m		:	OUT	STD_LOGIC;	--vertical sync pulse 
		
		red_m      :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green_m    :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue_m     :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --blue magnitude output to DAC
		
		
		HEX0           : out STD_LOGIC_VECTOR(6 downto 0);
		HEX1           : out STD_LOGIC_VECTOR(6 downto 0);
		HEX2           : out STD_LOGIC_VECTOR(6 downto 0);
		HEX3           : out STD_LOGIC_VECTOR(6 downto 0);
		HEX4           : out STD_LOGIC_VECTOR(6 downto 0);
		HEX5           : out STD_LOGIC_VECTOR(6 downto 0)
	
	);
	
end vga_top_level;

architecture vga_structural of vga_top_level is

	component vga_pll_25_175 is 
	
		port(
		
			inclk0		:	IN  STD_LOGIC := '0';  -- Input clock that gets divided (50 MHz for max10)
			c0			:	OUT STD_LOGIC          -- Output clock for vga timing (25.175 MHz)
		
		);
		
	end component;
	
	component vga_controller is 
	
		port(
		
			pixel_clk	:	IN	STD_LOGIC;	--pixel clock at frequency of VGA mode being used
			reset_n		:	IN	STD_LOGIC;	--active low asycnchronous reset
			h_sync		:	OUT	STD_LOGIC;	--horiztonal sync pulse
			v_sync		:	OUT	STD_LOGIC;	--vertical sync pulse
			disp_ena	:	OUT	STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
			column		:	OUT	INTEGER;	--horizontal pixel coordinate
			row			:	OUT	INTEGER;	--vertical pixel coordinate
			n_blank		:	OUT	STD_LOGIC;	--direct blacking output to DAC
			n_sync		:	OUT	STD_LOGIC   --sync-on-green output to DAC
		
		);
		
	end component;
	
	component hw_image_generator is
	
		port(
		
			disp_ena :  IN  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
			row      :  IN  INTEGER;    --row pixel coordinate
			column   :  IN  INTEGER;    --column pixel coordinate
			paddle_move : IN INTEGER;
			clk		: IN STD_LOGIC;
			reset		: IN STD_LOGIC;
			key0		: IN  STD_LOGIC;
			red      :  OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
			green    :  OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
			blue     :  OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');   --blue magnitude output to DAC
			HEX0          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX1          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		   HEX2          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX3          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		   HEX4          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			HEX5          : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
		
		);
		
	end component;
	

	
	signal pll_OUT_to_vga_controller_IN, dispEn : STD_LOGIC;
	signal rowSignal, colSignal : INTEGER;
	
	
begin

-- Just need 3 components for VGA system 
	U1	:	vga_pll_25_175 port map(pixel_clk_m, pll_OUT_to_vga_controller_IN);
	U2	:	vga_controller port map(pll_OUT_to_vga_controller_IN, reset_n_m, h_sync_m, v_sync_m, dispEn, colSignal, rowSignal, open, open);
	U3 : hw_image_generator port map(
    disp_ena => dispEn,
    row => rowSignal,
    column => colSignal,
    paddle_move => paddle_move,
    clk => pixel_clk_m,
    reset => reset_n_m,
    key0 => key0,
    red => red_m,
    green => green_m,
    blue => blue_m,
    HEX0 => HEX0,
    HEX1 => HEX1,
    HEX2 => HEX2,
    HEX3 => HEX3,
    HEX4 => HEX4,
    HEX5 => HEX5);
	 
	


end vga_structural;
