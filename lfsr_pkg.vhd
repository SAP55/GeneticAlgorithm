-- ----------------------------------------------------------------
-- lfsr_pkg.vhd
--
-- 2/27/2008 D. W. Hawkins (dwh@ovro.caltech.edu)
--
-- Pseudo-random binary sequence (PRBS) and Linear feedback
-- shift-register (LFSR) package.
--
-- This package provides default primitive polynomials and
-- conversion utilities for use in LFSR/PRBS generators.
--
-- ----------------------------------------------------------------
-- References
-- ----------
--
-- [1] "Linear feedback shift register", Wikipedia
--     http://en.wikipedia.org/wiki/Linear_feedback_shift_register
--
-- [2] "XAPP052: Efficient shift registers, LFSR counters, and
--     long pseudo-random sequence generators", P. Alfke,
--     Xilinx application note, 1996.
--
-- [3] "XAPP211: PN genertors using the SRL macro", A. Miller and
--     M. Gulotta, Xilinx application note (v1.4), 2004.
--
-- [4] "DS257: Linear Feedback Shift Register (v3.0)", Xilinx
--     LogicCore product specification (lfsr.pdf).
--
-- [5] MATLAB communications toolbox (primpoly)
--
-- ----------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------

package genetics_lfsr_pkg is

	-- ------------------------------------------------------------
	-- Default LFSR polynomials
	-- ------------------------------------------------------------
	--
	-- Return a primitive polynomial for a given LFSR width
	function lfsr_polynomial (
		w : integer) return std_logic_vector;

	-- ------------------------------------------------------------
	-- LFSR polynomial conversion functions
	-- ------------------------------------------------------------
	--
	-- LFSR polynomials can be described in several different
	-- forms, eg., the PRBS7 SONET polynomial X^7 + X^6 + 1 can
	-- be described in tap form as [7,6], or in binary form as
	-- 1100_0001b = C1h = 193.
	--
	-- LFSR polynomials for use as a digital noise source need
	-- to have widths in excess of 32-bits, so the polynomial
	-- cannot be described using an integer.
	--
	-- The following conversion functions take string arguments
	-- and return the binary polynomial form as a std_logic_vector
	-- (these are essentially string-to-slv conversion functions).
	--
	-- The binary and hexadecimal digits can be separated by
	-- underscore characters.
	--

	-- Convert a string of bits to std_logic_vector
	function lfsr_binary_string_to_polynomial (
		s : string) return std_logic_vector;

	-- Convert a string of hex digits to std_logic_vector (width w)
	function lfsr_hex_string_to_polynomial (
		s : string;
		w : integer) return std_logic_vector;

	-- Convert a tap string to std_logic_vector (width w)
	function lfsr_tap_string_to_polynomial (
		s : string;
		w : integer) return std_logic_vector;

	-- ------------------------------------------------------------
	-- PRBS sequence and word calculations
	-- ------------------------------------------------------------
	--
	-- These functions are used in testbenches to create and check
	-- PRBS sequences.
	--

	-- PRBS sequence
	--  * returns all (2**w-1)-bits of the sequence
	--  * uses the default polynomial lfsr_polynomial(w)
	function prbs_sequence (
		w : integer            -- LFSR width
	) return std_logic_vector;

	-- Create a vector of an LFSR sequence
	--  * user specified polynomial
	function prbs_sequence (
		w : integer;           -- LFSR width
		p : std_logic_vector   -- LFSR polynomial
	) return std_logic_vector;

	-- Given a PRBS sequence return the parallel word at the
	-- requested bit offset into the sequence
	function prbs_word (
		s : std_logic_vector; -- sequence
		b : integer;          -- bit offset into sequence
		w : integer           -- parallel output word width
	) return std_logic_vector;

end package;

-- ----------------------------------------------------------------

