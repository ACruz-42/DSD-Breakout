-- Alex Cruz
-- 4/13/2025
-- Created for HW7, adapted for PE2
-- Credits:
-- In general, Tyler McCormick's code was adapted for VGA controller
-- Sean Borchers (capstone teammate) was consulted for general encoder help
-- Cooper and Lauren (DSD teammates) were consulted for help with regards to fibonacci and general visual logic.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bout1 is
    port (
        -- Clock and Reset
        pixel_clk_m  : in std_logic;                     
        reset_n_m    : in std_logic;                     

        -- Rotary Encoder Inputs
        encoder_A    : in std_logic;
        encoder_B    : in std_logic;
        
        -- Accelerometer Interface
        GSENSOR_CS_N : out STD_LOGIC;
        GSENSOR_SCLK : out STD_LOGIC;
        GSENSOR_SDI  : inout STD_LOGIC;
        GSENSOR_SDO  : inout STD_LOGIC;
        
        -- VGA Outputs
        h_sync_m     : out std_logic;
        v_sync_m     : out std_logic;
        red_m        : out std_logic_vector(7 downto 0);
        green_m      : out std_logic_vector(7 downto 0);
        blue_m       : out std_logic_vector(7 downto 0);
        
        -- Hex Output
        HEX5         : out std_logic_vector(6 downto 0);
        HEX4         : out std_logic_vector(6 downto 0);    
        HEX3         : out std_logic_vector(6 downto 0);
        HEX2         : out std_logic_vector(6 downto 0);
        HEX1         : out std_logic_vector(6 downto 0);
        HEX0         : out std_logic_vector(6 downto 0)
    );
end entity bout1;

architecture rtl of bout1 is
    -- Pattern color signals from VGA
    signal pattern_red    : std_logic_vector(7 downto 0);
    signal pattern_green  : std_logic_vector(7 downto 0);
    signal pattern_blue   : std_logic_vector(7 downto 0);

    -- Accelerometer data
    signal data_x        : std_logic_vector(15 downto 0);
    signal data_y        : std_logic_vector(15 downto 0);
    signal data_z        : std_logic_vector(15 downto 0);

    -- Paddle position
    signal paddle_pos     : integer := 320;

    -- Component declarations
--    component accelerometer_top is
--        port(
--            max10_clk      : in STD_LOGIC;
--            GSENSOR_CS_N   : out STD_LOGIC;
--            GSENSOR_SCLK   : out STD_LOGIC;
--            GSENSOR_SDI    : inout STD_LOGIC;
--            GSENSOR_SDO    : inout STD_LOGIC;
--            dFix           : out STD_LOGIC_VECTOR(5 downto 0);
--            ledFix         : out STD_LOGIC_VECTOR(9 downto 0);
--            hex5           : out STD_LOGIC_VECTOR(6 downto 0);
--            hex4           : out STD_LOGIC_VECTOR(6 downto 0);
--            hex3           : out STD_LOGIC_VECTOR(6 downto 0);
--            hex2           : out STD_LOGIC_VECTOR(6 downto 0);
--            hex1           : out STD_LOGIC_VECTOR(6 downto 0);
--            hex0           : out STD_LOGIC_VECTOR(6 downto 0);
--            data_x         : buffer STD_LOGIC_VECTOR(15 downto 0);
--            data_y         : buffer STD_LOGIC_VECTOR(15 downto 0);
--            data_z         : buffer STD_LOGIC_VECTOR(15 downto 0)
--        );
--    end component;

    component joystick_controller is
        port(
            clk          : in std_logic;
            encoder_A    : in std_logic;
            encoder_B    : in std_logic;
				paddle_pos   : out integer
        );
    end component;

    component vga_top is
        port (
            pixel_clk_m  : in std_logic;
            reset_n_m    : in std_logic;
            paddle_move  : in integer;
            h_sync_m     : out std_logic;
            v_sync_m     : out std_logic;
            red_m        : out std_logic_vector(7 downto 0);
            green_m      : out std_logic_vector(7 downto 0);
            blue_m       : out std_logic_vector(7 downto 0);
				HEX0           : out STD_LOGIC_VECTOR(6 downto 0);
				HEX1           : out STD_LOGIC_VECTOR(6 downto 0);
				HEX2           : out STD_LOGIC_VECTOR(6 downto 0);
				HEX3           : out STD_LOGIC_VECTOR(6 downto 0);
				HEX4           : out STD_LOGIC_VECTOR(6 downto 0);
				HEX5           : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

begin
    -- Joystick controller with quadrature decoding
    joystick_controller_inst : joystick_controller
        port map (
            clk         => pixel_clk_m,
            encoder_A   => encoder_A,
            encoder_B   => encoder_B,
            paddle_pos => paddle_pos
        );

    -- VGA output
    vga_top_inst : vga_top
        port map (
            pixel_clk_m => pixel_clk_m,
            reset_n_m   => reset_n_m,
            paddle_move => paddle_pos,
            h_sync_m    => h_sync_m,
            v_sync_m    => v_sync_m,
            red_m       => red_m,
            green_m     => green_m,
            blue_m      => blue_m,
				HEX0 => HEX0,
				HEX1 => HEX1,
				HEX2 => HEX2,
				HEX3 => HEX3,
				HEX4 => HEX4,
				HEX5 => HEx5
        );

    -- Accelerometer
--    accelerometer_top_inst : accelerometer_top
--        port map (
--            max10_clk    => pixel_clk_m,
--            GSENSOR_CS_N => GSENSOR_CS_N,
--            GSENSOR_SCLK => GSENSOR_SCLK,
--            GSENSOR_SDI  => GSENSOR_SDI,
--            GSENSOR_SDO  => GSENSOR_SDO,
--            dFix         => open,
--            ledFix       => open,
--            hex5         => hex5,
--            hex4         => hex4,
--            hex3         => hex3,
--            hex2         => hex2,
--            hex1         => hex1,
--            hex0         => hex0,
--            data_x       => data_x,
--            data_y       => data_y,
--            data_z       => data_z
        --);

end architecture rtl;
