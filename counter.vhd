library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity binary_counter is

	generic(
		MAX_COUNT : natural := 50000
	);
	port(
		clk		  : in std_logic;
		reset	  : in std_logic;
		enable	  : in std_logic;
		q_usec		  : out std_logic_vector(15 downto 0);
		q_msec		  : out std_logic_vector(15 downto 0)
	);

end entity;

architecture rtl of binary_counter is
	
	signal	usec : std_logic_vector(15 downto 0);
	signal	msec : std_logic_vector(15 downto 0);

begin
	process (clk, reset, enable)
		variable   m_max : natural := MAX_COUNT/1000;
		variable   u_max : natural := m_max/1000;
	begin
		if (rising_edge(clk)) then

			if reset = '1' then
				msec <= (others => '0');
				usec <= (others => '0');

			elsif enable = '1' then		   
				usec <= usec + 1;
				
				if usec = u_max then
					msec <= msec + 1;
					usec <= (others => '0');
				end if;

			end if;
		end if;
	end process;

end rtl;