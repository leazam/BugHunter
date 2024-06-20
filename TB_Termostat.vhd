library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;

entity TB_THERMOSTAT is
end TB_THERMOSTAT;

architecture TEST of TB_THERMOSTAT is
component THERMOSTAT
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
end component;

signal CURRENT_TEMP, DESIRED_TEMP 			  : std_logic_vector (6 downto 0);
signal DISPLAY_SELECT, COOL, HEAT, FURNACE_HOT, AC_READY  : std_logic;
signal A_C_ON, FURNACE_ON, FAN_ON			  : std_logic;
signal TEMP_DISPLAY					  : std_logic_vector (6 downto 0);
signal CLK						  : std_logic := '0'; 

begin 

CLK <= not CLK after 5 ns; 
UUT: THERMOSTAT port map ( CURRENT_TEMP   => CURRENT_TEMP,
			   DESIRED_TEMP   => DESIRED_TEMP, 
			   DISPLAY_SELECT => DISPLAY_SELECT, 
			   COOL           => COOL, 
			   HEAT		  => HEAT, 
			   A_C_ON 	  => A_C_ON, 
			   FURNACE_ON	  => FURNACE_ON, 
			   TEMP_DISPLAY   => TEMP_DISPLAY,
			   CLK		  => CLK,
			   FURNACE_HOT    => FURNACE_HOT,
			   AC_READY       => AC_READY,
	   		   FAN_ON 	  => FAN_ON);

process 
begin 
CURRENT_TEMP   <= "0000000"; 
DESIRED_TEMP   <= "1111111";
FURNACE_HOT <= '0'; 
AC_READY <= '0'; 
HEAT <= '0'; 
COOL <= '0'; 
DISPLAY_SELECT <= '0';
wait for 50 ns;
DISPLAY_SELECT <= '1' ; 
wait for 50 ns;
HEAT <= '1';
wait until FURNACE_ON = '1';
FURNACE_HOT <= '1';    
wait until FAN_ON = '1';
HEAT <= '0';
wait until FURNACE_ON = '0'; 
FURNACE_HOT <= '0';
wait for 50 ns; 
HEAT <= '0'; 
wait for 50 ns; 
CURRENT_TEMP <= "1000000";
DESIRED_TEMP <= "0100000";
wait for 50 ns;
COOL <= '1';
wait until A_C_ON = '1'; 
AC_READY <= '1'; 
wait until FAN_ON = '1';
COOL <= '0'; 
AC_READY <= '0'; 
wait for 50 ns; 
COOL <= '0'; 
wait for 50 ns; 
wait;
end process; 
end TEST; 
	