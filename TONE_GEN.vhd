-- Simple DDS tone generator.
-- 5-bit tuning word
-- 9-bit phase register
-- 256 x 8-bit ROM.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY ALTERA_MF;
USE ALTERA_MF.ALTERA_MF_COMPONENTS.ALL;


ENTITY TONE_GEN IS 
	PORT
	(
		CMD        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		CS         : IN  STD_LOGIC;
		SAMPLE_CLK : IN  STD_LOGIC;
		RESETN     : IN  STD_LOGIC;
		L_DATA     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		R_DATA     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END TONE_GEN;

ARCHITECTURE gen OF TONE_GEN IS 

	TYPE octaveType IS (
		Two,
		Three,
		Four,
		Five,
		Six,
		Seven,
		Eight
	);
	
	Type playingStatus IS (
		playingNote,
		notPlayingNote
	);

	SIGNAL phase_register : STD_LOGIC_VECTOR(14 DOWNTO 0);
	SIGNAL tuning_word    : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL sounddata      : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL octave         : octaveType;
	SIGNAL playing        : playingStatus;
	
	
	
BEGIN

	-- ROM to hold the waveform
	SOUND_LUT : altsyncram
	GENERIC MAP (
		lpm_type => "altsyncram",
		width_a => 8,
		widthad_a => 8,
		numwords_a => 256,
		init_file => "SOUND_SINE.mif",
		intended_device_family => "Cyclone II",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		power_up_uninitialized => "FALSE"
	)
	PORT MAP (
		clock0 => NOT(SAMPLE_CLK),
		-- In this design, one bit of the phase register is a fractional bit
		address_a => phase_register(14 downto 1),
		q_a => sounddata -- output is amplitude
	);
	
	-- 8-bit sound data is used as bits 12-5 of the 16-bit output.
	-- This is to prevent the output from being too loud.
	L_DATA(15 DOWNTO 13) <= sounddata(7)&sounddata(7)&sounddata(7); -- sign extend
	L_DATA(12 DOWNTO 5) <= sounddata;
	L_DATA(4 DOWNTO 0) <= "00000"; -- pad right side with 0s
	
	-- Right channel is the same.
	R_DATA(15 DOWNTO 13) <= sounddata(7)&sounddata(7)&sounddata(7); -- sign extend
	R_DATA(12 DOWNTO 5) <= sounddata;
	R_DATA(4 DOWNTO 0) <= "00000"; -- pad right side with 0s
	
	-- process to perform DDS
	PROCESS(RESETN, SAMPLE_CLK) BEGIN
		IF RESETN = '0' THEN
			phase_register <= "000000000000000";
		ELSIF RISING_EDGE(SAMPLE_CLK) THEN
			IF playing = playingNote THEN
				phase_register <= phase_register + ("000" & tuning_word);
			ELSE
				phase_register <= "000000000000000";
			END IF;
		END IF;
	END PROCESS;

	-- process to latch command data from SCOMP
	PROCESS(RESETN, CS) BEGIN
		IF RESETN = '0' THEN
			tuning_word <= "000000";
		ELSIF RISING_EDGE(CS) THEN
			IF CMD(6 DOWNTO 0) = "0000001" THEN
				playing <= playingNote;
				tuning_word <= "000001000111"; -- Start of Octave 2, G#2/Ab2
			ELSIF CMD(6 DOWNTO 0) = "0000010" THEN
				playing <= playingNote;
				tuning_word <= "000001001011"; -- A2
			ELSIF CMD(6 DOWNTO 0) = "0000011" THEN
				playing <= playingNote;
				tuning_word <= "000001010000"; -- A#2/Bb2
			ELSIF CMD(6 DOWNTO 0) = "0000100" THEN
				playing <= playingNote;
				tuning_word <= "000001010100"; -- B2
			ELSIF CMD(6 DOWNTO 0) = "0000101" THEN
				playing <= playingNote;
				tuning_word <= "000001011001"; -- Start of Octave 3, C3
			ELSIF CMD(6 DOWNTO 0) = "0000110" THEN
				playing <= playingNote;
				tuning_word <= "000001011111"; -- C#3/Db3
			ELSIF CMD(6 DOWNTO 0) = "0000111" THEN
				playing <= playingNote;
				tuning_word <= "000001100100"; -- D3
			ELSIF CMD(6 DOWNTO 0) = "0001000" THEN
				playing <= playingNote;
				tuning_word <= "000001101010"; -- D#3/Eb3
			ELSIF CMD(6 DOWNTO 0) = "0001001" THEN
				playing <= playingNote;
				tuning_word <= "000001110001"; -- E3
			ELSIF CMD(6 DOWNTO 0) = "0001010" THEN
				playing <= playingNote;
				tuning_word <= "000001110111"; -- F3
			ELSIF CMD(6 DOWNTO 0) = "0001011" THEN
				playing <= playingNote;
				tuning_word <= "000001111110"; -- F#3/Gb3
			ELSIF CMD(6 DOWNTO 0) = "0001100" THEN
				playing <= playingNote;
				tuning_word <= "000010000110"; -- G3
				

			-- TODO	
			ELSIF CMD(7 DOWNTO 0) = "00000100" THEN
				playing <= playingNote;
				tuning_word <= "000100";
			ELSIF CMD(7 DOWNTO 0) = "00001000" THEN
				playing <= playingNote;
				tuning_word <= "001000";
			ELSIF CMD(7 DOWNTO 0) = "00010000" THEN
				playing <= playingNote;
				tuning_word <= "010000";
			ELSIF CMD(7 DOWNTO 0) = "00100000" THEN
				playing <= playingNote;
				tuning_word <= "100000";
			ELSIF CMD(7 DOWNTO 0) = "01000000" THEN
				playing <= playingNote;
				tuning_word <= "100010";
			ELSIF CMD(7 DOWNTO 0) = "10000000" THEN
				playing <= playingNote;
				tuning_word <= "100110";
			ELSE
				playing <= notPlayingNote;
			END IF;
		END IF;
	END PROCESS;
END gen;
