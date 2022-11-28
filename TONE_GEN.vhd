LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

LIBRARY ALTERA_MF;
USE ALTERA_MF.ALTERA_MF_COMPONENTS.ALL;

ENTITY TONE_GEN_DEMO IS 
   PORT
   (
      CMD       		: IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
      CS         		: IN  STD_LOGIC;
      SAMPLE_CLK 		: IN  STD_LOGIC;
		ROM_CLK	  		: IN  STD_LOGIC; -- Faster clock to switch channels in between samples
      RESETN     		: IN  STD_LOGIC;
		WF_TOGGLE		: IN 	STD_LOGIC;
      L_DATA     		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      R_DATA     		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		INDICATOR		: OUT STD_LOGIC
   );
END TONE_GEN_DEMO;

ARCHITECTURE gen OF TONE_GEN_DEMO IS 
	Type waveform is (
		first,
		second,
		third,
		fourth
	);
	
   Type playingStatus IS (
      playingNote,
      notPlayingNote
   );
	
	SIGNAL waveform_current			: waveform;
	
   SIGNAL phase_register_current	: STD_LOGIC_VECTOR(16 DOWNTO 0);
	SIGNAL phase_register_L			: STD_LOGIC_VECTOR(16 DOWNTO 0);
	SIGNAL phase_register_R			: STD_LOGIC_VECTOR(16 DOWNTO 0);
   SIGNAL tuning_word_current 	: STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL tuning_word_L 			: STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL tuning_word_R 			: STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL sounddata_current   	: STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL sounddata_L		   	: STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL sounddata_R		   	: STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL playing_current        : playingStatus;
   SIGNAL playing_L        		: playingStatus;
   SIGNAL playing_R        		: playingStatus;
	SIGNAL LR_toggle					: STD_LOGIC;
   
	-- Select section of ROM file
	SIGNAL offset						: STD_LOGIC_VECTOR(16 DOWNTO 0);
	CONSTANT SINE_OFFSET		 		: STD_LOGIC_VECTOR(16 DOWNTO 0) := "00000000000000000";
	CONSTANT SQUARE_OFFSET   		: STD_LOGIC_VECTOR(16 DOWNTO 0) := "00111111111111100";
	CONSTANT TRIANGLE_OFFSET 		: STD_LOGIC_VECTOR(16 DOWNTO 0) := "01111111111111000";
	CONSTANT SAWTOOTH_OFFSET 		: STD_LOGIC_VECTOR(16 DOWNTO 0) := "10111111111010100";
   
