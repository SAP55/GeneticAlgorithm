library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity crossover is 

	generic (
		m 			: integer := 8
	);

	port(
		clk 		: in std_logic;
		en 		: in std_logic;
		prbg 		: in 	std_logic_vector (m-1 downto 0);
		parent1 	: in 	std_logic_vector (m-1 downto 0);
		parent2 	: in 	std_logic_vector (m-1 downto 0);
		child 	: out std_logic_vector (m-1 downto 0);
		vd 		: out std_logic
	);

end crossover;

architecture structure of crossover is 

begin

	process (clk)  begin                                                          
		if clk='1' and clk'event then  
			child <= (parent1 and prbg) or (parent2 and not prbg);

			vd <= en;
		end if ;
	end process;

end structure;