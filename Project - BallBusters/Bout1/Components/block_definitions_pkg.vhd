LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

PACKAGE block_definitions_pkg IS

    CONSTANT DEFAULT_NUM_ROWS       : INTEGER := 6;
    CONSTANT DEFAULT_BLOCKS_PER_ROW : INTEGER := 11;
    CONSTANT DEFAULT_BLOCK_WIDTH    : INTEGER := 35;
    CONSTANT DEFAULT_BLOCK_HEIGHT   : INTEGER := 10;
    CONSTANT DEFAULT_BLOCK_SPACE_X  : INTEGER := 5;
    CONSTANT DEFAULT_BLOCK_SPACE_Y  : INTEGER := 5;
    CONSTANT DEFAULT_START_X        : INTEGER := 35;
    CONSTANT DEFAULT_START_Y        : INTEGER := 50;

    -- == Type Definitions ==
    TYPE block_type IS RECORD
        x_min   : INTEGER;
        x_max   : INTEGER;
        y_min   : INTEGER;
        y_max   : INTEGER;
        enabled : STD_LOGIC;
    END RECORD block_type;

	 
    TYPE block_array_type IS ARRAY (INTEGER RANGE <>, INTEGER RANGE <>) OF block_type;

END PACKAGE block_definitions_pkg;
