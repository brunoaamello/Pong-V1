library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ff_d;

entity clk_divider is
	generic(
		n: integer := 8
	);
	port(
		clk_in:	in 	std_logic;
		rst:		in 	std_logic;
		data_in: in		unsigned(n-1 downto 0);
		clk_out:	inout	std_logic
	);
end entity clk_divider;

architecture synchronous of clk_divider is
	signal int_rst:		std_logic := '0';
	signal clear: 			std_logic_vector(0 to n-1);
	signal setbit: 		std_logic_vector(0 to n-1);
	signal ff_prein:		std_logic_vector(0 to n-1);
	signal ff_out: 		std_logic_vector(0 to n-1);
	constant max:			std_logic_vector(0 to n-1) := (others=>'1');
	component ff_d port(D:in std_logic; clk_in:in std_logic; clr:in std_logic; set:in std_logic; Q:out std_logic); end component;
	begin
		int_rst<=clk_out or rst;
COMPONENTASSIGNMENT:
		for i in 0 to n-1 generate
		begin
			clear(i)<=(not data_in(i)) and int_rst;
			setbit(i)<=data_in(i) and int_rst;
		FIRSTFFCHECK:
			if (i=0) generate
					ff_prein(i)<='1';
			else generate
					ff_prein(i)<=ff_out(i-1) and ff_prein(i-1);
			end generate FIRSTFFCHECK;
FLIPFLOPS:		ff_d port map (ff_prein(i) xor ff_out(i),clk_in,clear(i),setbit(i),ff_out(i));
		end generate COMPONENTASSIGNMENT;

OUTCHECK:
		process(clk_in) is
		begin
			if(rising_edge(clk_in)) then
				if(std_match(ff_out, max)) then
					clk_out<='1';
				else
					clk_out<='0';
				end if;
			end if;
		end process OUTCHECK;
		
end architecture synchronous;