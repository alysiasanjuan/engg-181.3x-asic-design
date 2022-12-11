-- final_project_simulation_tb.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity final_project_simulation_tb is
end final_project_simulation_tb;

architecture tb of final_project_simulation_tb is
  signal clk, rst_n 			: std_logic; -- inputs
	signal sw 					: std_logic_vector(2 downto 0);
	signal pb_n 				: std_logic_vector(3 downto 0);
	signal led 					: std_logic_vector(17 downto 0); -- outputs
	signal h1, ah1, m1, am1, s1	   : std_logic_vector(5 downto 0);
	signal display1, display2	: std_logic_vector(5 downto 0);
	constant clk_period 		: time := 10 ns; -- Clock period definition
  
  begin
    -- connecting testbench signals with final_project_simulation.vhd
    UUT : entity work.final_project_simulation port map (
		clk => clk,
        rst_n => rst_n,
        sw => sw,
        pb_n => pb_n,
        led => led,
        h1 => h1, 
        ah1 => ah1, 
        m1 => m1, 
        am1 => am1, 
        s1 => s1,
        display1 => display1,
        display2 => display2
        );

    -- Clock process definitions
   clk_process :process
   begin
	   clk <= '0';
	   wait for clk_period/2;
	   clk <= '1';
	   wait for clk_period/2;
   end process;
   
   -- Stimulus process
   stim_proc: process
   begin 
    sw <= "000";
		pb_n <= "1111";
		rst_n <= '1';
		wait for 100 ns;
		-- hold reset state for 100 ns.
		--rst_n <= '0';
		--wait for 100 ns; 
		--rst_n <= '1';
		wait for 500 ns;
		-- change time
		sw <= "100";
		wait for 10 ns;
		pb_n(2) <= '0';
		wait for 1200 ns;
		pb_n(2) <= '0';
		sw <= "110";
		wait for 10 ns;
		pb_n(2) <= '0';
		pb_n(1) <= '0';
		wait for 10 ns;
		pb_n(2) <= '1';
		wait for 10 ns;
		pb_n(1) <= '1';
		sw <= "010";
		wait for 500 ns;
		sw <= "001";
   end process;
   
    
    
    
    -- inputs
    -- 00 at 0 ns
    -- 01 at 20 ns, as b is 0 at 20 ns and a is changed to 1 at 20 ns
    -- 10 at 40 ns
    -- 11 at 60 ns
    --a <= '0', '1' after 20 ns, '0' after 40 ns, '1' after 60 ns;
    --b <= '0', '1' after 40 ns;        
end tb ;