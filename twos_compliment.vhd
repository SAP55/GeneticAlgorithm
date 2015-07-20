library ieee;
use ieee.std_logic_1164.all; 
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity twos_compliment is
	generic(
		m : positive := 8 
	);
	port( 
		din : in std_logic_vector (m-1 downto 0);
		sign : out std_logic_vector (3 downto 0);
		dout : out std_logic_vector (m-1 downto 0)
	);
end twos_compliment;

architecture structure of twos_compliment is
begin
	process(din)
	begin
		if (din(m-1) = '1') then
			sign <= x"A";
			dout <= std_logic_vector((not din) + '1');
		else
			sign <= x"F";
			dout <= din;
		end if;
	end process;
end structure;