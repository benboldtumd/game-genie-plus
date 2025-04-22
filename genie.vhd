library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GENIE is
port
    (
        cpu_address_bus_in      : in std_logic_vector(14 downto 0);
        romsel_N_in             : in std_logic;
        cpu_r_w_in              : in std_logic;
        m2_in                   : in std_logic;
        buffer_direction_in     : in std_logic;

        fc_cpu_data_bus         : inout std_logic_vector(7 downto 0);
        cart_cpu_data_bus       : inout std_logic_vector(7 downto 0);
        
        gui_active              : out std_logic
    );
end GENIE;

architecture logic of GENIE is
    signal gui_active_internal   : std_logic := '1';
    
    signal code_1_address        : std_logic_vector(14 downto 0);
    signal code_1_compare        : std_logic_vector(7 downto 0);
    signal code_1_compare_enable : std_logic := '0';
    signal code_1_replace        : std_logic_vector(7 downto 0);
    signal code_1_replace_enable : std_logic := '0';

    signal code_2_address        : std_logic_vector(14 downto 0);
    signal code_2_compare        : std_logic_vector(7 downto 0);
    signal code_2_compare_enable : std_logic := '0';
    signal code_2_replace        : std_logic_vector(7 downto 0);
    signal code_2_replace_enable : std_logic := '0';

    signal code_3_address        : std_logic_vector(14 downto 0);
    signal code_3_compare        : std_logic_vector(7 downto 0);
    signal code_3_compare_enable : std_logic := '0';
    signal code_3_replace        : std_logic_vector(7 downto 0);
    signal code_3_replace_enable : std_logic := '0';

--    signal code_4_address        : std_logic_vector(14 downto 0);
--    signal code_4_compare        : std_logic_vector(7 downto 0);
--    signal code_4_compare_enable : std_logic := '0';
--    signal code_4_replace        : std_logic_vector(7 downto 0);
--    signal code_4_replace_enable : std_logic := '0';

begin
    process( cpu_address_bus_in, romsel_N_in, cpu_r_w_in, m2_in )
        begin
        
        gui_active <= gui_active_internal;
        
        -- Manage the transfer of the data bus between the cart and the famicom:
        if( buffer_direction_in = '1' ) then  -- Data direction is going from the famicom out to the cart.
            fc_cpu_data_bus <= "ZZZZZZZZ";  -- Set the FC's data bus as an input.
            cart_cpu_data_bus <= fc_cpu_data_bus;  -- Copy the FC's data bus out to the cart's data bus.
        else  -- Data direction is going from the cart into the famicom.
            cart_cpu_data_bus <= "ZZZZZZZZ";  -- Set the cart's data bus as an input.
            
            -- Genie subsitiutions made here:
            if( (code_1_replace_enable = '1') AND
                (cpu_address_bus_in = code_1_address) AND
                (  (cart_cpu_data_bus = code_1_compare) OR
                   (code_1_compare_enable = '0') ) ) then
                fc_cpu_data_bus <= code_1_replace;
                
            elsif( (code_2_replace_enable = '1') AND
                (cpu_address_bus_in = code_2_address) AND
                (  (cart_cpu_data_bus = code_2_compare) OR
                   (code_2_compare_enable = '0') ) ) then
                fc_cpu_data_bus <= code_2_replace;
                
            elsif( (code_3_replace_enable = '1') AND
                (cpu_address_bus_in = code_3_address) AND
                (  (cart_cpu_data_bus = code_3_compare) OR
                   (code_3_compare_enable = '0') ) ) then
                fc_cpu_data_bus <= code_3_replace;
                
--            elsif( (code_4_replace_enable = '1') AND
--                (cpu_address_bus_in = code_4_address) AND
--                (  (cart_cpu_data_bus = code_4_compare) OR
--                   (code_4_compare_enable = '0') ) ) then
--                fc_cpu_data_bus <= code_4_replace;
                
            else  -- if no replacements were made:
                fc_cpu_data_bus <= cart_cpu_data_bus;  -- Copy the cart's data bus in to the FC's data bus.
                
            end if;
        end if;
        
        
        -- Manage register writes on the falling edge of M2:
		if( falling_edge(m2_in) ) then  -- Writes are accepted from the 6502 at the falling edge of M2.
            if( gui_active_internal = '1' ) then
                if( (romsel_N_in = '0') AND (cpu_r_w_in = '0') ) then
                    case cpu_address_bus_in(4 downto 0) is
                    
                        -- MASTER CONTROL
                        when "00000" =>  -- $8000 Master Control Register
                            gui_active_internal <= fc_cpu_data_bus(0);
                            -- Enable bits normally go here but I am enabling when the registers are written instead.
                            
                        -- CODE 1
                        when "00001" =>  -- $8001 Code 1 address high byte
                            code_1_address(14 downto 8) <= fc_cpu_data_bus(6 downto 0);
                        when "00010" =>  -- $8002 Code 1 address low byte
                            code_1_address(7 downto 0) <= fc_cpu_data_bus;
                        when "00011" =>  -- $8003 Code 1 compare byte
                            code_1_compare <= fc_cpu_data_bus;
                            code_1_compare_enable <= '1';
                        when "00100" =>  -- $8004 Code 1 replace byte
                            code_1_replace <= fc_cpu_data_bus;
                            code_1_replace_enable <= '1';
                            
                        -- CODE 2
                        when "00101" =>  -- $8005 Code 2 address high byte
                            code_2_address(14 downto 8) <= fc_cpu_data_bus(6 downto 0);
                        when "00110" =>  -- $8006 Code 2 address low byte
                            code_2_address(7 downto 0) <= fc_cpu_data_bus;
                        when "00111" =>  -- $8007 Code 2 compare byte
                            code_2_compare <= fc_cpu_data_bus;
                            code_2_compare_enable <= '1';
                        when "01000" =>  -- $8008 Code 2 replace byte
                            code_2_replace <= fc_cpu_data_bus;
                            code_2_replace_enable <= '1';
                            
                        -- CODE 3
                        when "01001" =>  -- $8009 Code 3 address high byte
                            code_3_address(14 downto 8) <= fc_cpu_data_bus(6 downto 0);
                        when "01010" =>  -- $800A Code 3 address low byte
                            code_3_address(7 downto 0) <= fc_cpu_data_bus;
                        when "01011" =>  -- $800B Code 3 compare byte
                            code_3_compare <= fc_cpu_data_bus;
                            code_3_compare_enable <= '1';
                        when "01100" =>  -- $800C Code 3 replace byte
                            code_3_replace <= fc_cpu_data_bus;
                            code_3_replace_enable <= '1';

--                        -- CODE 4
--                        when "01101" =>  -- $800D Code 4 address high byte
--                            code_4_address(14 downto 8) <= fc_cpu_data_bus(6 downto 0);
--                        when "01110" =>  -- $800E Code 4 address low byte
--                            code_4_address(7 downto 0) <= fc_cpu_data_bus;
--                        when "01111" =>  -- $800F Code 4 compare byte
--                            code_4_compare <= fc_cpu_data_bus;
--                            code_4_compare_enable <= '1';
--                        when "10000" =>  -- $8010 Code 4 replace byte
--                            code_4_replace <= fc_cpu_data_bus;
--                            code_4_replace_enable <= '1';

                        when others =>
                            null;  -- No effect.
                    end case;
                end if;
            end if;
        end if;
        
    end process;
    
end logic;
        
        
        
        
        