library ieee;                                                           
use ieee.std_logic_1164.all;                                            
use ieee.numeric_std.all;                                                                        
        
library work;
use work.genetics_utilities_pkg.all;
use work.genetics_lfsr_pkg.all;        
        
-- Top entity of Genetic Algorythm
                    
--           _   _   _   _      _   _   _   _   _   _   _   _   _    _   _   _   _   _   _   _   _   _   _   _   _   
--  clk    _/ \_/ \_/ \_/ \_.... \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/......\_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_
--               ___
--  reset  _____/   \_______....._______________________________......____________________________________________
--                                      ___
--  start  _________________.....______/   \____________________......____________________________________________
--                                          ____________________      __________________
--  busy   _________________.....__________/                    ......                  \_________________________
--                                                                                   ___
--  vd     _________________....._______________________________......______________/   \___________________________
--                                                                                   ___
--  dout   -----------------.....-------------------------------......--------------X___X---------------------------
--

                    
entity genetics is  
	generic (
		n 			: integer := 64;                    	-- Number of individuals in the population
		m 			: integer := 8;                      	-- Individual bit
		a 			: integer := 32                      	-- Number of memory address
	);                                             
   port (
		clk      : in  std_logic;                     	-- Clock (UP)
		reset    : in std_logic;                      	-- Synchronous reset
		start    : in  std_logic;                     	-- Signal the start of the circuit
		X        : in  std_logic_vector(15 downto 0); 	-- Number of iterations
		busy     : out std_logic;                     	-- Signal ready module (0 - module is ready, 1 - calculates)
		vd       : out std_logic;                     	-- Data is ready at the output dout module (1 - the data is ready, 0 - no data ready)
		dout    	: out std_logic_vector (m-1 downto 0)	-- Output
	);
end genetics;                                                          
                                                                        
architecture structure of genetics is

	component prng is
		generic (
			LFSR_WIDTH : integer 			:= 7;
			POLYNOMIAL : std_logic_vector := lfsr_polynomial(7);
			PRBS_WIDTH : integer 			:= m
		);
		port (
			clk    	: in  std_logic;
			enable 	: in  std_logic;
			en     	: in  std_logic;
			vd     	: out std_logic;
			lfsr_q 	: out std_logic_vector(LFSR_WIDTH-1 downto 0);
			prbs_q 	: out std_logic_vector(PRBS_WIDTH-1 downto 0)
		);
	end component;

	component crossover is 
		generic (
			m 			: integer := 8
		);
		port (
			clk 		: in 	std_logic;
			en 		: in 	std_logic;
			prbg 		: in 	std_logic_vector (m-1 downto 0);
			parent1 	: in 	std_logic_vector (m-1 downto 0);
			parent2 	: in 	std_logic_vector (m-1 downto 0);
			child 	: out std_logic_vector (m-1 downto 0);
			vd 		: out std_logic
		);
	end component crossover;
  
	component mutation is
		generic (
			m 			: integer := 8
		);	
		port (
			clk 		: in 	std_logic;
			en 		: in 	std_logic;
			prbg 		: in 	std_logic_vector (m-1 downto 0);
			child 	: in 	std_logic_vector (m-1 downto 0);
			child_m 	: out std_logic_vector (m-1 downto 0);
			vd 		: out std_logic
		);
	end component mutation;

	component ram is  
		generic (
			w 			: integer := 8;
		   h 			: integer := 64;
		   a 			: integer := 6
		);                                             
      port (                                                           
			clk 		: in  std_logic;
         we 		: in  std_logic;  
         din 		: in  std_logic_vector (w-1 downto 0); 
         addr 		: in  std_logic_vector (a-1 downto 0); 
         dout 		: out std_logic_vector (w-1 downto 0)
		);         
	end component ram;     

	component fitness is
		generic (
			m 			: integer := 8;
			f 			: integer := 15
		);
		port (
			clk 		: in 	std_logic;
			en 		: in 	std_logic;
			din 		: in 	std_logic_vector (m-1 downto 0);
			dout 		: out std_logic_vector(f-1 downto 0);
			vd 		: out std_logic
		);
	end component fitness;


	component control_unit is
		generic (
			m 			: integer := 8;
			n 			: integer := 64;
			f 			: integer := 15
		);  
		port (
			clk 		: in std_logic;
			reset 	: in std_logic;       
			start 	: in std_logic;
			X 			: in std_logic_vector(15 downto 0);
			dout 		: out std_logic_vector(m-1 downto 0);
			busy 		: out std_logic;
			vd 		: out std_logic;
			
			prbg 		: in  std_logic_vector(m-1 downto 0);
			
			en_pop 		: out std_logic;
			vd_pop 		: in std_logic;
					  
			en_cros 		: out std_logic;
			child_cros 	: in  std_logic_vector(m-1 downto 0);
			vd_cros 		: in  std_logic;
			parent1_cros: out std_logic_vector(m-1 downto 0); 
			parent2_cros: out std_logic_vector(m-1 downto 0);   
					 
			en_mut 		: out std_logic;
			child_mut 	: out std_logic_vector(m-1 downto 0); 
			child_m_mut : in  std_logic_vector(m-1 downto 0);
			vd_mut 		: in  std_logic; 
					 
			we_mem_pop 	: out std_logic;
			din_mem_pop : out std_logic_vector(m-1 downto 0);
			addr_mem_pop: out std_logic_vector(31  downto 0);
			dout_mem_pop: in  std_logic_vector(m-1 downto 0);
					 
			we_mem_fit 	: out std_logic;
			din_mem_fit : out std_logic_vector(f-1 downto 0);
			addr_mem_fit: out std_logic_vector(31  downto 0);
			dout_mem_fit: in  std_logic_vector(f-1 downto 0);
					
			en_fit 		: out std_logic;
			din_fit 		: out std_logic_vector(m-1 downto 0);
			dout_fit 	: in  std_logic_vector(f-1 downto 0);
			vd_fit 		: in  std_logic
		);
	end component control_unit;

	signal 	enable_prng		: std_logic;
	signal 	en_population, 
				en_cros, 
				en_mut, 
				en_fit, 
				we_mem_pop, 
				we_mem_fit 		: std_logic;
	signal 	vd_population, 
				vd_cros, 
				vd_mut, 
				vd_fit			: std_logic;
    
	signal 	prbs,
				din_fit 			: std_logic_vector (m-1 downto 0);
	signal 	child_cros, 
				parent1_cros, 
				parent2_cros 	: std_logic_vector (m-1 downto 0);
				
	signal 	child_mut, 
				child_m_mut 	: std_logic_vector (m-1 downto 0);
  
	signal 	din_mem_pop, 
				dout_mem_pop 	: std_logic_vector (m-1 downto 0);
				
	signal 	din_mem_fit, 
				dout_mem_fit, 
				dout_fit 		: std_logic_vector (6*m-1 downto 0);
  
	signal 	addr_mem_pop, 
				addr_mem_fit 	: std_logic_vector (31 downto 0);
	
	signal 	clk_1Hz 			: std_logic;
  
