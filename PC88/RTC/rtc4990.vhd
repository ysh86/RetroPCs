LIBRARY	IEEE;
	USE	IEEE.STD_LOGIC_1164.ALL;
	USE	IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rtc4990 is
generic(
	clkfreq	:integer	:=21477270
);
port(
	DCLK	:in std_logic;
	DIN		:in std_logic;
	DOUT	:out std_logic;
	C		:in std_logic_vector(2 downto 0);
	CS		:in std_logic;
	STB		:in std_logic;
	OE		:in std_logic;


--I2C I/F
	TXOUT		:out	std_logic_vector(7 downto 0);		--tx data in
	RXIN		:in		std_logic_vector(7 downto 0);		--rx data out
	WRn			:out	std_logic;							--write
	RDn			:out	std_logic;							--read

	TXEMP		:in		std_logic;							--tx buffer empty
	RXED		:in		std_logic;							--rx buffered
	NOACK		:in		std_logic;							--no ack
	COLL		:in		std_logic;							--collision detect
	NX_READ		:out	std_logic;							--next data is read
	RESTART		:out	std_logic;							--make re-start condition
	START		:out	std_logic;							--make start condition
	FINISH		:out	std_logic;							--next data is final(make stop condition)
	F_FINISH	:out	std_logic;							--next data is final(make stop condition)
	INIT		:out	std_logic;

 	sclk	:in std_logic;
	rstn	:in std_logic
);
end rtc4990;

architecture MAIN of rtc4990 is
signal	YEH		:std_logic_vector(3 downto 0);
signal	YEL		:std_logic_vector(3 downto 0);
signal	MON		:std_logic_vector(3 downto 0);
signal	DAYH	:std_logic_vector(1 downto 0);
signal	DAYL	:std_logic_vector(3 downto 0);
signal	WDAY	:std_logic_vector(2 downto 0);
signal	HORH	:std_logic_vector(1 downto 0);
signal	HORL	:std_logic_vector(3 downto 0);
signal	MINH	:std_logic_vector(2 downto 0);
signal	MINL	:std_logic_vector(3 downto 0);
signal	SECH	:std_logic_vector(2 downto 0);
signal	SECL	:std_logic_vector(3 downto 0);

signal	YEHWD	:std_logic_vector(3 downto 0);
signal	YELWD	:std_logic_vector(3 downto 0);
signal	MONWD	:std_logic_vector(3 downto 0);
signal	DAYHWD	:std_logic_vector(1 downto 0);
signal	DAYLWD	:std_logic_vector(3 downto 0);
signal	WDAYWD	:std_logic_vector(2 downto 0);
signal	HORHWD	:std_logic_vector(1 downto 0);
signal	HORLWD	:std_logic_vector(3 downto 0);
signal	MINHWD	:std_logic_vector(2 downto 0);
signal	MINLWD	:std_logic_vector(3 downto 0);
signal	SECHWD	:std_logic_vector(2 downto 0);
signal	SECLWD	:std_logic_vector(3 downto 0);

signal	YEHID	:std_logic_vector(3 downto 0);
signal	YELID	:std_logic_vector(3 downto 0);
signal	MONID	:std_logic_vector(3 downto 0);
signal	DAYHID	:std_logic_vector(1 downto 0);
signal	DAYLID	:std_logic_vector(3 downto 0);
signal	WDAYID	:std_logic_vector(2 downto 0);
signal	HORHID	:std_logic_vector(1 downto 0);
signal	HORLID	:std_logic_vector(3 downto 0);
signal	MINHID	:std_logic_vector(2 downto 0);
signal	MINLID	:std_logic_vector(3 downto 0);
signal	SECHID	:std_logic_vector(2 downto 0);
signal	SECLID	:std_logic_vector(3 downto 0);
signal	I2CINI	:std_logic;

signal	TIMESET	:std_logic;
signal	SYS_SET	:std_logic;
signal	S_Pn	:std_logic;
signal	OUT1Hz	:std_logic;

