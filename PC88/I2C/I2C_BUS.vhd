library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.I2C_pkg.all;

entity I2C_BUS is
port(
	ADR	:in		std_logic_vector(1 downto 0);
	CSn	:in 	std_logic;
	DATAOUT :out std_logic_vector(7 downto 0);
	DATAIN	:in std_logic_vector(7 downto 0);
	DATAOE	:out std_logic;
	WRn	:in		std_logic;
	RDn	:in		std_logic;
	INTn :out	std_logic;

	SDAIN :in	std_logic;
	SDAOUT :out	std_logic;
	SCLIN :in	std_logic;
	SCLOUT :out	std_logic;

	SFT	:in		std_logic;
	clk	:in		std_logic;
	rstn :in	std_logic
);
end I2C_BUS;

architecture MAIN of I2C_BUS is
signal	WR,lWR	:std_logic;
signal	WRtrig	:std_logic;
signal	RD,lRD	:std_logic;
signal	isDAT	:std_logic;

component I2CIF
port(
	DATIN	:in	std_logic_vector(I2CDAT_WIDTH-1 downto 0);		--tx data in
	DATOUT	:out	std_logic_vector(I2CDAT_WIDTH-1 downto 0);	--rx data out
	WRn		:in		std_logic;						--write
	RDn		:in		std_logic;						--read

	TXEMP	:out std_logic;							--tx buffer empty
	RXED	:out std_logic;							--rx buffered
	NOACK	:out std_logic;							--no ack
	COLL	:out std_logic;							--collision detect
	NX_READ	:in std_logic;							--next data is read
	RESTART	:in std_logic;							--make re-start condition
	START	:in std_logic;							--make start condition
	FINISH	:in std_logic;							--next data is final(make stop condition)
	F_FINISH :in std_logic;							--next data is final(make stop condition)
	INIT	:in std_logic;
	
--	INTn :out	std_logic;

	SDAIN :in	std_logic;
	SDAOUT :out	std_logic;
	SCLIN :in	std_logic;
	SCLOUT :out	std_logic;

	SFT	:in		std_logic;
	clk	:in		std_logic;
	rstn :in	std_logic
);
end component;

signal	TXDAT	:std_logic_vector(I2CDAT_WIDTH-1 downto 0);
signal	RXDAT	:std_logic_vector(I2CDAT_WIDTH-1 downto 0);
signal	I2C_WRn	:std_logic;						--write
signal	I2C_RDn	:std_logic;						--read

signal	TXEMP	:std_logic;
signal	RXED	:std_logic;
signal	NOACK	:std_logic;
signal	COLL	:std_logic;
signal	NX_READ	:std_logic;
signal	RESTART	:std_logic;
signal	START	:std_logic;
signal	FINISH	:std_logic;
signal	F_FINISH :std_logic;
signal	INIT	:std_logic;

signal	STATUS	:std_logic_vector(7 downto 0);
signal	CONTROL	:std_logic_vector(7 downto 0);
 constant BIT_TXEMP	:integer	:=7;	-- TX buffer empty
 constant BIT_RXFULL :integer	:=6;	-- RX data full
 constant BIT_NOACK	:integer	:=5;	-- No ack detected
 constant BIT_COLL	:integer	:=4;	-- Collision detected
 constant BIT_READ	:integer	:=3;	-- next state is read
 constant BIT_RES	:integer	:=2;	-- Make re-start condition
 constant BIT_START	:integer	:=1;	-- Make start condition
 constant BIT_FIN	:integer	:=0;	-- Final data(make stop condition)

constant ADR_DAT	:std_logic_vector(1 downto 0)	:="00";
constant ADR_STA	:std_logic_vector(1 downto 0)	:="01";
constant ADR_CNT	:std_logic_vector(1 downto 0)	:="10";

begin
	WR<=(not CSn) and (not WRn);
	RD<=(not CSn) and (not RDn);
	process(clk,rstn)begin
		if(rstn='0')then
			lWR<='0';
			WRtrig<='0';
		elsif(clk' event and clk='1')then
			WRtrig<='0';
			lWR<=WR;
			if(lWR='1' and WR='0')then
				WRtrig<='1';
			end if;
		end if;
	end process;
	
	process(clk,rstn)begin
		if(rstn='0')then
			TXDAT<=(others=>'0');
			CONTROL<=(others=>'0');
			isDAT<='0';
		elsif(clk' event and clk='1')then
			if(WR='1')then
				if(ADR=ADR_DAT)then
					isDAT<='1';
				else
					isDAT<='0';
				end if;
				case ADR is
					when ADR_DAT =>
						TXDAT<=DATAIN;
					when ADR_CNT =>
						CONTROL<=DATAIN;
					when others =>
				end case;
			elsif(RD='1')then
				if(ADR=ADR_DAT)then
					isDAT<='1';
				else
					isDAT<='0';
				end if;
			end if;
		end if;
	end process;

	DATAOUT<=
		RXDAT 	when ADR=ADR_DAT else
		STATUS 	when ADR=ADR_STA else
		CONTROL	when ADR=ADR_CNT else
		(others=>'0');
	
	DATAOE<=RD;
	
	process(clk,rstn)begin
		if(rstn='0')then
			lRD<='0';
			I2C_RDn<='1';
		elsif(clk' event and clk='1')then
			I2C_RDn<='1';
			lRD<=RD;
			if(isDAT='1' and lRD='1' and RD='0')then
				I2C_RDn<='0';
			end if;
		end if;
	end process;
	
	process(clk,rstn)begin
		if(rstn='0')then
			I2C_WRn<='1';
		elsif(clk' event and clk='1')then
			I2C_WRn<='1';
			if(WRtrig='1' and isDAT='1')then
				I2C_WRn<='0';
			end if;
		end if;
	end process;

	NX_READ	<=CONTROL(BIT_READ);
	RESTART	<=CONTROL(BIT_RES);
	START	<=CONTROL(BIT_START);
	FINISH	<=CONTROL(BIT_FIN);
	F_FINISH<='0';
	
	STATUS(BIT_TXEMP)<=TXEMP;
	STATUS(BIT_RXFULL)<=RXED;
	STATUS(BIT_NOACK)<=NOACK;
	STATUS(BIT_COLL)<=COLL;
	STATUS(3 downto 0)<=(others=>'0');
	
	process(CONTROL,STATUS)
	variable INT	:std_logic;
	begin
		INT:='0';
		for i in BIT_COLL to BIT_TXEMP loop
			INT:=INT or (STATUS(i) and CONTROL(i));
		end loop;
		INTn<=not INT;
	end process;
	
	INIT<='0';

	I2C	:I2CIF port map(TXDAT,RXDAT,I2C_WRn,I2C_RDn,TXEMP,RXED,NOACK,COLL,NX_READ,RESTART,START,FINISH,F_FINISH,INIT,SDAIN,SDAOUT,SCLIN,SCLOUT,SFT,clk,rstn);

end MAIN;
