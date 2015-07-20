LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY clk_div_1Hz IS

	PORT(
		clock_50Mhz				: IN	STD_LOGIC;
		clock_1Hz				: OUT	STD_LOGIC
	);
	
END clk_div_1Hz;

ARCHITECTURE a OF clk_div_1Hz IS

	SIGNAL	count_1hz: STD_LOGIC_VECTOR(25 DOWNTO 0); 
	SIGNAL	clock_1Hz_int : STD_LOGIC;
BEGIN
	PROCESS 
	BEGIN
-- Divide by 50 Mhz
		WAIT UNTIL clock_50Mhz'EVENT and clock_50Mhz = '1';
			IF count_1hz < 49000000 THEN
				count_1hz <= count_1hz + 1;
			ELSE
				count_1hz <= "00000000000000000000000000";
			END IF;
			
			IF count_1hz < 25000000 THEN
				clock_1hz_int <= '0';
			ELSE
				clock_1hz_int <= '1';
			END IF;	

			clock_1hz <= clock_1hz_int;
	END PROCESS;	

END a;