package body genetics_lfsr_pkg is

	-- ------------------------------------------------------------
	-- Default LFSR polynomials
	-- ------------------------------------------------------------
	--
	-- Return a primitive polynomial for a given LFSR width
	function lfsr_polynomial (
		w : integer) return std_logic_vector is
		variable v : std_logic_vector(w downto 0);
	begin
		assert ((w >= 2) and (w <= 100))
			report "Error: the LFSR width must be between 2 and 168"
			severity failure;

		-- Polynomials as defined in Table 8 in reference [4]
		--  * the table has entries for 2 to 168
		--  * the following has the entries for 2 to 100
		case w is
			when   2 => v:= lfsr_tap_string_to_polynomial("2,1",        w+1);
			when   3 => v:= lfsr_tap_string_to_polynomial("3,2",        w+1);
			when   4 => v:= lfsr_tap_string_to_polynomial("4,3",        w+1);
			when   5 => v:= lfsr_tap_string_to_polynomial("5,3",        w+1);
			when   6 => v:= lfsr_tap_string_to_polynomial("6,5",        w+1);
			when   7 => v:= lfsr_tap_string_to_polynomial("7,6",        w+1);
			when   8 => v:= lfsr_tap_string_to_polynomial("8,6,5,4",    w+1);
			when   9 => v:= lfsr_tap_string_to_polynomial("9,5",        w+1);
			--
			when  10 => v:= lfsr_tap_string_to_polynomial("10,7",       w+1);
			when  11 => v:= lfsr_tap_string_to_polynomial("11,9",       w+1);
			when  12 => v:= lfsr_tap_string_to_polynomial("12,6,4,1",   w+1);
			when  13 => v:= lfsr_tap_string_to_polynomial("13,4,3,1",   w+1);
			when  14 => v:= lfsr_tap_string_to_polynomial("14,5,3,1",   w+1);
			when  15 => v:= lfsr_tap_string_to_polynomial("15,14",      w+1);
			when  16 => v:= lfsr_tap_string_to_polynomial("16,15,13,4", w+1);
			when  17 => v:= lfsr_tap_string_to_polynomial("17,14",      w+1);
			when  18 => v:= lfsr_tap_string_to_polynomial("18,11",      w+1);
			when  19 => v:= lfsr_tap_string_to_polynomial("19,6,2,1",   w+1);
			--
			when  20 => v:= lfsr_tap_string_to_polynomial("20,17",       w+1);
			when  21 => v:= lfsr_tap_string_to_polynomial("21,19",       w+1);
			when  22 => v:= lfsr_tap_string_to_polynomial("22,21",       w+1);
			when  23 => v:= lfsr_tap_string_to_polynomial("23,18",       w+1);
			when  24 => v:= lfsr_tap_string_to_polynomial("24,23,22,17", w+1);
			when  25 => v:= lfsr_tap_string_to_polynomial("25,22",       w+1);
			when  26 => v:= lfsr_tap_string_to_polynomial("26,6,2,1",    w+1);
			when  27 => v:= lfsr_tap_string_to_polynomial("27,5,2,1",    w+1);
			when  28 => v:= lfsr_tap_string_to_polynomial("28,25",       w+1);
			when  29 => v:= lfsr_tap_string_to_polynomial("29,27",       w+1);
			--
			when  30 => v:= lfsr_tap_string_to_polynomial("30,6,4,1",    w+1);
			when  31 => v:= lfsr_tap_string_to_polynomial("31,28",       w+1);
			when  32 => v:= lfsr_tap_string_to_polynomial("32,22,2,1",   w+1);
			when  33 => v:= lfsr_tap_string_to_polynomial("33,20",       w+1);
			when  34 => v:= lfsr_tap_string_to_polynomial("34,27,2,1",   w+1);
			when  35 => v:= lfsr_tap_string_to_polynomial("35,33",       w+1);
			when  36 => v:= lfsr_tap_string_to_polynomial("36,25",       w+1);
			when  37 => v:= lfsr_tap_string_to_polynomial("37,5,4,3,2,1",w+1);
			when  38 => v:= lfsr_tap_string_to_polynomial("38,6,5,1",    w+1);
			when  39 => v:= lfsr_tap_string_to_polynomial("39,35",       w+1);
			--
			when  40 => v:= lfsr_tap_string_to_polynomial("40,38,21,19", w+1);
			when  41 => v:= lfsr_tap_string_to_polynomial("41,38",       w+1);
			when  42 => v:= lfsr_tap_string_to_polynomial("42,41,20,19", w+1);
			when  43 => v:= lfsr_tap_string_to_polynomial("43,42,38,37", w+1);
			when  44 => v:= lfsr_tap_string_to_polynomial("44,43,18,17", w+1);
			when  45 => v:= lfsr_tap_string_to_polynomial("45,44,42,41", w+1);
			when  46 => v:= lfsr_tap_string_to_polynomial("46,45,26,25", w+1);
			when  47 => v:= lfsr_tap_string_to_polynomial("47,42",       w+1);
			when  48 => v:= lfsr_tap_string_to_polynomial("48,47,21,20", w+1);
			when  49 => v:= lfsr_tap_string_to_polynomial("49,40",       w+1);
			--
			when  50 => v:= lfsr_tap_string_to_polynomial("50,49,24,23", w+1);
			when  51 => v:= lfsr_tap_string_to_polynomial("51,50,36,35", w+1);
			when  52 => v:= lfsr_tap_string_to_polynomial("52,49",       w+1);
			when  53 => v:= lfsr_tap_string_to_polynomial("53,52,38,37", w+1);
			when  54 => v:= lfsr_tap_string_to_polynomial("54,53,18,17", w+1);
			when  55 => v:= lfsr_tap_string_to_polynomial("55,31",       w+1);
			when  56 => v:= lfsr_tap_string_to_polynomial("56,55,35,34", w+1);
			when  57 => v:= lfsr_tap_string_to_polynomial("57,50",       w+1);
			when  58 => v:= lfsr_tap_string_to_polynomial("58,39",       w+1);
			when  59 => v:= lfsr_tap_string_to_polynomial("59,58,38,37", w+1);
			--
			when  60 => v:= lfsr_tap_string_to_polynomial("60,59",       w+1);
			when  61 => v:= lfsr_tap_string_to_polynomial("61,60,46,45", w+1);
			when  62 => v:= lfsr_tap_string_to_polynomial("62,61,6,5",   w+1);
			when  63 => v:= lfsr_tap_string_to_polynomial("63,62",       w+1);
			when  64 => v:= lfsr_tap_string_to_polynomial("64,63,61,60", w+1);
			when  65 => v:= lfsr_tap_string_to_polynomial("65,47",       w+1);
			when  66 => v:= lfsr_tap_string_to_polynomial("66,65,57,56", w+1);
			when  67 => v:= lfsr_tap_string_to_polynomial("67,66,58,57", w+1);
			when  68 => v:= lfsr_tap_string_to_polynomial("68,59",       w+1);
			when  69 => v:= lfsr_tap_string_to_polynomial("69,67,42,40", w+1);
			--
			when  70 => v:= lfsr_tap_string_to_polynomial("70,69,55,54", w+1);
			when  71 => v:= lfsr_tap_string_to_polynomial("71,65",       w+1);
			when  72 => v:= lfsr_tap_string_to_polynomial("72,66,25,19", w+1);
			when  73 => v:= lfsr_tap_string_to_polynomial("73,48",       w+1);
			when  74 => v:= lfsr_tap_string_to_polynomial("74,73,59,58", w+1);
			when  75 => v:= lfsr_tap_string_to_polynomial("75,74,65,64", w+1);
			when  76 => v:= lfsr_tap_string_to_polynomial("76,75,41,40", w+1);
			when  77 => v:= lfsr_tap_string_to_polynomial("77,76,47,46", w+1);
			when  78 => v:= lfsr_tap_string_to_polynomial("78,77,59,58", w+1);
			when  79 => v:= lfsr_tap_string_to_polynomial("79,70",       w+1);
			--
			when  80 => v:= lfsr_tap_string_to_polynomial("80,79,43,42", w+1);
			when  81 => v:= lfsr_tap_string_to_polynomial("81,77",       w+1);
			when  82 => v:= lfsr_tap_string_to_polynomial("82,79,47,44", w+1);
			when  83 => v:= lfsr_tap_string_to_polynomial("83,82,38,37", w+1);
			when  84 => v:= lfsr_tap_string_to_polynomial("84,71",       w+1);
			when  85 => v:= lfsr_tap_string_to_polynomial("85,84,58,57", w+1);
			when  86 => v:= lfsr_tap_string_to_polynomial("86,85,74,73", w+1);
			when  87 => v:= lfsr_tap_string_to_polynomial("87,74",       w+1);
			when  88 => v:= lfsr_tap_string_to_polynomial("88,87,17,16", w+1);
			when  89 => v:= lfsr_tap_string_to_polynomial("89,51",       w+1);
			--
			when  90 => v:= lfsr_tap_string_to_polynomial("90,89,72,71", w+1);
			when  91 => v:= lfsr_tap_string_to_polynomial("91,90,8,7",   w+1);
			when  92 => v:= lfsr_tap_string_to_polynomial("92,91,80,79", w+1);
			when  93 => v:= lfsr_tap_string_to_polynomial("93,91",       w+1);
			when  94 => v:= lfsr_tap_string_to_polynomial("94,73",       w+1);
			when  95 => v:= lfsr_tap_string_to_polynomial("95,84",       w+1);
			when  96 => v:= lfsr_tap_string_to_polynomial("96,94,49,47", w+1);
			when  97 => v:= lfsr_tap_string_to_polynomial("97,91",       w+1);
			when  98 => v:= lfsr_tap_string_to_polynomial("98,87",       w+1);
			when  99 => v:= lfsr_tap_string_to_polynomial("99,97,54,52", w+1);
			--
			when 100 => v:= lfsr_tap_string_to_polynomial("100,63",      w+1);
			--
			when others =>
				null;
		end case;
		return v;
	end function;

	-- ------------------------------------------------------------
	-- LFSR polynomial conversion functions
	-- ------------------------------------------------------------
	--
	-- Convert a string of bits to std_logic_vector
	function lfsr_binary_string_to_polynomial (
		s : string) return std_logic_vector is
		constant w : integer := s'length;
		variable v : std_logic_vector(w-1 downto 0);
		variable n : integer;
	begin
		n := 0;
		for i in 0 to w-1 loop
			--
			-- Parse for '0', '1', '_', and invalid characters.
			--
			-- The string is parsed from high (the right-most
			-- or least-significant bit) to low (the left-most
			-- or most-significant bit).
			--
			case s(s'high-i) is
				when '0' =>
					v(n) := '0';
					n := n + 1;
				when '1' =>
					v(n) := '1';
					n := n + 1;
				when '_' =>
					null;
				when others =>
					assert false
						report "Error: invalid LFSR polynomial"
						severity failure;
			end case;

		end loop;

		-- Return the valid bits
		return v(n-1 downto 0);
	end function;

	-- Convert a string of hex digits to std_logic_vector (width w)
	function lfsr_hex_string_to_polynomial (
		s : string;
		w : integer) return std_logic_vector is
		constant m : integer := s'length;
		variable v : std_logic_vector(4*m-1 downto 0);
		variable n : integer;
	begin
		n := 0;
		for i in 0 to m-1 loop
			--
			-- Parse for '0' to 'F', '_', and invalid characters.
			--
			-- The string is parsed from high (the right-most
			-- or least-significant bit) to low (the left-most
			-- or most-significant bit).
			--
			case s(s'high-i) is
				when '0' =>
					v(4*(n+1)-1 downto 4*n) := X"0";
					n := n + 1;
				when '1' =>
					v(4*(n+1)-1 downto 4*n) := X"1";
					n := n + 1;
				when '2' =>
					v(4*(n+1)-1 downto 4*n) := X"2";
					n := n + 1;
				when '3' =>
					v(4*(n+1)-1 downto 4*n) := X"3";
					n := n + 1;
				when '4' =>
					v(4*(n+1)-1 downto 4*n) := X"4";
					n := n + 1;
				when '5' =>
					v(4*(n+1)-1 downto 4*n) := X"5";
					n := n + 1;
				when '6' =>
					v(4*(n+1)-1 downto 4*n) := X"6";
					n := n + 1;
				when '7' =>
					v(4*(n+1)-1 downto 4*n) := X"7";
					n := n + 1;
				when '8' =>
					v(4*(n+1)-1 downto 4*n) := X"8";
					n := n + 1;
				when '9' =>
					v(4*(n+1)-1 downto 4*n) := X"9";
					n := n + 1;
				when 'A' =>
					v(4*(n+1)-1 downto 4*n) := X"A";
					n := n + 1;
				when 'B' =>
					v(4*(n+1)-1 downto 4*n) := X"B";
					n := n + 1;
				when 'C' =>
					v(4*(n+1)-1 downto 4*n) := X"C";
					n := n + 1;
				when 'D' =>
					v(4*(n+1)-1 downto 4*n) := X"D";
					n := n + 1;
				when 'E' =>
					v(4*(n+1)-1 downto 4*n) := X"E";
					n := n + 1;
				when 'F' =>
					v(4*(n+1)-1 downto 4*n) := X"F";
					n := n + 1;
				when '_' =>
					null;
				when others =>
					assert false
						report "Error: invalid LFSR polynomial"
						severity failure;
			end case;
		end loop;

		-- Return the valid bits
		return v(w-1 downto 0);
	end function;

	-- Convert a tap string to std_logic_vector (width w)
	function lfsr_tap_string_to_polynomial (
		s : string;
		w : integer) return std_logic_vector is
		variable v : std_logic_vector(w-1 downto 0);
		variable t : integer;
	begin
		-- Set all bits to zero
		v := (others => '0');

		-- Bit 0 is always set
		v(0) := '1';

		-- Parse the taps string, eg. [7,6] or T[7,6]
		-- and set bits to one at the tap indices
		--
		t := 0;
		for i in s'low to s'high loop
			if (s(i) >= '0') and (s(i) <= '9') then
				-- When a digit is detected, convert it to
				-- an integer tap until a non-digit is detected
				t := t*10 + (character'pos(s(i)) - character'pos('0'));
			else
				-- If the tap value is non-zero, then set that bit
				if (t /= 0) then
					assert t < w
						report "Error: invalid LFSR tap value"
						severity failure;
					v(t) := '1';
					t := 0;
				end if;
			end if;
		end loop;

		-- If the tap value is non-zero, then set that bit
		if (t /= 0) then
			assert t < w
				report "Error: invalid LFSR tap value"
				severity failure;
			v(t) := '1';
		end if;

		return v;
	end function;

	-- ------------------------------------------------------------
	-- PRBS sequence and word calculations
	-- ------------------------------------------------------------
	--
	-- PRBS sequence
	--  * returns all (2**w-1)-bits of the sequence
	--  * uses the default polynomial lfsr_polynomial(w)
	function prbs_sequence (
		w : integer
	) return std_logic_vector is
	begin
		return prbs_sequence(w,lfsr_polynomial(w));
	end function;

	-- Create a vector of an LFSR sequence
	--  * user specified polynomial
	function prbs_sequence (
		w : integer;
		p : std_logic_vector
	) return std_logic_vector is
		variable s : std_logic_vector(2**w-2 downto 0);
		variable r : std_logic_vector(w-1 downto 0)
			:= (others => '1');
		variable f : std_logic;
	begin
		-- PRBS calculation:
		--
		--  * LFSR using Fibonacci form
		--  * XOR feedback
		--  * Left-shifting shift-register with the PRBS
		--    output from the MSB and feedback into the LSB.
		--  * All ones initial seed
		--
		for i in 0 to 2**w-2 loop

			-- PRBS output (MSB)
			s(i) := r(w-1);

			-- Feedback (LSB)
			-- * calculate the XOR sum at the feedback taps
			-- * the loop uses p(j+1), so the feedback tap
			--   is not included in the XOR sum
			f := '0';
			for j in 0 to w-1 loop
				if p(j+1) = '1' then
					f := f xor r(j);
				end if;
			end loop;

			-- Update the LFSR state
			r := r(w-2 downto 0) & f;

		end loop;
		return s;
	end function;

	-- Given a PRBS sequence return the parallel word at the
	-- requested bit offset into the sequence
	function prbs_word (
		s : std_logic_vector;
		b : integer;
		w : integer
	) return std_logic_vector is
		-- Sequence length
		constant l : integer := s'length;
		-- Increase the sequence length by (w-1)-bits
		-- (repeating bits from the start of the sequence)
		constant d : std_logic_vector(w+l-1 downto 0) :=
			s(w-1 downto 0) & s;
		-- Offset into the requested data in the sequence
		-- modulo the sequence length
		constant i : integer := b mod l;
	begin
		-- Return the w-bits from the sequence
		return d(i+w-1 downto i);
	end function;

end package body;
