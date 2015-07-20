LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bcd7seg IS
	PORT (
		bcd : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		display : OUT STD_LOGIC_VECTOR(0 TO 6)
	);
END bcd7seg;

ARCHITECTURE structure OF bcd7seg IS
BEGIN
--
-- 0
-- ---
-- | |
-- 5| |1
-- | 6 |
-- ---
-- | |
-- 4| |2
-- | |
-- ---
-- 3
--
	PROCESS (bcd)

	BEGIN
		CASE (bcd) IS
			WHEN "0000" => display <= "0000001";	-- 0
			WHEN "0001" => display <= "1001111";	-- 1
			WHEN "0010" => display <= "0010010";	-- 2
			WHEN "0011" => display <= "0000110";	-- 3
			WHEN "0100" => display <= "1001100";	-- 4
			WHEN "0101" => display <= "0100100";	-- 5
			WHEN "0110" => display <= "1100000";	-- 6
			WHEN "0111" => display <= "0001111";	-- 7
			WHEN "1000" => display <= "0000000";	-- 8
			WHEN "1001" => display <= "0001100";	-- 9
			WHEN "1010" => display <= "1111110";	-- "-"
			WHEN OTHERS => display <= "1111111";	-- "x"
		END CASE;
	END PROCESS;
	
END structure;