begin

	enable_prng <= not reset;

	-- Generation of initial population	
	module_number_generator : prng 
		generic map (
			LFSR_WIDTH => 7,
			PRBS_WIDTH => m
		)
		port map(
			clk    	=> clk,
			enable 	=> enable_prng,
			en     	=> en_population,
			vd     	=> vd_population,
			lfsr_q 	=> open,
			prbs_q 	=> prbs
		);
  
	-- Crossover
	module_crossover : crossover  
		generic map (
			m 			=> m
		)
		port map (
			clk 		=> clk,
			en 		=> en_cros,
			prbg 		=> prbs,
			parent1 	=> parent1_cros, 
			parent2 	=> parent2_cros,
			child 	=> child_cros,
			vd 		=> vd_cros
		);
  	
  	
	-- Mutation
	module_mutation : mutation  
		generic map (
			m 			=> m
		)
		port map (
			clk 		=> clk,
			en 		=> en_mut,
			prbg 		=> prbs,
			child 	=> child_mut,
			child_m 	=> child_m_mut,
			vd 		=> vd_mut
		);
  	
	-- Memory for individuals in a population
	RAM_population  : ram
		generic map (
			w 			=> m,
			h 			=> n + n/2,
			a 			=> a
		)                                            
		port map (                                                           
			clk 		=> clk,
			we 		=> we_mem_pop,
			din 		=> din_mem_pop,
			addr 		=> addr_mem_pop,
			dout 		=> dout_mem_pop
		);         
 
	-- Memory for fitness individuals
	RAM_fitness : ram 
		generic map (
			w 			=> 6*m,
			h 			=> n + n/2 ,
			a 			=> a
		)                                             
		port map (                                                           
			clk 		=> clk,
			we 		=> we_mem_fit,
			din 		=> din_mem_fit,
			addr 		=> addr_mem_fit,
			dout 		=> dout_mem_fit
		);  
    
	-- Fitness Calculation Module
	module_fitness : fitness
		generic map (
			m 			=> m,
			f 			=> 6*m  
		)  
		port map (
			clk 		=> clk,
			en 		=> en_fit,
			din 		=> din_fit,
			dout 		=> dout_fit,
			vd 		=> vd_fit
		);

	-- Control Unit
	module_CU : control_unit 
		generic map (
			m 				=> m,
			n 				=> n, 
			f 				=> 6*m
		)    
		port map(
			clk         => clk,
			reset 		=> reset,
			start       => start,
			X           => X,
			dout        => dout,
			busy        => busy,
			vd          => vd,
			
			prbg    		=> prbs,
			en_pop      => en_population, 
			vd_pop      => vd_population,

			en_cros     => en_cros,
			child_cros  => child_cros,
			vd_cros     => vd_cros,
			parent1_cros=> parent1_cros,
			parent2_cros=> parent2_cros,

			en_mut      => en_mut,
			child_mut   => child_mut,
			child_m_mut => child_m_mut,
			vd_mut      => vd_mut,

			we_mem_pop  => we_mem_pop,
			din_mem_pop => din_mem_pop,
			addr_mem_pop=> addr_mem_pop,
			dout_mem_pop=> dout_mem_pop,

			we_mem_fit  => we_mem_fit,
			din_mem_fit => din_mem_fit,
			addr_mem_fit=> addr_mem_fit,
			dout_mem_fit=> dout_mem_fit,
					 
			en_fit      => en_fit,
			din_fit     => din_fit,
			dout_fit    => dout_fit,
			vd_fit      => vd_fit   
		);
		
end structure; 

