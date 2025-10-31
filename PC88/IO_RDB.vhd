LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;
USE	IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IO_RDB is
generic(
	IOADR	:in std_logic_vector(7 downto 0)	:=x"00"
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	RDn		:in std_logic;
	DAT		:out std_logic_vector(7 downto 0);
	OUTE	:out std_logic;
	
	DIN		:in std_logic_vector(7 downto 0);
	DATRD	:out std_logic;
	clk		:in std_logic;
	rstn	:in std_logic
);
end IO_RDB;

architecture rtl of IO_RDB is
signal	SEL	:std_logic;
begin

	process(clk,rstn)begin
		if(rstn='0')then
			DAT<=(others=>'0');
		elsif(clk' event and clk='1')then
			DAT<=DIN;
		end if;
	end process;
	
	SEL<='1' when ADR=IOADR and IORQn='0' and RDn='0' else '0';
	OUTE<=SEL;

	process(clk,rstn)
	variable lSEL	:std_logic;
	begin
		if(rstn='0')then
			lSEL:='0';
			DATRD<='0';
		elsif(clk' event and clk='1')then
			DATRD<='0';
			if(SEL='0' and lSEL='1')then
				DATRD<='1';
			end if;
			lSEL:=SEL;
		end if;
	end process;
		
end rtl;
