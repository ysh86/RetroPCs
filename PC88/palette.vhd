LIBRARY	IEEE;
USE	IEEE.STD_LOGIC_1164.ALL;
USE	IEEE.STD_LOGIC_UNSIGNED.ALL;

entity palette is
port(
	IORQn	:in std_logic;
	WRn		:in std_logic;
	ADR		:in std_logic_vector(7 downto 0);
	WDAT	:in std_logic_vector(7 downto 0);
	
	PMODE	:in std_logic;
	
	DOTIN	:in std_logic_vector(2 downto 0);
	ROUT	:out std_logic_vector(2 downto 0);
	GOUT	:out std_logic_vector(2 downto 0);
	BOUT	:out std_logic_vector(2 downto 0);
	
	clk		:in std_logic;
	rstn	:in std_logic
);
end palette;

architecture MAIN of palette is
signal	R0	:std_logic_vector(2 downto 0);
signal	G0	:std_logic_vector(2 downto 0);
signal	B0	:std_logic_vector(2 downto 0);
signal	R1	:std_logic_vector(2 downto 0);
signal	G1	:std_logic_vector(2 downto 0);
signal	B1	:std_logic_vector(2 downto 0);
signal	R2	:std_logic_vector(2 downto 0);
signal	G2	:std_logic_vector(2 downto 0);
signal	B2	:std_logic_vector(2 downto 0);
signal	R3	:std_logic_vector(2 downto 0);
signal	G3	:std_logic_vector(2 downto 0);
signal	B3	:std_logic_vector(2 downto 0);
signal	R4	:std_logic_vector(2 downto 0);
signal	G4	:std_logic_vector(2 downto 0);
signal	B4	:std_logic_vector(2 downto 0);
signal	R5	:std_logic_vector(2 downto 0);
signal	G5	:std_logic_vector(2 downto 0);
signal	B5	:std_logic_vector(2 downto 0);
signal	R6	:std_logic_vector(2 downto 0);
signal	G6	:std_logic_vector(2 downto 0);
signal	B6	:std_logic_vector(2 downto 0);
signal	R7	:std_logic_vector(2 downto 0);
signal	G7	:std_logic_vector(2 downto 0);
signal	B7	:std_logic_vector(2 downto 0);

signal	IOWRn	:std_logic;

begin

	IOWRn<=IORQn or WRn;
	
	process(clk,rstn)begin
		if(rstn='0')then
			R0<="000";
			G0<="000";
			B0<="000";
			R1<="000";
			G1<="000";
			B1<="111";
			R2<="111";
			G2<="000";
			B2<="000";
			R3<="111";
			G3<="000";
			B3<="111";
			R4<="111";
			G4<="000";
			B4<="000";
			R5<="000";
			G5<="111";
			B5<="111";
			R6<="111";
			G6<="111";
			B6<="000";
			R7<="111";
			G7<="111";
			B7<="111";
		elsif(clk' event and clk='1')then
			if(IOWRn='0')then
				case ADR is
				when x"54" =>
					if(PMODE='0')then
						R0<=(others=>WDAT(1));
						B0<=(others=>WDAT(0));
						G0<=(others=>WDAT(2));
					elsif(WDAT(7 downto 6)="00")then
						R0<=WDAT(5 downto 3);
						B0<=WDAT(2 downto 0);
					elsif(WDAT(7 downto 6)="01")then
						G0<=WDAT(2 downto 0);
					end if;
				when x"55" =>
					if(PMODE='0')then
						R1<=(others=>WDAT(1));
						B1<=(others=>WDAT(0));
						G1<=(others=>WDAT(2));
					elsif(WDAT(7 downto 6)="00")then
						R1<=WDAT(5 downto 3);
						B1<=WDAT(2 downto 0);
					elsif(WDAT(7 downto 6)="01")then
						G1<=WDAT(2 downto 0);
					end if;
				when x"56" =>
					if(PMODE='0')then
						R2<=(others=>WDAT(1));
						B2<=(others=>WDAT(0));
						G2<=(others=>WDAT(2));
					elsif(WDAT(7 downto 6)="00")then
						R2<=WDAT(5 downto 3);
						B2<=WDAT(2 downto 0);
					elsif(WDAT(7 downto 6)="01")then
						G2<=WDAT(2 downto 0);
					end if;
				when x"57" =>
					if(PMODE='0')then
						R3<=(others=>WDAT(1));
						B3<=(others=>WDAT(0));
						G3<=(others=>WDAT(2));
					elsif(WDAT(7 downto 6)="00")then
						R3<=WDAT(5 downto 3);
						B3<=WDAT(2 downto 0);
					elsif(WDAT(7 downto 6)="01")then
						G3<=WDAT(2 downto 0);
					end if;
				when x"58" =>
					if(PMODE='0')then
						R4<=(others=>WDAT(1));
						B4<=(others=>WDAT(0));
						G4<=(others=>WDAT(2));
					elsif(WDAT(7 downto 6)="00")then
						R4<=WDAT(5 downto 3);
						B4<=WDAT(2 downto 0);
					elsif(WDAT(7 downto 6)="01")then
						G4<=WDAT(2 downto 0);
					end if;
				when x"59" =>
					if(PMODE='0')then
						R5<=(others=>WDAT(1));
						B5<=(others=>WDAT(0));
						G5<=(others=>WDAT(2));
					elsif(WDAT(7 downto 6)="00")then
						R5<=WDAT(5 downto 3);
						B5<=WDAT(2 downto 0);
					elsif(WDAT(7 downto 6)="01")then
						G5<=WDAT(2 downto 0);
					end if;
				when x"5a" =>
					if(PMODE='0')then
						R6<=(others=>WDAT(1));
						B6<=(others=>WDAT(0));
						G6<=(others=>WDAT(2));
					elsif(WDAT(7 downto 6)="00")then
						R6<=WDAT(5 downto 3);
						B6<=WDAT(2 downto 0);
					elsif(WDAT(7 downto 6)="01")then
						G6<=WDAT(2 downto 0);
					end if;
				when x"5b" =>
					if(PMODE='0')then
						R7<=(others=>WDAT(1));
						B7<=(others=>WDAT(0));
						G7<=(others=>WDAT(2));
					elsif(WDAT(7 downto 6)="00")then
						R7<=WDAT(5 downto 3);
						B7<=WDAT(2 downto 0);
					elsif(WDAT(7 downto 6)="01")then
						G7<=WDAT(2 downto 0);
					end if;
				when others=>
				end case;
			end if;
		end if;
	end process;
	
	
	ROUT<=	R0	when DOTIN="000" else
			R1	when DOTIN="001" else
			R2	when DOTIN="010" else
			R3	when DOTIN="011" else
			R4	when DOTIN="100" else
			R5	when DOTIN="101" else
			R6	when DOTIN="110" else
			R7;

	GOUT<=	G0	when DOTIN="000" else
			G1	when DOTIN="001" else
			G2	when DOTIN="010" else
			G3	when DOTIN="011" else
			G4	when DOTIN="100" else
			G5	when DOTIN="101" else
			G6	when DOTIN="110" else
			G7;

	BOUT<=	B0	when DOTIN="000" else
			B1	when DOTIN="001" else
			B2	when DOTIN="010" else
			B3	when DOTIN="011" else
			B4	when DOTIN="100" else
			B5	when DOTIN="101" else
			B6	when DOTIN="110" else
			B7;
	
end MAIN;