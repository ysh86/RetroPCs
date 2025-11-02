LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;
USE	IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.FDC_sectinfo.all;
use work.FDC_timing.all;

entity SUBunitsDEMU2 is
generic(
	sysclk	:integer	:=21477;		--in kHz
	memclk	:integer	:=80000;			--in kHz
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
end SUBunitsDEMU2;

architecture MAIN of SUBunitsDEMU2 is
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

component mmapsub
generic(
	awidth	:integer	:=25
);
port(
	CPU_ADR		:in std_logic_vector(15 downto 0);
	CPU_MREQn	:in std_logic;
	CPU_WRn		:in std_logic;
	
	RAM_ADR		:out std_logic_vector(awidth-1 downto 0);
	RAM_CE		:out std_logic;
	
	clk			:in std_logic;
	rstn		:in std_logic
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

component IO_DETAC
generic(
	IOADR	:in std_logic_vector(7 downto 0)	:=x"00"
);
port(
	ADR		:in std_logic_vector(7 downto 0);
	IORQn	:in std_logic;
	ACn		:in std_logic;

	det		:out std_logic;

	clk		:in std_logic;
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

component INTSUB
port(
	IORQn	:in std_logic;
	MREQn	:in std_logic;
	RDn		:in std_logic;
	M1n		:in std_logic;
	DATOUT	:out std_logic_vector(7 downto 0);
	DATOE	:out std_logic;

	
	cpuclk	:in std_logic;
	rstn	:in std_logic
);
end component;

component FDtiming
generic(
	sysclk	:integer	:=21477		--in kHz
);
port(
	drv0sel		:in std_logic;		--0:300rpm 1:360rpm
	drv1sel		:in std_logic;
	drv0sele	:in std_logic;		--1:speed selectable
	drv1sele	:in std_logic;

	drv0hd		:in std_logic;
	drv0hdi		:in std_logic;		--IBM 1.44MB format
	drv1hd		:in std_logic;
	drv1hdi		:in std_logic;		--IBM 1.44MB format
	
	drv0hds		:out std_logic;
	drv1hds		:out std_logic;
	
	drv0int		:out integer range 0 to (BR_300_D*sysclk/1000000);
	drv1int		:out integer range 0 to (BR_300_D*sysclk/1000000);
	
	hmssft		:out std_logic;
	
	clk			:in std_logic;
	rstn		:in std_logic
);
end component;

component  FDCs
generic(
	maxtrack	:integer	:=85;
	maxbwidth	:integer	:=88;
	rdytout		:integer	:=800;
	preseek		:std_logic	:='0';
	sysclk		:integer	:=20
);
port(
	RDn		:in std_logic;
	WRn		:in std_logic;
	CSn		:in std_logic;
	A0		:in std_logic;
	WDAT	:in std_logic_vector(7 downto 0);
	RDAT	:out std_logic_vector(7 downto 0);
	DATOE	:out std_logic;
	DACKn	:in std_logic;
	DRQ		:out std_logic;
	TC		:in std_logic;
	INTn	:out std_logic;
	WAITIN	:in std_logic	:='0';

	WREN	:out std_logic;		--pin24
	WRBIT	:out std_logic;		--pin22
	RDBIT	:in std_logic;		--pin30
	STEP	:out std_logic;		--pin20
	SDIR	:out std_logic;		--pin18
	WPRT	:in std_logic;		--pin28
	track0	:in std_logic;		--pin26
	index	:in std_logic;		--pin8
	side	:out std_logic;		--pin32
	usel	:out std_logic_vector(1 downto 0);
	READY	:in std_logic;		--pin34
	
	int0	:in integer range 0 to maxbwidth;
	int1	:in integer range 0 to maxbwidth;
	int2	:in integer range 0 to maxbwidth;
	int3	:in integer range 0 to maxbwidth;
	
	td0		:in std_logic;
	td1		:in std_logic;
	td2		:in std_logic;
	td3		:in std_logic;
	
	hmssft	:in std_logic;		--0.5msec
	
	busy	:out std_logic;
	mfm		:out std_logic;
	
	ismode	:in std_logic	:='1';
	
	sclk	:in std_logic;
	fclk	:in std_logic;
	rstn	:in std_logic
);
end component;

component FDC
generic(
	maxtrack	:integer	:=85;
	maxbwidth	:integer	:=88;
	sysclk		:integer	:=20
);
port(
	RDn		:in std_logic;
	WRn		:in std_logic;
	CSn		:in std_logic;
	A0		:in std_logic;
	WDAT	:in std_logic_vector(7 downto 0);
	RDAT	:out std_logic_vector(7 downto 0);
	DATOE	:out std_logic;
	DACKn	:in std_logic;
	DRQ		:out std_logic;
	TC		:in std_logic;
	INTn	:out std_logic;

	WREN	:out std_logic;		--pin24
	WRBIT	:out std_logic;		--pin22
	RDBIT	:in std_logic;		--pin30
	STEP	:out std_logic;		--pin20
	SDIR	:out std_logic;		--pin18
	WPRT	:in std_logic;		--pin28
	track0	:in std_logic;		--pin26
	index	:in std_logic;		--pin8
	side	:out std_logic;		--pin32
	usel	:out std_logic_vector(1 downto 0);
	READY	:in std_logic;		--pin34
	
	int0	:in integer range 0 to maxbwidth;
	int1	:in integer range 0 to maxbwidth;
	int2	:in integer range 0 to maxbwidth;
	int3	:in integer range 0 to maxbwidth;
	
	td0		:in std_logic;
	td1		:in std_logic;
	td2		:in std_logic;
	td3		:in std_logic;
	hmssft	:in std_logic;		--0.5msec
	
	busy	:out std_logic;
	mfm		:out std_logic;
	
	mon0	:out std_logic_vector(7 downto 0);
	mon1	:out std_logic_vector(7 downto 0);
	mon2	:out std_logic_vector(7 downto 0);
	mon3	:out std_logic_vector(7 downto 0);
	mon4	:out std_logic_vector(7 downto 0);
	mon5	:out std_logic_vector(7 downto 0);
	mon6	:out std_logic_vector(7 downto 0);
	mon7	:out std_logic_vector(7 downto 0);

	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component dc2ry
generic(
	delay	:integer	:=100
);
port(
	USEL	:in std_logic_vector(1 downto 0);
	BUSY	:in std_logic;
	DSKCHGn	:in std_logic;
	RDBITn	:in std_logic;
	INDEXn	:in std_logic;
	
	READYn	:out std_logic;
	READYV	:out std_logic_vector(3 downto 0);
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component MTsave
generic(
	SYS_CLK	:integer	:=20;
	DELAY	:integer	:=4000
);
port(
	MTIN	:in std_logic;
	EN		:in std_logic;
	READY	:in std_logic;
	MTOUT	:out std_logic;
	
	SAVEON	:in std_logic;
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end component;

component intchk
generic(
	interval	:integer	:=100;
	chk			:integer	:=10
);
port(
	en			:out std_logic;
	clk			:in std_logic;
	rstn		:in std_logic
);
end component;

component diskemuunit
generic(
	clkfreq		:integer	:=30000;
	VLwidth		:integer	:=6;
	VCwidth		:integer	:=7;
	motordly	:integer	:=500;		--motor rotate delay(msec)	
	FDDs		:integer	:=4;
	fdwait	:integer	:=10
);
port(
--video
	vaddr		:in std_logic_vector(12 downto 0);
	vdata		:out std_logic_vector(7 downto 0);
	vcursor_L	:out std_logic_vector(VLwidth-1 downto 0);
	vcursor_C	:out std_logic_vector(VCwidth-1 downto 0);
	vcursoren	:out std_logic;

--Keyboard
	kbdat		:in std_logic_vector(7 downto 0);
	kbrx		:in std_logic;

--SDcard
	sdc_miso	:in std_logic;
	sdc_mosi	:out std_logic;
	sdc_sclk	:out std_logic;
	sdc_cs		:out std_logic;
	
--FDD
	fdc_useln	:in std_logic_vector(FDDs-1 downto 0)	:=(others=>'1');
	fdc_motorn	:in std_logic_vector(FDDs-1 downto 0)	:=(others=>'1');
	fdc_readyn	:out std_logic;
	fdc_wrenn	:in std_logic						:='1';
	fdc_wrbitn	:in std_logic						:='1';
	fdc_rdbitn	:out std_logic;
	fdc_stepn	:in std_logic						:='1';
	fdc_sdirn	:in std_logic						:='1';
	fdc_track0n	:out std_logic;
	fdc_indexn	:out std_logic;
	fdc_siden	:in std_logic						:='1';
	fdc_wprotn	:out std_logic;
	fdc_eject	:in std_logic_vector(FDDs-1 downto 0)	:=(others=>'0');
	fdc_indisk	:out std_logic_vector(FDDs-1 downto 0)	:=(others=>'0');
	fdc_trackwid:in std_logic						:='1';	--1:2HD/2DD 0:2D
	fdc_dencity	:in std_logic						:='1';	--1:2HD 0:2DD/2D
	fdc_rpm		:in std_logic						:='0';	--1:360rpm 0:300rpm
	fdc_mfm		:in std_logic						:='1';
	
	fdd_useln	:out std_logic_vector(1 downto 0);
	fdd_motorn	:out std_logic_vector(1 downto 0);
	fdd_readyn	:in std_logic						:='1';
	fdd_wrenn	:out std_logic;
	fdd_wrbitn	:out std_logic;
	fdd_rdbitn	:in std_logic						:='1';
	fdd_stepn	:out std_logic;
	fdd_sdirn	:out std_logic;
	fdd_track0n	:in std_logic						:='1';
	fdd_indexn	:in std_logic						:='1';
	fdd_siden	:out std_logic;
	fdd_wprotn	:in std_logic						:='1';
	fdd_eject	:out std_logic_vector(1 downto 0);
	fdd_indisk	:in std_logic_vector(1 downto 0)	:=(others=>'0');
	fdd_cpyen	:out std_logic;

--FD emulator
	fde_tracklen:out std_logic_vector(13 downto 0);
	fde_ramaddr	:out std_logic_vector(23 downto 0);
	fde_ramrdat	:in std_logic_vector(15 downto 0);
	fde_ramwdat	:out std_logic_vector(15 downto 0);
	fde_ramwr	:out std_logic;
	fde_ramwait	:in std_logic;
	fec_ramaddrh :out std_logic_vector(15 downto 0);
	fec_ramaddrl :in std_logic_vector(7 downto 0);
	fec_ramwe	:in std_logic;
	fec_ramrdat	:out std_logic_vector(15 downto 0);
	fec_ramwdat	:in std_logic_vector(15 downto 0);
	fec_ramrd	:out std_logic;
	fec_ramwr	:out std_logic;
	fec_rambusy	:in std_logic;

--common
	model		:in std_logic_vector(7 downto 0);
	initdone	:out std_logic;
	busy		:out std_logic;
	pclk		:in std_logic;
	vclk		:in std_logic;
	fclk		:in std_logic;
	sclk		:in std_logic;
	rclk		:in std_logic;
	rstn		:in std_logic
);
end component;

component FECcont
generic(
	SDRAWIDTH	:integer	:=22
);
port(
	HIGHADDR	:in std_logic_vector(15 downto 0);
	BUFADDR		:out std_logic_vector(7 downto 0);
	RD			:in std_logic;
	WR			:in std_logic;
	RDDAT		:out std_logic_vector(15 downto 0);
	WRDAT		:in std_logic_vector(15 downto 0);
	BUFRD		:out std_logic;
	BUFWR		:out std_logic;
	BUFWAIT		:in std_logic;
	BUSY		:out std_logic;
	
	SDR_ADDR	:out std_logic_vector(SDRAWIDTH-1 downto 0);
	SDR_RD		:out std_logic;
	SDR_WR		:out std_logic;
	SDR_RDAT	:in std_logic_vector(15 downto 0);
	SDR_WDAT	:out std_logic_vector(15 downto 0);
	SDR_WAIT	:in std_logic;
	
	clk			:in std_logic;
	rstn		:in std_logic
);
end component;

signal	CPUrstn	:std_logic;
signal	EMUINITDONEb	:std_logic;
signal	IDAT	:std_logic_vector(7 downto 0);
signal	CPUDAT	:std_logic_vector(7 downto 0);
signal	IDAT_IO12	:std_logic_vector(7 downto 0);
signal	IO12_OE		:std_logic;
signal	IDAT_PPI	:std_logic_vector(7 downto 0);
signal	PPI_OE		:std_logic;
signal	IDAT_FDC	:std_logic_vector(7 downto 0);
signal	FDC_OE		:std_logic;
signal	IDAT_INT	:std_logic_vector(7 downto 0);
signal	INT_OE		:std_logic;
signal	ADR			:std_logic_Vector(15 downto 0);
signal	MREQn		:std_logic;
signal	IORQn		:std_logic;
signal	M1n			:std_logic;
signal	RDn			:std_logic;
signal	WRn			:std_logic;
signal	RAMCE		:std_logic;
signal	INTn		:std_logic;
signal	TD1,TD0		:std_logic;
signal	RV1,RV0		:std_logic;
signal	MON1,MON0	:std_logic;
signal	TC			:std_logic;
signal	FDC_CEn		:std_logic;
signal	FD_USEL		:std_logic_vector(1 downto 0);
signal	FD_HDS		:std_logic_vector(1 downto 0);
signal	FD_hmssft	:std_logic;
signal	FD_int0		:integer range 0 to (BR_300_D*sysclk/1000000);
signal	FD_int1		:integer range 0 to (BR_300_D*sysclk/1000000);
signal	FD_READYn	:std_logic;
signal	FDC_READYn	:std_logic;
signal	PPI_CSn		:std_logic;
signal	PSEN		:std_logic;
signal	FD_DENl		:std_logic;
signal	FDC_BUSY	:std_logic;
signal	MONEN		:std_logic;
signal	FDDEN		:std_logic;
signal	EN1,EN0		:std_logic;
signal	MON1S,MON0S	:std_logic;
signal	RDYV		:std_logic_vector(3 downto 0);

signal	FDC_USELn	:std_logic_vector(3 downto 0);
signal	FDC_MOTORn	:std_logic_vector(3 downto 0);
signal	FDC_WRENn	:std_logic;
signal	FDC_WRBITn	:std_logic;
signal	FDC_RDBITn	:std_logic;
signal	FDC_STEPn	:std_logic;
signal	FDC_SDIRn	:std_logic;
signal	FDC_TRACK0n	:std_logic;
signal	FDC_INDEXn	:std_logic;
signal	FDC_SIDEn	:std_logic;
signal	FDC_WPROTn	:std_logic;
signal	FDC_MFM		:std_logic;
signal	FDE_EMUEN	:std_logic_vector(1 downto 0);
signal	FDD_USELn	:std_logic_Vector(1 downto 0);
signal	FDD_USEL	:std_logic_Vector(1 downto 0);
signal	FDD_MOTORn	:std_logic_Vector(1 downto 0);
signal	TDSEL		:std_logic;
signal	RVSEL		:std_logic;

signal	fec_ramaddrh :std_logic_vector(15 downto 0);
signal	fec_ramaddrl :std_logic_vector(7 downto 0);
signal	fec_ramwe	:std_logic;
signal	fec_ramrdat	:std_logic_vector(15 downto 0);
signal	fec_ramwdat	:std_logic_vector(15 downto 0);
signal	fec_ramrd	:std_logic;
signal	fec_ramwr	:std_logic;
signal	fec_rambusy	:std_logic;
signal	fde_ramwr	:std_logic;
signal	fde_cpyen	:std_logic;

begin

	CPUrstn<=rstn and EMUINITDONEb;
	mondat<=CPUDAT;
	cpu:T80a generic map(0)port map(
       RESET_n		=>CPUrstn,
        CLK_n		=>CPUCLK,
        WAIT_n		=>not RAMWAIT,
        INT_n       =>INTn,
--        INT_n       =>'1',
        NMI_n       =>'1',
        BUSRQ_n     =>'1',
        M1_n        =>M1n,
        MREQ_n      =>MREQn,
        IORQ_n      =>IORQn,
        RD_n        =>RDn,
        WR_n        =>WRn,
        RFSH_n      =>open,
        HALT_n      =>open,
        BUSAK_n     =>open,
        A           =>ADR,
        D           =>CPUDAT
	);

	mmap	:mmapsub generic map(awidth) port map(
		CPU_ADR		=>ADR,
		CPU_MREQn	=>MREQn,
		CPU_WRn		=>WRn,
	
		RAM_ADR		=>RAMADR,
		RAM_CE		=>RAMCE,
		
		clk			=>CPUCLK,
		rstn		=>CPUrstn
	);
	
	CPUDAT<=	IDAT_INT	when INT_OE='1'  else
				RAMRDAT when RAMCE='1' and RDn='0' else
				IDAT_IO12	when IO12_OE='1' else
				IDAT_PPI	when PPI_OE='1' else
				IDAT_FDC	when FDC_OE='1'  else
				(others=>'Z');
	
	RAMWDAT<=CPUDAT;
	RAMWR<=RAMCE and not WRn;
	RAMRD<=RAMCE and not RDn;
	
--	IO12	:IO_RWS generic map(x"12") port map(ADR(7 downto 0),IORQn,RDn,WRn,CPUDAT,IDAT_IO12,IO12_OE,monout(7),monout(6),monout(5),monout(4),monout(3),monout(2),monout(1),monout(0),CPUCLK,CPUrstn);
	IOf4	:IO_WRS generic map(x"f4") port map(ADR(7 downto 0),IORQn,WRn,CPUDAT,open,open,open,open,TD1,TD0,RV1,RV0,CPUCLK,CPUrstn);
	IOf8	:IO_WRS generic map(x"f8") port map(ADR(7 downto 0),IORQn,WRn,CPUDAT,open,open,open,open,PSEN,open,MON1S,MON0S,CPUCLK,CPUrstn);
	IOf8r	:IO_DETAC generic map(x"f8") port map(ADR(7 downto 0),IORQn,RDn,TC,CPUCLK,CPUrstn);
	
	TDSEL<=TD0 when FD_USEL="00" else TD1 when FD_USEL="01" else '0';
	RVSEL<=RV0 when FD_USEL="00" else RV1 when FD_USEL="01" else '0';
	
	FDC_MOTORn<="11" & not MON1 & not MON0;
	FDC_CEn<='0' when IORQn='0' and ADR(7 downto 1)="1111101" else '1';
	PPI_CSn<='0' when IORQn='0' and ADR(7 downto 2)="111111" else '1';
	PPI	:e8255 port map(
		CSn		=>PPI_CSn,
		RDn		=>RDn,
		WRn		=>WRn,
		ADR		=>ADR(1 downto 0),
		DATIN	=>CPUDAT,
		DATOUT	=>IDAT_PPI,
		DATOE	=>PPI_OE,
		
		PAi		=>SUBIO_PAI,
		PAo		=>SUBIO_PAO,
		PAoe		=>open,
		PBi		=>SUBIO_PBI,
		PBo		=>SUBIO_PBO,
		PBoe		=>open,
		PCHi		=>SUBIO_PCHI,
		PCHo		=>SUBIO_PCHO,
		PCHoe		=>open,
		PCLi		=>SUBIO_PCLI,
		PCLo		=>SUBIO_PCLO,
		PCLoe		=>open,
		
		clk		=>CPUCLK,
		rstn	=>CPUrstn
	);
	
	INTC	:INTSUB port map(IORQn,MREQn,RDn,M1n,IDAT_INT,INT_OE,CPUCLK,CPUrstn);
	
	FDT	:FDtiming generic map(sysclk) port map(
		drv0sel		=>FDSSEL0,	--0:300rpm 1:360rpm
		drv1sel		=>FDSSEL1,
		drv0sele	=>'0',
		drv1sele	=>'0',
	
		drv0hd		=>RV0,
		drv0hdi		=>'1',		--IBM 1.44MB format
		drv1hd		=>RV1,
		drv1hdi		=>'1',		--IBM 1.44MB format
		
		drv0hds		=>FD_HDS(0),
		drv1hds		=>FD_HDS(1),
		
		drv0int		=>FD_int0,
		drv1int		=>FD_int1,
		
		hmssft		=>FD_hmssft,
		
		clk			=>clk21m,
		rstn		=>CPUrstn
	);
--	FDT	:FDtiming generic map(sysclk) port map(
--		drv0sel		=>FDSSEL0,	--0:300rpm 1:360rpm
--		drv1sel		=>FDSSEL1,
--		drv0sele	=>'0',
--		drv1sele	=>'0',
--	
--		drv0hd		=>RV0,
--		drv0hdi		=>'1',		--IBM 1.44MB format
--		drv1hd		=>RV1,
--		drv1hdi		=>'1',		--IBM 1.44MB format
--		
--		drv0hds		=>FD_HDS(0),
--		drv1hds		=>FD_HDS(1),
--		
--		drv0int		=>FD_int0,
--		drv1int		=>FD_int1,
--		
--		hmssft		=>FD_hmssft,
--		
--		clk			=>clk21m,
--		rstn		=>CPUrstn
--	);
	
	FD	:FDCs generic map(
	maxtrack	=>85,
	maxbwidth	=>(BR_300_D*sysclk/1000000),
	sysclk		=>sysclk/1000
)
port map(
	RDn		=>RDn,
	WRn		=>WRn,
	CSn		=>FDC_CEn,
	A0		=>ADR(0),
	WDAT	=>CPUDAT,
	RDAT	=>IDAT_FDC,
	DATOE	=>FDC_OE,
	DACKn	=>'1',
	DRQ		=>open,
	TC		=>TC,
	INTn	=>INTn,

	WREN	=>FDC_WRENn,
	WRBIT	=>FDC_WRBITn,
	RDBIT	=>FDC_RDBITn,
	STEP	=>FDC_STEPn,
	SDIR	=>FDC_SDIRn,
	WPRT	=>FDC_WPROTn,
	track0	=>FDC_TRACK0n,
	index	=>FDC_INDEXn,
	side	=>FDC_SIDEn,
	usel	=>FD_USEL,
	READY	=>FDC_READYn,
	
	int0	=>FD_int0,
	int1	=>FD_int1,
	int2	=>FD_int0,
	int3	=>FD_int1,
	
	td0		=>TD0,
	td1		=>TD1,
	td2		=>'0',
	td3		=>'0',
	
	hmssft	=>FD_hmssft,
	
	busy	=>FDC_BUSY,
	mfm		=>FDC_MFM,
	
	sclk	=>CPUCLK,
	fclk	=>clk21m,
	rstn	=>CPUrstn
);
--	FD	:FDC generic map(
--	maxtrack	=>85,
--	maxbwidth	=>(BR_300_D*sysclk/1000000),
--	sysclk		=>sysclk/1000
--)
--port map(
--	RDn		=>RDn,
--	WRn		=>WRn,
--	CSn		=>FDC_CEn,
--	A0		=>ADR(0),
--	WDAT	=>CPUDAT,
--	RDAT	=>IDAT_FDC,
--	DATOE	=>FDC_OE,
--	DACKn	=>'1',
--	DRQ		=>open,
--	TC		=>TC,
--	INTn	=>INTn,
--
--	WREN	=>FDC_WRENn,
--	WRBIT	=>FDC_WRBITn,
--	RDBIT	=>FDC_RDBITn,
--	STEP	=>FDC_STEPn,
--	SDIR	=>FDC_SDIRn,
--	WPRT	=>FDC_WPROTn,
--	track0	=>FDC_TRACK0n,
--	index	=>FDC_INDEXn,
--	side	=>FDC_SIDEn,
--	usel	=>FD_USEL,
--	READY	=>FDC_READYn,
--	
--	int0	=>FD_int0,
--	int1	=>FD_int1,
--	int2	=>FD_int0,
--	int3	=>FD_int1,
--	
--	td0		=>TD0,
--	td1		=>TD1,
--	td2		=>'0',
--	td3		=>'0',
--	
--	hmssft	=>FD_hmssft,
--	
--	busy	=>FDC_BUSY,
--	mfm		=>FDC_MFM,
--	
--	mon0	=>dmon0,
--	mon1	=>dmon1,
--	mon2	=>dmon2,
--	mon3	=>dmon3,
--	mon4	=>dmon4,
--	mon5	=>dmon5,
--	mon6	=>dmon6,
--	mon7	=>dmon7,
--	
--	clk		=>clk21m,
--	rstn	=>CPUrstn
--);

	DSKE	:diskemuunit generic map(
		clkfreq		=>sysclk,
		VLwidth		=>5,
		VCwidth		=>7,
		motordly	=>500,
		FDDs		=>4,
		fdwait	=>20
	)port map(
	--video
		vaddr		=>EMUVADDR,
		vdata		=>EMUVDATA,
		vcursor_L	=>EMUCUR_L,
		vcursor_C	=>EMUCUR_C,
		vcursoren	=>EMUCUREN,

	--Keyboard
		kbdat		=>EMUKBDAT,
		kbrx		=>EMUKBRX,

	--SDcard
		sdc_miso	=>sdc_miso,
		sdc_mosi	=>sdc_mosi,
		sdc_sclk	=>sdc_sclk,
		sdc_cs		=>sdc_cs,
		
	--FDD
		fdc_useln	=>FDC_USELn,
		fdc_motorn	=>FDC_MOTORn,
		fdc_readyn	=>FDC_READYn,
		fdc_wrenn	=>FDC_WRENn,
		fdc_wrbitn	=>FDC_WRBITn,
		fdc_rdbitn	=>FDC_RDBITn,
		fdc_stepn	=>FDC_STEPn,
		fdc_sdirn	=>FDC_SDIRn,
		fdc_track0n	=>FDC_TRACK0n,
		fdc_indexn	=>FDC_INDEXn,
		fdc_siden	=>FDC_SIDEn,
		fdc_wprotn	=>FDC_WPROTn,
		fdc_eject	=>(others=>'0'),
		fdc_indisk	=>open,
		fdc_trackwid=>TDSEL,
		fdc_dencity	=>RVSEL,
		fdc_rpm		=>'0',
		fdc_mfm		=>FDC_MFM,
		
		fdd_useln	=>FDD_USELn,
		fdd_motorn	=>FDD_MOTORn,
		fdd_readyn	=>FD_READYn,
		fdd_wrenn	=>FD_WGATEn,
		fdd_wrbitn	=>FD_WDATAn,
		fdd_rdbitn	=>FD_RDATAn,
		fdd_stepn	=>FD_STEPn,
		fdd_sdirn	=>FD_DIRn,
		fdd_track0n	=>FD_TRK00n,
		fdd_indexn	=>FD_INDEXn,
		fdd_siden	=>FD_SIDE1n,
		fdd_wprotn	=>FD_WPTn,
		fdd_eject	=>open,
		fdd_indisk	=>(others=>'0'),
		fdd_cpyen	=>fde_cpyen,

	--FD emulator
		fde_tracklen=>open,
		fde_ramaddr	=>FDE_ADDR,
		fde_ramrdat	=>FDE_RDAT,
		fde_ramwdat	=>FDE_WDAT,
		fde_ramwr	=>fde_ramwr,
		fde_ramwait	=>FDE_RAMWAIT,
		fec_ramaddrh =>fec_ramaddrh,
		fec_ramaddrl =>fec_ramaddrl,
		fec_ramwe	=>fec_ramwe,
		fec_ramrdat	=>fec_ramwdat,
		fec_ramwdat	=>fec_ramrdat,
		fec_ramrd	=>fec_ramrd,
		fec_ramwr	=>fec_ramwr,
		fec_rambusy	=>fec_rambusy,

	--common
		model		=>x"00",
		initdone	=>EMUINITDONEb,
		busy		=>EMUBUSY,
		pclk		=>pclk,
		vclk		=>vclk,
		fclk		=>clk21m,
		sclk		=>clk21m,
		rclk		=>ramclk,
		rstn		=>'1'
	);
	EMUINITDONE<=EMUINITDONEb;
	FDE_WR<=fde_ramwr;
	FDE_RD<=not fde_ramwr;
	
	FECC :FECcont generic map(24) port map(
		HIGHADDR	=>fec_ramaddrh,
		BUFADDR		=>fec_ramaddrl,
		RD			=>fec_ramrd,
		WR			=>fec_ramwr,
		RDDAT		=>fec_ramrdat,
		WRDAT		=>fec_ramwdat,
		BUFRD		=>open,
		BUFWR		=>fec_ramwe,
		BUFWAIT		=>'0',
		BUSY		=>fec_rambusy,
		
		SDR_ADDR	=>FEC_ADDR,
		SDR_RD		=>FEC_RD,
		SDR_WR		=>FEC_WR,
		SDR_RDAT	=>FEC_RDAT,
		SDR_WDAT	=>FEC_WDAT,
		SDR_WAIT	=>FEC_RAMWAIT,
		
		clk			=>clk21m,
		rstn		=>srstn
	);
	
	CHK	:intchk generic map(500*sysclk,1*sysclk)port map(MONEN,clk21m,CPUrstn);
	FDC_USELn<=	"1110" when FD_USEL="00" else
				"1101" when FD_USEL="01" else
				"1111";
	FDDEN<=FDC_BUSY or MONEN or fde_cpyen;

	FD_DS0<='1' when FDDEN='0' else '0' when FDD_USELn="10" else '1';
	FD_DS1<='1' when FDDEN='0' else '0' when FDD_USELn="01" else '1';

	FDD_USEL<=	"00" when FDD_USELn="10" else
				"01" when FDD_USELn="01" else
				"00";
	d2r	:dc2ry generic map(100) port map(
		USEL	=> FD_USEL,
		BUSY	=> FDDEN,
		DSKCHGn	=> FD_DSKCHG,
		RDBITn	=> FD_RDATAn,
		INDEXn	=> FD_INDEXn,
		
		READYn	=> FD_READYn,
		READYV	=> RDYV,
		
		clk		=> clk21m,
		rstn	=> rstn
	);
	EN0<='1' when FDC_BUSY='1' and FD_USEL="00" else '0';
	EN1<='1' when FDC_BUSY='1' and FD_USEL="01" else '0';

	MTS0 :MTsave generic map(sysclk,4000) port map(MON0S,EN0,RDYV(0),MON0,MTSAVEON,clk21m,rstn);
	MTS1 :MTsave generic map(sysclk,4000) port map(MON1S,EN1,RDYV(1),MON1,MTSAVEON,clk21m,rstn);

	FD_MOTOR0<=FDD_MOTORn(0);
	FD_MOTOR1<=FDD_MOTORn(1);

--	FD_READY<=not FD_DSKCHG;
	FD_DENl<=not FD_HDS(0) when FDD_USEL="00" else not FD_HDS(1) when FDD_USEL="01" else '1';
	FD_DENn<='0' when FD_DENl='0' else 'Z';
end MAIN;