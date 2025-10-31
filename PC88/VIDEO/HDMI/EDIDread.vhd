library ieee,work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.EDID_PKG.all;
use work.I2C_pkg.all;

entity EDIDread is
generic(
	CFREQ	:integer	:=20;	--MHz
	I2CFREQ	:integer	:=400;	--kHz
	HPWAIT	:integer	:=100	--msec
);
port(
	SCLI	:in std_logic;
	SCLO	:out std_logic;
	SDAI	:in std_logic;
	SDAO	:out std_logic;
	HPIN	:in std_logic;
	
	EDID	:out EDID_ARRAY(0 to 127);
	CONNECT	:out std_logic;
	ERROR	:out std_logic;
	DONE	:out std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end EDIDread;

architecture rtl of EDIDread is

component I2CIF is
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

component sftgen
generic(
	maxlen	:integer	:=100
);
port(
	len		:in integer range 0 to maxlen;
	sft		:out std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

signal	sft	:std_logic;
type state_t is(
	st_DISCONNECT,
	st_HPWAIT,
	st_INIT,
	st_SENDADDRADDR,
	st_SENDREGADDR,
	st_SENDADDRREAD,
	st_READ,
	st_END,
	st_IDLE
);
signal	state	:state_t;
signal	txdat	:std_logic_vector(7 downto 0);
signal	rxdat	:std_logic_vector(7 downto 0);
signal	txwrn	:std_logic;
signal	rxrdn	:std_logic;
signal	txemp	:std_logic;
signal	rxed	:std_logic;
signal	noack	:std_logic;
signal	coll	:std_logic;
signal	nx_read	:std_logic;
signal	restart	:std_logic;
signal	start	:std_logic;
signal	finish	:std_logic;
signal	f_finish :std_logic;
signal	init	:std_logic;
constant sftdiv	:integer	:=cfreq*1000/4/I2CFREQ;
signal	sHP		:std_logic;
constant hpwlen	:integer	:=HPWAIT*1000*CFREQ;
signal	hpwcount :integer range 0 to hpwlen-1;
constant retnum	:integer	:=4;
signal	retcount	:integer range 0 to retnum-1;
signal	addr	:integer range 0 to 127;

begin
	sclk	:sftgen generic map(sftdiv-1) port map(sftdiv-1,sft,clk,rstn);
	
	i2c	:i2cif port map(
		DATIN	=>txdat,
		DATOUT	=>rxdat,
		WRn		=>txwrn,
		RDn		=>rxrdn,

		TXEMP	=>txemp,
		RXED	=>rxed,
		NOACK	=>noack,
		COLL	=>coll,
		NX_READ	=>nx_read,
		RESTART	=>restart,
		START	=>start,
		FINISH	=>finish,
		F_FINISH =>f_finish,
		INIT	=>init,
		
		SDAIN	=>sdai,
		SDAOUT	=>sdao,
		SCLIN	=>scli,
		SCLOUT	=>sclo,

		SFT		=>sft,
		clk		=>clk,
		rstn	=>rstn
	);
	
	process(clk,rstn)begin
		if(rstn='0')then
			sHP<='0';
		elsif(clk' event and clk='1')then
			sHP<=HPIN;
		end if;
	end process;
	
	process(clk,rstn)begin
		if(rstn='0')then
			txdat<=(others=>'0');
			txwrn<='1';
			rxrdn<='1';
			nx_read<='0';
			restart<='0';
			start<='0';
			finish<='0';
			f_finish<='0';
			init<='0';
			state<=st_DISCONNECT;
			hpwcount<=hpwlen-1;
			retcount<=retnum-1;
			CONNECT<='0';
			DONE<='0';
			ERROR<='0';
			EDID<=(others=>x"00");
			addr<=0;
		elsif(clk' event and clk='1')then
			txwrn<='1';
			rxrdn<='1';
			f_finish<='0';
			init<='0';
			DONE<='0';
			
			if(sHP='0')then
				EDID<=(others=>x"00");
				CONNECT<='0';
				ERROR<='0';
				state<=st_DISCONNECT;
			else
				case state is
				when st_DISCONNECT =>
					if(sHP='1' and txemp='1')then
						hpwcount<=hpwlen-1;
						state<=st_HPWAIT;
						retcount<=retnum-1;
					end if;
				when st_HPWAIT =>
					if(hpwcount>0)then
						hpwcount<=hpwcount-1;
					else
						init<='1';
						state<=st_INIT;
					end if;
				when st_INIT =>
					if(txemp='1')then
						txdat<=x"a0";
						nx_read<='0';
						restart<='0';
						finish<='0';
						start<='1';
						txwrn<='0';
						state<=st_SENDADDRADDR;
					end if;
				when st_SENDADDRADDR =>
					if(txemp='1')then
						if(noack='1' or coll='1')then
							if(retcount>0)then
								retcount<=retcount-1;
								state<=st_INIT;
							else
								ERROR<='1';
								state<=st_IDLE;
							end if;
						else
							txdat<=x"00";
							start<='0';
							txwrn<='0';
							state<=st_SENDREGADDR;
						end if;
					end if;
				when st_SENDREGADDR =>
					if(txemp='1')then
						if(noack='1' or coll='1')then
							if(retcount>0)then
								retcount<=retcount-1;
								state<=st_INIT;
							else
								ERROR<='1';
								state<=st_IDLE;
							end if;
						else
							txdat<=x"a1";
							restart<='1';
							txwrn<='0';
							addr<=0;
							nx_read<='1';
							state<=st_READ;
						end if;
					end if;
				when st_READ =>
					if(rxed='1')then
						EDID(addr)<=rxdat;
						restart<='0';
--						if(addr=126)then
--							nx_read<='0';
--						end if;
						if(addr=127)then
							finish<='1';
							nx_read<='0';
							state<=st_END;
						else
							addr<=addr+1;
						end if;
						rxrdn<='0';
					elsif(txemp='1' and (noack='1' or coll='1'))then
						if(retcount>0)then
							retcount<=retcount-1;
							state<=st_INIT;
						else
							ERROR<='1';
							state<=st_IDLE;
						end if;
					end if;
				when st_END	=>
					if(txemp='1')then
						finish<='0';
						DONE<='1';
						CONNECT<='1';
						state<=st_IDLE;
					end if;
				when st_IDLE =>
				when others =>
				end case;
			end if;
		end if;
	end process;
	
end rtl;