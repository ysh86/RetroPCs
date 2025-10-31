LIBRARY	IEEE;
	USE	IEEE.STD_LOGIC_1164.ALL;
	USE	IEEE.STD_LOGIC_UNSIGNED.ALL;

entity rtc1990 is
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

 	sclk	:in std_logic;
	rstn	:in std_logic
);
end rtc1990;

architecture MAIN of rtc1990 is
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

signal	TIMESET	:std_logic;
signal	OUT1Hz	:std_logic;

signal	TXSFT	:std_logic_vector(39 downto 0);
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
		elsif(sclk' event and sclk='1')then
			if(STBe='1')then
				Clat<=C;
			end if;
		end if;
	end process;

	process(sclk,rstn)begin
		if(rstn='0')then
			TXSFT<=(others=>'0');
		elsif(sclk' event and sclk='1')then
			if(sDCLK='1' and lDCLK='0' and Clat="001" and CS='1')then
				TXSFT<=sDIN & TXSFT(39 downto 1);
			elsif(Clat="011")then
				TXSFT<=MON & '0' & WDAY & "00" & DAYH & DAYL & "00" & HORH & HORL & '0' & MINH & MINL & '0' & SECH & SECL;
			end if;
			lDCLK<=sDCLK;
		end if;
	end process;
	
	SDOUT<=TXSFT(0);
	
	MONWD	<=TXSFT(39 downto 36);
	DAYHWD	<=TXSFT(29 downto 28);
	DAYLWD	<=TXSFT(27 downto 24);
	WDAYWD	<=TXSFT(34 downto 32);
	HORHWD	<=TXSFT(21 downto 20);
	HORLWD	<=TXSFT(19 downto 16);
	MINHWD	<=TXSFT(14 downto 12);
	MINLWD	<=TXSFT(11 downto  8);
	SECHWD	<=TXSFT( 6 downto  4);
	SECLWD	<=TXSFT( 3 downto  0);
	
	TIMESET<='1' when (Clat="010") else '0';
	
	fast<='1' when (C="111" and STBe='1') else '0';
	
	rtc	:rtcbody generic map(clkfreq) port map(
	YERHIN	=>(others=>'0'),
	YERHWR	=>'0',
	YERLIN	=>(others=>'0'),
	YERLWR	=>'0',
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
	
	YERHOUT	=>open,
	YERLOUT	=>open,
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
end MAIN;