signal	TXSFT	:std_logic_vector(51 downto 0);
signal	RXDAT	:std_logic_vector(47 downto 0);
signal	CMDSFT	:std_logic_vector(3 downto 0);
signal	SDOUT	:std_logic;
signal	sDCLK	:std_logic;
signal	lDCLK	:std_logic;
signal	sDIN	:std_logic;
signal	sSTB	:std_logic;
signal	STBe	:std_logic;
signal	fast	:std_logic;
signal	Clat	:std_logic_vector(2 downto 0);

component rtcbody
generic(
	clkfreq	:integer	:=21477270
);
port(
	YERHIN	:in std_logic_vector(3 downto 0);
	YERHWR	:in std_logic;
	YERLIN	:in std_logic_vector(3 downto 0);
	YERLWR	:in std_logic;
	MONIN	:in std_logic_vector(3 downto 0);
	MONWR	:in std_logic;
	DAYHIN	:in std_logic_vector(1 downto 0);
	DAYHWR	:in std_logic;
	DAYLIN	:in std_logic_vector(3 downto 0);
	DAYLWR	:in std_logic;
	WDAYIN	:in std_logic_vector(2 downto 0);
	WDAYWR	:in std_logic;
	HORHIN	:in std_logic_vector(1 downto 0);
	HORHWR	:in std_logic;
	HORLIN	:in std_logic_vector(3 downto 0);
	HORLWR	:in std_logic;
	MINHIN	:in std_logic_vector(2 downto 0);
	MINHWR	:in std_logic;
	MINLIN	:in std_logic_vector(3 downto 0);
	MINLWR	:in std_logic;
	SECHIN	:in std_logic_vector(2 downto 0);
	SECHWR	:in std_logic;
	SECLIN	:in std_logic_vector(3 downto 0);
	SECLWR	:in std_logic;
	SECZERO	:in std_logic;
	
	YERHOUT	:out std_logic_vector(3 downto 0);
	YERLOUT	:out std_logic_vector(3 downto 0);
	MONOUT	:out std_logic_vector(3 downto 0);
	DAYHOUT	:out std_logic_vector(1 downto 0);
	DAYLOUT	:out std_logic_vector(3 downto 0);
	WDAYOUT	:out std_logic_vector(2 downto 0);
	HORHOUT	:out std_logic_vector(1 downto 0);
	HORLOUT	:out std_logic_vector(3 downto 0);
	MINHOUT	:out std_logic_vector(2 downto 0);
	MINLOUT	:out std_logic_vector(3 downto 0);
	SECHOUT	:out std_logic_vector(2 downto 0);
	SECLOUT	:out std_logic_vector(3 downto 0);

	OUT1Hz	:out std_logic;
	
	fast	:in std_logic;

 	sclk	:in std_logic;
	rstn	:in std_logic
);
end component;

