library ieee;                                                           
use ieee.std_logic_1164.all;                                            
use ieee.numeric_std.all;

library work;
use work.genetics_utilities_pkg.all;
use work.genetics_lfsr_pkg.all;

entity ga_panel is
	generic (
		n 			: integer := 1024;		-- Number of individuals in the population
		m 			: integer := 16;			-- Individual bit
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
end ga_panel;

architecture structure of ga_panel is

	component genetics
		generic (
			n : integer := 64;
			m : integer := 8;
			a : integer := 32
		);                                             
		port (  
			reset 	: in 	std_logic;
         clk 		: in  std_logic;
         start 	: in  std_logic;
         X 			: in  std_logic_vector(15 downto 0);
         busy 		: out std_logic;
         vd 		: out std_logic;
         dout 		: out std_logic_vector (m-1 downto 0)
		);
         
	end component;
	
	component binary_to_bcd
		generic (
			m 			: positive := 8
		);
		port (
			number   : in  std_logic_vector (m-1 downto 0);
			hundreds : out std_logic_vector (3 downto 0);
			tens     : out std_logic_vector (3 downto 0);
			ones     : out std_logic_vector (3 downto 0)
		);
	end component;
	
	component bcd7seg
		port (
			bcd 		: in std_logic_vector(3 DOWNTO 0);
			display 	: out std_logic_vector(0 TO 6)
		);
	end component;
	
	component hex7seg
		port (
			hex 		: in std_logic_vector(3 DOWNTO 0);
			display 	: out std_logic_vector(0 TO 6)
		);
	end component;
	
	component clk_div_1Hz
		port(
			clock_50Mhz	: in	std_logic;
			clock_1Hz	: out	std_logic
		);
	end component;
	
	component twos_compliment
		generic(
			m 			: positive := 8 
		);
		port( 
			din 		: in std_logic_vector (m-1 downto 0);
			sign 		: out std_logic_vector (3 downto 0);
			dout 		: out std_logic_vector (m-1 downto 0)
		);
	end component;
	
	component binary_counter
		generic
		(
			MAX_COUNT : natural := 50000000
		);
		port
		(
			clk 		: in std_logic;
			reset 	: in std_logic;
			enable 	: in std_logic;
			q_usec 	: out std_logic_vector(15 downto 0);
			q_msec 	: out std_logic_vector(15 downto 0)
		);
	end component;
	
	signal clk_1Hz 	: std_logic;
	
	signal reset_ga, start_ga, vd_ga, busy_ga : std_logic;
	
	signal timer_enable, timer_reset : std_logic;
	signal timer_usec, timer_msec : std_logic_vector(15 downto 0);
	
	signal control 	: std_logic_vector(0 to 64);
	
	signal output, number, number_output : std_logic_vector(m-1 downto 0);
	
	signal sign 		: std_logic_vector(3 downto 0);
	signal hundreds 	: std_logic_vector(3 downto 0);
	signal tens 		: std_logic_vector(3 downto 0);
	signal ones 		: std_logic_vector(3 downto 0);
begin

	reset_ga <= SW(17);
	start_ga <= SW(16);
	LEDG(7) <= busy_ga;
--	LEDG(6) <= vd_ga;
	
	timer_reset <= reset_ga;

	panel: genetics
	generic map(
		n 			=> n,		-- Number of individuals in the population
		m 			=> m,		-- Individual bit
		a 			=> a			-- Number of memory address
	)
	port map(
		reset 	=> reset_ga,
		clk 		=> CLOCK_50,
		start 	=> start_ga,
		X 			=> x"0064",
		busy 		=> busy_ga,
		vd 		=> vd_ga,
		dout 		=> output
	);
	
	bcd_converter: binary_to_bcd 
	generic map (
		m 		=> m
	)
	port map (
		number 	=> number,
		hundreds => hundreds,
		tens 		=> tens,
		ones 		=> ones
	);
	
	clock_slow: clk_div_1Hz port map(
		clock_50Mhz => CLOCK_50,
		clock_1Hz 	=> clk_1Hz
	);
	
	m_twos_compliment: twos_compliment
	generic map (
		m 		=> m
	) 
	port map (
		din 	=> number_output,
		sign 	=> sign,
		dout 	=> number
	);
	
	timer: binary_counter
	generic map(
		MAX_COUNT => 50000000
	) port map(
		clk => CLOCK_50,
		reset => timer_reset,
		enable => busy_ga,
		q_usec => timer_usec,
		q_msec => timer_msec
	);
		
	
	digit0: bcd7seg PORT MAP (sign, HEX3);			-- sign
	digit1: bcd7seg PORT MAP (hundreds, HEX2);	-- 1XX, hunders
	digit2: bcd7seg PORT MAP (tens, HEX1);			-- X1X, tens
	digit3: bcd7seg PORT MAP (ones, HEX0);			-- XX1, ones
	
	digit7: hex7seg PORT MAP (control(0 to 3), HEX7);
	digit6: hex7seg PORT MAP (control(4 to 7), HEX6);
	

	
	process(clk_1Hz)
	begin
		if rising_edge(clk_1Hz) then
			number_output <= output;
		end if;
	end process;
	
	LEDR(m-1 downto 0) <= output;
	
	
end structure;