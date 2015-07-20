library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

-- Fitness function(x^3-6*x^2-67*x+360)
-- Fitness function(x^2-3*x+4)

entity fitness is
	generic (
		m 		: integer := 8;
		f 		: integer := 18
	);
	port (
		clk   : in std_logic;
		en 	: in std_logic;
		din  	: in std_logic_vector (m-1 downto 0);
		dout  : out std_logic_vector(f-1 downto 0);
		vd 	: out std_logic
	);
end fitness;

architecture f_1 of fitness is

	signal tmp3 : std_logic_vector (3*m-1 downto 0);
	signal tmp2 : std_logic_vector (4*m-1 downto 0);
	signal tmp1 : std_logic_vector (3*m-1 downto 0);
	signal tmp : std_logic_vector (4*m-1 downto 0);
	
	signal vd_tmp1, vd_tmp2 : std_logic;
	
begin

	process (clk)
	begin

		if clk'event and clk = '1' then

			tmp3 <= std_logic_vector (signed ( din ) * signed ( din ) * signed ( din ));
			tmp2 <= std_logic_vector (to_signed(6, 2*m) * signed ( din ) * signed ( din ));
			tmp1 <= std_logic_vector (to_signed(67, 2*m) * signed ( din ));
			tmp <= std_logic_vector(signed (tmp3) - signed (tmp2) - signed (tmp1) + to_signed(360, 2*m));
			
			dout <= std_logic_vector( abs(signed(tmp)) );
		
			vd_tmp1 <= en;
			vd_tmp2 <= vd_tmp1;
			vd      <= vd_tmp2;
		end if;
	end process;
end f_1;


architecture f_2 of fitness is
	
	signal vd_tmp1, vd_tmp2 : std_logic;
	
	signal i, N : integer range 0 to 100 := 10;
	
begin

	process (clk)	
		variable tmp3 : std_logic_vector (4*m-1 downto 0);
		variable tmp2 : std_logic_vector (2*m-1 downto 0);
		variable tmp1 : std_logic_vector (4*m-1 downto 0);
		variable tmp0 : std_logic_vector (4*m-1 downto 0);
		variable tmp : std_logic_vector (4*m-1 downto 0);
	begin

		if clk'event and clk = '1' then
			tmp0 := (others => '0');
			
			-- tmp3 = 10*N
			tmp3 := std_logic_vector (to_signed(10, 2*m) * to_signed(N, 2*m));			
			
			for i in 1 to N loop
				-- tmp2 = x^2
				tmp2 := std_logic_vector(signed (din) * signed (din));
				
				-- tmp1 = 10*cos(2*pi*x)
				tmp1 := std_logic_vector(to_signed(10, 2*m) * to_signed( integer(cos( real(2)*MATH_PI*real( to_integer(signed(din(0 downto m))) ) )), 2*m ));
				
				-- tmp0 = tmp2-tmp1 = x^2 - 10*cos(2*pi*x)
				tmp0 := std_logic_vector(signed(tmp0) + signed(tmp2) - signed(tmp1));
			end loop;
			
			tmp := std_logic_vector(signed (tmp3) + signed (tmp0));
			
			dout <= std_logic_vector( abs(signed(tmp)) );
		
			vd_tmp1 <= en;
			vd_tmp2 <= vd_tmp1;
			vd      <= vd_tmp2;
		end if;
	end process;
end f_2;


architecture f_3 of fitness is
	
	signal vd_tmp1, vd_tmp2 : std_logic;
	
	signal i, N : integer range 0 to 100 := 10;
	
begin

	process (clk)
		variable tmp4 : std_logic_vector (2*m-1 downto 0);
		variable tmp3 : std_logic_vector (2*m-1 downto 0);
		variable tmp2 : std_logic_vector (6*m-1 downto 0);
		variable tmp1 : std_logic_vector (2*m-1 downto 0);
		variable tmp0 : std_logic_vector (6*m-1 downto 0);
		variable tmp : std_logic_vector (6*m-1 downto 0);
	begin

		if clk'event and clk = '1' then
			tmp0 := (others => '0');			
			
			for i in 1 to N loop
			
				-- tmp4 = x^2
				tmp4 := std_logic_vector(signed (din) * signed (din));
				
				-- tmp3 = x - tmp4 = (x - x^2)
				tmp3 := std_logic_vector (signed (din) - signed (tmp4));
				
				-- tmp2 = 100 * tmp3 * tmp3 = 100*(x - x^2)^2
				tmp2 := std_logic_vector(to_signed(100, 2*m) * signed (tmp3) * signed (tmp3));
				
				-- tmp1 = (x - 1)
				tmp1 := std_logic_vector (signed (din) - to_signed(1, 2*m));
				
				-- tmp0 = tmp2 + (x - 1)^2 = 100*(x - x^2)^2 + (x - 1)^2
				tmp0 := std_logic_vector(signed(tmp0) + signed (tmp2) + signed (tmp1) * signed (tmp1));
			
			end loop;
			
			tmp := std_logic_vector(signed (tmp3) + signed (tmp0));
			
			dout <= std_logic_vector( abs(signed(tmp)) );
		
			vd_tmp1 <= en;
			vd_tmp2 <= vd_tmp1;
			vd      <= vd_tmp2;
		end if;
	end process;
end f_3;

configuration conf of fitness is
	for 
--		f_1
--		f_2
		f_3
	end for ;
end conf;



