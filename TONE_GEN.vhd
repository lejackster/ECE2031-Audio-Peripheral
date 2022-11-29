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
		
		-- added
		KEY3       : IN    STD_LOGIC;
		KEY2       : IN    STD_LOGIC;
      -- buttons
		
      L_DATA     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
      R_DATA     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
   );
END TONE_GEN;

ARCHITECTURE gen OF TONE_GEN IS 
   
   Type playingStatus IS (
      playingNote,
      notPlayingNote
   );
	
	Type volume is (
		default,
		volumeUpOne,
		volumeUpTwo,
		volumeUpThree,
		volumeDownOne,
		volumeDownTwo,
		volumeDownThree
	);

   SIGNAL phase_register : STD_LOGIC_VECTOR(14 DOWNTO 0);
   SIGNAL tuning_word    : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL sounddata      : STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL playing        : playingStatus;
   SHARED VARIABLE scale_factor : INTEGER :=1;
   SIGNAL volume_current			: volume;
   
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
   
   -- 12-bit sound data is used as bits 12-3 of the 16-bit output.
   -- This is to prevent the output from being too loud.
	

	
	PROCESS (RESETN) BEGIN
		IF(RESETN='0') THEN
			L_DATA(15 DOWNTO 13) <= sounddata(11)&sounddata(11)&sounddata(11); -- sign extend
					L_DATA(12 DOWNTO 1) <= sounddata;
					L_DATA(0 DOWNTO 0) <= "0"; -- pad right side with 0s
					
					-- Right channel is the same.
					R_DATA(15 DOWNTO 13) <= sounddata(11)&sounddata(11)&sounddata(11); -- sign extend
					R_DATA(12 DOWNTO 1) <= sounddata;
					R_DATA(0 DOWNTO 0) <= "0"; -- pad right side with 0s
		Else
		
			CASE scale_factor is
							
				WHEN 8 =>
						L_DATA(15 DOWNTO 4) <= sounddata(11 DOWNTO 0);
						L_DATA(3 DOWNTO 0) <= "0000"; -- pad right side with 0s
						
						-- Right channel is the same.
						R_DATA(15 DOWNTO 4) <= sounddata(11 DOWNTO 0);
						R_DATA(3 DOWNTO 0) <= "0000"; -- pad right side with 0s
					
				WHEN 4 =>
						L_DATA(15) <= sounddata(11); -- sign extend
						L_DATA(14 DOWNTO 3) <= sounddata(11 DOWNTO 0);
						L_DATA(2 DOWNTO 0) <= "000"; -- pad right side with 0s
						
						-- Right channel is the same.
						R_DATA(15) <= sounddata(11); -- sign extend
						R_DATA(14 DOWNTO 3) <= sounddata(11 DOWNTO 0);
						R_DATA(2 DOWNTO 0) <= "000"; -- pad right side with 0s
						
				WHEN 2 =>
						L_DATA(15 DOWNTO 14) <= sounddata(11)&sounddata(11); -- sign extend
						L_DATA(13 DOWNTO 2) <= sounddata(11 DOWNTO 0);
						L_DATA(1 DOWNTO 0) <= "00"; -- pad right side with 0s
						
						-- Right channel is the same.
						R_DATA(15 DOWNTO 14) <= sounddata(11)&sounddata(11); -- sign extend
						R_DATA(13 DOWNTO 2) <= sounddata(11 DOWNTO 0);
						R_DATA(1 DOWNTO 0) <= "00"; -- pad right side with 0s
						
				WHEN 1 =>
						L_DATA(15 DOWNTO 13) <= sounddata(11)&sounddata(11)&sounddata(11); -- sign extend
						L_DATA(12 DOWNTO 1) <= sounddata;
						L_DATA(0 DOWNTO 0) <= "0"; -- pad right side with 0s
						
						-- Right channel is the same.
						R_DATA(15 DOWNTO 13) <= sounddata(11)&sounddata(11)&sounddata(11); -- sign extend
						R_DATA(12 DOWNTO 1) <= sounddata;
						R_DATA(0 DOWNTO 0) <= "0"; -- pad right side with 0s
				
				WHEN -2 =>
						L_DATA(15 DOWNTO 12) <= sounddata(11)&sounddata(11)&sounddata(11)&sounddata(11); -- sign extend
						L_DATA(11 DOWNTO 0) <= sounddata(11 DOWNTO 0);
						
						-- Right channel is the same.
						R_DATA(15 DOWNTO 12) <= sounddata(11)&sounddata(11)&sounddata(11)&sounddata(11); -- sign extend
						R_DATA(11 DOWNTO 0) <= sounddata(11 DOWNTO 0);
		     
				WHEN -4 =>
				L_DATA(15 DOWNTO 11) <= sounddata(10)&sounddata(10)&sounddata(10)&sounddata(10)&sounddata(10); -- sign extend
						L_DATA(10 DOWNTO 0) <= sounddata(10 DOWNTO 0);
						
						-- Right channel is the same.
						R_DATA(15 DOWNTO 11) <= sounddata(10)&sounddata(10)&sounddata(10)&sounddata(10)&sounddata(10); -- sign extend
						R_DATA(10 DOWNTO 0) <= sounddata(10 DOWNTO 0);
		     
			  WHEN -8 =>
						L_DATA(15 DOWNTO 10) <= sounddata(10)&sounddata(10)&sounddata(10)&sounddata(10)&sounddata(10)&sounddata(10); -- sign extend
						L_DATA(9 DOWNTO 0) <= sounddata(10 DOWNTO 1);
						
						-- Right channel is the same.
						R_DATA(15 DOWNTO 10) <= sounddata(10)&sounddata(10)&sounddata(10)&sounddata(10)&sounddata(10)&sounddata(10); -- sign extend
						R_DATA(9 DOWNTO 0) <= sounddata(10 DOWNTO 1);
			  
				WHEN OTHERS =>
					L_DATA(15 DOWNTO 13) <= sounddata(11)&sounddata(11)&sounddata(11); -- sign extend
					L_DATA(12 DOWNTO 1) <= sounddata;
					L_DATA(0 DOWNTO 0) <= "0"; -- pad right side with 0s
					
					-- Right channel is the same.
					R_DATA(15 DOWNTO 13) <= sounddata(11)&sounddata(11)&sounddata(11); -- sign extend
					R_DATA(12 DOWNTO 1) <= sounddata;
					R_DATA(0 DOWNTO 0) <= "0"; -- pad right side with 0s
				END CASE;
			END IF;
	END PROCESS;
   
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
				playing <= notplayingNote;
				tuning_word <= "000000000000";
			   
		Else
				playing <= playingNote;
						tuning_word <= "101010001001";
				CASE (volume_current) IS
					WHEN volumeUpThree => -- Octave 2
						scale_factor :=8;
						
					WHEN volumeUpTwo => -- Octave 2
						scale_factor :=4;
						
					WHEN volumeUpOne => -- Octave 2
						scale_factor :=2;
						
					WHEN default =>
						scale_factor :=1;	
						
					WHEN volumeDownOne => -- Octave 2
						scale_factor :=-2;
					
					WHEN volumeDownTwo => -- Octave 2
						scale_factor :=-4;
						
					WHEN volumeDownThree => -- Octave 2
						scale_factor :=-8;
						
					WHEN OTHERS =>
						scale_factor :=1;						
					END case;
      END IF;
   END PROCESS;
	
	PROCESS(KEY2) BEGIN
      
		IF FALLING_EDGE(KEY2) THEN
			CASE volume_current IS
				WHEN volumeUpThree =>
					volume_current <= volumeDownThree;
				WHEN volumeUpTwo =>
					volume_current <= volumeUpThree;
				WHEN volumeUpOne =>
					volume_current <= volumeUpTwo;
				WHEN default =>
					volume_current <= volumeUpOne;
				WHEN volumeDownOne =>
					volume_current <= default;
				WHEN volumeDownTwo =>
					volume_current <= volumeDownOne;
				WHEN volumeDownThree =>
					volume_current <= volumeDownTwo;
			END CASE;
      END IF;
   END PROCESS;
	
	

END gen;
