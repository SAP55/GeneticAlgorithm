library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ga_panel_tb is
end ga_panel_tb;
     
architecture structure of ga_panel_tb is
	
	component ga_panel
		generic (
			n 			: integer := 128;			-- Number of individuals in the population
			m 			: integer := 8;			-- Individual bit
			a 			: integer := 32			-- Number of memory address
		);  
		port(
			CLOCK_50 : in std_logic;
			LEDG 		: out std_logic_vector(7 downto 7);
			LEDR 		: out std_logic_vector(m-1 downto 0);
			SW 		: in std_logic_vector(17 downto 16);
			HEX0		: out std_logic_vector(0 to 6);
			HEX1		: out std_logic_vector(0 to 6);
			HEX2		: out std_logic_vector(0 to 6);
			HEX3		: out std_logic_vector(0 to 6);
			HEX4		: out std_logic_vector(0 to 6);
			HEX5		: out std_logic_vector(0 to 6);
			HEX6		: out std_logic_vector(0 to 6);
			HEX7		: out std_logic_vector(0 to 6)
			
		);
	end component;
	
signal clk, start, busy, reset : std_logic;
signal dout : std_logic_vector (15 downto 0);
signal cnt  : std_logic_vector (3 downto 0) := "0000";
  
signal control : std_logic_vector(0 to 64);

begin

	genetic_panel : ga_panel 
	generic map( 
		n => 64,
		m => 16,
		a => 32
	)                                           
	port map (
		CLOCK_50 => clk,
		SW(17)  => reset,
		SW(16)  => start,
		LEDG(7) => busy,
		LEDR(15 downto 0)   => dout
   );         
                                                          

	process begin
		clk <= '0';
			wait for 10 ns;
		clk <= '1';
			wait for 10 ns;
	end process;

	process (clk) begin
		if clk='1' and clk'event then 
			if (cnt < "1111") then 
				cnt <= std_logic_vector(unsigned(cnt) + 1);
			end if; 
     
     if (cnt = "1110")then
      start <= '1';
     else
      start <= '0';
     end if;


     if (cnt = "0001")then
      reset <= '1';
     else
      reset <= '0';
     end if;
   end if;
   
 end process;
end structure;