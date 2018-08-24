library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.base_pkg.all;

entity vga_driver is
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
	
end entity vga_driver;

architecture simple of vga_driver is
	signal		vga_clock_n:	std_logic					:= '0';
	
	signal		delay_bus:		std_logic_vector(4 downto 0);
	signal		delay_busv:		std_logic_vector(4 downto 0);
	signal		delay_bush:		std_logic_vector(4 downto 0);
	
	signal				rgb_data_delayed: std_logic_vector(23 downto 0);
	signal				rgb_data:		std_logic_vector(23 downto 0);
	shared variable 	rgb_data_raw:	std_logic_vector(23 downto 0);
	
	shared variable	xpos:				unsigned(18 downto 0);
	shared variable	ypos:				unsigned(18 downto 0);
	shared variable	address:			unsigned(18 downto 0);
	
	constant		field_w:			unsigned(10 downto 0) := hori_line-hori_backporch-hori_frontporch;
	constant		field_h:			unsigned(9 downto 0)	:= vert_line-vert_backporch-vert_frontporch;
		
	signal		iHS: 				std_logic;
	signal		iVS: 				std_logic;
	signal		iBlank:			std_logic;
	signal		iRST:				std_logic;
	
	procedure updateAddress is
	begin
		address:=resize(ypos, 9) & resize(xpos, 10);
	end updateAddress;
	
	begin
	
	
	iRST<=not rst;
	vga_clock_n<=not clk_in;

SYNCGEN: video_sync_generator generic 	map(H_sync_cycle, hori_backporch, hori_frontporch, hori_line, V_sync_cycle, vert_backporch, vert_frontporch, vert_line) 
										port 		map(clk_in, iRST, iBlank, iHS, iVS);

ADDGEN:
	process(clk_in, rst) is
	begin
		if(not rst) then
			updateAddress;
		elsif(rising_edge(clk_in)) then
			if((not iHS) and (not iVS)) then
				xpos:=resize(field_w-1,19);
				ypos:=resize(field_h-1,19);
				updateAddress;
			elsif(std_match(iBlank, '1')) then
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
			end if;
		end if;
	end process ADDGEN;

memaddress<=std_logic_vector(address);
memclock<=vga_clock_n;

COLORGEN:
	process(vga_clock_n) is
	begin
		if(rising_edge(vga_clock_n)) then
			if(std_match(memread, '1')) then
				rgb_data_raw:=(others=>'1');
			else
				rgb_data_raw:=(others=>'0');
			end if;
--			rgb_data<=rgb_data_raw;
		end if;
	end process COLORGEN;
	
process(clk_in) is
begin
	if(rising_edge(clk_in)) then
		rgb_data<=rgb_data_raw;
	end if;
end process;

process(vga_clock_n) is
begin
	if(rising_edge(vga_clock_n)) then
		rgb_data_delayed<=rgb_data;
	end if;
end process;
	
COLORPASS:
	process(vga_clock_n, rst) is
	begin
		if(not rst) then
			r_data<=(others=>'0');
			g_data<=(others=>'0');
			b_data<=(others=>'0');
		elsif(rising_edge(vga_clock_n)) then
			r_data <= rgb_data_delayed(23 downto 16);
			g_data <= rgb_data_delayed(15 downto 8);
			b_data <= rgb_data_delayed(7 downto 0);
		end if;
	end process COLORPASS;
	
DELAYEDSIGNALS:
	process(vga_clock_n, rst) is
	begin
		if(not rst) then
				delay_bus<=(others=>'0');
				delay_bush<=(others=>'0');
				delay_busv<=(others=>'0');
		elsif(rising_edge(vga_clock_n)) then
			delay_bus(4 downto 1)<=delay_bus(3 downto 0);
			delay_bus(0)<=iBlank;
			delay_bush(4 downto 1)<=delay_bush(3 downto 0);
			delay_bush(0)<=iHS;
			delay_busv(4 downto 1)<=delay_busv(3 downto 0);
			delay_busv(0)<=iVS;
		end if;
	end process DELAYEDSIGNALS;
	
vga_blank<=delay_bus(1);
hsync<=delay_bush(1);
vsync<=delay_busv(1);
	
end architecture simple;