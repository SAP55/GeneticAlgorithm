library ieee;                                                           
use ieee.std_logic_1164.all;                                            
use ieee.numeric_std.all;           
use ieee.std_logic_arith.all;                                                             
use ieee.std_logic_unsigned.all; 
                                                                       
entity ram is  
	generic (
		w 		: integer := 8;	-- Width of vector
		h 		: integer := 64;	-- Number of rows in memory
		a 		: integer := 6		-- Width of address
	);                                             
	port (                                                           
		clk 	: in  std_logic;
		we 	: in  std_logic;  
		din 	: in  std_logic_vector (w-1 downto 0); 
		addr 	: in  std_logic_vector (a-1 downto 0); 
		dout 	: out std_logic_vector (w-1 downto 0)
	);         
end ram;                                                          
                                                                        
architecture structure of ram is                              
	type   mem_type is array (0 to h-1) of std_logic_vector (w-1 downto 0);
	signal mem : mem_type;
begin

	process (clk)  begin                                                          
		if clk='1' and clk'event then  
			if (we = '1') then
				mem(conv_integer(addr))(w-1 downto 0) <= din(w-1 downto 0);
			end if;

			dout <= mem(conv_integer(addr))(w-1 downto 0);
		end if;
	end process;   

end structure;