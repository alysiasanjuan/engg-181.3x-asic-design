library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_counter is
	generic
	(
		MIN_COUNT : natural := 0;
		MAX_COUNT : natural := 255
	);
	port
	(
		clk		  : in std_logic;
		reset	  : in std_logic;
		enable	  : in std_logic;
		q		  : out integer range MIN_COUNT to MAX_COUNT
	);

end entity;

architecture rtl of binary_counter is
begin

	process (clk)
		variable   cnt		   : integer range MIN_COUNT to MAX_COUNT;
	begin
		if (rising_edge(clk)) then
			if reset = '0' then
				-- Reset the counter to 0
				cnt := MIN_COUNT;
			elsif enable = '1' then
				-- Increment the counter if counting is enabled			   
				cnt := cnt + 1;
			end if;
		end if;

		-- Output the current count
		q <= cnt;
	end process;

end rtl;
