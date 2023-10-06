library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ssd_controller is
  Port (
    clk:    in STD_LOGIC;
    data:   in integer;
    sel:    buffer STD_LOGIC := '0';
    ssd:    out STD_LOGIC_VECTOR (6 downto 0)     
  );
end ssd_controller;

architecture Behavioral of ssd_controller is
    signal digit: integer; 
    signal clk_100Hz: STD_LOGIC := '0';
    -- Add any signal if you want
    signal pulse: std_logic := '0';
    signal count: integer := 0;
begin

    -- TODO:  Step 2 - Clock Divider 100MHz -> 100Hz
    process(clk) begin
        if rising_edge(clk) then
        if (count = ( 500000 - 1)) then
            pulse <= not pulse;
            count <= 0;
        else 
            count <= count + 1;
        end if;
        end if;
        clk_100hz <= pulse;
    end process;

    -- TODO: Step 3 - Modify the process to display both digits. You can create as many process as you want.
    process(clk_100Hz) begin
        if(rising_edge(clk_100Hz)) then
            if ( sel = '1') then
            digit <= data mod 10;
            elsif (sel = '0') then
            digit <= data/10;
            end if;
            sel <= not sel;
        end if;
    end process;

    -- TODO: Step 1 - Fill in the blank
    process(digit) begin
        case digit is
            when 0 => ssd <= "1111110";
            when 1 => ssd <= "0110000";
            when 2 => ssd <= "1101101";
            when 3 => ssd <= "1111001";
            when 4 => ssd <= "0110011";
            when 5 => ssd <= "1011011";
            when 6 => ssd <= "1011111";
            when 7 => ssd <= "1110000";
            when 8 => ssd <= "1111111"; --8
            when 9 => ssd <= "1111011"; --9
--            when "1010" => ssd <= "1110111"; --A
--            when "1011" => ssd <= "0011111"; --b
--            when "1100" => ssd <= "1001110"; --C
--            when "1101" => ssd <= "0111101"; --d
--            when "1110" => ssd <= "1001111"; --E
--            when "1111" => ssd <= "1000111"; --F
            when others => ssd <= "0000000";
        end case;
    end process;

end Behavioral;
