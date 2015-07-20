-- ----------------------------------------------------------------
-- utilities_pkg.vhd
--
-- 2/27/2008 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Utilities package.
--
-- These utility functions are used in synthesizeable designs.
--
-- ----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------

package genetics_utilities_pkg is

	type my_array_t is array (1 to 7) of integer range 0 to 255;

	-- ------------------------------------------------------------
	-- Utility functions
	-- ------------------------------------------------------------
	--
	-- Maximum value
	function max(
		a : integer;
		b : integer) return integer;

	function max(
		a : time;
		b : time) return time;

	function max(
		a : real;
		b : real) return real;

	-- VHDL-2008 adds maximum/minimum functions, however,
	-- Quartus II v10.1 does not support them.
	--
	-- synthesis read_comments_as_HDL on
	--	function maximum(
	--		a : integer;
	--		b : integer) return integer;
	--
	--	function maximum(
	--		a : time;
	--		b : time) return time;
	--
	--	function maximum(
	--		a : real;
	--		b : real) return real;
	--
	--type integer_vector is array (natural range <>) of integer;
	
	--	function maximum(
	--		a : integer_vector) return integer;
	--
	-- synthesis read_comments_as_HDL off

	-- ------------------------------------------------------------
	-- Conversion functions
	-- ------------------------------------------------------------
	--
	-- Integer-to-std_logic_vector
	function to_slv(
		arg  : in integer;
		size : in natural) return std_logic_vector;

	-- String-to-std_logic_vector
	function to_slv(
		arg  : in string;
		size : in natural) return std_logic_vector;

	-- std_logic_vector-to-integer
	function to_int(
		arg  : in std_logic_vector) return integer;

	-- String-to-integer
	function to_int(
		arg  : in string) return integer;

	-- ------------------------------------------------------------
	-- String conversion
	-- ------------------------------------------------------------
	--
	-- Although VHDL is case-insensitive, string comparison logic
	-- is case sensitive (in both Modelsim and Quartus), so the
	-- statements
	--
	--    if (INIT_FILE = "none") then
	--
	-- and
	--
	--    if (INIT_FILE = "NONE") then
	--
	-- are not identical. The following string case conversion
	-- functions allow for case-insensitive comparisons, eg.,
	--
	--    if (toupper(INIT_FILE) = "NONE") then
	--
	-- The altera_max2_ufm.vhd file shows an example use of this
	-- procedure to check the UFM component INIT_FILE argument.
	--
	function toupper(str: string) return string;
	function tolower(str: string) return string;
	
	
end package;

