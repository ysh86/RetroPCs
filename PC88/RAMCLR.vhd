LIBRARY	IEEE;
	USE	IEEE.STD_LOGIC_1164.ALL;
	USE	IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAMCLR is
generic(
	ADRWIDTH	:integer	:=18;
	ENDADR		:std_logic_vector(19 downto 0)	:=x"10000"
);
port(
	RAM_ADR		:out std_logic_vector(ADRWIDTH-1 downto 0);
	RAM_WDAT	:out std_logic_vector(7 downto 0);
	RAM_OE		:out std_logic;
	RAM_WR		:out std_logic;
	RAM_BUSY	:in std_logic;
	
	done		:out std_logic;

	clk			:in std_logic;
	rstn		:in std_logic
);
end RAMCLR;

architecture rtl of RAMCLR is
signal	CURADR	:std_logic_vector(ADRWIDTH-1 downto 0);
signal 	STATE	:integer range 0 to 4;
	constant ST_INIT		:integer	:=0;
	constant ST_RAMWRITE	:integer	:=1;
	constant ST_NEXT		:integer	:=2;
	constant ST_CHBNK		:integer	:=3;
	constant ST_IDLE		:integer	:=4;

begin
	process(clk,rstn)begin
		if(rstn='0')then
			CURADR<=(others=>'0');
			STATE<=ST_INIT;
			RAM_WDAT<=(others=>'0');
			RAM_OE<='0';
		elsif(clk' event and clk='1')then
			case STATE is
			when ST_INIT =>
				RAM_OE<='1';
				RAM_WDAT<=(others=>'0');
				RAM_WR<='1';
				STATE<=ST_RAMWRITE;
			when ST_RAMWRITE =>
				if(RAM_BUSY='0')then
					RAM_WR<='0';
					CURADR<=CURADR+1;
					STATE<=ST_NEXT;
				end if;
			when ST_NEXT =>
				if(CURADR=ENDADR(ADRWIDTH-1 downto 0))then
					RAM_OE<='0';
					STATE<=ST_IDLE;
				else
					STATE<=ST_INIT;
				end if;
			when others=>
				STATE<=ST_IDLE;
			end case;
		end if;
	end process;

	done <='1' when STATE=ST_IDLE else '0';
	RAM_ADR<=CURADR;
end rtl;
					
					
					
				

		