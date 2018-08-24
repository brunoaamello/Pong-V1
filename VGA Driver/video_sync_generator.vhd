library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity video_sync_generator is
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
end entity video_sync_generator;


architecture simple of video_sync_generator is

	signal		h_count:			unsigned(10 downto 0);
	signal		v_count:			unsigned(9 downto 0);
	
	signal		iHS: 				std_logic;
	signal		iVS: 				std_logic;
	signal		iBlank:			std_logic;
	
	signal		hori_valid:		std_logic;
	signal		vert_valid:		std_logic;	
	
	begin

VIDEOSYNCCOUNTER:
	process(vga_clock, rst) is
	begin
		if(rst) then
			h_count<=to_unsigned(0,11);
			v_count<=to_unsigned(0,10);
		elsif(falling_edge(vga_clock)) then
			if(h_count=hori_line) then
				h_count<=to_unsigned(0,11);
				if(v_count=vert_line) then
					v_count<=to_unsigned(0,10);
				else
					v_count<=v_count+1;
				end if;
			else
				h_count<=h_count+1;
			end if;
		end if;
	end process VIDEOSYNCCOUNTER;

	iHS	<=	'0'	when h_count<H_sync_cycle else
				'1';
	iVS	<=	'0'	when v_count<V_sync_cycle else
				'1';
				
	hori_valid <= 	'1' when (h_count<(hori_line-hori_frontporch) and h_count>=hori_backporch) else
						'0';
	vert_valid <=	'1' when (v_count<(vert_line-vert_frontporch) and v_count>=vert_backporch) else
						'0';
	iBlank	<= hori_valid and vert_valid;
						
VIDEOSYNCGENERATOR:
	process(vga_clock) is
	begin
		if(falling_edge(vga_clock)) then
			vga_blank	<=	iBlank;
			hsync			<=	iHS;
			vsync			<=	iVS;
		end if;
	end process VIDEOSYNCGENERATOR;
	
end architecture simple;