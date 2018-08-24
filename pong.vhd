library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;
use work.base_pkg.all;

entity pong is
	port(
		signal clk_in: 			in 	std_logic;
		signal rst:					in 	std_logic;
		signal pause:				in		std_logic;
		
		signal left_ctr_A:		in 	std_logic;
		signal left_ctr_B:		in 	std_logic;
		signal right_ctr_A:		in 	std_logic;
		signal right_ctr_B:		in 	std_logic;
		
		signal r_data: 			out 	std_logic_vector(7 downto 0);
		signal g_data: 			out 	std_logic_vector(7 downto 0);
		signal b_data: 			out 	std_logic_vector(7 downto 0);
		signal clk_vga:			out	std_logic;
		signal hsync:				out	std_logic;	
		signal vsync:				out	std_logic;
		signal vga_blank:			out	std_logic
	);
end entity pong;

architecture interconnect of pong is
	signal 				vga_clk: 		std_logic								:= '0';
	signal				vga_ctrl_clk:	std_logic								:= '1';
	signal				int_rst: 		std_logic								:= '0';
	signal				memwrite_clk:	std_logic								:= 'L';
	signal				memwrite_add:	std_logic_vector(18 downto 0)		:= (others=>'L');
	signal				memwrite_data:	std_logic_vector(0 downto 0);
	signal				memwrite_en:	std_logic								:= '0';
	signal				memread_clk:	std_logic								:= 'L';
	signal				memread_add:	std_logic_vector(18 downto 0)		:= (others=>'L');
	signal				memread_data:	std_logic_vector(0 downto 0);
	
	signal				refresh_clk:	std_logic								:= '0';
	signal				left_goal:		std_logic								:= '0';
	signal				right_goal:		std_logic								:= '0';
	signal				int_pause:		std_logic								:= '0';
	
	signal 				ball_posx:		unsigned(9 downto 0)					:= to_unsigned(277, 10);
	signal 				ball_posy:		unsigned(9 downto 0)					:= to_unsigned(239, 10);
	signal 				left_pos:		unsigned(9 downto 0)					:= to_unsigned(239, 10);
	signal 				right_pos:		unsigned(9 downto 0)					:= to_unsigned(239, 10);
	
begin
	int_rst<=rst;
	int_pause<=pause;

CLKHALVING:
	process(clk_in) is
	begin
		if(rising_edge(clk_in)) then
			vga_clk<=not vga_clk;
		end if;
	end process CLKHALVING;
	
	vga_ctrl_clk<=vga_clk;
	clk_vga<= not vga_clk;
	
	
CLK60HZ:
	process(clk_in) is
		variable count: unsigned(31 downto 0) := to_unsigned(0, 32);
	begin
		if(rising_edge(clk_in)) then
			if(count=to_unsigned(833333,32)) then
				count := to_unsigned(0,32);
				refresh_clk<=not refresh_clk;
			else
				count:=count+1;
			end if;
		end if;
	end process CLK60HZ;

VGADRIVER: 	vga_driver port map(vga_ctrl_clk, int_rst, memread_data(0), memread_clk, memread_add, r_data, g_data, b_data, vga_blank, hsync, vsync);
MEMORY:		framebuffer port map(memwrite_data, memread_add, memread_clk, memwrite_add, memwrite_clk, memwrite_en, memread_data);
IMAGEGEN:	image_generator port map(clk_in, int_rst, ball_posx, ball_posy, left_pos, right_pos, memwrite_clk, memwrite_add, memwrite_data(0), memwrite_en);
POSCOLCTR:	position_collision_controller port map(refresh_clk, int_rst and ( not left_goal and not right_goal), left_ctr_A and not left_ctr_B, left_ctr_B and not left_ctr_A,
																	right_ctr_A and not right_ctr_B, right_ctr_B and not right_ctr_A, int_pause, left_goal, right_goal, ball_posx, ball_posy, left_pos, right_pos);
	
end architecture interconnect;