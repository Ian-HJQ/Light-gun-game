library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity bird is
    port (
        clk, hit, trigger : in std_logic;
        hsync, vsync : out std_logic;
        red, green, blue : out std_logic_vector(3 downto 0);
        sel:    buffer STD_LOGIC := '0';
        ssd     : OUT STD_LOGIC_VECTOR (6 downto 0)
        
    );
end bird;

architecture bird_arch of bird is
    --------- VGA CONSTANT START ---------
    -- row constants
    constant H_TOTAL : integer := 1344 - 1;
    constant H_SYNC : integer := 48 - 1;
    constant H_BACK : integer := 240 - 1;
    constant H_START : integer := 48 + 240 - 1;
    constant H_ACTIVE : integer := 1024 - 1;
    constant H_END : integer := 1344 - 32 - 1;
    constant H_FRONT : integer := 32 - 1;

    -- column constants
    constant V_TOTAL : integer := 625 - 1;
    constant V_SYNC : integer := 3 - 1;
    constant V_BACK : integer := 12 - 1;
    constant V_START : integer := 3 + 12 - 1;
    constant V_ACTIVE : integer := 600 - 1;
    constant V_END : integer := 625 - 10 - 1;
    constant V_FRONT : integer := 10 - 1;
    signal hcount, vcount : integer;
    --------- VGA CONSTANT END ---------

    -- for clock
    component clock_divider is
        generic (N : integer);
        port (
            clk : in std_logic;
            clk_out : out std_logic
        );
    end component;
    signal clk1Hz, clk100Hz, clk50MHz : std_logic;
    
    --for ssd
    COMPONENT ssd_controller
        PORT(
            clk:    in STD_LOGIC;
            data:   in integer;
            sel:    buffer STD_LOGIC := '0';
            ssd:    out STD_LOGIC_VECTOR (6 downto 0)  
        );
    END COMPONENT;

    -- for the position of bird
    signal X_STEP : integer := 2;
    signal Y_STEP : integer := 2;
    constant HEIGHT : integer := 96;
    constant WIDTH  : integer := 104;
    signal x : integer := H_START;
    signal y : integer := V_END;
    signal dx : integer := X_STEP;
    signal dy : integer := Y_STEP;
    
    --game variables
    signal edge_detect :std_logic_vector (1 downto 0);
    signal state : integer := 100;
    signal prev_state : integer := 0;
    signal score : integer := 0;
    signal lives : integer := 9;
    signal miss : integer := 0;
    signal rand : integer := 0; 

    -- for the color of the bird
    type colors is (C_Black, C_DarkGreen, C_LightGreen, C_Red, C_White, C_Pink);
    type T_2D is array(0 to 11, 0 to 12) of colors;
    constant fig : T_2D := ((C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_Black,C_Black,C_Black),
    (C_Black,C_DarkGreen,C_Black,C_Black,C_Black,C_Black,C_DarkGreen,C_LightGreen,C_LightGreen,C_LightGreen,C_DarkGreen,C_Black,C_Black),
    (C_Black,C_DarkGreen,C_DarkGreen,C_Black,C_Black,C_DarkGreen,C_LightGreen,C_White,C_White,C_White,C_White,C_DarkGreen,C_Black),
    (C_Black,C_DarkGreen,C_LightGreen,C_DarkGreen,C_Black,C_DarkGreen,C_LightGreen,C_White,C_White,C_Black,C_White,C_DarkGreen,C_Black),
    (C_Black,C_DarkGreen,C_LightGreen,C_LightGreen,C_DarkGreen,C_DarkGreen,C_LightGreen,C_White,C_Pink,C_White,C_White,C_Red,C_Red),
    (C_Black,C_DarkGreen,C_LightGreen,C_LightGreen,C_LightGreen,C_DarkGreen,C_LightGreen,C_White,C_White,C_White,C_DarkGreen,C_Black,C_Black),
    (C_Black,C_DarkGreen,C_LightGreen,C_LightGreen,C_LightGreen,C_LightGreen,C_LightGreen,C_LightGreen,C_DarkGreen,C_DarkGreen,C_Black,C_Black,C_Black),
    (C_Black,C_Black,C_DarkGreen,C_DarkGreen,C_LightGreen,C_LightGreen,C_Red,C_Red,C_Red,C_Red,C_Black,C_Black,C_Black),
    (C_Black,C_Black,C_Black,C_DarkGreen,C_LightGreen,C_Red,C_Red,C_Red,C_Red,C_Red,C_Black,C_Black,C_Black),
    (C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_LightGreen,C_Red,C_Red,C_Red,C_Red,C_Black,C_Black,C_Black,C_Black),
    (C_DarkGreen,C_LightGreen,C_LightGreen,C_LightGreen,C_DarkGreen,C_Red,C_Red,C_Red,C_Black,C_Black,C_Black,C_Black,C_Black),
    (C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black,C_Black));
    signal color : colors;
    
    --game over text
