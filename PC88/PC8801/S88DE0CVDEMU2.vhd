LIBRARY	IEEE,work;
	USE	IEEE.STD_LOGIC_1164.ALL;
	USE 	IEEE.STD_LOGIC_ARITH.ALL;
	USE	IEEE.STD_LOGIC_UNSIGNED.ALL;
	use 	work.I2C_pkg.all;
	use	work.EDID_PKG.all;
	USE	WORK.addressmap_pkg.ALL;

entity S88DE0CVDEMU2 is
generic(
	SYSCLK		:integer	:=20000;		--kHz
	VIDCLK		:integer	:=75000;		--kHz
	RAMCLK		:integer	:=75000;		--kHz
	USE_OPNA		:integer	:=1;
	RAMAWIDTH	:integer	:=25;
	RAMCAWIDTH	:integer	:=10
);
port(
	pclk50m		:in std_logic;
	
	pI2Cscl		: inout std_logic;
    pI2Csda		: inout std_logic;

    -- SD-RAM ports
    pMemClk     : out std_logic;                        -- SD-RAM Clock
    pMemCke     : out std_logic;                        -- SD-RAM Clock enable
    pMemCs_n    : out std_logic;                        -- SD-RAM Chip select
    pMemRas_n   : out std_logic;                        -- SD-RAM Row/RAS
    pMemCas_n   : out std_logic;                        -- SD-RAM /CAS
    pMemWe_n    : out std_logic;                        -- SD-RAM /WE
    pMemUdq     : out std_logic;                        -- SD-RAM UDQM
    pMemLdq     : out std_logic;                        -- SD-RAM LDQM
    pMemBa1     : out std_logic;                        -- SD-RAM Bank select address 1
    pMemBa0     : out std_logic;                        -- SD-RAM Bank select address 0
    pMemAdr     : out std_logic_vector(12 downto 0);    -- SD-RAM Address
    pMemDat     : inout std_logic_vector(15 downto 0);  -- SD-RAM Data

    -- PS/2 keyboard ports
    pPs2Clk     : inout std_logic;
    pPs2Dat     : inout std_logic;
    pPmsClk		: inout std_logic;
    pPmsDat		: inout std_logic;

    -- Joystick ports (Port_A, Port_B)
    pJoyA		: inout std_logic_vector( 5 downto 0);
    pJoyB		: inout std_logic_vector( 5 downto 0);
    pStrA		: out std_logic;
    pStrB		: out std_logic;
    -- SD/MMC slot ports
    pSd_Ck      : out std_logic;                        -- pin 5
    pSd_Cm      : out std_logic;                        -- pin 2
    pSd_Dt      : inout std_logic_vector( 3 downto 0);  -- pin 1(D3), 9(D2), 8(D1), 7(D0)

	-- FDD ports
	pFd_DENn		:out std_logic;
	pFd_INDEXn		:in std_logic;
	pFd_DIRn		:out std_logic;
	pFd_STEPn		:out std_logic;
	pFd_WDATAn		:out std_logic;
	pFd_WGATEn		:out std_logic;
	pFd_TRK00n		:in std_logic;
	pFd_WPTn		:in std_logic;
	pFd_RDATAn		:in std_logic;
	pFd_SIDE1n		:out std_logic;
	pFd_DSKCHG		:in std_logic;
	pFd_DS0			:out std_logic;
	pFd_MOTOR0		:out std_logic;
	pFd_DS1			:out std_logic;
	pFd_MOTOR1		:out std_logic;

    -- DIP switch, Lamp ports
    pDip        : in std_logic_vector( 9 downto 0);     -- 0=ON,  1=OFF(default on shipment)
    pLed        : out std_logic_vector( 9 downto 0);    -- 0=OFF, 1=ON(green)
    pPsw		: in std_logic_vector(1 downto 0);
    pSeg0		: out std_logic_vector(7 downto 0);
    pSeg1		: out std_logic_vector(7 downto 0);
    pSeg2		: out std_logic_vector(7 downto 0);
    pSeg3		: out std_logic_vector(7 downto 0);
    pSeg4		: out std_logic_vector(7 downto 0);
    pSeg5		: out std_logic_vector(7 downto 0);
	 pMonDbus	:out std_logic_vector(7 downto 0);
	pDemuSw		:in std_logic;
   -- Video, Audio/CMT ports
   pDac_VR     : inout std_logic_vector( 3 downto 0);  -- RGB_Red / Svideo_C
   pDac_VG     : inout std_logic_vector( 3 downto 0);  -- RGB_Grn / Svideo_Y
   pDac_VB     : inout std_logic_vector( 3 downto 0);  -- RGB_Blu / CompositeVideo
   pDac_SL     : out   std_logic;  -- Sound-L
   pDac_SR     : inout std_logic;  -- Sound-R / CMT

   pVideoHS_n  : out std_logic;                        -- Csync(RGB15K), HSync(VGA31K)
   pVideoVS_n  : out std_logic;                        -- Audio(RGB15K), VSync(VGA31K)

	pHDMI_DAT0	:out std_logic;
	pHDMI_DAT1	:out std_logic;
	pHDMI_DAT2	:out std_logic;
	pHDMI_CLK		:out std_logic;
	pHDMI_SCL	:inout std_logic;
	pHDMI_SDA	:inout std_logic;
	pHDMI_PWR	:in std_logic;
	
	-- COM(RS-232C) port
	pCOM_TxD	:out std_logic;
	pCOM_RxD	:in std_logic;
	pCOM_CTS	:in std_logic;
	pCOM_RTS	:out std_logic;
	
	rstn		:in std_logic
);
end S88DE0CVDEMU2;

architecture MAIN of S88DE0CVDEMU2 is
component SDRAMCde0cvDEMU2
	generic(
		CAWIDTH			:integer	:=10;
		AWIDTH			:integer	:=25;
		CLKMHZ			:integer	:=82;			--MHz
		REFCYC			:integer	:=64000/8192	--usec
	);
	port(
		-- SDRAM PORTS
		PMEMCKE			: OUT	STD_LOGIC;							-- SD-RAM CLOCK ENABLE
		PMEMCS_N		: OUT	STD_LOGIC;							-- SD-RAM CHIP SELECT
		PMEMRAS_N		: OUT	STD_LOGIC;							-- SD-RAM ROW/RAS
		PMEMCAS_N		: OUT	STD_LOGIC;							-- SD-RAM /CAS
		PMEMWE_N		: OUT	STD_LOGIC;							-- SD-RAM /WE
		PMEMUDQ			: OUT	STD_LOGIC;							-- SD-RAM UDQM
		PMEMLDQ			: OUT	STD_LOGIC;							-- SD-RAM LDQM
		PMEMBA1			: OUT	STD_LOGIC;							-- SD-RAM BANK SELECT ADDRESS 1
		PMEMBA0			: OUT	STD_LOGIC;							-- SD-RAM BANK SELECT ADDRESS 0
		PMEMADR			: OUT	STD_LOGIC_VECTOR( 12 DOWNTO 0 );	-- SD-RAM ADDRESS
		PMEMDAT			: INOUT	STD_LOGIC_VECTOR( 15 DOWNTO 0 );	-- SD-RAM DATA

		CPUADR			:in std_logic_vector(AWIDTH-1 downto 0);
		CPURDAT			:out std_logic_vector(7 downto 0);
		CPUWDAT			:in std_logic_vector(7 downto 0);
		CPUWR			:in std_logic;
		CPURD			:in std_logic;
		CPUWAIT			:out std_logic;
		CPUCLK			:out std_logic;
		CPURSTn			:out std_logic;
		MRAMDAT			:out std_logic_vector(7 downto 0);
		
		SUBADR			:in std_logic_vector(AWIDTH-1 downto 0);
		SUBRDAT			:out std_logic_vector(7 downto 0);
		SUBWDAT			:in std_logic_vector(7 downto 0);
		SUBWR			:in std_logic;
		SUBRD			:in std_logic;
		SUBWAIT			:out std_logic;
		SUBCLK			:out std_logic;

		ALURD0			:out std_logic_vector(7 downto 0);
		ALURD1			:out std_logic_vector(7 downto 0);
		ALURD2			:out std_logic_vector(7 downto 0);
		VRAMRSEL		:in integer range 0 to 3;
		
		ALUCWD			:out std_logic_vector(7 downto 0);
		ALUWD0			:in std_logic_vector(7 downto 0);
		ALUWD1			:in std_logic_vector(7 downto 0);
		ALUWD2			:in std_logic_vector(7 downto 0);
		VRAMWE			:in std_logic_vector(3 downto 0);
		
		VIDADR			:in std_logic_vector(AWIDTH-1 downto 0);
		VIDDAT0			:out std_logic_vector(7 downto 0);
		VIDDAT1			:out std_logic_vector(7 downto 0);
		VIDDAT2			:out std_logic_vector(7 downto 0);
		VIDRD			:in std_logic;
		VIDWAIT			:out std_logic;
		
		FDEADR			:in std_logic_vector(AWIDTH-1 downto 0)	:=(others=>'0');
		FDERD				:in std_logic								:='0';
		FDEWR				:in std_logic								:='0';
		FDERDAT			:out std_logic_Vector(15 downto 0);
		FDEWDAT			:in std_logic_vector(15 downto 0)	:=(others=>'0');
		FDEWAIT			:out std_logic;
		
		FECADR			:in std_logic_vector(AWIDTH-1 downto 0)	:=(others=>'0');
		FECRD				:in std_logic								:='0';
		FECWR				:in std_logic								:='0';
		FECRDAT			:out std_logic_vector(15 downto 0);
		FECWDAT			:in std_logic_vector(15 downto 0)	:=(others=>'0');
		FECWAIT			:out std_logic;
		
		SNDADR			:in std_logic_vector(AWIDTH-1 downto 0);
		SNDRD			:in std_logic;
		SNDWR			:in std_logic;
		SNDRDAT			:out std_logic_vector(7 downto 0);
		SNDWDAT			:in std_logic_vector(7 downto 0);
		SNDWAIT			:out std_logic;
		SNDH_Ln			:in std_logic;
				
		monout			:out std_logic_vector(7 downto 0);
		
		CLOCKM			:in std_logic;
		
		memclk			:in std_logic;
		rstn			:in std_logic
	);
end component;

component memorymaps
generic(
	extram	:integer	:=0;
	addrwidth	:integer	:=25
);
port(
	CPU_ADR		:in std_logic_vector(15 downto 0);
	CPU_MREQn	:in std_logic;
	CPU_IORQn	:in std_logic;
	CPU_RDn		:in std_logic;
	CPU_WRn		:in std_logic;
	CPU_WDAT	:in std_logic_vector(7 downto 0);
	CPU_RDAT	:out std_logic_vector(7 downto 0);
	CPU_OE		:out std_logic;
	
	KNJ1_ADR	:in std_logic_vector(16 downto 0);
	KNJ1_RD		:in std_logic;
	
	KNJ2_ADR	:in std_logic_vector(16 downto 0);
	KNJ2_RD		:in std_logic;

	RAM_ADR		:out std_logic_vector(addrwidth-1 downto 0);
	RAM_CE		:out std_logic;
	
	TRAM_ADR	:out std_logic_vector(11 downto 0);
	TRAM_CE		:out std_logic;

	TVRAM_ADR	:out std_logic_vector(11 downto 0);
	TVRAM_CE	:out std_logic;
	
	TXTWINEN	:out std_logic;
	
	G_EXTMODE	:out std_logic;
	G_RAMSEL	:out integer range 0 to 3;
	ALUOE		:out std_logic;
	ALUME		:out std_logic;
	ALURE		:out std_logic;
	GADR_MSEL	:out std_logic;
	
	clk			:in std_logic;
	rstn		:in std_logic
);
end component;

component T80a
    generic(
        Mode : integer := 0 -- 0 => Z80, 1 => Fast Z80, 2 => 8080, 3 => GB
    );
    port(
        RESET_n     : in std_logic;
        CLK_n       : in std_logic;
        WAIT_n      : in std_logic;
        INT_n       : in std_logic;
        NMI_n       : in std_logic;
        BUSRQ_n     : in std_logic;
        M1_n        : out std_logic;
        MREQ_n      : out std_logic;
        IORQ_n      : out std_logic;
        RD_n        : out std_logic;
        WR_n        : out std_logic;
        RFSH_n      : out std_logic;
        HALT_n      : out std_logic;
        BUSAK_n     : out std_logic;
        A           : out std_logic_vector(15 downto 0);
        D           : inout std_logic_vector(7 downto 0)
    );
