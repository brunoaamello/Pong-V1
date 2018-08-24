library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.base_pkg.all;

entity image_generator is
	generic(
		field_h: 		unsigned(9 downto 0) 	:= to_unsigned(480, 10);
		field_w:			unsigned(9 downto 0) 	:= to_unsigned(640, 10);
		player_h:		unsigned(9 downto 0)		:= to_unsigned(151, 10);
		ball_size:		unsigned(9 downto 0)		:= to_unsigned(7, 10);
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
end entity image_generator;

architecture framebuilder of image_generator is
	signal				local_clk:		std_logic := '0';
	shared variable	address:			unsigned(18 downto 0);
	shared variable	xpos:				unsigned(18 downto 0);
	shared variable	ypos:				unsigned(18 downto 0);
	
	procedure updateAddress is
	begin
		address:=resize(ypos, 9) & resize(xpos, 10);
	end updateAddress;
	
	procedure writePixel is
		variable	ball_startx:			unsigned(9 downto 0);
		variable	ball_endx:				unsigned(9 downto 0);
		variable	ball_starty:			unsigned(9 downto 0);
		variable	ball_endy:				unsigned(9 downto 0);
		variable	left_endy:				unsigned(9 downto 0);
		variable	left_starty:			unsigned(9 downto 0);
		variable	right_endy:				unsigned(9 downto 0);
		variable	right_starty:			unsigned(9 downto 0);
		variable writeVal:				std_logic;
		constant top_boundary:			unsigned(9 downto 0)	:= field_h-boundary_size;
		constant bottom_boundary:		unsigned(9 downto 0)	:= boundary_size;
		constant	left_startx:			unsigned(9 downto 0)	:= to_unsigned(0,10);
		constant left_endx:				unsigned(9 downto 0)	:= boundary_size;
		constant right_startx:			unsigned(9 downto 0)	:= field_w-boundary_size;
		constant right_endx:				unsigned(9 downto 0)	:= field_w;
	begin
		ball_startx	:= ball_posx-(ball_size/2);
		ball_endx	:= ball_startx+ball_size;
		ball_starty	:= ball_posy-(ball_size/2);
		ball_endy	:= ball_starty+ball_size;
		left_endy	:= left_pos+(player_h/2);
		left_starty	:= left_endy-player_h;
		right_endy	:= right_pos+(player_h/2);
		right_starty:= right_endy-player_h;
		writeVal		:='0';
		if(ypos>=top_boundary) then
			writeVal:='1';
		end if;
		if(ypos<=bottom_boundary) then
			writeVal:='1';
		end if;
		if((xpos<=ball_endx and xpos>=ball_startx)and(ypos<=ball_endy and ypos>=ball_starty)) then
			writeVal:='1';
		end if;
		if((xpos<=left_endx and xpos>=left_startx)and(ypos<=left_endy and ypos>=left_starty)) then
			writeVal:='1';
		end if;
		if((xpos<=right_endx and xpos>=right_startx)and(ypos<=right_endy and ypos>=right_starty)) then
			writeVal:='1';
		end if;
		memwrite_data<=writeVal;
	end writePixel;
	
	begin
	local_clk<=clk_in;
--	process(clk_in) is
--	begin
--		if(rising_edge(clk_in)) then
--			local_clk<=not local_clk;
--		end if;
--	end process;
	
ADDRESSPOSCONTROL:
	process(local_clk, rst) is
	begin
		if(not rst) then
			xpos:=resize(field_w-1,19);
			ypos:=resize(field_h-1,19);
			memwrite_en<='0';
			updateAddress;
		elsif(rising_edge(local_clk)) then
			memwrite_en<='0';
			if(xpos<=0) then
				xpos:=resize(field_w-1,19);
				if(ypos<=0) then
					ypos:=resize(field_h-1,19);
				else
					ypos:=ypos-1;
				end if;
			else
				xpos:=xpos-1;
			end if;
			updateAddress;
			writePixel;
			memwrite_add<=std_logic_vector(address);
			memwrite_en<='1';
		end if;
	end process ADDRESSPOSCONTROL;
	
	memwrite_clk<=not clk_in;
	

	
	
	
end architecture framebuilder;