-- ECE 4110 VGA example
--
-- This code is the top level structural file for code that can
-- generate an image on a VGA display. The default mode is 640x480 at 60 Hz
--
-- Note: This file is not where the pattern/image is produced
--
-- Tyler McCormick 
-- 10/13/2019


library   ieee;
use       ieee.std_logic_1164.all;

entity vga_top_level is
	
	port(
	
		-- Inputs for image generation
			 led0			: out std_logic;
	 led1			: out std_logic;
	 led2			: out std_logic;
	 channel_a : in std_logic;
	 channel_b : in std_logic;
			fib_index : inout integer;
				  reset			  : in std_logic;
     --   key0				: in std_logic;                 
        hex0     : out std_logic_vector(6 downto 0);  -- 7-segment display output
		  hex1     : out std_logic_vector(6 downto 0) := "1111111";
		  hex2     : out std_logic_vector(6 downto 0) := "1111111";
		  hex3     : out std_logic_vector(6 downto 0) := "1111111";
		  hex4     : out std_logic_vector(6 downto 0) := "1111111";
		  hex5     : out std_logic_vector(6 downto 0) := "1111111";
		  max10_clk	: in std_logic	;
		sw : in std_logic_vector(2 downto 0);
		pixel_clk_m		:	IN	STD_LOGIC;     -- pixel clock for VGA mode being used 
		reset_n_m		:	IN	STD_LOGIC; --active low asycnchronous reset
		
		-- Outputs for image generation 
		
		h_sync_m		:	OUT	STD_LOGIC;	--horiztonal sync pulse
		v_sync_m		:	OUT	STD_LOGIC;	--vertical sync pulse 
		
		red_m      :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green_m    :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue_m     :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0') --blue magnitude output to DAC
	
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
		pixel_clk_m : in std_logic;
				 led0			: out std_logic;
	 led1			: out std_logic;
	 led2			: out std_logic;
	 channel_a : in std_logic;
	 channel_b : in std_logic;
			fib_index : inout integer;
			sw : in std_logic_vector(2 downto 0);
			disp_ena :  IN  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
			row      :  IN  INTEGER;    --row pixel coordinate
			column   :  IN  INTEGER;    --column pixel coordinate
			red      :  OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
			green    :  OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
			blue     :  OUT STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0')   --blue magnitude output to DAC
		
		);
		
	end component;
	
	component pe2_DeFelice is
    port (      
			fib_index : inout integer;
		  reset			  : in std_logic;
    --    key0				: in std_logic;                 
        hex0     : out std_logic_vector(6 downto 0);  -- 7-segment display output
		  hex1     : out std_logic_vector(6 downto 0) := "1111111";
		  hex2     : out std_logic_vector(6 downto 0) := "1111111";
		  hex3     : out std_logic_vector(6 downto 0) := "1111111";
		  hex4     : out std_logic_vector(6 downto 0) := "1111111";
		  hex5     : out std_logic_vector(6 downto 0) := "1111111";
		  max10_clk	: in std_logic		  	
		  
    );
end component;
	
	signal pll_OUT_to_vga_controller_IN, dispEn : STD_LOGIC;
	signal rowSignal, colSignal : INTEGER;
	
	
begin

-- Just need 3 components for VGA system 
	U1	:	vga_pll_25_175 port map(pixel_clk_m, pll_OUT_to_vga_controller_IN);
	U2	:	vga_controller port map(pll_OUT_to_vga_controller_IN, reset_n_m, h_sync_m, v_sync_m, dispEn, colSignal, rowSignal, open, open);
	U3	:	hw_image_generator port map(pixel_clk_m, led0, led1, led2, channel_a, channel_b, fib_index, sw, dispEn, rowSignal, colSignal, red_m, green_m, blue_m);
	U4 :  pe2_DeFelice port map(fib_index, reset, hex0, hex1, hex2, hex3, hex4, hex5, max10_clk);

end vga_structural;