package body genetics_utilities_pkg is

	-- --------------------------------------------------------
	-- Maximum value
	-- --------------------------------------------------------
	--
	function max(
		a : integer;
		b : integer) return integer is
	begin
		if (a > b) then
			return a;
		else
			return b;
		end if;
	end function;

	function max(
		a : time;
		b : time) return time is
	begin
		if (a > b) then
			return a;
		else
			return b;
		end if;
	end function;

	function max(
		a : real;
		b : real) return real is
	begin
		if (a > b) then
			return a;
		else
			return b;
		end if;
	end function;

	--	synthesis read_comments_as_HDL on
	--	function maximum(
	--		a : integer;
	--		b : integer) return integer is
	-- begin
	--		return max(a,b);
	-- end function;
	--
	--	function maximum(
	--		a : time;
	--		b : time) return time is
	-- begin
	--		return max(a,b);
	--	end function;
	--
	--	function maximum(
	--		a : real;
	--		b : real) return real is
	-- begin
	--		return max(a,b);
	--	end function;
	--
	--	function maximum(
	--		a : integer_vector) return integer is
	--    variable ret : integer;
	-- begin
	--    ret := a(a'low);
	--    for i in a'low to a'high loop
	--			ret := max(ret, a(i));
	--		end loop;
	--    return ret;
	--	end function;
	--
	--	synthesis read_comments_as_HDL off

	-- --------------------------------------------------------
    -- Integer-to-std_logic_vector conversion
    -- --------------------------------------------------------
    --
	-- ieee.numeric_std has two useful integer to bit-vector
	-- conversion routines;
	--
	--  1) to_unsigned
	--       which takes a natural (31-bit integer)
	--
	--  2) to_signed
	--       which takes an integer (32-bit integer)
	--
	-- The problem with using to_unsigned, is that you get
	-- warnings when passing an integer with the MSB set,
	-- eg. 16#FFFFFFFF# = -1.
	--
	-- The problem with using to_signed, is that you get
	-- the warning
	--
	--   NUMERIC_STD.TO_SIGNED: vector truncated
	--
	-- for a conversion like; to_signed(16#F#,4) = 1111b
	-- since the routine considers 16#F# to be 15, not -7.
	--
	-- The warning messages can be avoided by using each
	-- function appropriately;
	--
	function to_slv(
		arg  : in integer;
		size : in natural) return std_logic_vector is
		variable result : std_logic_vector(size-1 downto 0);
	begin
		if (arg > 0) then
			result := std_logic_vector(to_unsigned(arg,size));
		else
			result := std_logic_vector(to_signed(arg,size));
		end if;
		return result;
	end function;

	-- --------------------------------------------------------
    -- String-to-std_logic_vector conversion
    -- --------------------------------------------------------
    --
	function to_slv(
		arg  : in string;
		size : in natural) return std_logic_vector is
		variable length : integer;
	begin
		-- Allow the user to specify the vector size.
		-- Default to 4-bits per nibble.
		if (size = 0) then
			length := 4*arg'length;
		else
			length := size;
		end if;
		return to_slv(to_int(arg), length);
	end function;

	-- --------------------------------------------------------
    -- std_logic_vector-to-integer conversion
    -- --------------------------------------------------------
    --
	-- Component testbench test-case generators pass integers
	-- to models. The integers are converted to
	-- std_logic_vectors with a design specific width.
	-- Data is written and read from designs, and integer
	-- comparison of results is performed by the test-case
	-- generators.
	--
	-- Sign-extension can cause issues when converting between
	-- integers and std_logic_vectors, eg.
	--
	-- variable i1,i2 : integer;
	-- variable s     : std_logic_vector(7 downto 0);
	--
	-- i1 := 16#D0#;
	-- s  := to_slv(i1,8);
	-- i2 := to_integer(signed(s));
	--
	-- i2 will equal 16#FFFFFFD0# which will fail a comparison
	-- with the integer i1 16#D0#. The following conversion
	-- function selects signed() or unsigned() appropriately.
	--
	-- std_logic_vector-to-integer
	function to_int(
		arg  : in std_logic_vector) return integer is
		variable result : integer;
	begin
		if (arg'length < 32) then
			-- Don't sign extend for less than 32-bits
			result := to_integer(unsigned(arg));
		else
			-- A 32-bit SLV needs to be interpreted as signed
			result := to_integer(signed(arg));
		end if;
		return result;
	end function;

	-- --------------------------------------------------------
    -- String-to-integer conversion
    -- --------------------------------------------------------
    --
	function to_int(
		arg  : in string) return integer is
		constant length : natural := arg'length;
		variable ch     : character;
		variable nibble : integer;
		variable result : integer;
	begin
		-- Integer strings cannot have more than 8 characters
		assert (length <= 8)
			report "Error: invalid string length for integer conversion"
			severity failure;

		-- Convert the string into an integer one nibble at a time
		result := 0;
		for i in 0 to length-1 loop
			-- Next character
			ch := arg(arg'high - i);

			-- Character to integer
			if ((ch >= '0') and (ch <= '9')) then
				nibble := character'pos(ch) - character'pos('0');
			elsif ((ch >= 'A') and (ch <= 'F')) then
				nibble := character'pos(ch) - character'pos('A') + 16#A#;
			elsif ((ch >= 'a') and (ch <= 'f')) then
				nibble := character'pos(ch) - character'pos('a') + 16#A#;
			else
				assert false
					report "Error: invalid character for integer conversion"
					severity failure;
			end if;

			-- Accumulate the nibble into the result
			result := result + nibble*(16**i);

		end loop;
		return result;
	end function;

	-- ------------------------------------------------------------
	-- String conversion
	-- ------------------------------------------------------------
	--
	function toupper(str: string) return string is
		variable res : string(str'range);
	begin
		for i in str'range loop
			if (str(i) >= 'a') and (str(i) <= 'z') then
				res(i) := character'val(
					character'pos(str(i))   -
					character'pos('a') +
					character'pos('A')
				);
			else
				res(i) := str(i);
			end if;
		end loop;
		return res;
	end function;

	function tolower(str: string) return string is
		variable res : string(str'range);
	begin
		for i in str'range loop
			if (str(i) >= 'A') and (str(i) <= 'Z') then
				res(i) := character'val(
					character'pos(str(i))   -
					character'pos('A') +
					character'pos('a')
				);
			else
				res(i) := str(i);
			end if;
		end loop;
		return res;
	end function;
	


end package body;

