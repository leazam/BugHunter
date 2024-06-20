library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;

entity THERMOSTAT is

port (  CURRENT_TEMP    : in std_logic_vector (6 downto 0);
        DESIRED_TEMP    : in std_logic_vector (6 downto 0);
        DISPLAY_SELECT  : in std_logic;
        COOL	        : in std_logic;	
        HEAT	        : in std_logic;
        CLK	        : in std_logic;
	FURNACE_HOT     : in std_logic;
	AC_READY	: in std_logic; 
	FAN_ON		: out std_logic; 
        A_C_ON	        : out std_logic;
        FURNACE_ON      : out std_logic; 
        TEMP_DISPLAY    : out std_logic_vector (6 downto 0));
end THERMOSTAT;

architecture RTL of THERMOSTAT is
type FSM_STATE is (IDLE,
		   HEATON,
		   FURNACEHOT,
		   FURNACECOOL,
		   COOLON,
		   ACREADY,
		   ACDONE);

signal CURRENT_STATE	 	  : FSM_STATE; 
signal NEXT_STATE	 	  : FSM_STATE;		   
signal CURRENT_TEMP_REG  	  : std_logic_vector (6 downto 0); 
signal DESIRED_TEMP_REG  	  : std_logic_vector (6 downto 0);
signal DISPLAY_SELECT_REG 	  : std_logic;
signal COOL_REG	         	  : std_logic;	
signal HEAT_REG	     	 	  : std_logic; 
signal AC_READY_REG	 	  : std_logic;
signal FURNACE_HOT_REG	 	  : std_logic;


begin
process (CLK)
begin
	if CLK'event and CLK = '1' then
		CURRENT_TEMP_REG   <= CURRENT_TEMP;
		DESIRED_TEMP_REG   <= DESIRED_TEMP; 
		DISPLAY_SELECT_REG <= DISPLAY_SELECT; 
		COOL_REG 	   <= COOL;
		HEAT_REG	   <= HEAT; 
		AC_READY_REG 	   <= AC_READY; 
		FURNACE_HOT_REG    <= FURNACE_HOT;
	end if;		
end process;

process (CLK)
begin
	if CLK'event and CLK = '1' then
		if DISPLAY_SELECT_REG = '1' then
			TEMP_DISPLAY <= DESIRED_TEMP_REG;
		else 
			TEMP_DISPLAY <= CURRENT_TEMP_REG;
		end if;
	end if; 
end process;		 

process (CLK)
begin
	if CLK'event and CLK = '1' then
		CURRENT_STATE <= NEXT_STATE;
	end if; 
end process;

process (CURRENT_STATE, CURRENT_TEMP_REG, DESIRED_TEMP_REG, HEAT_REG, FURNACE_HOT_REG, COOL_REG, AC_READY_REG)
variable COUNTDOWN : integer;
begin
case (CURRENT_STATE) is 
	when IDLE  =>
		if HEAT_REG = '1' and (CURRENT_TEMP_REG < DESIRED_TEMP_REG) then
			NEXT_STATE <= HEATON;
		elsif 	COOL_REG = '1' and (CURRENT_TEMP_REG > DESIRED_TEMP_REG) then
			NEXT_STATE <= COOLON;
		else
			NEXT_STATE <= IDLE;
		end if;
	when HEATON =>
		if FURNACE_HOT_REG = '1' then 
			NEXT_STATE <= FURNACEHOT;
		else
			 NEXT_STATE <= HEATON;
		end if;
	when FURNACEHOT =>
		COUNTDOWN := 10;
		if not (HEAT_REG = '1' and (CURRENT_TEMP_REG < DESIRED_TEMP_REG)) then
			NEXT_STATE <= FURNACECOOL;
		else
			NEXT_STATE <= FURNACEHOT;
		end if;
	when FURNACECOOL =>
		COUNTDOWN := COUNTDOWN - 1; 
		if (FURNACE_HOT_REG = '0' and COUNTDOWN = 0) then
			NEXT_STATE <= IDLE;
		else 
			NEXT_STATE <= FURNACECOOL;
		end if;
	when COOLON =>
		if AC_READY_REG = '1' then
			NEXT_STATE <= ACREADY;
		else
			NEXT_STATE <= COOLON;
		end if;
	when ACREADY =>
		COUNTDOWN := 20; 
		if not(COOL_REG = '1' and (CURRENT_TEMP_REG > DESIRED_TEMP_REG)) then
			NEXT_STATE <= ACDONE;
		else
			NEXT_STATE <= ACREADY;
		end if;
	when ACDONE =>
		COUNTDOWN := COUNTDOWN -1; 
		if (AC_READY_REG = '0' and COUNTDOWN = 0) then
			NEXT_STATE <= IDLE;
		else
			NEXT_STATE <= ACDONE;
		end if;
	when others =>
		NEXT_STATE <= IDLE;
end case;
end process;

process (CLK)
begin
	if CLK'event and CLK = '1' then
		if NEXT_STATE = HEATON or NEXT_STATE = FURNACEHOT then 
			FURNACE_ON <= '1'; 
		else
			FURNACE_ON <= '0';  
		end if; 
		if NEXT_STATE = COOLON or NEXT_STATE = ACREADY then 
			A_C_ON <= '1'; 
		else 
			A_C_ON <= '0'; 
		end if; 
		if NEXT_STATE = ACREADY or NEXT_STATE = ACDONE or 
		   NEXT_STATE = FURNACEHOT or NEXT_STATE = FURNACECOOL then
			FAN_ON <= '1'; 
		else 
			FAN_ON <= '0'; 
		end if; 
	end if; 
end process; 
end RTL;
