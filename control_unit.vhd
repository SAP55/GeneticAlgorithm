library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all; 
use ieee.numeric_std.all;

entity control_unit is
	generic(
		m 			: integer := 8;
		n 			: integer := 64;
		f 			: integer := 15
	);   
	port(
		clk   	: in 	std_logic;
		reset 	: in 	std_logic;
		start 	: in 	std_logic;
		X     	: in 	std_logic_vector(15 downto 0);              
		dout  	: out std_logic_vector(m-1 downto 0);
		busy  	: out std_logic;
		vd    	: out std_logic;
		
		prbg 		: in  std_logic_vector(m-1 downto 0);

		en_pop 	: out std_logic;
		vd_pop 	: in 	std_logic;		

		en_cros     : out std_logic;
		child_cros  : in  std_logic_vector(m-1 downto 0);
		vd_cros     : in  std_logic;
		parent1_cros: out std_logic_vector(m-1 downto 0); 
		parent2_cros: out std_logic_vector(m-1 downto 0);    
				 
		en_mut      : out std_logic;
		child_mut   : out std_logic_vector(m-1 downto 0); 
		child_m_mut : in  std_logic_vector(m-1 downto 0);
		vd_mut      : in  std_logic;
				 
		we_mem_pop  : out std_logic;
		din_mem_pop : out std_logic_vector(m-1 downto 0);
		addr_mem_pop: out std_logic_vector(31  downto 0);
		dout_mem_pop: in  std_logic_vector(m-1 downto 0);
				 
		we_mem_fit  : out std_logic;
		din_mem_fit : out std_logic_vector(f-1 downto 0);
		addr_mem_fit: out std_logic_vector(31  downto 0);
		dout_mem_fit: in  std_logic_vector(f-1 downto 0);
				 
		en_fit      : out std_logic;
		din_fit     : out std_logic_vector(m-1 downto 0);
		dout_fit    : in  std_logic_vector(f-1 downto 0);
		vd_fit      : in  std_logic
	);	 
end control_unit;

architecture structure of control_unit is
	
	signal state 	: std_logic_vector(7 downto 0) := (others => '0');
	
	-- Counters for state machine
	signal cnt     : std_logic_vector(31 downto 0) := (others => '0');
	signal cnt_glb : std_logic_vector(31 downto 0) := (others => '0');
	signal cnt_addr : std_logic_vector(31 downto 0) := (others => '0');
  
	-- Triggers for storage intermediate data
	signal tmp_fit : std_logic_vector(f-1 downto 0) := (others=>'0');
	signal tmp_pop : std_logic_vector(m-1 downto 0) := (others=>'0');
  
	-- Counter for integration (from 0 to Х-1)  
	signal cnt_X 	: std_logic_vector(15 downto 0) := (others => '0');
  
	-- Signals for sorting
	-- '1' - sort n elements
	-- '0' - sort n+(n/2)
	signal sort_N 	: std_logic;
	
	-- n - sort n elements
	-- n+(n/2) - sort n+(n/2)
	signal stop_N 	: integer;
  
	-- Flag for end sorting
	signal ok_sort : std_logic;
  
