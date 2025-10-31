library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity windrv is
port(
	cs		:in std_logic;
	rd		:in std_logic;
	wr		:in std_logic_vector(1 downto 0);
	rdat	:out std_logic_vector(15 downto 0);
	wdat	:in std_logic_vector(15 downto 0);
	doe	:out std_logic;

	clk	:in std_logic;
	rstn	:in std_logic
);
end windrv;

architecture rtl of windrv is
begin
	rdat<=	x"5700";
	doe<='1' when cs='1' and rd='1' else '0';
end rtl;

	
	