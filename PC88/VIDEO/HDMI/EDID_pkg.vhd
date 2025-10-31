library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package EDID_PKG is
	subtype EDID_TYPE is std_logic_vector(7 downto 0); 
	type EDID_ARRAY is array (natural range <>) of EDID_TYPE; 
end EDID_PKG;