begin

	process (clk)
	begin
		if clk'event and clk = '1' then
		
			if (reset = '1')  then
				state <= x"00";
				dout <= (others => '0');
			else      
				case state is
					
					---------------------------
					-- Initialization signal --
					---------------------------
					when x"00" => 
						vd 				<= '0';
						
						en_pop  			<= '0';
						en_cros 			<= '0';
						parent1_cros 	<= (others => '0');
						parent2_cros 	<= (others => '0');
						en_mut 			<= '0';
						child_mut 		<= (others => '0');
						we_mem_pop 		<= '0';
						din_mem_pop 	<= (others => '0');
						addr_mem_pop 	<= (others => '0');
						we_mem_fit 		<= '0';
						din_mem_fit 	<= (others => '0');
						addr_mem_fit 	<= (others => '0');
						en_fit 			<= '0';
						din_fit 			<= (others=>'0');
						cnt 				<= (others=>'0');
						cnt_glb 			<= (others=>'0');
						sort_N 			<= '1';
						stop_N 			<= n;
						cnt_X 			<= (others=>'0');
     
						-- If start enable "1"
						if (start = '1') then
							busy  		<= '1';
							state 		<= x"01";  			  
						else
							busy  		<= '0';
							state 		<= x"00";
						end if;
						
					when x"01"  =>
						en_pop 			<= '1'; 
						state 			<= x"02";
        	
					when x"02"  =>  	
						en_pop <= '0';
						
						din_mem_pop  	<= prbg;
						we_mem_pop   	<= vd_pop;
						addr_mem_pop 	<= cnt;
	        
						if (vd_pop = '1') then
							if (cnt = n-1) then
								state 	<= x"03";
								cnt   	<= (others=>'0');
							else 
								cnt 		<= cnt + 1;
								state 	<= x"01"; 
							end if;			    	    
						end if;	

					when x"03"  => 
						we_mem_pop 		<= '0'; 
						addr_mem_pop 	<= cnt;
						state 			<= x"04";

					when x"04"  => 
						state 			<= x"05";

					---------------------
					-- Fitness process --
					---------------------
					-- Select induvidual from memory
					when x"05" =>
						en_fit 			<= '1';
						din_fit 			<= dout_mem_pop;
						state 			<= x"06";

					-- Write to memory new fitness value
					when x"06" =>
						en_fit 			<= '0';
						addr_mem_fit 	<= cnt;
						din_mem_fit 	<= dout_fit;
						we_mem_fit 		<= vd_fit;

						if (vd_fit = '1') then
							if (cnt = n-1) then
								state 	<= x"07"; 
								ok_sort 	<= '1';	         		
								cnt 		<= (others=>'0');
								cnt_glb 	<= (others=>'0');
							else 
								cnt 		<= cnt + 1;
								state 	<= x"03";
							end if;
						end if;
						
					---------------------
					-- Ranking process --
					---------------------
					-- Select first induvidual from memory
					when x"07"  =>
						we_mem_fit 		<= '0';

						addr_mem_pop 	<= cnt;
						addr_mem_fit 	<= cnt;
						state 			<= x"08";

					-- Select second induvidual from memory
					when x"08"  =>               
						addr_mem_pop 	<= cnt+1;
						addr_mem_fit 	<= cnt+1;
						state  			<= x"09";
					
					-- Set to data register
					when x"09"  =>
						tmp_pop 			<= dout_mem_pop;
						tmp_fit 			<= dout_mem_fit;
						state        	<= x"0A";

					-- Sequent induviduals
					when x"0A"  =>
					if (dout_mem_fit < tmp_fit) then
					
						-- Changing places and writing to memory
						we_mem_fit 		<= '1';
						we_mem_pop 		<= '1';
						
						ok_sort 			<= '0';	-- Sort again?
						tmp_pop 			<= dout_mem_pop;
						tmp_fit 			<= dout_mem_fit;
						din_mem_pop 	<= tmp_pop;
						din_mem_fit 	<= tmp_fit;
						state 			<= x"0B";
					else  
						state 			<= x"0C";
					end if;            

					when x"0B" => 
						addr_mem_pop 	<= cnt;
						addr_mem_fit 	<= cnt;
						din_mem_pop 	<= tmp_pop;
						din_mem_fit 	<= tmp_fit;
						state 			<= x"0C";

					-- Stop or continue sorting
					when x"0C" =>
						we_mem_fit 		<= '0';
						we_mem_pop 		<= '0';

						if (cnt = stop_N-2) then
							state 		<= x"0D";
							cnt 			<= (others=>'0');
						else
							state 		<= x"07";
							cnt 			<= cnt + 1;
						end if;
           
					when x"0D" =>
						if ((cnt_glb = stop_N-1) or (ok_sort = '1')) then
							cnt_glb 		<= std_logic_vector(to_unsigned(n, cnt_glb'length));
							
							if (sort_N = '1') then
								state 	<= x"0E"; 
							else
								cnt 		<= (others=>'0');
								cnt_glb 	<= (others=>'0');
								stop_N 	<= n;
								state 	<= x"22"; -- to selection without replies
--								state 	<= x"17"; -- to selection with replies 
							end if;	
						else 
							ok_sort 		<= '1';
							cnt_glb 		<= cnt_glb + 1; 
							state 		<= x"07"; 
						end if; 
          
					------------------------
					-- Crossoving process --
					------------------------
					-- Select first induvidual from memory
					when x"0E"  =>
						addr_mem_pop 	<= cnt;
						state 			<= x"0F";
					
					-- Select second induvidual from memory          
					when x"0F" => 
						addr_mem_pop 	<= cnt+1;                        
						state 			<= x"10";

					when x"10" =>
						parent1_cros 	<= dout_mem_pop;
						state 			<= x"11";

					-- Crossoving
					when x"11" =>
						parent2_cros 	<= dout_mem_pop;
						en_cros 			<= '1';
						state 			<= x"12";

					----------------------
					-- Mutation process --
					----------------------
					-- Select induvidual from memory
					when x"12" =>
						en_cros 			<= '0';
						if (vd_cros = '1') then
							en_mut 		<= '1';
							child_mut 	<= child_cros;       		  
							state 		<= x"13";
						end if; 

					when x"13" =>
						en_mut 			<= '0';
						
						if (vd_mut = '1') then
							en_fit 		<= '1';
							din_fit 		<= child_m_mut;
							state 		<= x"14";
						end if;

					when x"14" =>
						en_fit <= '0';
						
						if (vd_fit = '1') then
							addr_mem_pop <= cnt_glb;
							addr_mem_fit <= cnt_glb;
							we_mem_pop 	<= '1';
							we_mem_fit 	<= '1';
							din_mem_pop <= child_m_mut;
							din_mem_fit <= dout_fit;
							state 		<= x"15"; 
						end if;

					when x"15" =>
						we_mem_pop 		<= '0';
						we_mem_fit 		<= '0';
						cnt_glb 			<= cnt_glb + 1;
					
					if (cnt < n-2) then
						cnt 				<= cnt + 2;
						state 			<= x"0E";
					else
						cnt 				<= (others=>'0');
						state 			<= x"16";
					end if;

				---------------------
				-- Ranking process --
				---------------------
				-- Population n + n/2
				when x"16" =>
					cnt 			<= (others=>'0');
					cnt_glb 		<= (others=>'0');
					sort_N 		<= '0';
					stop_N 		<= n + n/2 ;
					ok_sort 		<= '1';
					state 		<= x"07";

				------------------------------
				-- Select new population #1 --
				-- 		with replies		 --
				------------------------------
				-- Selection induviduals from 0 to n
				when x"17" =>               
					cnt 			<= (others=>'0');
					cnt_glb 		<= std_logic_vector(to_unsigned(n, cnt_glb'length));             
					sort_N 		<= '1';
					stop_N 		<= n;
					cnt_X 		<= cnt_X + 1;

				if (cnt_X = X-1) then
					state 		<= x"18";
				else
					state 		<= x"0E";
				end if;

				------------------------------
				-- Select new population #2 --
				-- 		without replies	 --
				------------------------------
				-- Select first induvidual from memory
				when x"22"  =>
					we_mem_fit <= '0';

					addr_mem_pop <= cnt;
					addr_mem_fit <= cnt;
					state 				<= x"23";

				-- Select second induvidual from memory
				when x"23"  =>               
					addr_mem_pop <= cnt+1;
					addr_mem_fit <= cnt+1;
					state  				<= x"24";
				
				-- Set to data register
				when x"24"  =>
					tmp_pop <= dout_mem_pop;
					tmp_fit <= dout_mem_fit;
					state        <= x"25";

				-- Sequent induviduals
				when x"25"  =>
				if (dout_mem_pop /= tmp_pop) then
				
					-- Changing places and writing to memory
					we_mem_fit <= '1';
					we_mem_pop <= '1';
					
					addr_mem_pop <= cnt_glb;
					addr_mem_fit <= cnt_glb;
					
					cnt_glb <= cnt_glb + 1;
					state <= x"26";
				else  
					state <= x"27";
				end if;            

				when x"26" =>					
					din_mem_pop <= tmp_pop;
					din_mem_fit <= tmp_fit;
					state <= x"27";

				-- Stop or continue sorting
				when x"27" =>
					we_mem_fit <= '0';
					we_mem_pop <= '0';
					
					if (cnt_glb = stop_N) then
						state <= x"28";
					else
						cnt <= cnt + 1;
						state <= x"22";          
					end if;
		  
				when x"28" =>
					state <= x"17";
             
				-- End of all integrations
				-- The solution in zero address of memory
				when x"18"  =>              
					addr_mem_pop <= (others=>'0');
					state <= x"19";
								 
				when x"19"  =>              
					state <= x"20";
               
				----------------
				-- Set output --
				----------------
				when x"20"  =>              
					vd 		<= '1';
					dout 		<= dout_mem_pop;
					state 	<= x"21";

				-- Stop calculation
				when x"21"  =>              
					busy 		<= '0';
					vd 		<= '0';
					state 	<= x"00";

				when others  =>
					state 	<= x"00";
			end case; 
     
			end if;
		end if;	
	end process;

end structure;