--    constant go: T_2D := ((C_DarkGreen,C_White,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_White,C_White,C_DarkGreen,C_White,C_White,C_White,C_DarkGreen),
--    (C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_DarkGreen,C_White,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White),
--    (C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White),
--    (C_White,C_DarkGreen,C_White,C_White,C_DarkGreen,C_White,C_White,C_White,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_White,C_White,C_DarkGreen),
--    (C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White),
--    (C_DarkGreen,C_White,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_White,C_White,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White));
--    constant go_height : integer := 48;
--    constant go_width : integer := 344;
    
--    --starting title screen
--    constant st: T_2D := ((C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_White,C_White,C_White),
--    (C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen),
--    (C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_White,C_White,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen),
--    (C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen),
--    (C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen),
--    (C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_White,C_White,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen,C_DarkGreen,C_White,C_DarkGreen,C_DarkGreen));
--    constant st_height : integer := 48;
--    constant st_width : integer := 312;

begin
    --------- VGA UTILITY START ---------
    -- generate 50MHz clock
    u_clk50mhz : clock_divider generic map(N => 1) port map(clk, clk50MHz);

    -- horizontal counter in [0, H_TOTAL]
    pixel_count_proc : process (clk50MHz)
    begin
        if (rising_edge(clk50MHz)) then
            if (hcount = H_TOTAL) then
                hcount <= 0;
            else
                hcount <= hcount + 1;
            end if;
        end if;
    end process pixel_count_proc;

    -- generate hsync in [0, H_SYNC)
    hsync_gen_proc : process (hcount) begin
        if (hcount <= H_SYNC) then
            hsync <= '1';
        else
            hsync <= '0';
        end if;
    end process hsync_gen_proc;

    -- vertical counter in [0, V_TOTAL]
    line_count_proc : process (clk50MHz)
    begin
        if (rising_edge(clk50MHz)) then
            if (hcount = H_TOTAL) then
                if (vcount = V_TOTAL) then
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
                end if;
            end if;
        end if;
    end process line_count_proc;

    -- generate vsync in [0, V_SYNC)
    vsync_gen_proc : process (hcount)
    begin
        if (vcount <= V_SYNC) then
            vsync <= '1';
        else
            vsync <= '0';
        end if;
    end process vsync_gen_proc;
    --------- VGA UTILITY END ---------

    -- generate 1Hz, 50Hz clock
    u_clk1hz : clock_divider generic map(N => 50000000) port map(clk, clk1Hz);
    u_clk100hz : clock_divider generic map(N => 500000) port map(clk, clk100Hz);
    
    --ssd 
    ssd_controller_0: ssd_controller
    PORT MAP(
        clk => clk,
        data => score,
        sel => sel,
        ssd => ssd
    );
    
    --rng
    process (clk100Hz) 
    variable clock_count : integer := 0;
    begin
        if rising_edge(clk100Hz) then
            clock_count := clock_count + 1;
            if (clock_count >= 2000000) then
                clock_count := 0;
            end if;
            rand <= clock_count * 13 + 123;
        end if;
    end process;
    
    --edge detection
    process(clk100Hz)
        begin
        if rising_edge(clk100Hz) then
            edge_detect <= edge_detect(0) & trigger;
        end if;
        end process;
        
    --change state
    process(clk100Hz)
    variable count: integer := 0;
    variable bird_count: integer := 0;
    begin
        if rising_edge(clk100Hz) then
            if (lives = 0) then
                state <= 101; 
            end if;  
            if (state = 0) then         --game running
                X_STEP <= 2 + (bird_count/10)*2;
                Y_STEP <= 2 + (bird_count/10)*2;
                if (edge_detect = "01") then
                    state <= 1;
                else
                    if(x + WIDTH >= H_END) then
                        dx <= -X_STEP;
                    end if;
                    if(x <= H_START) then
                        dx <= X_STEP;
                    end if;
                    if(y + HEIGHT >= V_END) then
                        dy <= -Y_STEP;
                    end if;
                    if(y <= V_START) then
                        dy <= Y_STEP;
                    end if;
                        x <= x + dx;
                        y <= y + dy;                    
                    end if;
                    
            elsif (state = 1) then      --black calibration screen 
                if (count <= 4) then
                    count := count + 1;
                else 
                    count := 0;
                    state <= 2;
                end if;    
                
            elsif (state = 2) then      --white hitbox
                if (count <= 2) then
                    count := count + 1;
                else
                    count := 0;
                    if (hit = '1') then
                        score <= score + 1;
                        miss <= 0;
                        if (score >= 99) then
                            score <= 0;
                        end if;
                        state <= 3;
                    else
                        miss <= miss + 1;
                        lives <= lives - 1;
                        if (miss >= 2) then
                           miss <= 0;
                           state <= 4;    
                        else
                            state <= 0;
                        end if;
                    end if;
                end if;
                
            elsif (state = 3) then      --bird gets hit
                if (count <= 100) then
                    count := count + 1;
                else
                    count := 0;
                    if (score >= 99) then
                        state <= 101;
                    else
                        bird_count := bird_count + 1;
                        if ( (bird_count > 1) and (bird_count mod 10 = 0 )) then
                            lives <= lives + 1;
                        end if;
                        x <= (rand mod (H_ACTIVE)) + H_START;
                        y <= V_END;
                        state <= 0;
                    end if;
                end if;
                
            elsif (state = 4) then      --bird flies away
                y <= y - 4;
                if (y + HEIGHT <= V_START) then
                    count := count + 1;
                    if (count = 100) then
                        count := 0;
                        bird_count := bird_count + 1;
                        if ( (bird_count > 1) and (bird_count mod 10 = 0 )) then
                            lives <= lives + 1;
                        end if;
                        x <= (rand mod (H_ACTIVE)) + H_START;
                        y <= V_END;
                        state <= 0;
                    end if;
                end if;
                     
            elsif (state = 100) then      --start screen
                if (edge_detect = "01") then
                    lives <= 9;
                    miss <= 0;
                    dx <= 2;
                    dy <= 2;
                    bird_count := 0;
                    score <= 0;
                    x <= (rand mod (H_ACTIVE)) + H_START;
                    y <= V_END;                
                    state <= 0;
                end if;
                
            elsif (state = 101) then      --game over screen
                if (edge_detect = "01") then
                    lives <= 9;
                    miss <= 0;
                    dx <= 2;
                    dy <= 2;
                    score <= 0;
                    x <= (rand mod (H_ACTIVE)) + H_START;
                    y <= V_END;
                    state <= 100;
                end if;
            end if;
        end if;
    end process;

    -- select the correct color of the pixel (hcount, vcount).
    process (hcount, vcount, x, y)
    begin
    if (state < 100) then
        if ((hcount >= H_START and hcount < H_END) and (vcount >= V_START and vcount < V_TOTAL)) then
            if (x <= hcount and hcount < x + WIDTH and y <= vcount and vcount < y + HEIGHT) then
                if (state = 0 or state = 4) then
                    if (dx > 0) then
                    color <= fig((vcount-y)/8, (hcount-x)/8);
                    else
                    color <= fig((vcount-y)/8, (x + WIDTH - hcount)/8);
                    end if;
                elsif (state = 1) then
                    color <= C_Black;
                elsif (state = 2) then
                    color <= C_White;      
                elsif (state = 3) then
                    if (dx > 0) then
                        if (fig((vcount-y)/8, (hcount-x)/8) /= C_BLACK) then
                            color <= C_Red;
                        else
                            color <= C_Black;
                        end if;
                    else
                        if (fig((vcount-y)/8, (x + WIDTH - hcount)/8) /= C_BLACK) then
                            color <= C_Red;
                        else
                            color <= C_Black;
                        end if;
                    end if;
                end if;
            else
                color <= C_Black;
            end if;
        else
            color <= C_Black;
        end if;   
     else
        if ((hcount >= 747 and hcount < 851) and (vcount >= 252 and vcount < 348)) then
            if (state = 100) then
                color <= fig((vcount-252)/8, (hcount-747)/8);
            elsif (state = 101) then
                if (fig((vcount-252)/8, (hcount-747)/8) /= C_BLACK) then
                    color <= C_White;
                else
                    color <= C_Black;
                end if;
            end if;
        else
        color <= C_Black;
        end if;
     end if;
    end process;

    -- output the correct RGB according to the signal 'color'.
    process (color)
    begin
        case(color) is
            when C_Black =>
                red <= "0000"; green <= "0000"; blue <= "0000";
            when C_DarkGreen =>
                red <= "0000"; green <= "0100"; blue <= "0000";
            when C_LightGreen =>
                red <= "0000"; green <= "1111"; blue <= "0000";
            when C_Red =>
                red <= "1111"; green <= "0000"; blue <= "0000";
            when C_White =>
                red <= "1111"; green <= "1111"; blue <= "1111";
            when C_Pink =>
                red <= "1111"; green <= "1000"; blue <= "1000";
            when others =>
                red <= "0000"; green <= "0000"; blue <= "0000";
        end case;
    end process; 
end bird_arch;