library ieee;                                                           
use ieee.std_logic_1164.all;                                            
use ieee.numeric_std.all;           
use ieee.std_logic_arith.all;                                                             
use ieee.std_logic_unsigned.all; 

entity mutation is

	generic(
		m : integer := 8
	);
	
	port(
		clk 		: in std_logic;
		en 		: in std_logic;
		prbg 		: in std_logic_vector (m-1 downto 0);
		child 	: in std_logic_vector (m-1 downto 0);
		child_m 	: out std_logic_vector (m-1 downto 0);
		vd 		: out std_logic
	);

end mutation;

architecture structure of mutation is

	signal k : integer range 0 to m;
	signal temp_k : std_logic_vector(3 downto 0);

begin

	k <= 3;
--	temp_k <= std_logic_vector(to_unsigned(conv_integer(prbg), 4));
--	k <= conv_integer(temp_k);

	process (clk)  begin                                                          
		if clk='1' and clk'event then  
			for i in child'range loop
				if i = k then
					child_m(i) <= not child(i);
				else 
					child_m(i) <= child(i); 
				end if;
			end loop;
			
			vd <= en;
		end if;		
	end process;
	
end structure;