library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.ff_d;

entity simple_counter is
	generic(
		n: integer := 8
	);
	port(
		clk_in:	in 	std_logic;
		rst:		in 	std_logic;
		counter: out	unsigned(n-1 downto 0)
	);
end entity simple_counter;

architecture synchronous of simple_counter is
	signal int_rst:		std_logic := '0';
	signal peak_rst:		std_logic := '0';
	signal clear: 			std_logic_vector(0 to n-1);
	signal setbit: 		std_logic_vector(0 to n-1);
	signal ff_prein:		std_logic_vector(0 to n-1);
	signal ff_out: 		std_logic_vector(0 to n-1);
	constant max:			std_logic_vector(0 to n-1) := (others=>'1');
	component ff_d port(D:in std_logic; clk_in:in std_logic; clr:in std_logic; set:in std_logic; Q:out std_logic); end component;
	begin
		int_rst<=peak_rst or rst;
COMPONENTASSIGNMENT:
		for i in 0 to n-1 generate
		begin
			counter(i)<=ff_out(i);
			clear(i)<=int_rst;
		FIRSTFFCHECK:
			if (i=0) generate
					ff_prein(i)<='1';
			else generate
					ff_prein(i)<=ff_out(i-1) and ff_prein(i-1);
			end generate FIRSTFFCHECK;
FLIPFLOPS:		ff_d port map (ff_prein(i) xor ff_out(i),clk_in,clear(i),'0',ff_out(i));
		end generate COMPONENTASSIGNMENT;

OUTCHECK:
		process(clk_in) is
		begin
			if(rising_edge(clk_in)) then
				if(std_match(ff_out, max)) then
					peak_rst<='1';
				else
					peak_rst<='0';
				end if;
			end if;
		end process OUTCHECK;
		
end architecture synchronous;