component I2Crtc is
port(
	TXOUT		:out	std_logic_vector(7 downto 0);		--tx data in
	RXIN		:in		std_logic_vector(7 downto 0);	--rx data out
	WRn			:out	std_logic;						--write
	RDn			:out	std_logic;						--read

	TXEMP		:in		std_logic;							--tx buffer empty
	RXED		:in		std_logic;							--rx buffered
	NOACK		:in		std_logic;							--no ack
	COLL		:in		std_logic;							--collision detect
	NX_READ		:out	std_logic;							--next data is read
	RESTART		:out	std_logic;							--make re-start condition
	START		:out	std_logic;							--make start condition
	FINISH		:out	std_logic;							--next data is final(make stop condition)
	F_FINISH	:out	std_logic;							--next data is final(make stop condition)
	INIT		:out	std_logic;

	YEHID		:out std_logic_vector(3 downto 0);
	YELID		:out std_logic_vector(3 downto 0);
	MONID		:out std_logic_vector(3 downto 0);
	DAYHID		:out std_logic_vector(1 downto 0);
	DAYLID		:out std_logic_vector(3 downto 0);
	WDAYID		:out std_logic_vector(2 downto 0);
	HORHID		:out std_logic_vector(1 downto 0);
	HORLID		:out std_logic_vector(3 downto 0);
	MINHID		:out std_logic_vector(2 downto 0);
	MINLID		:out std_logic_vector(3 downto 0);
	SECHID		:out std_logic_vector(2 downto 0);
	SECLID		:out std_logic_vector(3 downto 0);
	RTCINI		:out std_logic;
	
	YEHWD		:in std_logic_vector(3 downto 0);
	YELWD		:in std_logic_vector(3 downto 0);
	MONWD		:in std_logic_vector(3 downto 0);
	DAYHWD		:in std_logic_vector(1 downto 0);
	DAYLWD		:in std_logic_vector(3 downto 0);
	WDAYWD		:in std_logic_vector(2 downto 0);
	HORHWD		:in std_logic_vector(1 downto 0);
	HORLWD		:in std_logic_vector(3 downto 0);
	MINHWD		:in std_logic_vector(2 downto 0);
	MINLWD		:in std_logic_vector(3 downto 0);
	SECHWD		:in std_logic_vector(2 downto 0);
	SECLWD		:in std_logic_vector(3 downto 0);
	RTCWR		:in std_logic;
	
	clk			:in std_logic;
	rstn		:in std_logic
);
end component;