end component;

component romcopy
generic(
	BGNADDR	:std_logic_vector(23 downto 0)	:=x"700000";
	ENDADDR	:std_logic_vector(23 downto 0)	:=x"7fffff";
	AWIDTH	:integer	:=20
);
port(
	addr	:out std_logic_vector(AWIDTH-1 downto 0);
	wdat	:out std_logic_vector(7 downto 0);
	aen		:out std_logic;
	wr		:out std_logic;
	ack		:in std_logic;
	done	:out std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component RAMCLR
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
end component;

component pllCVdemu
	port (
		refclk   : in  std_logic := '0'; --  refclk.clk
		rst      : in  std_logic := '0'; --   reset.reset
		outclk_0 : out std_logic;        -- outclk0.clk
		outclk_1 : out std_logic;        -- outclk1.clk
		outclk_2 : out std_logic;        -- outclk2.clk
		outclk_3 : out std_logic;        -- outclk3.clk
		locked   : out std_logic         --  locked.export
	);
end component;

component TEXTRAM
	PORT
	(
		address_a		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;

component CRTCP
port(
	IORQn		:in std_logic;
	WRn			:in std_logic;
	ADR			:in std_logic_vector(7 downto 0);
	WDAT		:in std_logic_vector(7 downto 0);
	PALEN		:in std_logic	:='1';
	
	TRAM_ADR	:out std_logic_vector(11 downto 0);
	TRAM_DAT	:in std_logic_vector(7 downto 0);
	
	GRAMADR		:out std_logic_vector(13 downto 0);
	GRAMRD		:out std_logic;
	GRAMWAIT	:in std_logic;
	GRAMDAT0	:in std_logic_vector(7 downto 0);
	GRAMDAT1	:in std_logic_vector(7 downto 0);
	GRAMDAT2	:in std_logic_vector(7 downto 0);
	
	ROUT		:out std_logic_vector(2 downto 0);
	GOUT		:out std_logic_vector(2 downto 0);
	BOUT		:out std_logic_vector(2 downto 0);
	VIDEN		:out std_logic;
	
	HSYNC		:out std_logic;
	VSYNC		:out std_logic;
	
	HMODE		:in std_logic;		-- 1:80chars 0:40chars
	VMODE		:in std_logic;		-- 1:25lines 0:20lines
	PMODE		:in std_logic;		-- 1:512 colors 0:8 colors
	TXTMODE		:in std_logic;
	
	GRAPHEN		:in std_logic;
	LOWRES		:in std_logic;
	GCOLOR		:in std_logic;

	MONOEN		:in std_logic_vector(2 downto 0);
	TXTEN		:in std_logic;

	CURL		:in std_logic_vector(4 downto 0);
	CURC		:in std_logic_vector(6 downto 0);
	CURE		:in std_logic;
	CURM		:in std_logic;
	CBLINK		:in std_logic;

	VRTC		:out std_logic;
	HRTC		:out std_logic;

	FRAMWADR	:in std_logic_Vector(12 downto 0);
	FRAMWDAT	:in std_logic_vector(7 downto 0);
	FRAMWR	:in std_logic;

	gclk		:out std_logic;
	cpuclk		:in std_logic;
	clk			:in std_logic;
	rstn		:in std_logic
);
end component;

component CRTCREGS
generic(
	DATADR	:std_logic_vector(7 downto 0)	:=x"50";
	CMDADR	:std_logic_vector(7 downto 0)	:=x"51"
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	WRn		:in std_logic;
	RDn		:in std_logic;
	DATIN	:in std_logic_vector(7 downto 0);
	DATOUT	:out std_logic_vector(7 downto 0);
	DATOE	:out std_logic;

	CURL	:out std_logic_vector(4 downto 0);
	CURC	:out std_logic_vector(6 downto 0);
	CURE	:out std_logic;
	CURM	:out std_logic;
	CBLINK	:out std_logic;
	VMODE	:out std_logic;
	CRTCen	:out std_logic;
	DMAMODE	:out std_logic;
	H		:out std_logic_vector(6 downto 0);	--Horizontal characters
	B		:out std_logic_vector(1 downto 0);	--Cursor blink
	L		:out std_logic_vector(5 downto 0);	--Vertical Characters
	S		:out std_logic;						--??
	C		:out std_logic_vector(1 downto 0);	--??
	R		:out std_logic_vector(4 downto 0);	--Character height
	V		:out std_logic_vector(2 downto 0);	--Vertical porch
	Z		:out std_logic_vector(4 downto 0);	--Horizontal porch
	AT1		:out std_logic;						--??
	AT0		:out std_logic;						--Color
	SC		:out std_logic;						--??
	ATTR	:out std_logic_vector(4 downto 0);	--Attribute length
	
	mon0	:out std_logic_vector(7 downto 0);
	mon1	:out std_logic_vector(7 downto 0);
	mon2	:out std_logic_vector(7 downto 0);
	mon3	:out std_logic_vector(7 downto 0);
	mon4	:out std_logic_vector(7 downto 0);

	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component GraphALU
port(
	CS		:in std_logic;
	RDn		:in std_logic;
	RDDAT0	:in std_logic_vector(7 downto 0);
	RDDAT1	:in std_logic_vector(7 downto 0);
	RDDAT2	:in std_logic_vector(7 downto 0);
	
	WRDAT0	:out std_logic_vector(7 downto 0);
	WRDAT1	:out std_logic_vector(7 downto 0);
	WRDAT2	:out std_logic_vector(7 downto 0);
	WEBIT	:out std_logic_vector(2 downto 0);
	
	CPUWD	:in std_logic_vector(7 downto 0);
	CPURD	:out std_logic_vector(7 downto 0);
	
	ALU0	:in std_logic_vector(1 downto 0);
	ALU1	:in std_logic_vector(1 downto 0);
	ALU2	:in std_logic_vector(1 downto 0);
	
	GDM		:in std_logic_vector(1 downto 0);
	
	PLN		:in std_logic_vector(2 downto 0);

	GVAM	:in std_logic;
	GAM		:in std_logic;
	NSEL	:in integer range 0 to 3;

	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component trammaps
generic(
	awidth	:integer	:=25
);
port(
	VADR		:in std_logic_vector(15 downto 0);
	
	RAM_ADR		:out std_logic_vector(awidth-1 downto 0)
);
end component;

component IO_RD
generic(
	IOADR	:in std_logic_vector(7 downto 0)	:=x"00"
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	RDn		:in std_logic;
	DAT		:out std_logic_vector(7 downto 0);
	OUTE	:out std_logic;
	
	bit7	:in std_logic;
	bit6	:in std_logic;
	bit5	:in std_logic;
	bit4	:in std_logic;
	bit3	:in std_logic;
	bit2	:in std_logic;
	bit1	:in std_logic;
	bit0	:in std_logic
);
end component;

component IO_WRS
generic(
	IOADR	:in std_logic_vector(7 downto 0)	:=x"00"
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	WRn		:in std_logic;
	DAT		:in std_logic_vector(7 downto 0);
	
	bit7	:out std_logic;
	bit6	:out std_logic;
	bit5	:out std_logic;
	bit4	:out std_logic;
	bit3	:out std_logic;
	bit2	:out std_logic;
	bit1	:out std_logic;
	bit0	:out std_logic;

	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component IO_RWS
generic(
	IOADR	:in std_logic_vector(7 downto 0)	:=x"00"
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	RDn		:in std_logic;
	WRn		:in std_logic;
	DATIN	:in std_logic_vector(7 downto 0);
	DATOUT	:out std_logic_vector(7 downto 0);
	DATOE	:out std_logic;
	
	bit7	:out std_logic;
	bit6	:out std_logic;
	bit5	:out std_logic;
	bit4	:out std_logic;
	bit3	:out std_logic;
	bit2	:out std_logic;
	bit1	:out std_logic;
	bit0	:out std_logic;

	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component IOWAIT
port(
	IORQn	:in std_logic;
	RDn		:in std_logic;
	WRn		:in std_logic;
	
	WAITn	:out std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component TDMAREGS
generic(
	ADRTOP	:in std_logic_vector(7 downto 0)	:=x"64";
	ADRLEN	:in std_logic_vector(7 downto 0)	:=x"65";
	ADRCMD	:in std_logic_vector(7 downto 0)	:=x"68"
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	WRn		:in std_logic;
	DAT		:in std_logic_vector(7 downto 0);
	
	TRAMTOP	:out std_logic_vector(15 downto 0);
	TRAMLEN	:out std_logic_vector(15 downto 0);
	TDMAEN	:out std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component TRAMCONV
port(
	TVRMODE		:in std_logic;
	TMODE		:in std_logic;
	COLOR		:in std_logic;
	TEXTEN		:in std_logic;
	ATTRLEN		:in std_logic_vector(4 downto 0);
	
	TADR_TOP	:in std_logic_vector(15 downto 0);

	TRAM_ADR	:out std_logic_vector(11 downto 0);
	TRAM_DAT	:in std_logic_vector(7 downto 0);
	
	MRAM_ADR	:out std_logic_vector(15 downto 0);
	MRAM_DAT	:in std_logic_vector(7 downto 0);
	MRAM_RDn	:out std_logic;
	MRAM_WAIT	:in std_logic;
	BUS_USE		:out std_logic;
	
	BUSREQn		:out std_logic;
	BUSACKn		:in std_logic;
	

	TVRAM_ADR	:out std_logic_vector(11 downto 0);
	TVRAM_WDAT	:out std_logic_vector(7 downto 0);
	TVRAM_WR	:out std_logic;
	
	VRET		:in std_logic;
	HRET		:in std_logic;
	DONE		:out std_logic;
	
	clk			:in std_logic;
	rstn		:in std_logic
);
end component;

component KBMAP
generic(
	CLKCYC	:integer	:=20000;
	SFTCYC	:integer	:=400
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	RDn		:in std_logic;
	DAT		:out std_logic_vector(7 downto 0);
	OE		:out std_logic;

	KBCLKIN	:in std_logic;
	KBCLKOUT:out std_logic;
	KBDATIN	:in std_logic;
	KBDATOUT:out std_logic;
	
	KBDAT	:out std_logic_vector(7 downto 0);
	KBRX	:out std_logic;
	KBEN	:in std_logic	:='1';
	
	monout	:out std_logic_vector(7 downto 0);

	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component INTCONTS
generic(
	CNTADR	:std_logic_vector(7 downto 0)	:=x"e4";
	MSKADR	:std_logic_vector(7 downto 0)	:=x"e6"
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	WRn		:in std_logic;
	RDn		:in std_logic;
	M1n		:in std_logic;
	RFRSHn	:in std_logic;
	DATIN	:in std_logic_vector(7 downto 0);
	DATOUT	:out std_logic_vector(7 downto 0);
	DATOE	:out std_logic;

	INTn	:out std_logic;
	
	INT0n	:in std_logic;
	INT1n	:in std_logic;
	INT2n	:in std_logic;
	INT3n	:in std_logic;
	INT4n	:in std_logic;
	INT5n	:in std_logic;
	INT6n	:in std_logic;
	INT7n	:in std_logic;
	
	cpuclk	:in std_logic;
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component rtc4990
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
end component;

component e8255
port(
	CSn		:in std_logic;
	RDn		:in std_logic;
	WRn		:in std_logic;
	ADR		:in std_logic_vector(1 downto 0);
	DATIN	:in std_logic_vector(7 downto 0);
	DATOUT	:out std_logic_vector(7 downto 0);
	DATOE	:out std_logic;
	
	PAi		:in std_logic_vector(7 downto 0);
	PAo		:out std_logic_vector(7 downto 0);
	PAoe	:out std_logic;
	PBi		:in std_logic_vector(7 downto 0);
	PBo		:out std_logic_vector(7 downto 0);
	PBoe	:out std_logic;
	PCHi	:in std_logic_vector(3 downto 0);
	PCHo	:out std_logic_vector(3 downto 0);
	PCHoe	:out std_logic;
	PCLi	:in std_logic_vector(3 downto 0);
	PCLo	:out std_logic_vector(3 downto 0);
	PCLoe	:out std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component KANJIROM
	generic(
	BASEADR	:std_logic_vector(7 downto 0)	:=x"e8"
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	RDn		:in std_logic;
	WRn		:in std_logic;
	WDAT	:in std_logic_vector(7 downto 0);
	
	KNJADR	:out std_logic_vector(16 downto 0);
	KNJRD	:out std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component e8251
port(
	WRn		:in std_logic;
	RDn		:in std_logic;
	C_Dn	:in std_logic;
	CSn		:in std_logic;
	DATIN	:in std_logic_vector(7 downto 0);
	DATOUT	:out std_logic_vector(7 downto 0);
	DATOE	:out std_logic;
	
	TXD		:out std_logic;
	RxD		:in std_logic;
	
	DSRn	:in std_logic;
	DTRn	:out std_logic;
	RTSn	:out std_logic;
	CTSn	:in std_logic;
	
	TxRDY	:out std_logic;
	TxEMP	:out std_logic;
	RxRDY	:out std_logic;
	
	TxCn	:in std_logic;
	RxCn	:in std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component addsat
generic(
	datwidth	:integer	:=16
);
port(
	INA		:in std_logic_vector(datwidth-1 downto 0);
	INB		:in std_logic_vector(datwidth-1 downto 0);
	
	OUTQ	:out std_logic_vector(datwidth-1 downto 0);
	OFLOW	:out std_logic;
	UFLOW	:out std_logic
);
end component;

component average
generic(
	datwidth	:integer	:=16
);
port(
	INA		:in std_logic_vector(datwidth-1 downto 0);
	INB		:in std_logic_vector(datwidth-1 downto 0);
	
	OUTQ	:out std_logic_vector(datwidth-1 downto 0)
);
end component;

component SFTCLK
generic(
	SYS_CLK	:integer	:=20000;
	OUT_CLK	:integer	:=1600;
	selWIDTH :integer	:=2
);
port(
	sel		:in std_logic_vector(selWIDTH-1 downto 0);
	SFT		:out std_logic;

	clk		:in std_logic;
	rstn	:in std_logic
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

component SUBunitsDEMU2
generic(
	sysclk	:integer	:=21477;	--in kHz
	memclk	:integer	:=80000;		--in kHz
	awidth	:integer	:=25
);
port(
	RAMADR			:out std_logic_vector(awidth-1 downto 0);
	RAMRDAT			:in std_logic_vector(7 downto 0);
	RAMWDAT			:out std_logic_vector(7 downto 0);
	RAMWR			:out std_logic;
	RAMRD			:out std_logic;
	RAMWAIT			:in std_logic;
	
	SUBIO_PAI		:in std_logic_vector(7 downto 0);
	SUBIO_PAO		:out std_logic_vector(7 downto 0);
	SUBIO_PBI		:in std_logic_vector(7 downto 0);
	SUBIO_PBO		:out std_logic_vector(7 downto 0);
	SUBIO_PCHI		:in std_logic_vector(3 downto 0);
	SUBIO_PCHO		:out std_logic_vector(3 downto 0);
	SUBIO_PCLI		:in std_logic_vector(3 downto 0);
	SUBIO_PCLO		:out std_logic_vector(3 downto 0);
	
	dmon0			:out std_logic_vector(7 downto 0);
	dmon1			:out std_logic_vector(7 downto 0);
	dmon2			:out std_logic_vector(7 downto 0);
	dmon3			:out std_logic_vector(7 downto 0);
	dmon4			:out std_logic_vector(7 downto 0);
	dmon5			:out std_logic_vector(7 downto 0);
	dmon6			:out std_logic_vector(7 downto 0);
	dmon7			:out std_logic_vector(7 downto 0);
	
	FD_DENn			:out std_logic;
	FD_INDEXn		:in std_logic;
	FD_DIRn			:out std_logic;
	FD_STEPn		:out std_logic;
	FD_WDATAn		:out std_logic;
	FD_WGATEn		:out std_logic;
	FD_TRK00n		:in std_logic;
	FD_WPTn			:in std_logic;
	FD_RDATAn		:in std_logic;
	FD_SIDE1n		:out std_logic;
	FD_DSKCHG		:in std_logic;
	FD_DS0			:out std_logic;
	FD_MOTOR0		:out std_logic;
	FD_DS1			:out std_logic;
	FD_MOTOR1		:out std_logic;
	FDSSEL0			:in std_logic;
	FDSSEL1			:in std_logic;
	
	MTSAVEON		:in std_logic;
	
	sdc_miso		:in std_logic;
	sdc_mosi		:out std_logic;
	sdc_sclk		:out std_logic;
	sdc_cs			:out std_logic;
	EMUVADDR		:in std_logic_vector(12 downto 0);
	EMUVDATA		:out std_logic_vector(7 downto 0);
	EMUCUR_L		:out std_logic_vector(4 downto 0);
	EMUCUR_C		:out std_logic_vector(6 downto 0);
	EMUCUREN		:out std_logic;
	EMUKBDAT		:in std_logic_vector(7 downto 0);
	EMUKBRX			:in std_logic;
	EMUBUSY			:out std_logic;
	
	FDE_ADDR		:out std_logic_vector(23 downto 0);
	FDE_RD			:out std_logic;
	FDE_WR			:out std_logic;
	FDE_WDAT		:out std_logic_vector(15 downto 0);
	FDE_RDAT		:in std_logic_vector(15 downto 0);
	FDE_RAMWAIT		:in std_logic;
	
	FEC_ADDR		:out std_logic_vector(23 downto 0);
	FEC_RD			:out std_logic;
	FEC_WR			:out std_logic;
	FEC_WDAT		:out std_logic_vector(15 downto 0);
	FEC_RDAT		:in std_logic_vector(15 downto 0);
	FEC_RAMWAIT		:in std_logic;

	mondat	:out std_logic_vector(7 downto 0);

	EMUINITDONE		:out std_logic;
	CPUCLK			:in std_logic;
	clk21m			:in std_logic;
	ramclk			:in std_logic;
	pclk			:in std_logic;
	vclk			:in std_logic;
	srstn			:in std_logic;
	rstn			:in std_logic
);
end component;

component  OPN
generic(
	res		:integer	:=9
);
port(
	DIN		:in std_logic_vector(7 downto 0);
	DOUT	:out std_logic_vector(7 downto 0);
	DOE		:out std_logic;
	CSn		:in std_logic;
	ADR0	:in std_logic;
	RDn		:in std_logic;
	WRn		:in std_logic;
	INTn	:out std_logic;
	
	snd		:out std_logic_vector(res-1 downto 0);
	
	PAOUT	:out std_logic_vector(7 downto 0);
	PAIN	:in std_logic_vector(7 downto 0);
	PAOE	:out std_logic;
	
	PBOUT	:out std_logic_vector(7 downto 0);
	PBIN	:in std_logic_vector(7 downto 0);
	PBOE	:out std_logic;

	clk		:in std_logic;
	cpuclk	:in std_logic;
	sft		:in std_logic;
	rstn	:in std_logic
);
end component;

component OPNA
generic(
	res		:integer	:=16
);
port(
	DIN		:in std_logic_vector(7 downto 0);
	DOUT	:out std_logic_vector(7 downto 0);
	DOE		:out std_logic;
	CSn		:in std_logic;
	ADR		:in std_logic_vector(1 downto 0);
	RDn		:in std_logic;
	WRn		:in std_logic;
	INTn	:out std_logic;
	
	sndL		:out std_logic_vector(res-1 downto 0);
	sndR		:out std_logic_vector(res-1 downto 0);
	sndPSG		:out std_logic_vector(res-1 downto 0);
	
	PAOUT	:out std_logic_vector(7 downto 0);
	PAIN	:in std_logic_vector(7 downto 0);
	PAOE	:out std_logic;
	
	PBOUT	:out std_logic_vector(7 downto 0);
	PBIN	:in std_logic_vector(7 downto 0);
	PBOE	:out std_logic;
	
	RAMADDR	:out std_logic_vector(17 downto 0);
	RAMRD	:out std_logic;
	RAMWR	:out std_logic;
	RAMRDAT	:in std_logic_vector(7 downto 0);
	RAMWDAT	:out std_logic_vector(7 downto 0);
	RAMWAIT	:in std_logic;

	clk		:in std_logic;
	cpuclk	:in std_logic;
	sft		:in std_logic;
	rstn	:in std_logic
);
end component;

component deltasigmadac
	generic(
		width	:integer	:=8
	);
	port(
		data	:in	std_logic_vector(width-1 downto 0);
		datum	:out std_logic;
		
		sft		:in std_logic;
		clk		:in std_logic;
		rstn	:in std_logic
	);
end component;

component DIGIFILTER
	generic(
		TIME	:integer	:=2;
		DEF		:std_logic	:='0'
	);
	port(
		D	:in std_logic;
		Q	:out std_logic;

		clk	:in std_logic;
		rstn :in std_logic
	);
end component;

component  beeposc
generic(
	beepcyc	:integer	:=10000;		--Hz
	sysclk	:integer	:=20000			--kHz
);
port(
	sndout	:out std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component CPUCLK
generic(
	divmain	:integer	:=5;
	divsub	:integer	:=10
);
port(
	clkin	:in std_logic;
	clksel	:in std_logic;
	mainout	:out std_logic;
	subout	:out std_logic;
	rstn	:in std_logic
);
end component;

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

component EDIDread
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
end component;

component EDIDmon
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
end component;

component SPI_IF
port(
	MODE	:in std_logic_vector(1 downto 0);
	WRDAT	:in std_logic_vector(7 downto 0);
	RDDAT	:out std_logic_vector(7 downto 0);
	TX		:in std_logic;
	BUSY	:out std_logic;
	
	SCLK	:out std_logic;
	SDI		:in std_logic;
	SDO		:out std_logic;
	
	SFT		:in std_logic;
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component UNCHCHATA
	generic(
		MASKTIME	:integer	:=200;	--usec
		SYS_CLK		:integer	:=20	--MHz
	);
	port(
		SRC		:in std_logic;
		DST		:out std_logic;
		
		clk		:in std_logic;
		rstn	:in std_logic
	);
end component;

component  clkdiv
generic(
	dwidth	:integer	:=8
);
port(
	div		:in std_logic_vector(dwidth-1 downto 0);
	
	cout	:out std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component hdmiconv
port(
	datinR	:in std_logic_vector(7 downto 0);
	datinG	:in std_logic_vector(7 downto 0);
	datinB	:in std_logic_vector(7 downto 0);
	Hsync		:in std_logic;
	Vsync		:in std_logic;
	VIDen		:in std_logic;
	
	LVDS0		:out std_logic;
	LVDS1		:out std_logic;
	LVDS2		:out std_logic;
	LVDSclk	:out std_logic;
	
	vclk		:in std_logic;
	clk2		:in std_logic;
	rstn		:in std_logic
);
end component;

component DBGLINE
port(
	START		:in std_logic;
	dat0		:in std_logic_vector(7 downto 0);
	dat1		:in std_logic_vector(7 downto 0);
	dat2		:in std_logic_vector(7 downto 0);
	dat3		:in std_logic_vector(7 downto 0);
	dat4		:in std_logic_vector(7 downto 0);
	dat5		:in std_logic_vector(7 downto 0);
	dat6		:in std_logic_vector(7 downto 0);
	dat7		:in std_logic_vector(7 downto 0);
	
	BUSUSE		:out std_logic;
	TVRAM_ADR	:out std_logic_vector(11 downto 0);
	TVRAM_WDAT	:out std_logic_vector(7 downto 0);
	TVRAM_WR	:out std_logic;
	
	clk			:in std_logic;
	rstn		:in std_logic
);
end component;

component HEX2SEGn
	port(
		HEX	:in std_logic_vector(3 downto 0);
		DOT	:in std_logic;
		SEG	:out std_logic_vector(7 downto 0)
	);
end component;

signal	cVer		:std_logic;
signal	cHS			:std_logic;
signal	cN			:std_logic;
signal	cBT			:std_logic;
signal	c20L		:std_logic;
signal	c40C		:std_logic;
signal	cDisk		:std_logic;

signal	SDI			:std_logic;
signal	CPUADR		:std_logic_vector(15 downto 0);
signal	RAMADR		:std_logic_vector(RAMAWIDTH-1 downto 0);
signal	RAM_WR		:std_logic;
signal	RAM_RD		:std_logic;
signal	RAM_WDAT	:std_logic_vector(7 downto 0);
signal	IDAT_RAM	:std_logic_vector(7 downto 0);
signal	CPUDAT		:std_logic_vector(7 downto 0);
signal	RD_n		:std_logic;
signal	WR_n		:std_logic;
signal	MREQ_n		:std_logic;
signal	IORQ_n		:std_logic;
signal	WAIT_n		:std_logic;
signal	INT_n		:std_logic;
signal	NMI_n		:std_logic;
signal	M1_n		:std_logic;
signal	LOADER_DONE	:std_logic;
signal	CPU_rstn	:std_logic;
signal	CPU_clk		:std_logic;
signal	BUSRQ_n		:std_logic;
signal	BUSACK_n	:std_logic;
signal	RAM_WAIT	:std_logic;
signal	LOADER_rstn :std_logic;
signal	CLR_ADR		:std_logic_vector(18 downto 0);
signal	CLR_WDAT	:std_logic_vector(7 downto 0);
signal	CLR_WR		:std_logic;
signal	CLR_OE		:std_logic;
signal	CLR_rstn	:std_logic;
signal	LOADER_ADR		:std_logic_vector(18 downto 0);
signal	LOADER_WDAT	:std_logic_vector(7 downto 0);
signal	LOADER_OE		:std_logic;
signal	LOADER_WR		:std_logic;
signal	clk21m		:std_logic;
signal	rclk		:std_logic;
signal	gclk		:std_logic;
signal	clkcount	:integer range 0 to 5000000;
signal	slowclk		:std_logic;
signal	MAP_RADR	:std_logic_vector(RAMAWIDTH-1 downto 0);
signal	VMAP_RADR	:std_logic_vector(RAMAWIDTH-1 downto 0);
signal	IDAT_MAP	:std_logic_vector(7 downto 0);
signal	MAP_OE		:std_logic;
signal	RAM_CE		:std_logic;
signal	TRAM_ADR	:std_logic_vector(11 downto 0);
signal	TRAM_CE		:std_logic;
signal	IDAT_TRAM	:std_logic_vector(7 downto 0);
signal	TVRAM_ADR	:std_logic_vector(11 downto 0);
signal	TVRAM_CE	:std_logic;
signal	IDAT_TVRAM	:std_logic_vector(7 downto 0);
signal	CRTC_TADR	:std_logic_vector(11 downto 0);
signal	CRTC_TDAT	:std_logic_vector(7 downto 0);
signal	IDAT_CRTR	:std_logic_vector(7 downto 0);
signal	CRTR_OE		:std_logic;
signal	IDAT_KB		:std_logic_vector(7 downto 0);
signal	KB_OE		:std_logic;
signal	IDAT_ALU	:std_logic_vector(7 downto 0);
signal	ALU_OE		:std_logic;
signal	IDAT_IOR30	:std_logic_vector(7 downto 0);
signal	IOR30_OE	:std_logic;
signal	IDAT_IOR31	:std_logic_vector(7 downto 0);
signal	IOR31_OE	:std_logic;
signal	IDAT_IOR32	:std_logic_vector(7 downto 0);
signal	IOR32_OE	:std_logic;
signal	IDAT_IOR33	:std_logic_vector(7 downto 0);
signal	IOR33_OE	:std_logic;
signal	IDAT_IOR38	:std_logic_vector(7 downto 0);
signal	IOR38_OE	:std_logic;
signal	IDAT_IOR40	:std_logic_vector(7 downto 0);
signal	IOR40_OE	:std_logic;
signal	IDAT_IOR6e	:std_logic_vector(7 downto 0);
signal	IOR6e_OE	:std_logic;
signal	IDAT_IOR71	:std_logic_vector(7 downto 0);
signal	IOR71_OE	:std_logic;
signal	IDAT_PPIFD	:std_logic_vector(7 downto 0);
signal	PPIFD_OE	:std_logic;
signal	IDAT_PSG	:std_logic_vector(7 downto 0);
signal	PSG_OE		:std_logic;
signal	IDAT_COM	:std_logic_vector(7 downto 0);
signal	COM_OE		:std_logic;
signal	COM_CSn		:std_logic;
signal	IO_WAIT		:std_logic;
signal	IDAT_INTC	:std_logic_vector(7 downto 0);
signal	INTC_OE		:std_logic;
signal	HRTC		:std_logic;
signal	VRTC		:std_logic;
signal	CDI			:std_logic;
signal	CCK			:std_logic;
signal	CSTB		:std_logic;
signal	C_RTC		:std_logic_vector(2 downto 0);
signal	C_DO		:std_logic;
signal	CD0			:std_logic;
signal	TRAMTOP		:std_logic_vector(15 downto 0);
signal	TRAMLEN		:std_logic_vector(15 downto 0);
signal	TDMAEN		:std_logic;
signal	PMODE		:std_logic;
signal	TMODE		:std_logic;
signal	TVRMODE		:std_logic;
signal	TVRAM_WDAT	:std_logic_vector(7 downto 0);
signal	TVRAM_MADR	:std_logic_vector(11 downto 0);
signal	TVRAM_WE	:std_logic;
signal	ATTRLEN		:std_logic_vector(4 downto 0);
signal	TXTWINEN	:std_logic;
signal	VRTCi		:std_logic;
signal	PPIFD_CSn	:std_logic;
signal	PSG_CEn		:std_logic;

signal	TCNV_TDAT	:std_logic_vector(7 downto 0);
signal	TCNV_TADR	:std_logic_vector(11 downto 0);
signal	TCNV_RDAT	:std_logic_vector(7 downto 0);
signal	TCNV_RADR	:std_logic_vector(15 downto 0);
signal	TCNV_RDn	:std_logic;
signal	TCNV_BURQn	:std_logic;
signal	TCNV_BUSACKn:std_logic;
signal	TCNV_WADR	:std_logic_vector(11 downto 0);
signal	TCNV_WDAT	:std_logic_vector(7 downto 0);
signal	TCNV_WE		:std_logic;
signal	TCNV_BUSUSE	:std_logic;
signal	COLORn		:std_logic;
signal	ODAT_TCNV	:std_logic_vector(7 downto 0);
signal	pclk		:std_logic;
signal	emuclk	:std_logic;

signal	CURL		:std_logic_vector(4 downto 0);
signal	CURC		:std_logic_vector(6 downto 0);
signal	CURE		:std_logic;
signal	CURM		:std_logic;
signal	CBLINK		:std_logic;
signal	TEXTDS		:std_logic;
signal	CRTCen		:std_logic;

signal	G_RAMSEL	:std_logic;
signal	ALU_RE		:std_logic;
signal	GRDAT0		:std_logic_vector(7 downto 0);
signal	GRDAT1		:std_logic_vector(7 downto 0);
signal	GRDAT2		:std_logic_vector(7 downto 0);
signal	GWDAT0		:std_logic_vector(7 downto 0);
signal	GWDAT1		:std_logic_vector(7 downto 0);
signal	GWDAT2		:std_logic_vector(7 downto 0);
signal	GWEBIT		:std_logic_vector(2 downto 0);
signal	ALU0		:std_logic_vector(1 downto 0);
signal	ALU1		:std_logic_vector(1 downto 0);
signal	ALU2		:std_logic_vector(1 downto 0);
signal	GDM			:std_logic_vector(1 downto 0);
signal	PLN			:std_logic_vector(2 downto 0);
signal	GVAM		:std_logic;
signal	NG_RAMSEL	:integer range 0 to 3;
signal	GR_RSEL		:integer range 0 to 3;
signal	GWME		:std_logic;
signal	GRAM_M_OE	:std_logic;
signal	GAM			:std_logic;
signal	ALUCWD		:std_logic_vector(7 downto 0);
signal	GxDS		:std_logic_vector(2 downto 0);

signal	KBCLKIN		:std_logic;
signal	KBCLKOUT	:std_logic;
signal	KBDATIN		:std_logic;
signal	KBDATOUT	:std_logic;

signal	RTI			:std_logic;

signal	GRAMADR		:std_logic_vector(13 downto 0);
signal	GRAMADRW		:std_logic_vector(RAMAWIDTH-1 downto 0);
signal	GRAMRD		:std_logic;
signal	GRAMWAIT	:std_logic;
signal	GRAMDAT0	:std_logic_vector(7 downto 0);
signal	GRAMDAT1	:std_logic_vector(7 downto 0);
signal	GRAMDAT2	:std_logic_vector(7 downto 0);

signal	GRAPHEN		:std_logic;
signal	L200		:std_logic;
signal	LOWRES		:std_logic;
signal	GCOLOR		:std_logic;

signal	INT0n		:std_logic;
signal	INT1n		:std_logic;
signal	INT2n		:std_logic;
signal	INT3n		:std_logic;
signal	INT4n		:std_logic;
signal	INT5n		:std_logic;
signal	INT6n		:std_logic;
signal	INT7n		:std_logic;

signal	SUBADR		:std_logic_vector(RAMAWIDTH-1 downto 0);
signal	SUBRDAT		:std_logic_vector(7 downto 0);
signal	SUBWDAT		:std_logic_vector(7 downto 0);
signal	SUBWR		:std_logic;
signal	SUBRD		:std_logic;
signal	SUBWAIT		:std_logic;
signal	SUBCLK		:std_logic;

signal	KANJI1ADR	:std_logic_vector(16 downto 0);
signal	KANJI1RD	:std_logic;

signal	KANJI2ADR	:std_logic_vector(16 downto 0);
signal	KANJI2RD	:std_logic;

signal	cpuclkb,subclkb	:std_logic;

signal	loaderclk	:std_logic;
signal	plllocked	:std_logic;
signal	srstn		:std_logic;

signal	SUB_TXM2S	:std_logic_vector(7 downto 0);
signal	SUB_TXS2M	:std_logic_vector(7 downto 0);
signal	SUB_RXM2S	:std_logic_vector(7 downto 0);
signal	SUB_RXS2M	:std_logic_vector(7 downto 0);
signal	SUB_HTM2S	:std_logic_vector(3 downto 0);
signal	SUB_HTS2M	:std_logic_vector(3 downto 0);
signal	SUB_HRM2S	:std_logic_vector(3 downto 0);
signal	SUB_HRS2M	:std_logic_vector(3 downto 0);

signal	IORQ_np		:std_logic;
signal	MREQ_np		:std_logic;
signal	WR_np		:std_logic;
signal	RD_np		:std_logic;
signal	CPUADRp		:std_logic_vector(15 downto 0);
signal	REFRSHn		:std_logic;
signal	HMODE		:std_logic;
signal	VMODE		:std_logic;
signal	srstna	:std_logic;
signal	rstcnt	:integer range 0 to 100;
signal	CPUCT	:std_logic_vector(1 downto 0);
signal	SUBCT	:std_logic_vector(1 downto 0);
signal	COLCOUNT	:integer range 0 to 15;
signal	MONSFT		:std_logic_vector(7 downto 0);
signal	VRAMWE		:std_logic_vector(3 downto 0);

signal	pStr	:std_logic;
signal	pJoy	:std_logic_vector(5 downto 0);

signal	SEG0	:std_logic_vector(3 downto 0);
signal	SEG1	:std_logic_vector(3 downto 0);
signal	SEG2	:std_logic_vector(3 downto 0);
signal	SEG3	:std_logic_vector(3 downto 0);
signal	SEG4	:std_logic_vector(3 downto 0);
signal	SEG5	:std_logic_vector(3 downto 0);

signal RMODE,MMODE	:std_logic;
signal EROMSEL1,EROMSEL0	:std_logic;
signal	IEROM	:std_logic;
signal	TCNVDONE	:std_logic;

signal	beepsig	:std_logic;
signal	beepen	:std_logic;
signal	BEEPsnd	:std_logic_vector(15 downto 0);

signal	OPNsft		:std_logic;
signal	INTn_OPN	:std_logic;
signal	SINTM		:std_logic;

signal	TXTen		:std_logic;
signal	TenSw		:std_logic;
signal	CPUMD		:std_logic;
signal	sndPSG	:std_logic_vector(15 downto 0);
signal	monosnd	:std_logic_vector(15 downto 0);
signal	sndL,sndR	:std_logic_vector(15 downto 0);
signal	snddatL,usnddatL	:std_logic_vector(15 downto 0);
signal	snddatR,usnddatR	:std_logic_vector(15 downto 0);

signal	INT_COMRX	:std_logic;
signal	COM_clk		:std_logic;

signal	BS			:std_logic_vector(1 downto 0);
constant COM_BAUD	:integer	:=9600;
constant COM_DIV	:integer	:=(SYSCLK*1000/COM_BAUD/32)-1;
signal	COM_vDIV	:std_logic_vector(10 downto 0);
signal	MTON		:std_logic;
signal	CDS			:std_logic;

signal	MODE		:std_logic_vector(1 downto 0);
constant MOD_N		:std_logic_vector(1 downto 0)	:="00";
constant MOD_V1S	:std_logic_vector(1 downto 0)	:="01";
constant MOD_V1H	:std_logic_vector(1 downto 0)	:="10";
constant MOD_V2		:std_logic_vector(1 downto 0)	:="11";

signal	MTSAVE		:std_logic;
signal	TRAM_TDAT	:std_logic_vector(7 downto 0);
signal	CRTC_CURL	:std_logic_vector(4 downto 0);
signal	CRTC_CURC	:std_logic_vector(6 downto 0);
signal	CRTC_CURE	:std_logic;

--Font data
signal	FRAMADDR		:std_logic_vector(12 downto 0);
signal	FRAMWDAT		:std_logic_vector(7 downto 0);
signal	FRAMWR		:std_logic;

--DISK emulation
signal	EMUINITDONE	:std_logic;
signal	emudisp		:std_logic;
signal	emusel		:std_logic;
signal	sdc_miso	:std_logic;
signal	sdc_mosi	:std_logic;
signal	sdc_csel	:std_logic;
signal	sdc_sclk	:std_logic;
signal	DEMU_VADDR	:std_logic_vector(12 downto 0);
signal	DEMU_VDAT	:std_logic_vector(7 downto 0);
signal	DEMU_CURL	:std_logic_vector(4 downto 0);
signal	DEMU_CURC	:std_logic_vector(6 downto 0);
signal	DEMU_CUREN	:std_logic;
signal	DEMU_KBDAT	:std_logic_vector(7 downto 0);
signal	DEMU_KBRX	:std_logic;
signal	KBRX		:std_logic;

signal	FDE_ADDR	:std_logic_vector(23 downto 0);
signal	FDE_ADDRW	:std_logic_vector(RAMAWIDTH-1 downto 0);
signal	FDE_RD		:std_logic;
signal	FDE_WR		:std_logic;
signal	FDE_WDAT	:std_logic_vector(15 downto 0);
signal	FDE_RDAT	:std_logic_vector(15 downto 0);
signal	FDE_RAMWAIT	:std_logic;
	
signal	FEC_ADDR	:std_logic_vector(23 downto 0);
signal	FEC_ADDRW	:std_logic_vector(RAMAWIDTH-1 downto 0);
signal	FEC_RD		:std_logic;
signal	FEC_WR		:std_logic;
signal	FEC_WDAT	:std_logic_vector(15 downto 0);
signal	FEC_RDAT	:std_logic_vector(15 downto 0);
signal	FEC_RAMWAIT	:std_logic;

--OPNA
signal	PCMADDR	:std_logic_vector(17 downto 0);
signal	PCMADDRW	:std_logic_vector(RAMAWIDTH-1 downto 0);
signal	PCMRD		:std_logic;
signal	PCMWR		:std_logic;
signal	PCMRDAT	:std_logic_vector(7 downto 0);
signal	PCMWDAT	:std_logic_vector(7 downto 0);
signal	PCMRWAIT	:std_logic;

--for I2C I/F
signal	SDAIN,SDAOUT	:std_logic;
signal	SCLIN,SCLOUT	:std_logic;
signal	I2CCLKEN	:std_logic;
signal	I2C_TXDAT	:std_logic_vector(7 downto 0);		--tx data in
signal	I2C_RXDAT	:std_logic_vector(7 downto 0);	--rx data out
signal	I2C_WRn		:std_logic;						--write
signal	I2C_RDn		:std_logic;						--read
signal	I2C_TXEMP	:std_logic;							--tx buffer empty
signal	I2C_RXED	:std_logic;							--rx buffered
signal	I2C_NOACK	:std_logic;							--no ack
signal	I2C_COLL	:std_logic;							--collision detect
signal	I2C_NX_READ	:std_logic;							--next data is read
signal	I2C_RESTART	:std_logic;							--make re-start condition
signal	I2C_START	:std_logic;							--make start condition
signal	I2C_FINISH	:std_logic;							--next data is final(make stop condition)
signal	I2C_F_FINISH :std_logic;							--next data is final(make stop condition)
signal	I2C_INIT	:std_logic;

--EDID  I/F
signal	EDID				:EDID_ARRAY(0 to 127);
signal	HDMI_I2C_SCLI	:std_logic;
signal	HDMI_I2C_SCLO	:std_logic;
signal	HDMI_I2C_SDAI	:std_logic;
signal	HDMI_I2C_SDAO	:std_logic;
signal	EDIDmon_CS		:std_logic;
signal	IDAT_EDIDmon	:std_logic_vector(7 downto 0);
signal	EDIDmon_DOE		:std_logic;
signal	EDID_CONNECT	:std_logic;
signal	EDID_ERROR		:std_logic;
--video signal
signal	vidR3	:std_logic_vector(2 downto 0);
signal	vidG3	:std_logic_vector(2 downto 0);
signal	vidB3	:std_logic_vector(2 downto 0);
signal	vidR8	:std_logic_vector(7 downto 0);
signal	vidG8	:std_logic_vector(7 downto 0);
signal	vidB8	:std_logic_vector(7 downto 0);
signal	vidHS	:std_logic;
signal	vidVS	:std_logic;
signal	vidEN	:std_logic;
signal	hdmiclk	:std_logic;
begin

	MODE <=	pDip(1 downto 0);

	cHS	<=	'1' when MODE=MOD_V1H else
			'1' when MODE=MOD_V2 else
			'0';
	
	cVer <=	'1' when MODE=MOD_V1S else
			'1' when MODE=MOD_V1H else
			'1' when MODE=MOD_N else
			'0';
	cN <=	'0' when MODE=MOD_N else
			'1';

	cBT		<=pDip(2);
	c40C	<=pDip(4);
	c20L	<=pDip(5);
	cDisk	<=pDip(6);

	MTSAVE	<=pDip(3);

	CPUMD<=pDip(9);

	srstna<=rstn and plllocked;
	process(rclk,srstna)begin
		if(srstna='0')then
			rstcnt<=100;
			srstn<='0';
		elsif(rclk' event and rclk='0')then
			if(rstcnt=0)then
				srstn<='1';
			else
				rstcnt<=rstcnt-1;
			end if;
		end if;
	end process;
	
	CPU	:T80a generic map(0)
	port map(
		RESET_n	=>CPU_rstn,
		CLK_n	=>CPU_clk,
--		CLK_n	=>slowclk,
--		CLK_n	=>pPsw(0),
		WAIT_n	=>WAIT_n,
		INT_n	=>INT_n,
		NMI_n	=>NMI_n,
		BUSRQ_n	=>BUSRQ_n,
		M1_n	=>M1_n,
		MREQ_n	=>MREQ_np,
		IORQ_n	=>IORQ_np,
		RD_n	=>RD_np,
		WR_n	=>WR_np,
		RFSH_n	=>REFRSHn,
		HALT_n	=>open,
		BUSAK_n	=>BUSACK_n,
		A		=>CPUADRp,
		D		=>CPUDAT
	);

	IORQ_n	<=IORQ_np	when BUSACK_n='1' else '1';
	MREQ_n	<=MREQ_np	when BUSACK_n='1' else '1';
	RD_n	<=RD_np		when BUSACK_n='1' else '1';
	WR_n	<=WR_np		when BUSACK_n='1' else '1';
	CPUADR	<=CPUADRp	when BUSACK_n='1' else (others=>'0');
	


	VRTCi<=not VRTC;

	INT0n<=not INT_COMRX;
	INT1n<=VRTCi;
	INT2n<=RTI;
	INT3n<='1';
	INT4n<=INTn_OPN or SINTM;
	INT5n<='1';
	INT6n<='1';
	INT7n<='1';

	INT	:INTCONTS generic map(x"e4",x"e6")
	port map(
	ADR			=>CPUADR(7 downto 0),
	IORQn		=>IORQ_n,
	WRn			=>WR_n,
	RDn			=>RD_n,
	M1n			=>M1_n,
	RFRSHn		=>REFRSHn,
	DATIN		=>CPUDAT,
	DATOUT		=>IDAT_INTC,
	DATOE		=>INTC_OE,

	INTn		=>INT_n,
	
	INT0n		=>INT0n,
	INT1n		=>INT1n,
	INT2n		=>INT2n,
	INT3n		=>INT3n,
	INT4n		=>INT4n,
	INT5n		=>INT5n,
	INT6n		=>INT6n,
	INT7n		=>INT7n,
	
	cpuclk		=>CPU_clk,
	clk			=>clk21m,
	rstn		=>CPU_rstn
	);
	
	MMAP	:memorymaps generic map(1,RAMAWIDTH) port map(
	CPU_ADR		=>CPUADR,
	CPU_MREQn	=>MREQ_n,
	CPU_IORQn	=>IORQ_n,
	CPU_RDn		=>RD_n,
	CPU_WRn		=>WR_n,
	CPU_WDAT	=>CPUDAT,
	CPU_RDAT	=>IDAT_MAP,
	CPU_OE		=>MAP_OE,
	
	KNJ1_ADR	=>KANJI1ADR,
	KNJ1_RD		=>KANJI1RD,
	
	KNJ2_ADR	=>KANJI2ADR,
	KNJ2_RD		=>KANJI2RD,

	RAM_ADR		=>MAP_RADR,
	RAM_CE		=>RAM_CE,
	
	TRAM_ADR	=>TRAM_ADR,
	TRAM_CE		=>TRAM_CE,
	
	TVRAM_ADR	=>TVRAM_MADR,
	TVRAM_CE	=>TVRAM_CE,
	
	TXTWINEN	=>TXTWINEN,
	
	G_EXTMODE	=>GVAM,
	G_RAMSEL	=>NG_RAMSEL,
	ALUOE		=>ALU_OE,
	ALUME		=>GRAM_M_OE,
	ALURE		=>ALU_RE,
	GADR_MSEL	=>GWME,
	
	clk			=>CPU_clk,
	rstn		=>loader_rstn
);



--	pLed<=TRAM_CE & TVRAM_CE & RAM_CE & IORQ_n & CPUADR(15 downto 12);
	
	RAMADR<=
			ADDR_BACKRAM(RAMAWIDTH-1 downto 19) & CLR_ADR when CLR_OE='1' else
			ADDR_N88(RAMAWIDTH-1 downto 19) & LOADER_ADR when LOADER_OE='1' else
			VMAP_RADR when TCNV_BUSUSE='1' else
			MAP_RADR;
	RAM_WDAT<=	CLR_WDAT when CLR_OE='1' else 
				LOADER_WDAT when LOADER_OE='1' else
				 CPUDAT;
	RAM_WR<=	CLR_WR when CLR_OE='1' else
				LOADER_WR when LOADER_OE='1' else
				(RAM_CE and (not WR_n));
	RAM_RD<='0' when (LOADER_OE='1' or CLR_OE='1') else
			not TCNV_RDn when TCNV_BUSUSE='1' else
			'1' when KANJI1RD='1' or KANJI2RD='1' else
			(RAM_CE and (not RD_n));
	
	NMI_n<='1';

	FRAMADDR<=LOADER_ADR(12 downto 0);
	FRAMWDAT<=LOADER_WDAT;
	FRAMWR<=	LOADER_WR when LOADER_OE='1' and LOADER_ADR(18 downto 13)=ADDR_FONT(18 downto 13) else '0';

	GALU	:GraphALU
port map(
	CS		=>ALU_RE,
	RDn		=>RD_n,
	RDDAT0	=>GRDAT0,
	RDDAT1	=>GRDAT1,
	RDDAT2	=>GRDAT2,
	
	WRDAT0	=>GWDAT0,
	WRDAT1	=>GWDAT1,
	WRDAT2	=>GWDAT2,
	WEBIT	=>GWEBIT,
	
	CPUWD	=>ALUCWD,
	CPURD	=>IDAT_ALU,
	
	ALU0	=>ALU0,
	ALU1	=>ALU1,
	ALU2	=>ALU2,
	
	GDM		=>GDM,
	
	PLN		=>PLN,

	GVAM	=>GVAM,
	GAM		=>GAM,
	NSEL	=>NG_RAMSEL,

	clk		=>clk21m,
	rstn	=>srstn
);
	
	
--	cgen	:cpuclk port map(clk21m,pjoya(0),cpu_clk,subclk,srstn);
--	process(rclk)begin
--		if(rclk' event and rclk='1')then
--			CPU_clk<=cpuclkb;
--			SUBCLK<=subclkb;
--		end if;
--	end process;
	CPU_clk<=cpuclkb;
	SUBCLK<=subclkb;
	
	VRAMWE<=	"1000" when CLR_OE='1' else
				"1000" when TXTWINEN='1' else
				GWME & GWEBIT;

--	process(clk21m)begin
--		if(clk21m' event and clk21m='1')then
--			if(not pjoya(4)='0')then
--				dmon6<=CPUADR(15 downto 8);
--				dmon7<=CPUADR(7 downto 0);
--			end if;
--		end if;
--	end process;
	GR_RSEL<=	3 when TCNV_BUSUSE='1' else NG_RAMSEL;
	
	GRAMADRW<=ADDR_GVRAM(RAMAWIDTH-1 downto 15) & GRAMADR & '0';
	FDE_ADDRW<=ADDR_FDEMU(RAMAWIDTH-1 downto 23) & FDE_ADDR(22 downto 0);
	FEC_ADDRW<=ADDR_FDEMU(RAMAWIDTH-1 downto 23) & FEC_ADDR(22 downto 0);
	PCMADDRW<=ADDR_ADPCM(RAMAWIDTH-1 downto 18) & PCMADDR;

	RAM	:SDRAMCde0cvDEMU2 generic map(RAMCAWIDTH,RAMAWIDTH,ramclk/1000,64000/8192)
	port map(
		PMEMCKE			=>pMemCke,
		PMEMCS_N		=>pMemCs_n,
		PMEMRAS_N		=>pMemRas_n,
		PMEMCAS_N		=>pMemCas_n,
		PMEMWE_N		=>pMemWe_n,
		PMEMUDQ			=>pMemUdq,
		PMEMLDQ			=>pMemLdq,
		PMEMBA1			=>pMemBa1,
		PMEMBA0			=>pMemBa0,
		PMEMADR			=>pMemAdr,
		PMEMDAT			=>pMemDat,

		CPUADR			=>RAMADR,
		CPURDAT			=>IDAT_RAM,
		CPUWDAT			=>RAM_WDAT,
		CPUWR			=>RAM_WR,
		CPURD			=>RAM_RD,
		CPUWAIT			=>RAM_WAIT,
		CPUCLK			=>cpuclkb,
		CPURSTn			=>CLR_rstn,
		MRAMDAT			=>TCNV_RDAT,
		
		SUBADR			=>SUBADR,
		SUBRDAT			=>SUBRDAT,
		SUBWDAT			=>SUBWDAT,
		SUBWR			=>SUBWR,
		SUBRD			=>SUBRD,
		SUBWAIT			=>SUBWAIT,
		SUBCLK			=>subclkb,

		ALURD0			=>GRDAT0,
		ALURD1			=>GRDAT1,
		ALURD2			=>GRDAT2,
		VRAMRSEL		=>GR_RSEL,

		ALUCWD			=>ALUCWD,
		ALUWD0			=>GWDAT0,
		ALUWD1			=>GWDAT1,
		ALUWD2			=>GWDAT2,
		VRAMWE			=>VRAMWE,
		
		VIDADR			=>GRAMADRW,
		VIDDAT0			=>GRAMDAT0,
		VIDDAT1			=>GRAMDAT1,
		VIDDAT2			=>GRAMDAT2,
		VIDRD			=>GRAMRD,
		VIDWAIT			=>GRAMWAIT,
		
		FDEADR			=>FDE_ADDRW,
		FDERD			=>FDE_RD,
		FDEWR			=>FDE_WR,
		FDERDAT			=>FDE_RDAT,
		FDEWDAT			=>FDE_WDAT,
		FDEWAIT			=>FDE_RAMWAIT,
		
		FECADR			=>FEC_ADDRW,
		FECRD			=>FEC_RD,
		FECWR			=>FEC_WR,
		FECRDAT			=>FEC_RDAT,
		FECWDAT			=>FEC_WDAT,
		FECWAIT			=>FEC_RAMWAIT,
		
		SNDADR			=>PCMADDRW,
		SNDRD				=>PCMRD,
		SNDWR				=>PCMWR,
		SNDRDAT			=>PCMRDAT,
		SNDWDAT			=>PCMWDAT,
		SNDWAIT			=>PCMRWAIT,
		SNDH_Ln			=>'0',

		monout			=>open,
		
		CLOCKM			=>CPUMD,

		memclk			=>rclk,
		rstn			=>srstn
	);

--	CLEARER :RAMCLR generic map(19,x"10000")
--	port map(
--		RAM_BNK		=>CLR_BNK,
--		RAM_ADR		=>CLR_ADR,
--		RAM_WDAT	=>CLR_WDAT,
--		RAM_OE		=>CLR_OE,
--		RAM_WR		=>CLR_WR,
--		RAM_BUSY	=>RAM_WAIT,
--		
--		done		=> loader_rstn,
--
--		clk			=>loaderclk,
--		rstn		=>CLR_rstn
--	);
	CLR_OE<='0';
	loader_rstn<=CLR_rstn;
	
--	loader_rstn<=CLR_RSTN;
	LOADER	:romcopy generic map(x"600000",x"65ffff",19)
	port map(
		addr	=>LOADER_ADR,
		wdat	=>LOADER_WDAT,
		aen	=>LOADER_OE,
		wr		=>LOADER_WR,
		ack	=>not RAM_WAIT,
		done	=>LOADER_DONE,
		
		clk	=>CPU_clk,
		rstn	=>loader_rstn
	);
	CPU_rstn<=LOADER_DONE and EMUINITDONE;
--	pLed(7 downto 0)<=LOADER_WDAT;

	TRAM	:TEXTRAM port map(
		address_a		=>TRAM_ADR,
		address_b		=>TCNV_TADR,
		clock			=>gclk,
		data_a			=>CPUDAT,
		data_b			=>(others=>'0'),
		wren_a			=>TRAM_CE and (not WR_n),
		wren_b			=>'0',
		q_a				=>IDAT_TRAM,
		q_b				=>TCNV_TDAT
	);
	

	T2V	:TRAMCONV
	port map(
	TVRMODE		=>TVRMODE,
--	TMODE		=>TMODE,
	TMODE		=>not cHS,
	COLOR		=>not COLORn,
	TEXTEN		=>(not TEXTDS) and CRTCen and TDMAEN,
	ATTRLEN		=>ATTRLEN,
	
	TADR_TOP	=>TRAMTOP,

	TRAM_ADR	=>TCNV_TADR,
	TRAM_DAT	=>TCNV_TDAT,
	
	MRAM_ADR	=>TCNV_RADR,
	MRAM_DAT	=>TCNV_RDAT,
	MRAM_RDn	=>TCNV_RDn,
	MRAM_WAIT	=>RAM_WAIT,
	BUS_USE		=>TCNV_BUSUSE,
	
	BUSREQn		=>BUSRQ_n,
	BUSACKn		=>BUSACK_n,
	

	TVRAM_ADR	=>TCNV_WADR,
	TVRAM_WDAT	=>TCNV_WDAT,
	TVRAM_WR	=>TCNV_WE,
	
	VRET		=>VRTC,
	HRET		=>HRTC,
	DONE		=>TCNVDONE,
	
	clk			=>clk21m,
	rstn		=>srstn
);

	TVRAM_WDAT	<=CPUDAT					when TMODE='0' and TVRMODE='1' else TCNV_WDAT;
	TVRAM_ADR	<=TVRAM_MADR 				when TMODE='0' and TVRMODE='1' else TCNV_WADR;
	TVRAM_WE	<=TVRAM_CE and (not WR_n)	when TMODE='0' and TVRMODE='1' else TCNV_WE;

tmap	:trammaps generic map(RAMAWIDTH) port map(
	VADR		=>TCNV_RADR,
	
	RAM_ADR		=>VMAP_RADR
);

	TVRAM	:TEXTRAM port map(
		address_a		=>TVRAM_ADR,
		address_b		=>CRTC_TADR,
		clock			=>gclk,
		data_a			=>TVRAM_WDAT,
		data_b			=>(others=>'0'),
		wren_a			=>TVRAM_WE,
		wren_b			=>'0',
		q_a				=>IDAT_TVRAM,
		q_b				=>TRAM_TDAT
	);
	
	CREG	:CRTCREGS
generic map(
	DATADR	=>x"50",
	CMDADR	=>x"51"
)
port map(
	ADR		=>CPUADR(7 downto 0),
	IORQn	=>IORQ_n,
	WRn		=>WR_n,
	RDn		=>RD_n,
	DATIN	=>CPUDAT,
	DATOUT	=>IDAT_CRTR,
	DATOE	=>CRTR_OE,

	CURL	=>CURL,
	CURC	=>CURC,
	CURE	=>CURE,
	CURM	=>CURM,
	CBLINK	=>CBLINK,
	VMODE	=>VMODE,
	CRTCen	=>CRTCen,
	
	ATTR	=>ATTRLEN,

	clk		=>CPU_clk,
	rstn	=>CPU_rstn
);


	WAIT_n<=	not RAM_WAIT when RAM_CE='1' else
				not RAM_WAIT when KANJI1RD='1' else
				not RAM_WAIT when KANJI2RD='1' else
				IO_WAIT;

	
	MAINPLL : pllCVdemu
    port map(
		refclk	=>pclk50m,
		rst     =>not rstn,
		outclk_0=>clk21m,
		outclk_1=>rclk,
		outclk_2=>pMemClk,
		outclk_3=>emuclk,
		locked	=>plllocked
    );

	process(clk21m,srstn)begin
		if(srstn='0')then
			KBCLKIN<='1';
			KBDATIN<='1';
		elsif(clk21m' event and clk21m='1')then
			KBCLKIN<=pPs2Clk;
			KBDATIN<=pPs2Dat;

		end if;
	end process;
	
	pPs2Clk<='0' when KBCLKOUT='0' else 'Z';
	pPs2Dat<='0' when KBDATOUT='0' else 'Z';

	KB	:KBMAP generic map(SYSCLK,100) port map(
	ADR		=>CPUADR(7 downto 0),
	IORQn	=>IORQ_n,
	RDn		=>RD_n,
	DAT		=>IDAT_KB,
	OE		=>KB_OE,

	KBCLKIN	=>KBCLKIN,
	KBCLKOUT=>KBCLKOUT,
	KBDATIN	=>KBDATIN,
	KBDATOUT=>KBDATOUT,

	KBDAT	=>DEMU_KBDAT,
	KBRX	=>KBRX,
	KBEN	=>not emudisp,

	monout	=>open,
	
	clk		=>clk21m,
	rstn	=>srstn
);
--	pLED<=SPI_RDDAT;
	DEMU_KBRX<=KBRX and emudisp;

	
	CPUDAT<=
				IDAT_RAM	when GRAM_M_OE='1' else
				IDAT_ALU	when ALU_OE='1' else
				IDAT_RAM	when (RAM_CE='1' and RD_n='0') else
				IDAT_TRAM	when (TRAM_CE='1' and RD_n='0') else
				IDAT_TVRAM	when (TVRAM_CE='1' and RD_n='0') else
				IDAT_MAP	when MAP_OE='1' else
				IDAT_CRTR	when CRTR_OE='1' else
				IDAT_KB		when KB_OE='1' else
				IDAT_IOR30	when IOR30_OE='1' else
				IDAT_IOR31	when IOR31_OE='1' else
				IDAT_IOR32	when IOR32_OE='1' else
				IDAT_IOR33	when IOR33_OE='1' else
				IDAT_IOR38	when IOR38_OE='1' else
				IDAT_IOR40	when IOR40_OE='1' else
				IDAT_IOR6e	when IOR6e_OE='1' else
				IDAT_PPIFD	when PPIFD_OE='1' else
				IDAT_RAM	when KANJI1RD='1' else
				IDAT_RAM	when KANJI2RD='1' else
				IDAT_PSG	when PSG_OE='1' else
				IDAT_COM	when COM_OE='1' else
				IDAT_EDIDmon when EDIDmon_DOE='1' else
				IDAT_INTC	when INTC_OE='1' else
				(others=>'1') when IORQ_n='0' and RD_n='0' else
				(others=>'Z');
	
--	pMonDBus<=CPUDAT;

	IOW10	:IO_WRS generic map(x"10")port map(CPUADR(7 downto 0),IORQ_n,WR_n,CPUDAT,open,open,open,open,C_DO,C_RTC(2),C_RTC(1),C_RTC(0),CPU_clk,CPU_rstn);
	IOR30	:IO_RD generic map(x"30")port map(CPUADR(7 downto 0),IORQ_n,RD_n,IDAT_IOR30,IOR30_OE,'0','0','0','0',c20L,c40C,cBT,cN);
	IOW30	:IO_WRS generic map(x"30")port map(CPUADR(7 downto 0),IORQ_n,WR_n,CPUDAT,open,open,BS(1),BS(0),MTON,CDS,COLORn,HMODE,CPU_clk,CPU_rstn);
	IOR31	:IO_RD generic map(x"31")port map(CPUADR(7 downto 0),IORQ_n,RD_n,IDAT_IOR31,IOR31_OE,cVer,cHS,'1','1','1','0','1','1');
	IOW31	:IO_WRS generic map(x"31")port map(CPUADR(7 downto 0),IORQ_n,WR_n,CPUDAT,open,open,open,GCOLOR,GRAPHEN,RMODE,MMODE,L200,CPU_clk,CPU_rstn);
	IO32	:IO_RWS generic map(x"32")port map(CPUADR(7 downto 0),IORQ_n,RD_n,WR_n,CPUDAT,IDAT_IOR32,IOR32_OE,SINTM,open,PMODE,TMODE,open,open,EROMSEL1,EROMSEL0,CPU_clk,CPU_rstn);
	IO33	:IO_RWS generic map(x"33")port map(CPUADR(7 downto 0),IORQ_n,RD_n,WR_n,CPUDAT,IDAT_IOR33,IOR33_OE,open,open,open,open,open,open,open,open,CPU_clk,CPU_rstn);
	IOW34	:IO_WRS generic map(x"34")port map(CPUADR(7 downto 0),IORQ_n,WR_n,CPUDAT,open,ALU2(1),ALU1(1),ALU0(1),open,ALU2(0),ALU1(0),ALU0(0),CPU_clk,CPU_rstn);
	IOW35	:IO_WRS generic map(x"35")port map(CPUADR(7 downto 0),IORQ_n,WR_n,CPUDAT,GAM,open,GDM(1),GDM(0),open,PLN(2),PLN(1),PLN(0),CPU_clk,CPU_rstn);
	IO38	:IO_RWS generic map(x"38")port map(CPUADR(7 downto 0),IORQ_n,RD_n,WR_n,CPUDAT,IDAT_IOR38,IOR38_OE,open,open,open,open,open,open,open,TVRMODE,CPU_clk,CPU_rstn);
	IOR40	:IO_RD generic map(x"40")port map(CPUADR(7 downto 0),IORQ_n,RD_n,IDAT_IOR40,IOR40_OE,'0','0',VRTC,CDI,cDisk,'1','0','0');
	IOW40	:IO_WRS generic map(x"40")port map(CPUADR(7 downto 0),IORQ_n,WR_n,CPUDAT,open,pStr,beepen,open,open,CCK,CSTB,open,CPU_clk,CPU_rstn);
	IOR6e	:IO_RD generic map(x"6e")port map(CPUADR(7 downto 0),IORQ_n,RD_n,IDAT_IOR6e,IOR6e_OE,not CPUMD,'1','1','1','1','1','1','1');
	IOW53	:IO_WRS generic map(x"53")port map(CPUADR(7 downto 0),IORQ_n,WR_n,CPUDAT,open,open,open,open,GxDS(2),GxDS(1),GxDS(0),TEXTDS,CPU_clk,CPU_rstn);
	IOW71	:IO_WRS generic map(x"71")port map(CPUADR(7 downto 0),IORQ_n,WR_n,CPUDAT,open,open,open,open,open,open,open,IEROM,CPU_clk,CPU_rstn);
	TDREG	:TDMAREGS generic map(x"64",x"65",x"68") port map(CPUADR(7 downto 0),IORQ_n,WR_n,CPUDAT,TRAMTOP,TRAMLEN,TDMAEN,CPU_clk,CPU_rstn);
	pLed(9)<=slowclk;
	pStrA<=pStr;
	pStrB<=pStr;
	
	LOWRES<=L200 or GCOLOR;
	
	PPIFD_CSn<='0' when IORQ_n='0' and CPUADR(7 downto 2)="111111" else '1';
	PPIFD	:e8255 port map(
		CSn		=>PPIFD_CSn,
		RDn		=>RD_n,
		WRn		=>WR_n,
		ADR		=>CPUADR(1 downto 0),
		DATIN	=>CPUDAT,
		DATOUT	=>IDAT_PPIFD,
		DATOE	=>PPIFD_OE,
		
		PAi		=>SUB_RXS2M,
		PAo		=>SUB_RXM2S,
		PAoe		=>open,
		PBi		=>SUB_TXS2M,
		PBo		=>SUB_TXM2S,
		PBoe		=>open,
		PCHi		=>SUB_HTS2M,
		PCHo		=>SUB_HTM2S,
		PCHoe		=>open,
		PCLi		=>SUB_HRS2M,
		PCLo		=>SUB_HRM2S,
		PCLoe		=>open,
		
		clk		=>CPU_clk,
		rstn	=>CPU_rstn
	);

	KNJ1	:KANJIROM generic map(x"e8") port map(
		ADR		=>CPUADR(7 downto 0),
		IORQn	=>IORQ_n,
		RDn		=>RD_n,
		WRn		=>WR_n,
		WDAT	=>CPUDAT,
		
		KNJADR	=>KANJI1ADR,
		KNJRD	=>KANJI1RD,
		
		clk		=>CPU_clk,
		rstn	=>srstn
	);

	KNJ2	:KANJIROM generic map(x"ec") port map(
		ADR		=>CPUADR(7 downto 0),
		IORQn	=>IORQ_n,
		RDn		=>RD_n,
		WRn		=>WR_n,
		WDAT	=>CPUDAT,
		
		KNJADR	=>KANJI2ADR,
		KNJRD	=>KANJI2RD,
		
		clk		=>CPU_clk,
		rstn	=>srstn
	);


--	IOWA	:IOWAIT port map(IORQ_n,RD_n,WR_n,IO_WAIT,cpu_clk,srstn);
	IO_WAIT	<='1';
	
	process(cpu_clk,srstn)begin
		if(srstn='0')then
			slowclk<='0';
			clkcount<=500000;
		elsif(cpu_clk' event and cpu_clk='1')then
			if(clkcount>0)then
				clkcount<=clkcount-1;
			else
				slowclk<=not slowclk;
				clkcount<=500000;
			end if;
		end if;
	end process;

	CRTC_TDAT<=	TRAM_TDAT when emudisp='0' else DEMU_VDAT;
	
	CRT	:CRTCP port map(
	IORQn		=>IORQ_n,
	WRn			=>WR_n,
	ADR			=>CPUADR(7 downto 0),
	WDAT		=>CPUDAT,
	PALEN		=>not emudisp,
	
	TRAM_ADR	=>CRTC_TADR,
	TRAM_DAT	=>CRTC_TDAT,
	
	GRAMADR		=>GRAMADR,
	GRAMRD		=>GRAMRD,
	GRAMWAIT	=>GRAMWAIT,
	GRAMDAT0	=>GRAMDAT0,
	GRAMDAT1	=>GRAMDAT1,
	GRAMDAT2	=>GRAMDAT2,
	
	ROUT		=>vidR3,
	GOUT		=>vidG3,
	BOUT		=>vidB3,
	VIDEN		=>vidEN,
	
	HSYNC		=>vidHS,
	VSYNC		=>vidVS,
	
	HMODE		=>HMODE or emudisp,		-- 1:80chars 0:40chars
	VMODE		=>VMODE or emudisp,		-- 1:25lines 0:20lines
	PMODE		=>PMODE,		-- 1:512 colors 0:8 colors
	TXTMODE		=>emudisp,
	
	GRAPHEN		=>GRAPHEN and (not emudisp),
	LOWRES		=>LOWRES,
	GCOLOR		=>GCOLOR,
	MONOEN		=>not GxDS,
	TXTEN		=>emudisp or ((not TEXTDS) and TXTen and CRTCen and TDMAEN),
	
	CURL		=>CRTC_CURL,
	CURC		=>CRTC_CURC,
	CURE		=>CRTC_CURE,
	CURM		=>CURM,
	CBLINK		=>CBLINK,
	
	HRTC		=>HRTC,
	VRTC		=>VRTC,

	FRAMWADR	=>FRAMADDR,
	FRAMWDAT	=>FRAMWDAT,
	FRAMWR	=>FRAMWR,
	
	gclk		=>gclk,
	cpuclk		=>CPU_clk,
	clk			=>rclk,
	rstn		=>srstn
	);

	vidR8<=vidR3 & vidR3 & vidR3(2 downto 1);
	vidG8<=vidG3 & vidG3 & vidG3(2 downto 1);
	vidB8<=vidB3 & vidB3 & vidB3(2 downto 1);
	
	process(gclk,rstn)begin
		if(srstn='0')then
			hdmiclk<='0';
		elsif(gclk' event and gclk='1')then
			hdmiclk<=not hdmiclk;
		end if;
	end process;
	
	hdmi	:hdmiconv port map(
		datinR	=>vidR8,
		datinG	=>vidG8,
		datinB	=>vidB8,
		Hsync		=>vidHS,
		Vsync		=>vidVS,
		VIDen		=>vidEN,
		
		LVDS0		=>pHDMI_DAT0,
		LVDS1		=>pHDMI_DAT1,
		LVDS2		=>pHDMI_DAT2,
		LVDSclk	=>pHDMI_CLK,
		
		vclk		=>rclk,
		clk2		=>gclk,
		rstn		=>srstn
	);

	pDac_VR<=vidR3 & '0';
	pDac_VG<=vidG3 & '0';
	pDac_VB<=vidB3 & '0';
	pVideoHS_n<=vidHS;
	pVideoVS_n<=vidVS;

	CRTC_CURL<=	CURL when emudisp='0' else DEMU_CURL;
	CRTC_CURC<=	CURC when emudisp='0' else DEMU_CURC;
	CRTC_CURE<=	CURE when emudisp='0' else DEMU_CUREN;
	
	EDIDmon_CS<='1' when IORQ_n='0' and CPUADR(7 downto 1)="0110000" else '0';
	EDODRD	:EDIDread generic map(
		CFREQ		=>SYSCLK/1000,
		I2CFREQ	=>10,
		HPWAIT	=>100
	)port map(
		SCLI		=>HDMI_I2C_SCLI,
		SCLO		=>HDMI_I2C_SCLO,
		SDAI		=>HDMI_I2C_SDAI,
		SDAO		=>HDMI_I2C_SDAO,
		HPIN		=>pHDMI_PWR,
		
		EDID		=>EDID,
		CONNECT	=>EDID_CONNECT,
		ERROR		=>EDID_ERROR,
		DONE		=>open,
		
		clk		=>clk21m,
		rstn		=>srstn
	);
	
	EDIDm	:EDIDmon port map(
		CS			=>EDIDmon_CS,
		ADDR		=>CPUADR(0),
		RD			=>not RD_n,
		WR			=>not WR_n,
		RDAT		=>IDAT_EDIDmon,
		WDAT		=>CPUDAT,
		DATOE		=>EDIDmon_DOE,
		
		EDID		=>EDID,
		CONNECT	=>EDID_CONNECT,
		ERROR		=>EDID_ERROR,
		
		clk		=>clk21m,
		rstn		=>srstn
	);
	pHDMI_SCL <= '0' when HDMI_I2C_SCLO='0' else 'Z';
	pHDMI_SDA <= '0' when HDMI_I2C_SDAO='0' else 'Z';
	
	process(clk21m,srstn)begin
		if(srstn='0')then
			HDMI_I2C_SCLI<='1';
			HDMI_I2C_SDAI<='1';
		elsif(clk21m' event and clk21m='1')then
			HDMI_I2C_SCLI<=pHDMI_SCL;
			HDMI_I2C_SDAI<=pHDMI_SDA;
		end if;
	end process;

	U_RTC	:rtc4990 generic map(sysclk*1000) port map(
	DCLK	=>CCK,
	DIN		=>C_DO,
	DOUT	=>CDI,
	C		=>C_RTC,
	CS		=>'1',
	STB		=>not CSTB,
	OE		=>'1',

	TXOUT	=>I2C_TXDAT,
	RXIN	=>I2C_RXDAT,
	WRn		=>I2C_WRn,
	RDn		=>I2C_RDn,

	TXEMP	=>I2C_TXEMP,
	RXED	=>I2C_RXED,
	NOACK	=>I2C_NOACK,
	COLL	=>I2C_COLL,
	NX_READ	=>I2C_NX_READ,
	RESTART	=>I2C_RESTART,
	START	=>I2C_START,
	FINISH	=>I2C_FINISH,
	F_FINISH=>I2C_F_FINISH,
	INIT	=>I2C_INIT,

	sclk	=>clk21m,
	rstn	=>srstn
	);

	I2C	:I2CIF port map(
		DATIN	=>I2C_TXDAT,
		DATOUT	=>I2C_RXDAT,
		WRn		=>I2C_WRn,
		RDn		=>I2C_RDn,

		TXEMP	=>I2C_TXEMP,
		RXED	=>I2C_RXED,
		NOACK	=>I2C_NOACK,
		COLL	=>I2C_COLL,
		NX_READ	=>I2C_NX_READ,
		RESTART	=>I2C_RESTART,
		START	=>I2C_START,
		FINISH	=>I2C_FINISH,
		F_FINISH=>I2C_F_FINISH,
		INIT	=>I2C_INIT,
		

		SDAIN 	=>SDAIN,
		SDAOUT	=>SDAOUT,
		SCLIN	=>SCLIN,
		SCLOUT	=>SCLOUT,

		SFT		=>I2CCLKEN,
		clk		=>clk21m,
		rstn 	=>srstn
	);

	pI2CSCL <= '0' when SCLOUT='0' else 'Z';
	pI2CSDA <= '0' when SDAOUT='0' else 'Z';
	process(clk21m,srstn)begin
		if(srstn='0')then
			SCLIN<='1';
			SDAIN<='1';
		elsif(clk21m' event and clk21m='1')then
			SCLIN<=pI2CSCL;
			SDAIN<=pI2CSDA;
		end if;
	end process;

	I2CCLK :sftclk
	generic map(SYSCLK,800,1)
	port map(
		SEL => "0",
		SFT =>I2CCLKEN,
		CLK =>clk21m,
		RSTN => srstn
	);

	
	PCLKG	:unchchata port map(not pjoya(1),pclk,cpu_clk,srstn);
	
	TIMP600	:sftclk generic map(21477270,600,1) port map("0",RTI,clk21m,srstn);
	
--	pLed<=CSTB & CCK & C_RTC & CDI & VRTC;
	emudisp<=emusel or (not EMUINITDONE);
	emusel<=(not pDip(8)) xor pDemuSw;
	DEMU_VADDR<=	CRTC_TADR(0) & '0' & CRTC_TADR(11 downto 1);

	SUBU	:SUBunitsDEMU2 generic map(SYSCLK,RAMCLK,RAMAWIDTH) port map(
		RAMADR			=>SUBADR,
		RAMRDAT			=>SUBRDAT,
		RAMWDAT			=>SUBWDAT,
		RAMWR			=>SUBWR,
		RAMRD			=>SUBRD,
		RAMWAIT			=>SUBWAIT,
		
		SUBIO_PAI		=>SUB_TXM2S,
		SUBIO_PAO		=>SUB_TXS2M,
		SUBIO_PBI		=>SUB_RXM2S,
		SUBIO_PBO		=>SUB_RXS2M,
		SUBIO_PCHI		=>SUB_HRM2S,
		SUBIO_PCHO		=>SUB_HRS2M,
		SUBIO_PCLI		=>SUB_HTM2S,
		SUBIO_PCLO		=>SUB_HTS2M,
		
		FD_DENn			=>pFd_DENn,
		FD_INDEXn		=>pFd_INDEXn,
		FD_DIRn			=>pFd_DIRn,
		FD_STEPn		=>pFd_STEPn,
		FD_WDATAn		=>pFd_WDATAn,
		FD_WGATEn		=>pFd_WGATEn,
		FD_TRK00n		=>pFd_TRK00n,
		FD_WPTn			=>pFd_WPTn,
		FD_RDATAn		=>pFd_RDATAn,
		FD_SIDE1n		=>pFd_SIDE1n,
		FD_DSKCHG		=>pFd_DSKCHG,
		FD_DS0			=>pFd_DS0,
		FD_MOTOR0		=>pFd_MOTOR0,
		FD_DS1			=>pFd_DS1,
		FD_MOTOR1		=>pFd_MOTOR1,
		FDSSEL0			=>pDIP(7),
		FDSSEL1			=>pDIP(7),
		
		MTSAVEON		=>MTSAVE,
		
		sdc_miso		=>sdc_miso,
		sdc_mosi		=>sdc_mosi,
		sdc_sclk		=>sdc_sclk,
		sdc_cs			=>sdc_csel,
		EMUVADDR		=>DEMU_VADDR,
		EMUVDATA		=>DEMU_VDAT,
		EMUCUR_L		=>DEMU_CURL,
		EMUCUR_C		=>DEMU_CURC,
		EMUCUREN		=>DEMU_CUREN,
		EMUKBDAT		=>DEMU_KBDAT,
		EMUKBRX			=>DEMU_KBRX,
		EMUBUSY			=>pLed(6),
		
		FDE_ADDR		=>FDE_ADDR,
		FDE_RD			=>FDE_RD,
		FDE_WR			=>FDE_WR,
		FDE_WDAT		=>FDE_WDAT,
		FDE_RDAT		=>FDE_RDAT,
		FDE_RAMWAIT		=>FDE_RAMWAIT,
		
		FEC_ADDR		=>FEC_ADDR,
		FEC_RD			=>FEC_RD,
		FEC_WR			=>FEC_WR,
		FEC_WDAT		=>FEC_WDAT,
		FEC_RDAT		=>FEC_RDAT,
		FEC_RAMWAIT		=>FEC_RAMWAIT,
		
		mondat	=>pMonDbus,

		EMUINITDONE		=>EMUINITDONE,
		CPUCLK			=>SUBCLK,
		clk21m			=>clk21m,
		ramclk			=>rclk,
		pclk			=>emuclk,
		vclk			=>gclk,
		srstn			=>srstn,
		rstn			=>CPU_rstn
	);

	pSd_ck<=	sdc_sclk;
	pSd_Cm<=	sdc_mosi;
	pSd_Dt(3)<=	sdc_csel;
	sdc_miso<=	pSd_Dt(0);


OPNS	:sftgen generic map(2) port map(2,OPNsft,clk21m,srstn);	--22.222/2=11.111MHz

	pJoy<=pJoyA and pJoyB;

	selopn	:if USE_OPNA=0 generate
		
		PSG_CEn<=IORQ_n when CPUADR(7 downto 1)="0100010" else '1';		--0x44,45

		FMS	:OPN generic map(16) port map(
			DIN		=>CPUDAT,
			DOUT	=>IDAT_PSG,
			DOE		=>PSG_OE,
			CSn		=>PSG_CEn,
			ADR0	=>CPUADR(0),
			RDn		=>RD_n,
			WRn		=>WR_n,
			INTn	=>INTn_OPN,
			
			snd		=>snddatL,
			
			PAOUT	=>open,
			PAIN	=>"1111" & pJoy(3 downto 0),
			PAOE	=>open,
			
			PBOUT	=>open,
			PBIN	=>"111111" & pJoy(5 downto 4),
			PBOE	=>open,

			clk		=>clk21m,
			cpuclk	=>cpu_clk,
			sft		=>OPNsft,
			rstn	=>CPU_rstn
		);
		
		PCMADDR	<=(others=>'0');
		PCMRD		<='0';
		PCMWR		<='0';
		PCMWDAT	<=(others=>'0');
		snddatR<=BEEPSND;
		
	end generate;
	selopna	:if USE_OPNA/=0 generate

		PSG_CEn<=IORQ_n when CPUADR(7 downto 2)="010001" else '1';		--0x44,45,46,47
	
		FMS	:OPNA generic map(16) port map(
			DIN		=>CPUDAT,
			DOUT	=>IDAT_PSG,
			DOE		=>PSG_OE,
			CSn		=>PSG_CEn,
			ADR		=>CPUADR(1 downto 0),
			RDn		=>RD_n,
			WRn		=>WR_n,
			INTn	=>INTn_OPN,
			
			sndL		=>sndL,
			sndR		=>sndR,
			sndPSG	=>sndPSG,
		
			PAOUT	=>open,
			PAIN	=>"1111" & pJoy(3 downto 0),
			PAOE	=>open,
			
			PBOUT	=>open,
			PBIN	=>"111111" & pJoy(5 downto 4),
			PBOE	=>open,

			RAMADDR	=>PCMADDR,
			RAMRD		=>PCMRD,
			RAMWR		=>PCMWR,
			RAMRDAT	=>PCMRDAT,
			RAMWDAT	=>PCMWDAT,
			RAMWAIT	=>PCMRWAIT,

			clk		=>clk21m,
			cpuclk	=>cpu_clk,
			sft		=>OPNsft,
			rstn	=>CPU_rstn
		);
		
		sndmixL	:average generic map(16) port map(sndL,monosnd,snddatL);
		sndmixR	:average generic map(16) port map(sndR,monosnd,snddatR);
	
		monos	:average generic map(16) port map(sndPSG,BEEPsnd,monosnd);
		
	end generate;
	
	pJoyA<=(others=>'Z');
	pJoyB<=(others=>'Z');
	
	beep	:beeposc generic map(2400,SYSCLK) port map(beepsig,clk21m,rstn);
	
	BEEPsnd<=	(others=>'0') when BEEPEN='0' else
					x"4000"	when beepsig='1' else
					x"c000";

	usnddatL<=(not snddatL(15)) & snddatL(14 downto 0);
	usnddatR<=(not snddatR(15)) & snddatR(14 downto 0);
	dacL :deltasigmadac generic map(16) port map(
		data	=>usnddatL,
		datum	=>pDac_SL,
		
		sft		=>'1',
		clk		=>clk21m,
		rstn	=>srstn
	);
	
	dacR :deltasigmadac generic map(16) port map(
		data	=>usnddatR,
		datum	=>pDac_SR,
		
		sft		=>'1',
		clk		=>clk21m,
		rstn	=>srstn
	);
	
	COM_CSn<=IORQ_n when CPUADR(7 downto 1)="0010000" else '1';	--0x20,21

	COM_vDIV<=conv_std_logic_vector(COM_DIV,11);
	COMB	:clkdiv generic map(11) port map(COM_vDIV,COM_clk,clk21m,srstn);
	
	USART	:e8251 port map(
		WRn		=>WR_n,
		RDn		=>RD_n,
		C_Dn	=>CPUADR(0),
		CSn		=>COM_CSn,
		DATIN	=>CPUDAT,
		DATOUT	=>IDAT_COM,
		DATOE	=>COM_OE,
		
		TXD		=>pCOM_TxD,
		RxD		=>pCOM_RxD,
		
		DSRn	=>'0',
		DTRn	=>open,
		RTSn	=>pCOM_RTS,
		CTSn	=>pCOM_CTS and BS(1),
		
		TxRDY	=>open,
		TxEMP	=>open,
		RxRDY	=>INT_COMRX,
		
		TxCn	=>COM_clk,
		RxCn	=>COM_clk,
		
		clk		=>clk21m,
		rstn	=>CPU_rstn
	);

	pLED(0)<=MTON;
	pLED(1)<=CDS;
	pLED(3 downto 2)<=BS;

	process(cpu_clk,rstn)begin
		if(rstn='0')then
			SEG0<=(others=>'0');
			SEG1<=(others=>'0');
			SEG2<=(others=>'0');
			SEG3<=(others=>'0');
			SEG4<=(others=>'0');
			SEG5<=(others=>'0');
		elsif(cpu_clk' event and cpu_clk='1')then
			if(M1_n='0')then
				SEG0<=CPUDAT(3 downto 0);
				SEG1<=CPUDAT(7 downto 4);
				SEG2<=CPUADR(3 downto 0);
				SEG3<=CPUADR(7 downto 4);
				SEG4<=CPUADR(11 downto 8);
				SEG5<=CPUADR(15 downto 12);
			end if;
		end if;
	end process;

	MSEG0	:HEX2SEGn port map(SEG0,'0',pSeg0);
	MSEG1	:HEX2SEGn port map(SEG1,'0',pSeg1);
	MSEG2	:HEX2SEGn port map(SEG2,'0',pSeg2);
	MSEG3	:HEX2SEGn port map(SEG3,'0',pSeg3);
	MSEG4	:HEX2SEGn port map(SEG4,'0',pSeg4);
	MSEG5	:HEX2SEGn port map(SEG5,'0',pSeg5);

	pLed(7)<=CRTCen;

	

	process(clk21m,srstn)begin
		if(srstn='0')then
			pLed(8)<='1';
			TXTen<='1';
			TenSW<='0';
		elsif(clk21m' event and clk21m='1')then
			if(pPsw(1)='0' and TenSW='1')then
				pLed(8)<=not TXTen;
				TXTen<=not TXTen;
			end if;
			TenSW<=pPsw(1);
		end if;
	end process;

	pPmsClk<=cpu_clk when IORQ_n='0' and (RD_n='0' or WR_n='0') else '0';

	end MAIN;
