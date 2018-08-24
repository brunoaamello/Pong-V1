library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.std_match;

entity ff_d is
	port(
		D: 		in std_logic;
		clk_in: 	in std_logic;
		clr: 		in std_logic;
		set:		in std_logic;
		Q:			out std_logic
	);
end entity ff_d;

architecture synchronous of ff_d is
	begin
	process(clk_in) is
		begin
		if(rising_edge(clk_in)) then
			Q<=(not clr and (set or D));
		end if;
	end process;
end architecture synchronous;