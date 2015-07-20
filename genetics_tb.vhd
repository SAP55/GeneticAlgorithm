library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity genetics_tb is
end genetics_tb;
     
architecture genetics_tb_arch of genetics_tb is



 component genetics is  
		   generic (
		     n : integer := 64;
		     m : integer := 8
		         );                                             
       port (     
         reset        : in std_logic;                                                                
         clk          : in  std_logic;
         start        : in  std_logic;
         X            : in  std_logic_vector(15 downto 0);            
         busy         : out std_logic;         
         dout         : out std_logic_vector (m-1 downto 0);
         control	: out std_logic_vector(0 to 64)
            );         
  end component genetics;                                                          
                


  signal clk, start, busy, reset : std_logic;
  signal dout : std_logic_vector (3 downto 0);
  signal cnt  : std_logic_vector (3 downto 0) := "0000";
  
  signal control : std_logic_vector(0 to 64);

begin

  m_genetics : genetics generic map ( 
		     n => 512,
		     m => 4
		         )                                           
       port map (  
         reset  => reset,                                                         
         clk    => clk,
         start  => start,
         X      => x"0005",
         busy   => busy,
         dout   => dout,
         control => control
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
end genetics_tb_arch;