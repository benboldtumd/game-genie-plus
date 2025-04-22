library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CART_VS_GUI_MODE_SELECTION is
port
    (
        gui_active_in           : in std_logic;
        
        romsel_N_in               : in std_logic;

        irq_N_in_from_cart      : in std_logic;
        ciram_ce_N_in_from_cart : in std_logic;
        ciram_a10_in_from_cart  : in std_logic;
        ppu_rd_N_in_from_fc     : in std_logic;
        ppu_a11_in              : in std_logic;
        
        irq_N_out_to_fc         : out std_logic;
        ciram_ce_N_out_to_fc    : out std_logic;
        ciram_a10_out_to_fc     : out std_logic;
        ppu_rd_N_out_to_cart    : out std_logic;
        genie_rom_ce_N_out      : out std_logic
    );
end CART_VS_GUI_MODE_SELECTION;

architecture logic of CART_VS_GUI_MODE_SELECTION is
    
begin

    process( gui_active_in )
    
        begin
        
        if( gui_active_in = '1' ) then  -- In this mode, the cart is "disconnected" and the GUI is running.

            -- Our level shifter is an inverter, so 0 means IRQ is not requested.
            irq_N_out_to_fc <= '0';  -- This prevents the cart from requesting an interrupt.
            
            -- For 1-chip style nametable/pattern table, always enable CIRAM /CE and connect PPU A11 to CIRAM A10.
            ciram_ce_N_out_to_fc <= '1';
            ciram_a10_out_to_fc <= ppu_a11_in;
            
            ppu_rd_N_out_to_cart <= '0';  -- Our level shifter is an inverter, so 0 means "PPU is not reading".

            -- Allow ROMSEL to control the Genie ROM /CE:
            genie_rom_ce_N_out <= romsel_N_in;
            -- Note the cart's /ROMSEL is still running, but since the data bus passes through the CPLD,
            -- and the CPLD won't be passing it, it will have no effect.

        else  -- The GUI is not running; the cart is "connected" now.

            -- Pass through all signals normally betwen cart and FC.
            irq_N_out_to_fc <= irq_N_in_from_cart;
            ciram_ce_N_out_to_fc <= ciram_ce_N_in_from_cart;
            ciram_a10_out_to_fc <= ciram_a10_in_from_cart;
            ppu_rd_N_out_to_cart <= ppu_rd_N_in_from_fc;
            
            -- Disable the Genie ROM /CE:
            genie_rom_ce_N_out <= '1';

        end if;
        
    end process;
    
end logic;
        
        
        
        
        