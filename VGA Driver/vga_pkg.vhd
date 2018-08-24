library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pong_pkg.all;

package vga is
type rgb is (red, green, blue);
type rgbVal is array(rgb) of unsigned(7 downto 0);


end package vga;