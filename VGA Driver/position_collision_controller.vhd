library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.base_pkg.all;

entity position_collision_controller is
	generic(
		field_h: 		unsigned(9 downto 0) 	:= to_unsigned(480, 10);
		field_w:			unsigned(9 downto 0) 	:= to_unsigned(640, 10);
		player_h:		unsigned(9 downto 0)		:= to_unsigned(151, 10);
		player_step:	unsigned(9 downto 0)		:= to_unsigned(30, 10);
		ball_size:		unsigned(9 downto 0)		:= to_unsigned(7, 10);
		ball_max_spdx:	unsigned(9 downto 0)		:= to_unsigned(8, 10);
		ball_max_spdy:	unsigned(9 downto 0)		:= to_unsigned(4, 10);
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
end entity position_collision_controller;

architecture ponger of position_collision_controller is
	constant 			midx:		unsigned(9 downto 0) 	:=	resize(field_w/2, 10);
	constant 			midy:		unsigned(9 downto 0) 	:=	resize(field_h/2, 10);
	
	signal 				bpx:		signed(10 downto 0) 		:=	signed(resize(midx, 11));
	signal 				bpy:		signed(10 downto 0) 		:=	signed(resize(midy, 11));
	shared variable	nbpx:		signed(10 downto 0) 		:=	signed(resize(midx, 11));
	shared variable	nbpy:		signed(10 downto 0) 		:=	signed(resize(midy, 11));
	
	signal				bspdx:	signed(10 downto 0)		:=	signed(resize(ball_max_spdx, 11));
	signal				bspdy:	signed(10 downto 0)		:=	-signed(resize(ball_max_spdy, 11));
	
	signal				lgoal:	std_logic					:= '0';
	signal				rgoal:	std_logic					:= '0';
	
	signal				lposoff:	signed(10 downto 0)		:= to_signed(0, 11);
	signal				rposoff:	signed(10 downto 0)		:= to_signed(0, 11);
	shared variable 	nlposoff:signed(10 downto 0)		:= to_signed(0, 11);
	shared variable	nrposoff:signed(10 downto 0)		:= to_signed(0, 11);
	
	signal				lup:		std_logic					:= '0';
	signal				lupped:	std_logic					:= '0';
	signal				ldown:	std_logic					:= '0';
	signal				ldowned:	std_logic					:= '0';
	signal				rup:		std_logic					:= '0';
	signal				rupped:	std_logic					:= '0';
	signal				rdown:	std_logic					:= '0';
	signal				rdowned:	std_logic					:= '0';
	
	procedure processCollisions is
		variable	ball_startx:				signed(10 downto 0);
		variable	ball_endx:					signed(10 downto 0);
		variable	ball_starty:				signed(10 downto 0);
		variable	ball_endy:					signed(10 downto 0);
		variable	left_top_boundary:		signed(10 downto 0);
		variable	left_bottom_boundary:	signed(10 downto 0);
		variable	right_top_boundary:		signed(10 downto 0);
		variable	right_bottom_boundary:	signed(10 downto 0);
		variable offset:						signed(10 downto 0);
		constant top_boundary:				signed(10 downto 0)	:= signed(resize(field_h-boundary_size,11));
		constant bottom_boundary:			signed(10 downto 0)	:= signed(resize(boundary_size,11));
		constant left_boundary:				signed(10 downto 0)	:= signed(resize(boundary_size,11));
		constant right_boundary:			signed(10 downto 0)	:= signed(resize(field_w-boundary_size,11));
		constant left_right_boundary:		signed(10 downto 0)	:= signed(resize(boundary_size,11));
		constant right_left_boundary:		signed(10 downto 0)	:= signed(resize(field_w-boundary_size, 11));
	begin
		ball_startx				:= nbpx-signed(resize(ball_size/2,11));
		ball_endx				:= ball_startx+signed(resize(ball_size,11));
		ball_starty				:= nbpy-signed(resize(ball_size/2,11));
		ball_endy				:= ball_starty+signed(resize(ball_size,11));
		left_top_boundary		:= signed(resize(midy+(player_h/2),11))+nlposoff;
		left_bottom_boundary	:= left_top_boundary-signed(resize(player_h,11));
		right_top_boundary	:= signed(resize(midy+(player_h/2),11))+nrposoff;
		right_bottom_boundary:= right_top_boundary-signed(resize(player_h,11));
		offset					:= to_signed(0,11);
--PLAYER PROCESSING
	--LEFT
		if(left_bottom_boundary<=bottom_boundary) then
			offset := (bottom_boundary - left_bottom_boundary)+1;
			nlposoff := nlposoff+offset;
			left_top_boundary := left_top_boundary+offset;
			left_bottom_boundary	:= left_bottom_boundary+offset;
		end if;
		if(left_top_boundary>top_boundary) then
			offset := (left_top_boundary - top_boundary);
			nlposoff := nlposoff-offset;
			left_top_boundary := left_top_boundary-offset;
			left_bottom_boundary	:= left_bottom_boundary-offset;
		end if;
	--RIGHT
		if(right_bottom_boundary<=bottom_boundary) then
			offset := (bottom_boundary - right_bottom_boundary)+1;
			nrposoff := nrposoff+offset;
			right_top_boundary := right_top_boundary+offset;
			right_bottom_boundary := right_bottom_boundary+offset;
		end if;
		if(right_top_boundary>top_boundary) then
			offset := (right_top_boundary - top_boundary);
			nrposoff := nrposoff-offset;
			right_top_boundary := right_top_boundary-offset;
			right_bottom_boundary := right_bottom_boundary-offset;
		end if;
--BALL PROCESSING
	--GOAL
		if(ball_startx<=0) then
			rgoal<='1';
		else
			rgoal<='0';
		end if;
		if(ball_endx>=signed(resize(field_w,11))) then
			lgoal<='1';
		else
			lgoal<='0';
		end if;
	--PLAYERS
		--LEFT
		if(ball_startx<=left_boundary) then
			if(ball_starty<left_top_boundary and ball_endy>=left_bottom_boundary) then
				offset := (left_boundary - ball_startx)+1;
				nbpx := nbpx+offset;
				ball_startx := ball_startx+offset;
				ball_endx	:= ball_endx+offset;
				if(bspdx<0) then
					bspdx <= -bspdx;
				end if;				
			end if;
			if(ball_endy>=left_bottom_boundary and ball_starty<left_top_boundary) then
				offset := (left_boundary - ball_startx)+1;
				nbpx := nbpx+offset;
				ball_startx := ball_startx+offset;
				ball_endx	:= ball_endx+offset;
				if(bspdx<0) then
					bspdx <= -bspdx;
				end if;		
			end if;
		end if;
		--RIGHT
		if(ball_endx>right_boundary) then
			if(ball_starty<=right_top_boundary and ball_endy>=right_bottom_boundary) then
				offset := (ball_endx - right_boundary);
				nbpx := nbpx-offset;
				ball_startx := ball_startx-offset;
				ball_endx	:= ball_endx-offset;
				if(bspdx>0) then
					bspdx <= -bspdx;
				end if;				
			end if;
			if(ball_endy>=right_bottom_boundary and ball_starty<right_top_boundary) then
				offset := (ball_endx-right_boundary);
				nbpx := nbpx-offset;
				ball_startx := ball_startx-offset;
				ball_endx	:= ball_endx-offset;
				if(bspdx<0) then
					bspdx <= -bspdx;
				end if;		
			end if;
		end if;
	--WALLS
		if(ball_starty<=bottom_boundary) then
			offset := (bottom_boundary - ball_starty)+1;
			nbpy := nbpy+offset;
			ball_starty := ball_starty+offset;
			ball_endy	:= ball_endy+offset;
			bspdy <= -bspdy;
		end if;
		if(ball_endy>top_boundary) then
			offset := (ball_endy-top_boundary);
			nbpy := nbpy-offset;
			ball_starty := ball_starty-offset;
			ball_endy	:= ball_endy-offset;
			bspdy <= -bspdy;
		end if;
	end processCollisions;
		
begin
	process(clk_in) is
	begin
		if(rising_edge(clk_in)) then
			if(pause) then
				nbpx:=bpx;
				nbpy:=bpy;
				nlposoff:=lposoff;
				nrposoff:=rposoff; 
			elsif(not rst) then
				bpx<=signed(resize(midx, 11));
				bpy<=signed(resize(midy, 11));
				nbpx:=signed(resize(midx, 11));
				nbpy:=signed(resize(midy, 11));
				lposoff<=to_signed(0,11);
				rposoff<=to_signed(0,11);
				nlposoff:=to_signed(0,11);
				nrposoff:=to_signed(0,11);
				if(lgoal) then
					bspdx<=signed(resize(ball_max_spdx, 11));
					bspdy<=-signed(resize(ball_max_spdy, 11));
				else
					bspdx<=-signed(resize(ball_max_spdx, 11));
					bspdy<=signed(resize(ball_max_spdy, 11));
				end if;
				lgoal<='0';
				rgoal<='0';
			else
				nbpx:=bpx+resize(bspdx, 11);
				nbpy:=bpy+resize(bspdy, 11);
				if(lup) then
					nlposoff:=nlposoff+signed(resize(player_step,11));
				end if;
				if(ldown) then
					nlposoff:=nlposoff-signed(resize(player_step,11));
				end if;
				if(rup) then
					nrposoff:=nrposoff+signed(resize(player_step,11));
				end if;
				if(rdown) then
					nrposoff:=nrposoff-signed(resize(player_step,11));
				end if;
				processCollisions;
			end if;
			bpx<=nbpx;
			bpy<=nbpy;
			lposoff<=nlposoff;
			rposoff<=nrposoff;
		end if;
	end process;
	
	left_goal<=lgoal;
	right_goal<=rgoal;
	
	process(clk_in) is
	begin
		if(falling_edge(clk_in)) then
			ball_posx<=resize(unsigned(bpx),10);
			ball_posy<=resize(unsigned(bpy),10);
			left_pos<=resize(unsigned(signed(resize(midy,11))+lposoff),10);
			right_pos<=resize(unsigned(signed(resize(midy,11))+rposoff),10);
		end if;
	end process;
	
INPUTCONTROL0: ff_d port map(left_up, clk_in, '0', '0', lupped);
lup<=left_up and not lupped;
INPUTCONTROL1: ff_d port map(left_down, clk_in, '0', '0', ldowned);
ldown<=left_down and not ldowned;
INPUTCONTROL2: ff_d port map(right_up, clk_in, '0', '0', rupped);
rup<=right_up and not rupped;
INPUTCONTROL3: ff_d port map(right_down, clk_in, '0', '0', rdowned);
rdown<=right_down and not rdowned;
		
end architecture ponger;