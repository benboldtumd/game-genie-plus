library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADDRESS_OWNERSHIP_DECODER is
port
    (
        cpu_address_bus_in      : in std_logic_vector(14 downto 0);
        romsel_N_in             : in std_logic;
        cpu_r_w_in              : in std_logic;
        m2_in                   : in std_logic;

        fc_internal_address     : buffer std_logic;
        buffer_direction        : out std_logic
    );
end ADDRESS_OWNERSHIP_DECODER;

architecture logic of ADDRESS_OWNERSHIP_DECODER is
    
begin

    process( cpu_address_bus_in, romsel_N_in, cpu_r_w_in, m2_in )
    
        begin
        
        if( romsel_N_in = '0' ) then  -- ROMSEL_N low means the address >= $8000.
            fc_internal_address <= '0';
        elsif( unsigned(cpu_address_bus_in) < X"4020" ) then
            fc_internal_address <= '1';
        else
            fc_internal_address <= '0';
        end if;
        
        if( (cpu_r_w_in = '0') OR (m2_in = '0') ) then  -- CPU_RW low means the CPU is writing.  The data direction should always be going towards the cart for all addresses.
            buffer_direction <= '1';
        else  -- The CPU is reading.  The buffer direction should be going from the cart to the CPU *ONLY* if it isn't an internal address.
            if( fc_internal_address = '0' ) then
                -- The cart drives the data bus:
                buffer_direction <= '0';
            else
                -- When the CPU is reading from an internal address, the direction goes from the CPU to the cart for 2 reasons:
                  -- Prevent bus conflict.  The cart is never allowed to drive the bus in this range.
                  -- The cart may need to snoop those reads, for example MMC5 and probably rainbow.
                buffer_direction <= '1';
            end if;
        end if;
        
    end process;
    
end logic;
