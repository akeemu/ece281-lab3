--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port(
		i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        o_lights_L      : out   std_logic_vector(2 downto 0);
        o_lights_R      : out   std_logic_vector(2 downto 0)
	  );
	end component thunderbird_fsm;

	-- test I/O signals
	signal w_clk   : std_logic := '0';
	signal w_reset : std_logic := '0';
	signal w_left  : std_logic := '0';
	signal w_right : std_logic := '0';
	
	signal w_lights_L : std_logic_vector(2 downto 0) := "000";
	signal w_lights_R : std_logic_vector(2 downto 0) := "000";
	-- constants
	constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
	uut: thunderbird_fsm port map (
	       i_clk => w_clk,
	       i_reset => w_reset,
	       i_left => w_left,
	       i_right => w_right,
	       o_lights_L => w_lights_L,
	       o_lights_R => w_lights_R
	   );
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
	sim_proc: process
	begin
		-- sequential timing		
		w_reset <= '1';
		wait for k_clk_period*1;
		  assert w_lights_L = "000" report "bad reset left" severity failure;
		  assert w_lights_R = "000" report "bad reset right" severity failure;
		
		w_reset <= '0';
		wait for k_clk_period*1;
		
		-- left turn signal is activated and first turn signal light should turn on
		-- then the second and then third signals should progressively follow
		w_left <= '1'; wait for k_clk_period;
          assert w_lights_L = "001" report "should be LA on" severity failure;
        -- LA and LB should be on
        wait for k_clk_period;
          assert w_lights_L = "011" report "should be LA & LB on" severity failure;
        -- all left turn signals should be on
        wait for k_clk_period;
          assert w_lights_L = "111" report "should be LA, LB, & LC on" severity failure;
        -- cycle back to OFF, all lights off
        wait for k_clk_period;
          assert w_lights_L = "000" report "should be cycling to OFF state" severity failure;
        -- the turn signal pattern should be starting back up with LA
        wait for k_clk_period;
          assert w_lights_L = "001" report "should be cycling to OFF state" severity failure;
        -- even if input is changed and turned off in the middle of blinking pattern
        -- it should finish the cycle to the end until OFF state
        w_left <= '0'; wait for k_clk_period;
          assert w_lights_L = "011" report "should be LA, LB on even when input off" severity failure;
        -- all left lights should be on
        wait for k_clk_period;
          assert w_lights_L = "111" report "should be LA, LB, & LC on even when input off" severity failure; 
        -- blinking pattern cycles back to OFF state
        wait for k_clk_period;
          assert w_lights_L = "000" report "should be cycling to OFF state" severity failure;
        -- blinking pattern should be stopped and stay in OFF state
        wait for k_clk_period;
          assert w_lights_L = "000" report "should stay in OFF state" severity failure;   
        
        -- right turn signal is activated and first turn signal light should turn on
		-- then the second and then third signals should progressively follow
		w_right <= '1'; wait for k_clk_period;
          assert w_lights_R = "001" report "should be RA on" severity failure;
        -- RA and RB should be on
        wait for k_clk_period;
          assert w_lights_R = "011" report "should be RA & RB on" severity failure;
        -- all right turn signals should be on
        wait for k_clk_period;
          assert w_lights_R = "111" report "should be RA, RB, & RC on" severity failure;
        -- cycle back to OFF, all lights off
        wait for k_clk_period;
          assert w_lights_R = "000" report "should be cycling to OFF state" severity failure;
        -- the turn signal pattern should be starting back up with RA
        wait for k_clk_period;
          assert w_lights_R = "001" report "should be cycling to OFF state" severity failure;
        -- even if input is changed and turned off in the middle of blinking pattern
        -- it should finish the cycle to the end until OFF state
        w_right <= '0'; wait for k_clk_period;
          assert w_lights_R = "011" report "should be RA, RB on even when input off" severity failure;
        -- all right lights should be on
        wait for k_clk_period;
          assert w_lights_R = "111" report "should be RA, RB, & RC on even when input off" severity failure; 
        -- blinking pattern cycles back to OFF state
        wait for k_clk_period;
          assert w_lights_R = "000" report "should be cycling to OFF state" severity failure;
        -- blinking pattern should be stopped and stay in OFF state
        wait for k_clk_period;
          assert w_lights_R = "000" report "should stay in OFF state" severity failure;
        
        -- testing for reset during blinking pattern on left
        w_left <= '1'; wait for k_clk_period;
          assert w_lights_L = "001" report "should be LA on" severity failure;
        -- OFF state when reset
        w_reset <= '1'; wait for k_clk_period;
          assert w_lights_L = "000" report "should be OFF after reset" severity failure;
        -- check that pattern starts back up since signal still on
        w_reset <= '0'; wait for k_clk_period;
          assert w_lights_L = "001" report "should be LA on" severity failure;
        -- turn off signal input and wait for pattern to run through to OFF
        w_left <= '0'; wait for k_clk_period*4;
          assert w_lights_L = "000" report "should OFF after finishing pattern" severity failure;
        
        -- testing for reset during blinking pattern on right
        w_right <= '1'; wait for k_clk_period;
          assert w_lights_R = "001" report "should be RA on" severity failure;
        -- OFF state when reset
        w_reset <= '1'; wait for k_clk_period;
          assert w_lights_R = "000" report "should be OFF after reset" severity failure;
        -- check that pattern starts back up since signal still on
        w_reset <= '0'; wait for k_clk_period;
          assert w_lights_R = "001" report "should be RA on" severity failure;
        -- turn off signal input and wait for pattern to run through to OFF
        w_right <= '0'; wait for k_clk_period*4;
          assert w_lights_R = "000" report "should OFF after finishing pattern" severity failure;
        
        -- test that both right and left inputs on means hazard lights, ON
        w_left <= '1'; w_right <= '1'; wait for k_clk_period;
          assert w_lights_L = "111" report "all left lights should be on" severity failure;
          assert w_lights_R = "111" report "all right lights should be on" severity failure;
        -- blinking OFF state
        wait for k_clk_period;
          assert w_lights_L = "000" report "all left lights should be off" severity failure;
          assert w_lights_R = "000" report "all right lights should be off" severity failure;
        --blinking back ON
        wait for k_clk_period;
          assert w_lights_L = "111" report "all left lights should be on" severity failure;
          assert w_lights_R = "111" report "all right lights should be on" severity failure;
        -- turn off hazard lights and lights should stop blinking
        w_left <= '0'; w_right <= '0'; wait for k_clk_period;
          assert w_lights_L = "000" report "all left lights should be off" severity failure;
          assert w_lights_R = "000" report "all right lights should be off" severity failure;
          
        
		wait;
	end process;
	-----------------------------------------------------	
	
end test_bench;
