library ieee,work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.EDID_PKG.all;

entity EDIDmon is
port(
	CS		:in std_logic;
	ADDR	:in std_logic;
	RD		:in std_logic;
	WR		:in std_logic;
	RDAT	:out std_logic_vector(7 downto 0);
	WDAT	:in std_logic_vector(7 downto 0);
	DATOE	:out std_logic;
	
	EDID	:in EDID_ARRAY(0 to 127);
	CONNECT	:in std_logic;
	ERROR	:in std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end EDIDmon;

architecture RTL of EDIDmon is
signal	iaddr	:integer range 0 to 127;
begin
	process(clk,rstn)begin
		if(rstn='0')then
			iaddr<=0;
		elsif(clk' event and clk='1')then
			if(CS='1' and WR='1')then
				iaddr<=conv_integer(WDAT(6 downto 0));
			end if;
		end if;
	end process;
	
	RDAT<=	"000000" & ERROR & CONNECT	when ADDR='1' else
			EDID(iaddr);
	DATOE<=	'1' when CS='1' and RD='1' else '0';
	
end rtl;

				