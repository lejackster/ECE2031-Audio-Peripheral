
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
   
   Type playingStatus IS (
      playingNote,
      notPlayingNote
   );

   SIGNAL phase_register : STD_LOGIC_VECTOR(14 DOWNTO 0);
   SIGNAL tuning_word    : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL sounddata      : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL playing        : playingStatus;
   
   
   
BEGIN

   -- ROM to hold the waveform
   SOUND_LUT : altsyncram
   GENERIC MAP (
      lpm_type => "altsyncram",
      width_a => 12,
      widthad_a => 13,
      numwords_a => 8192,
      init_file => "SOUND_SINE_13_BIT.mif",
      intended_device_family => "Cyclone II",
      lpm_hint => "ENABLE_RUNTIME_MOD=NO",
      operation_mode => "ROM",
      outdata_aclr_a => "NONE",
      outdata_reg_a => "UNREGISTERED",
      power_up_uninitialized => "FALSE"
   )
   PORT MAP (
      clock0 => NOT(SAMPLE_CLK),
      -- In this design, 2 bits of the phase register are fractional bits
      address_a => phase_register(14 DOWNTO 2),
      q_a => sounddata -- output is amplitude
   );
   
   -- 10-bit sound data is used as bits 12-3 of the 16-bit output.
   -- This is to prevent the output from being too loud.
   L_DATA(15 DOWNTO 13) <= sounddata(11)&sounddata(11)&sounddata(11); -- sign extend
   L_DATA(12 DOWNTO 1) <= sounddata;
   L_DATA(0 DOWNTO 0) <= "0"; -- pad right side with 0s
   
   -- Right channel is the same.
   R_DATA(15 DOWNTO 13) <= sounddata(11)&sounddata(11)&sounddata(11); -- sign extend
   R_DATA(12 DOWNTO 1) <= sounddata;
   R_DATA(0 DOWNTO 0) <= "0"; -- pad right side with 0s
   
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
         tuning_word <= "000000000000";
      ELSIF RISING_EDGE(CS) THEN
         CASE CMD(10 DOWNTO 7) IS
            WHEN "0010" => -- Octave 2
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "0000110" =>
                     playing <= playingNote;
                     tuning_word <= "000001000111"; -- Start of Octave 2, G#2/Ab2
                  WHEN "0000010" =>
                     playing <= playingNote;
                     tuning_word <= "000001001011"; -- A2
                  WHEN "0000011" =>
                     playing <= playingNote;
                     tuning_word <= "000001010000"; -- A#2/Bb2
                  WHEN "0000001" =>
                     playing <= playingNote;
                     tuning_word <= "000001010100"; -- B2
                  WHEN OTHERS =>
                     playing <= notPlayingNote;
               END CASE;
            WHEN "0011" => -- Octave 3
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing <= playingNote;
                     tuning_word <= "000001011001"; -- Start of Octave 3, C3
                  WHEN "1100000" =>
                     playing <= playingNote;
                     tuning_word <= "000001011111"; -- C#3/Db3
                  WHEN "0100000" =>
                     playing <= playingNote;
                     tuning_word <= "000001100100"; -- D3
                  WHEN "0110000" =>
                     playing <= playingNote;
                     tuning_word <= "000001101010"; -- D#3/Eb3
                  WHEN "0010000" =>
                     playing <= playingNote;
                     tuning_word <= "000001110001"; -- E3
                  WHEN "0001000" =>
                     playing <= playingNote;
                     tuning_word <= "000001110111"; -- F3
                  WHEN "0001100" =>
                     playing <= playingNote;
                     tuning_word <= "000001111110"; -- F#3/Gb3
                  WHEN "0000100" =>
                     playing <= playingNote;
                     tuning_word <= "000010000110"; -- G3
                  WHEN "0000110" =>
                     playing <= playingNote;
                     tuning_word <= "000010001110"; -- G#3/Ab3
                  WHEN "0000010" =>
                     playing <= playingNote;
                     tuning_word <= "000010010110"; -- A3
                  WHEN "0000011" =>
                     playing <= playingNote;
                     tuning_word <= "000010011111"; -- A#3/Bb3
                  WHEN "0000001" =>
                     playing <= playingNote;
                     tuning_word <= "000010101001"; -- B3
                  WHEN OTHERS =>
                     playing <= notPlayingNote;
               END CASE;
            WHEN "0100" => -- Octave 4
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing <= playingNote;
                     tuning_word <= "000010110011"; -- C4
                  WHEN "1100000" =>
                     playing <= playingNote;
                     tuning_word <= "000010111101"; -- C#4/Db4
                  WHEN "0100000" =>
                     playing <= playingNote;
                     tuning_word <= "000011001000"; -- D4
                  WHEN "0110000" =>
                     playing <= playingNote;
                     tuning_word <= "000011010100"; -- D#4/Eb4
                  WHEN "0010000" =>
                     playing <= playingNote;
                     tuning_word <= "000011100001"; -- E4
                  WHEN "0001000" =>
                     playing <= playingNote;
                     tuning_word <= "000011101110"; -- F4
                  WHEN "0001100" =>
                     playing <= playingNote;
                     tuning_word <= "000011111101"; -- F#4/Gb4
                  WHEN "0000100" =>
                     playing <= playingNote;
                     tuning_word <= "000100001100"; -- G4
                  WHEN "0000110" =>
                     playing <= playingNote;
                     tuning_word <= "000100011100"; -- G#4/Ab4
                  WHEN "0000010" =>
                     playing <= playingNote;
                     tuning_word <= "000100101100"; -- A4
                  WHEN "0000011" =>
                     playing <= playingNote;
                     tuning_word <= "000100111110"; -- A#4/Bb4
                  WHEN "0000001" =>
                     playing <= playingNote;
                     tuning_word <= "000101010001"; -- B4
                  WHEN OTHERS =>
                     playing <= notPlayingNote;
               END CASE;
            WHEN "0101" => -- Octave 5
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing <= playingNote;
                     tuning_word <= "000101100101"; -- C5
                  WHEN "1100000" =>
                     playing <= playingNote;
                     tuning_word <= "000101111010"; -- C#5/Db5
                  WHEN "0100000" =>
                     playing <= playingNote;
                     tuning_word <= "000110010001"; -- D5
                  WHEN "0110000" =>
                     playing <= playingNote;
                     tuning_word <= "000110101001"; -- D#5/Eb5
                  WHEN "0010000" =>
                     playing <= playingNote;
                     tuning_word <= "000111000010"; -- E5
                  WHEN "0001000" =>
                     playing <= playingNote;
                     tuning_word <= "000111011101"; -- F5
                  WHEN "0001100" =>
                     playing <= playingNote;
                     tuning_word <= "000111111001"; -- F#5/Gb5
                  WHEN "0000100" =>
                     playing <= playingNote;
                     tuning_word <= "001000010111"; -- G5
                  WHEN "0000110" =>
                     playing <= playingNote;
                     tuning_word <= "001000110111"; -- G#5/Ab5
                  WHEN "0000010" =>
                     playing <= playingNote;
                     tuning_word <= "001001011001"; -- A5
                  WHEN "0000011" =>
                     playing <= playingNote;
                     tuning_word <= "001001111100"; -- A#5/Bb5
                  WHEN "0000001" =>
                     playing <= playingNote;
                     tuning_word <= "001010100010"; -- B5
                  WHEN OTHERS =>
                     playing <= notPlayingNote;
               END CASE;
            WHEN "0110" => -- Octave 6
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing <= playingNote;
                     tuning_word <= "001011001010"; -- C6
                  WHEN "1100000" =>
                     playing <= playingNote;
                     tuning_word <= "001011110101"; -- C#6/Db6
                  WHEN "0100000" =>
                     playing <= playingNote;
                     tuning_word <= "001100100010"; -- D6
                  WHEN "0110000" =>
                     playing <= playingNote;
                     tuning_word <= "001101010010"; -- D#6/Eb6
                  WHEN "0010000" =>
                     playing <= playingNote;
                     tuning_word <= "001110000100"; -- E6
                  WHEN "0001000" =>
                     playing <= playingNote;
                     tuning_word <= "001110111010"; -- F6
                  WHEN "0001100" =>
                     playing <= playingNote;
                     tuning_word <= "001111110010"; -- F#6/Gb6
                  WHEN "0000100" =>
                     playing <= playingNote;
                     tuning_word <= "010000101110"; -- G6
                  WHEN "0000110" =>
                     playing <= playingNote;
                     tuning_word <= "010001101110"; -- G#6/Ab6
                  WHEN "0000010" =>
                     playing <= playingNote;
                     tuning_word <= "010010110001"; -- A6
                  WHEN "0000011" =>
                     playing <= playingNote;
                     tuning_word <= "010011111001"; -- A#6/Bb6
                  WHEN "0000001" =>
                     playing <= playingNote;
                     tuning_word <= "010101000101"; -- B6
                  WHEN OTHERS =>
                     playing <= notPlayingNote;
               END CASE;   
            WHEN "0111" => -- Octave 7
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing <= playingNote;
                     tuning_word <= "010110010101"; -- C7
                  WHEN "1100000" =>
                     playing <= playingNote;
                     tuning_word <= "010111101010"; -- C#7/Db7
                  WHEN "0100000" =>
                     playing <= playingNote;
                     tuning_word <= "011001000100"; -- D7
                  WHEN "0110000" =>
                     playing <= playingNote;
                     tuning_word <= "011010100011"; -- D#7/Eb7
                  WHEN "0010000" =>
                     playing <= playingNote;
                     tuning_word <= "011100001000"; -- E7
                  WHEN "0001000" =>
                     playing <= playingNote;
                     tuning_word <= "011101110011"; -- F7
                  WHEN "0001100" =>
                     playing <= playingNote;
                     tuning_word <= "011111100101"; -- F#7/Gb7
                  WHEN "0000100" =>
                     playing <= playingNote;
                     tuning_word <= "100001011101"; -- G7
                  WHEN "0000110" =>
                     playing <= playingNote;
                     tuning_word <= "100011011100"; -- G#7/Ab7
                  WHEN "0000010" =>
                     playing <= playingNote;
                     tuning_word <= "100101100011"; -- A7
                  WHEN "0000011" =>
                     playing <= playingNote;
                     tuning_word <= "100111110010"; -- A#7/Bb7
                  WHEN "0000001" =>
                     playing <= playingNote;
                     tuning_word <= "101010001001"; -- B7
                  WHEN OTHERS =>
                     playing <= notPlayingNote;
               END CASE;
            WHEN "1000" => -- Octave 8
               CASE CMD(6 DOWNTO 0) IS
                  WHEN "1000000" =>
                     playing <= playingNote;
                     tuning_word <= "101100101010"; -- C8
                  WHEN "1100000" =>
                     playing <= playingNote;
                     tuning_word <= "101111010100"; -- C#8/Db8
                  WHEN "0100000" =>
                     playing <= playingNote;
                     tuning_word <= "110010001000"; -- D8
                  WHEN "0110000" =>
                     playing <= playingNote;
                     tuning_word <= "110101000110"; -- D#8/Eb8
                  WHEN OTHERS =>
                     playing <= notPlayingNote; 
               END CASE;
        -- All 68 equal-tempered notes from 100 Hz to 5 kHz are implemented above
            WHEN OTHERS =>
               playing <= notPlayingNote;
         END CASE;
      END IF;
   END PROCESS;
END gen;
