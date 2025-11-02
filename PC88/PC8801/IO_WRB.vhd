LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;
USE	IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IO_WRB is
generic(
	IOADR	:in std_logic_vector(7 downto 0)	:=x"00"
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	WRn		:in std_logic;
	DAT		:in std_logic_vector(7 downto 0);
	
	DOUT	:out std_logic_vector(7 downto 0);
	DATWR	:out std_logic;

	clk		:in std_logic;
	rstn	:in std_logic
);
end IO_WRB;

architecture MAIN of IO_WRB is
signal	IOWRn	:std_logic;
signal	lWRn	:std_logic;
begin

	IOWRn<=IORQn or WRn;

	process(clk,rstn)begin
		if(rstn='0')then
			DOUT<=(others=>'0');
			DATWR<='0';
		elsif(clk' event and clk='1')then
			DATWR<='0';
			if(ADR=IOADR and IOWRn='0' and lWRn='1')then
				DOUT<=DAT;
				DATWR<='1';
			end if;
		lWRn<=IOWRn;
		end if;
	end process;
end MAIN;