begin

	DOUT<=	'1'		when OE<='0' else
			OUT1Hz	when Clat="000" else
			SDOUT	when Clat="001" else
			SDOUT	when Clat="010" else
			SDOUT	when Clat="011" else
			'0';

	process(sclk,rstn)begin
		if(rstn='0')then
			sDCLK<='0';
			sDIN<='0';
			sSTB<='0';
			STBe<='0';
		elsif(sclk' event and sclk='1')then
			sDCLK<=DCLK;
			sDIN<=DIN;
			sSTB<=STB;
			if(STB='1' and sSTB='0' and CS='1')then
				STBe<='1';
			else
				STBe<='0';
			end if;
		end if;
	end process;
	
	process(sclk,rstn)begin
		if(rstn='0')then
			Clat<=(others=>'0');
			S_Pn<='0';
		elsif(sclk' event and sclk='1')then
			if(STBe='1')then
				if(C="111")then
					Clat<=CMDSFT(2 downto 0);
					S_Pn<='1';
				else
					Clat<=C;
					S_Pn<='0';
				end if;
			end if;
		end if;
	end process;

	process(sclk,rstn)begin
		if(rstn='0')then
			TXSFT<=(others=>'0');
		elsif(sclk' event and sclk='1')then
			if(sDCLK='1' and lDCLK='0')then
				CMDSFT<=sDIN & CMDSFT(3 downto 1);
			end if;
			if(sDCLK='1' and lDCLK='0' and Clat="001" and CS='1')then
				TXSFT<=sDIN & TXSFT(51 downto 1);
			elsif(Clat="011")then
				TXSFT<=x"0" & YEH & YEL & MON & '0' & WDAY & "00" & DAYH & DAYL & "00" & HORH & HORL & '0' & MINH & MINL & '0' & SECH & SECL;
			end if;
			lDCLK<=sDCLK;
		end if;
	end process;
	
	SDOUT<=TXSFT(0);
	
	RXDAT<=TXSFT(47 downto 0) when S_Pn='1' else YEH & YEL & TXSFT(51 downto 12);
	
	YEHWD	<=RXDAT(47 downto 44) when I2CINI='0' else YEHID;
	YELWD	<=RXDAT(43 downto 40) when I2CINI='0' else YELID;
	MONWD	<=RXDAT(39 downto 36) when I2CINI='0' else MONID;
	DAYHWD	<=RXDAT(29 downto 28) when I2CINI='0' else DAYHID;
	DAYLWD	<=RXDAT(27 downto 24) when I2CINI='0' else DAYLID;
	WDAYWD	<=RXDAT(34 downto 32) when I2CINI='0' else WDAYID;
	HORHWD	<=RXDAT(21 downto 20) when I2CINI='0' else HORHID;
	HORLWD	<=RXDAT(19 downto 16) when I2CINI='0' else HORLID;
	MINHWD	<=RXDAT(14 downto 12) when I2CINI='0' else MINHID;
	MINLWD	<=RXDAT(11 downto  8) when I2CINI='0' else MINLID;
	SECHWD	<=RXDAT( 6 downto  4) when I2CINI='0' else SECHID;
	SECLWD	<=RXDAT( 3 downto  0) when I2CINI='0' else SECLID;
	
	SYS_SET<='1' when (Clat="010") else '0';
	TIMESET<=SYS_SET or I2CINI;
	fast<='0';
	
	rtc	:rtcbody generic map(clkfreq) port map(
	YERHIN	=>YEHWD,
	YERHWR	=>TIMESET,
	YERLIN	=>YELWD,
	YERLWR	=>TIMESET,
	MONIN	=>MONWD,
	MONWR	=>TIMESET,
	DAYHIN	=>DAYHWD,
	DAYHWR	=>TIMESET,
	DAYLIN	=>DAYLWD,
	DAYLWR	=>TIMESET,
	WDAYIN	=>WDAYWD,
	WDAYWR	=>TIMESET,
	HORHIN	=>HORHWD,
	HORHWR	=>TIMESET,
	HORLIN	=>HORLWD,
	HORLWR	=>TIMESET,
	MINHIN	=>MINHWD,
	MINHWR	=>TIMESET,
	MINLIN	=>MINLWD,
	MINLWR	=>TIMESET,
	SECHIN	=>SECHWD,
	SECHWR	=>TIMESET,
	SECLIN	=>SECLWD,
	SECLWR	=>TIMESET,
	SECZERO	=>TIMESET,
	
	YERHOUT	=>YEH,
	YERLOUT	=>YEL,
	MONOUT	=>MON,
	DAYHOUT	=>DAYH,
	DAYLOUT	=>DAYL,
	WDAYOUT	=>WDAY,
	HORHOUT	=>HORH,
	HORLOUT	=>HORL,
	MINHOUT	=>MINH,
	MINLOUT	=>MINL,
	SECHOUT	=>SECH,
	SECLOUT	=>SECL,

	OUT1Hz	=>OUT1Hz,
	
	fast	=>fast,

 	sclk	=>sclk,
	rstn	=>rstn
);
	
	i2c	:I2Crtc port map(
	TXOUT		=>TXOUT,
	RXIN		=>RXIN,
	WRn			=>WRn,
	RDn			=>RDn,

	TXEMP		=>TXEMP,
	RXED		=>RXED,
	NOACK		=>NOACK,
	COLL		=>COLL,
	NX_READ		=>NX_READ,
	RESTART		=>RESTART,
	START		=>START,
	FINISH		=>FINISH,
	F_FINISH	=>F_FINISH,
	INIT		=>INIT,

	YEHID		=>YEHID,
	YELID		=>YELID,
	MONID		=>MONID,
	DAYHID		=>DAYHID,
	DAYLID		=>DAYLID,
	WDAYID		=>WDAYID,
	HORHID		=>HORHID,
	HORLID		=>HORLID,
	MINHID		=>MINHID,
	MINLID		=>MINLID,
	SECHID		=>SECHID,
	SECLID		=>SECLID,
	RTCINI		=>I2CINI,
	
	YEHWD		=>YEH,
	YELWD		=>YEL,
	MONWD		=>MON,
	DAYHWD		=>DAYH,
	DAYLWD		=>DAYL,
	WDAYWD		=>WDAY,
	HORHWD		=>HORH,
	HORLWD		=>HORL,
	MINHWD		=>MINH,
	MINLWD		=>MINL,
	SECHWD		=>SECH,
	SECLWD		=>SECL,
	RTCWR		=>SYS_SET,
	
	clk			=>sclk,
	rstn		=>rstn
);

end MAIN;

