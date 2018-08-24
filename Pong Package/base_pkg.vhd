library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ff_t;
use work.ff_d;
use work.clk_divider;
use work.simple_counter;
use work.video_sync_generator;

package base_pkg is

component clk_divider
	generic(
		n: integer
	);
	port(
		clk_in:	in 	std_logic;
		rst:		in 	std_logic;
		data_in: in		unsigned(n-1 downto 0);
		clk_out:	inout	std_logic
	);
end component;

component ff_d
	port(
		D:			in 	std_logic;
		clk_in:	in 	std_logic;
		clr:		in 	std_logic;
		set:		in 	std_logic;
		Q:			out 	std_logic
	); 
end component;

component ff_t
	port(
		T:			in 	std_logic;
		clk_in:	in 	std_logic;
		clr:		in 	std_logic;
		set:		in 	std_logic;
		Q:			inout 	std_logic
	); 
end component;

component simple_counter
	generic(
		n: integer
	);
	port(
		clk_in:	in 	std_logic;
		rst:		in 	std_logic;
		counter: out	unsigned(n-1 downto 0)
	);
end component;

component video_sync_generator is
	generic(
		H_sync_cycle: 		unsigned(10 downto 0) := to_unsigned(96, 11);
		hori_backporch: 	unsigned(10 downto 0) := to_unsigned(144, 11);
		hori_frontporch: 	unsigned(10 downto 0) := to_unsigned(16, 11);
		hori_line: 			unsigned(10 downto 0) := to_unsigned(800, 11);
		V_sync_cycle: 		unsigned(9 downto 0) := to_unsigned(2, 10);
		vert_backporch: 	unsigned(9 downto 0) := to_unsigned(34, 10);
		vert_frontporch: 	unsigned(9 downto 0) := to_unsigned(11, 10);
		vert_line: 			unsigned(9 downto 0) := to_unsigned(525, 10)
		);
	port(
		signal vga_clock: in 	std_logic;
		signal rst:			in		std_logic;
		
		signal vga_blank:	out 	std_logic;
		signal hsync: 		out 	std_logic;
		signal vsync:		out 	std_logic
	);
end component;

end package base_pkg;