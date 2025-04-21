LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fibonacci_hex_display IS
    GENERIC (
        FIB_MAX_VALUE : INTEGER := 1499999 -- Limit for sequence reset
    );
    PORT (
        -- Inputs
        clk         : IN  STD_LOGIC;
        reset_sync  : IN  STD_LOGIC; -- Synchronous reset
        fib_update  : IN  STD_LOGIC; -- Clock enable for sequence update

        output_bit  : OUT STD_LOGIC  -- Outputs a bit
    );
END ENTITY fibonacci_hex_display;

ARCHITECTURE Behavioral OF fibonacci_hex_display IS

    -- Internal signals for Fibonacci sequence state
    SIGNAL fib_current : INTEGER RANGE 0 TO FIB_MAX_VALUE := 1;
    SIGNAL fib_next    : INTEGER RANGE 0 TO FIB_MAX_VALUE*2 := 1; -- Needs larger range potentially

    -- Removed internal iHEX signals
    -- Removed int_to_7seg function

BEGIN

    -- Process to update the Fibonacci sequence (logic remains the same)
    fib_sequence_proc : PROCESS (clk)
        VARIABLE temp_fib : INTEGER := 1;
    BEGIN
        IF rising_edge(clk) THEN
            IF reset_sync = '1' THEN
                -- Reset values (using the ones from your provided code)
                fib_current <= 5; -- Or 1 depending on desired start
                fib_next    <= 1;
            ELSIF fib_update = '1' THEN
                IF fib_current >= FIB_MAX_VALUE THEN
                     -- Reset values (using the ones from your provided code)
                    fib_current <= 4; -- Or 1
                    fib_next    <= 1;
                ELSE
                    -- Check for potential overflow before adding
                    IF INTEGER'HIGH - fib_current < fib_next THEN
                        -- Handle overflow: Reset sequence (using the ones from your provided code)
                        fib_current <= 3; -- Or 1
                        fib_next <= 1;
                    ELSE
                        temp_fib    := fib_next;
                        fib_next    <= fib_current + fib_next;
                        fib_current <= temp_fib;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS fib_sequence_proc;

    -- Removed hex_display_proc

    -- Concurrent assignment for the new output bit
    -- Output '1' if fib_current is odd, '0' if even
    output_bit <= '1' WHEN (fib_current MOD 2) = 1 ELSE '0';

END ARCHITECTURE Behavioral;
