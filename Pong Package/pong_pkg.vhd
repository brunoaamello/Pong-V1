library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vga_driver;
use work.framebuffer;
use work.image_generator;
use work.position_collision_controller;

package pong_pkg is

component framebuffer is
	port
	(
		signal data: 		in 	std_logic_vector (0 downto 0);
		signal rdaddress: in 	std_logic_vector (18 downto 0);
		signal rdclock: 	in 	std_logic;
		signal wraddress:	in 	std_logic_vector (18 downto 0);
		signal wrclock:	in 	std_logic  := '1';
		signal wren: 		in 	std_logic  := '0';
		signal q:			out 	std_logic_vector (0 downto 0)
	);
end component;

component vga_driver is
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
		signal clk_in: 	in 	std_logic;
		signal rst:			in		std_logic;
		
		signal memread:	in		std_logic;
		signal memclock:	out	std_logic;
		signal memaddress:out	std_logic_vector(18 downto 0);
		
		signal r_data: 	out 	std_logic_vector(7 downto 0);
		signal g_data: 	out 	std_logic_vector(7 downto 0);
		signal b_data: 	out 	std_logic_vector(7 downto 0);
		signal vga_blank:	out 	std_logic;
		signal hsync: 		out 	std_logic;
		signal vsync:		out 	std_logic
	);
end component;

component image_generator is
	generic(
		field_h: 		unsigned(9 downto 0) 	:= to_unsigned(480, 10);
		field_w:			unsigned(9 downto 0) 	:= to_unsigned(600, 10);
		player_h:		unsigned(9 downto 0)		:= to_unsigned(151, 10);
		ball_size:		unsigned(9 downto 0)		:= to_unsigned(5, 10);
		boundary_size:	unsigned(9 downto 0)		:= to_unsigned(15, 10)
	);
	port(
		signal clk_in: 		in 	std_logic;
		signal rst:				in 	std_logic;
		signal ball_posx:		in		unsigned(9 downto 0);
		signal ball_posy:		in		unsigned(9 downto 0);
		signal left_pos:		in		unsigned(9 downto 0);
		signal right_pos:		in		unsigned(9 downto 0);
		
		signal memwrite_clk:	out 	std_logic;
		signal memwrite_add:	out 	std_logic_vector(18 downto 0);
		signal memwrite_data:out	std_logic;
		signal memwrite_en:	out 	std_logic
	);
end component;

component position_collision_controller is
	generic(
		field_h: 		unsigned(9 downto 0) 	:= to_unsigned(480, 10);
		field_w:			unsigned(9 downto 0) 	:= to_unsigned(600, 10);
		player_h:		unsigned(9 downto 0)		:= to_unsigned(151, 10);
		player_step:	unsigned(9 downto 0)		:= to_unsigned(5, 10);
		ball_size:		unsigned(9 downto 0)		:= to_unsigned(5, 10);
		ball_max_spdx:	unsigned(9 downto 0)		:= to_unsigned(1, 10);
		ball_max_spdy:	unsigned(9 downto 0)		:= to_unsigned(2, 10);
		boundary_size:	unsigned(9 downto 0)		:= to_unsigned(15, 10)
	);
	port(
		signal clk_in: 		in 	std_logic;
		signal rst:				in 	std_logic;
		
		signal left_up:		in 	std_logic;
		signal left_down:		in 	std_logic;
		signal right_up:		in 	std_logic;
		signal right_down:	in 	std_logic;
		
		signal pause:			in		std_logic;
		
		signal left_goal:		out	std_logic;
		signal right_goal:	out	std_logic;
		signal ball_posx:		out	unsigned(9 downto 0);
		signal ball_posy:		out	unsigned(9 downto 0);
		signal left_pos:		out	unsigned(9 downto 0);
		signal right_pos:		out	unsigned(9 downto 0)
	);
end component;

end package pong_pkg;