BEGIN
   -- ROM to hold the waveform
   SOUND_LUT : altsyncram
   GENERIC MAP (
		init_file => "SOUND_WAVEFORM_13_BIT.mif",
      lpm_type => "altsyncram",
      width_a => 12,
      widthad_a => 15,
      numwords_a => 32768,
      intended_device_family => "Cyclone II",
      lpm_hint => "ENABLE_RUNTIME_MOD=NO",
      operation_mode => "ROM",
      outdata_aclr_a => "NONE",
      outdata_reg_a => "UNREGISTERED",
      power_up_uninitialized => "FALSE"
   )
	
   PORT MAP (
      clock0 => NOT(ROM_CLK),
      -- In this design, 2 bits of the phase register are fractional bits
      address_a => phase_register_current(16 DOWNTO 2),
      q_a => sounddata_current -- output is amplitude
   );
   
   -- 10-bit sound data is used as bits 12-3 of the 16-bit output.
   -- This is to prevent the output from being too loud.
   L_DATA(15 DOWNTO 13) <= sounddata_L(11)&sounddata_L(11)&sounddata_L(11); -- sign extend
   L_DATA(12 DOWNTO 1) <= sounddata_L;
   L_DATA(0 DOWNTO 0) <= "0"; -- pad right side with 0s
   
   -- Right channel is the same.
   R_DATA(15 DOWNTO 13) <= sounddata_R(11)&sounddata_R(11)&sounddata_R(11); -- sign extend
   R_DATA(12 DOWNTO 1) <= sounddata_R;
   R_DATA(0 DOWNTO 0) <= "0"; -- pad right side with 0s
   
	-- process to switch between multiple channels
	
	PROCESS(WF_TOGGLE) BEGIN
		IF FALLING_EDGE(WF_TOGGLE) THEN
			CASE waveform_current IS
					WHEN first =>
						waveform_current <= second;
						offset <= SQUARE_OFFSET;
					WHEN second =>
						waveform_current <= third;
						offset <= TRIANGLE_OFFSET;
					WHEN third =>
						waveform_current <= fourth;
						offset <= SAWTOOTH_OFFSET;
					WHEN fourth =>
						waveform_current <= first;
						offset <= SINE_OFFSET;
				END CASE;	
		END IF;
	END PROCESS;
	
	PROCESS(ROM_CLK) BEGIN
      IF RISING_EDGE(ROM_CLK) THEN
			IF LR_toggle = '1' THEN
				LR_toggle <= '0';
				
				-- read right from ROM, load left into ROM
				sounddata_R <= sounddata_current;
				sounddata_L <= sounddata_L;
				
				phase_register_current <= phase_register_L + offset;
				
			ELSE
				LR_toggle <= '1';
				
				-- read left from ROM, load right into ROM
				sounddata_L <= sounddata_current;
				sounddata_R <= sounddata_R;
				
				phase_register_current <= phase_register_R + offset;
			END IF;
      END IF;
   END PROCESS;
	
   -- process to perform DDS
   PROCESS(RESETN, SAMPLE_CLK) BEGIN
		INDICATOR <= not(WF_TOGGLE)
		
      IF RESETN = '0' THEN
         phase_register_L <= "00000000000000000";
			phase_register_R <= "00000000000000000";
      ELSIF RISING_EDGE(SAMPLE_CLK) THEN
         IF playing_L = playingNote THEN
				CASE waveform_current IS
					WHEN first =>
						IF (phase_register_L + ("00000" & tuning_word_L)) > "00111111111111011" THEN
							phase_register_L <= phase_register_L + ("00000" & tuning_word_L) - "00111111111111100";
						ELSE
							phase_register_L <= phase_register_L + ("00000" & tuning_word_L);
						END IF;
					WHEN second =>
						IF (phase_register_L + ("00000" & tuning_word_L)) > "01111111111110111" THEN
							phase_register_L <= phase_register_L + ("00000" & tuning_word_L) - "00111111111111100";
						ELSE
							phase_register_L <= phase_register_L + ("00000" & tuning_word_L);
						END IF;
					WHEN third =>
						IF (phase_register_L + ("00000" & tuning_word_L)) > "10111111111010011" THEN
							phase_register_L <= phase_register_L + ("00000" & tuning_word_L) - "00111111111111100";
						ELSE
							phase_register_L <= phase_register_L + ("00000" & tuning_word_L);
						END IF;
					WHEN fourth =>
						IF (phase_register_L + ("00000" & tuning_word_L)) < "10111111111010100" THEN
							phase_register_L <= phase_register_L + ("00000" & tuning_word_L) - "00111111111111100";
						ELSE
							phase_register_L <= phase_register_L + ("00000" & tuning_word_L);
						END IF;
					END CASE;
         ELSE
            phase_register_L <= "00000000000000000";
         END IF;
			IF playing_R = playingNote THEN
				CASE waveform_current IS
					WHEN first =>
						IF (phase_register_R + ("00000" & tuning_word_L)) > "00111111111111011" THEN
							phase_register_R <= phase_register_R + ("00000" & tuning_word_R) - "00111111111111100";
						ELSE
							phase_register_R <= phase_register_R + ("00000" & tuning_word_R);
						END IF;
					WHEN second =>
						IF (phase_register_R + ("00000" & tuning_word_L)) > "01111111111110111" THEN
							phase_register_R <= phase_register_R + ("00000" & tuning_word_R) - "00111111111111100";
						ELSE
							phase_register_R <= phase_register_R + ("00000" & tuning_word_R);
						END IF;
					WHEN third =>
						IF (phase_register_R + ("00000" & tuning_word_L)) > "10111111111010011" THEN
							phase_register_R <= phase_register_R + ("00000" & tuning_word_R) - "00111111111111100";
						ELSE
							phase_register_R <= phase_register_R + ("00000" & tuning_word_R);
						END IF;
					WHEN fourth =>
						IF (phase_register_R + ("00000" & tuning_word_L)) < "10111111111010100" THEN
							phase_register_R <= phase_register_R + ("00000" & tuning_word_R) - "00111111111111100";
						ELSE
							phase_register_R <= phase_register_R + ("00000" & tuning_word_R);
						END IF;
					END CASE;
         ELSE
            phase_register_R <= "00000000000000000";
         END IF;
      END IF;
   END PROCESS;

   -- process to latch command data from SCOMP
   PROCESS(RESETN, CS) BEGIN
      IF RESETN = '0' THEN
         tuning_word_L <= "000000000000";
			tuning_word_R <= "000000000000";
      ELSIF RISING_EDGE(CS) THEN
         CASE CMD(9 DOWNTO 7) IS
            WHEN "001" => -- Octave 2
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "0000110" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001000111"; -- Start of Octave 2, G#2/Ab2
                  WHEN "0000010" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001001011"; -- A2
                  WHEN "0000011" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001010000"; -- A#2/Bb2
                  WHEN "0000001" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001010100"; -- B2
                  WHEN OTHERS =>
                     playing_current <= notPlayingNote;
               END CASE;
            WHEN "010" => -- Octave 3
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001011001"; -- Start of Octave 3, C3
                  WHEN "1100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001011111"; -- C#3/Db3
                  WHEN "0100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001100100"; -- D3
                  WHEN "0110000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001101010"; -- D#3/Eb3
                  WHEN "0010000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001110001"; -- E3
                  WHEN "0001000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001110111"; -- F3
                  WHEN "0001100" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000001111110"; -- F#3/Gb3
                  WHEN "0000100" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000010000110"; -- G3
                  WHEN "0000110" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000010001110"; -- G#3/Ab3
                  WHEN "0000010" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000010010110"; -- A3
                  WHEN "0000011" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000010011111"; -- A#3/Bb3
                  WHEN "0000001" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000010101001"; -- B3
                  WHEN OTHERS =>
                     playing_current <= notPlayingNote;
               END CASE;
            WHEN "011" => -- Octave 4
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000010110011"; -- C4
                  WHEN "1100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000010111101"; -- C#4/Db4
                  WHEN "0100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000011001000"; -- D4
                  WHEN "0110000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000011010100"; -- D#4/Eb4
                  WHEN "0010000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000011100001"; -- E4
                  WHEN "0001000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000011101110"; -- F4
                  WHEN "0001100" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000011111101"; -- F#4/Gb4
                  WHEN "0000100" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000100001100"; -- G4
                  WHEN "0000110" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000100011100"; -- G#4/Ab4
                  WHEN "0000010" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000100101100"; -- A4
                  WHEN "0000011" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000100111110"; -- A#4/Bb4
                  WHEN "0000001" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000101010001"; -- B4
                  WHEN OTHERS =>
                     playing_current <= notPlayingNote;
               END CASE;
            WHEN "100" => -- Octave 5
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000101100101"; -- C5
                  WHEN "1100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000101111010"; -- C#5/Db5
                  WHEN "0100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000110010001"; -- D5
                  WHEN "0110000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000110101001"; -- D#5/Eb5
                  WHEN "0010000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000111000010"; -- E5
                  WHEN "0001000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000111011101"; -- F5
                  WHEN "0001100" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "000111111001"; -- F#5/Gb5
                  WHEN "0000100" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001000010111"; -- G5
                  WHEN "0000110" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001000110111"; -- G#5/Ab5
                  WHEN "0000010" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001001011001"; -- A5
                  WHEN "0000011" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001001111100"; -- A#5/Bb5
                  WHEN "0000001" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001010100010"; -- B5
                  WHEN OTHERS =>
                     playing_current <= notPlayingNote;
               END CASE;
            WHEN "101" => -- Octave 6
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001011001010"; -- C6
                  WHEN "1100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001011110101"; -- C#6/Db6
                  WHEN "0100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001100100010"; -- D6
                  WHEN "0110000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001101010010"; -- D#6/Eb6
                  WHEN "0010000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001110000100"; -- E6
                  WHEN "0001000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001110111010"; -- F6
                  WHEN "0001100" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "001111110010"; -- F#6/Gb6
                  WHEN "0000100" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "010000101110"; -- G6
                  WHEN "0000110" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "010001101110"; -- G#6/Ab6
                  WHEN "0000010" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "010010110001"; -- A6
                  WHEN "0000011" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "010011111001"; -- A#6/Bb6
                  WHEN "0000001" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "010101000101"; -- B6
                  WHEN OTHERS =>
                     playing_current <= notPlayingNote;
               END CASE;   
            WHEN "110" => -- Octave 7
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "010110010101"; -- C7
                  WHEN "1100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "010111101010"; -- C#7/Db7
                  WHEN "0100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "011001000100"; -- D7
                  WHEN "0110000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "011010100011"; -- D#7/Eb7
                  WHEN "0010000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "011100001000"; -- E7
                  WHEN "0001000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "011101110011"; -- F7
                  WHEN "0001100" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "011111100101"; -- F#7/Gb7
                  WHEN "0000100" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "100001011101"; -- G7
                  WHEN "0000110" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "100011011100"; -- G#7/Ab7
                  WHEN "0000010" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "100101100011"; -- A7
                  WHEN "0000011" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "100111110010"; -- A#7/Bb7
                  WHEN "0000001" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "101010001001"; -- B7
                  WHEN OTHERS =>
                     playing_current <= notPlayingNote;
               END CASE;
            WHEN "111" => -- Octave 8
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "101100101010"; -- C8
                  WHEN "1100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "101111010100"; -- C#8/Db8
                  WHEN "0100000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "110010001000"; -- D8
                  WHEN "0110000" =>
                     playing_current <= playingNote;
                     tuning_word_current <= "110101000110"; -- D#8/Eb8
                  WHEN OTHERS =>
                     playing_current <= notPlayingNote; 
               END CASE;
        -- All 68 equal-tempered notes from 100 Hz to 5 kHz are implemented above
            WHEN OTHERS =>
               playing_current <= notPlayingNote;
         END CASE;
		ELSIF FALLING_EDGE(CS) THEN
			IF CMD(15) = '1' THEN
				playing_L <= playing_current;
				playing_R <= playing_R;
				tuning_word_L <= tuning_word_current;
				tuning_word_R <= tuning_word_R;
			ELSE
				playing_R <= playing_current;
				playing_L <= playing_L;
				tuning_word_R <= tuning_word_current;
				tuning_word_L <= tuning_word_L;
			END IF;
		END IF;
   END PROCESS;
END gen;
