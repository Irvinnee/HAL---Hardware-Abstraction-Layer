-- PWM Implementation for Renesas RA4M1
-- Uses AGT (Asynchronous General Purpose Timer) modules for PWM output

with RA4M1_Registers;
use RA4M1_Registers;

package body HAL_PWM is

   -- PCLKB = 48 MHz
   PCLKB_Hz : constant := 48_000_000;

   -- PWM state array (for query functions)
   type PWM_State is record
      Frequency : PWM_Frequency;
      Duty      : PWM_Duty;
      Enabled   : Boolean;
   end record;

   PWM_States : array (PWM_Pin) of PWM_State :=
      (others => (Frequency => 1000, Duty => 0, Enabled => False));

   -- Pin to AGT module mapping
   function Get_AGT (Pin : PWM_Pin) return access AGT_Registers_Type is
   begin
      case Pin is
         when PWM_D3 | PWM_D5 | PWM_D6 => return AGT0_Regs'Access;
         when PWM_D9 | PWM_D10 | PWM_D11 => return AGT1_Regs'Access;
      end case;
   end Get_AGT;

   -- Calculate prescaler and period for a given frequency
   procedure Calc_Params (Freq : PWM_Frequency;
                           Prescaler : out UInt8;
                           Period    : out UInt16) is
      Div  : Natural;
      Cnt  : Natural;
   begin
      -- Try prescaler=1 first (raw PCLKB)
      Cnt := PCLKB_Hz / Freq;
      if Cnt <= 65536 then
         Prescaler := 16#00#;  -- TCK=000 (PCLKB/1)
         Period := UInt16 (Cnt - 1);
         return;
      end if;

      -- prescaler /8
      Div := PCLKB_Hz / 8;
      Cnt := Div / Freq;
      if Cnt <= 65536 then
         Prescaler := 16#10#;  -- TCK=001 (PCLKB/8)
         Period := UInt16 (Cnt - 1);
         return;
      end if;

      -- prescaler /2 of divided clock (/16 total approx)
      Prescaler := 16#30#;  -- TCK=011 (PCLKB/2)
      Cnt := (PCLKB_Hz / 2) / Freq;
      if Cnt > 65536 then Cnt := 65536; end if;
      Period := UInt16 (Cnt - 1);
   end Calc_Params;

   -- Initialize PWM
   procedure PWM_Init (Config : PWM_Config) is
      AGT_Reg  : access AGT_Registers_Type := Get_AGT (Config.Pin);
      Prescaler : UInt8;
      Period    : UInt16;
      CMP       : UInt16;
   begin
      -- 1. Enable AGT clock (clear MSTPCRD bits)
      case Config.Pin is
         when PWM_D3 | PWM_D5 | PWM_D6 =>
            MSTPCRD := MSTPCRD and (not 16#0000_0008#);  -- AGT0
         when PWM_D9 | PWM_D10 | PWM_D11 =>
            MSTPCRD := MSTPCRD and (not 16#0000_0004#);  -- AGT1
      end case;

      -- 2. Stop timer
      AGT_Reg.AGTCR := AGTCR_TSTOP;

      -- 3. Calculate prescaler and period
      Calc_Params (Config.Frequency, Prescaler, Period);

      -- 4. Set mode register (PWM mode + clock source)
      AGT_Reg.AGTMR1 := Prescaler;  -- PWM mode implied by using compare match

      -- 5. Set period
      AGT_Reg.AGT := Period;

      -- 6. Set compare match for duty cycle
      CMP := UInt16 ((Natural (Period) * Natural (Config.Duty)) / 255);
      AGT_Reg.AGTCMA := CMP;

      -- 7. Configure AGT I/O for PWM output
      AGT_Reg.AGTIOC := AGTIOC_TOE;  -- Enable timer output

      -- 8. Start timer
      AGT_Reg.AGTCR := AGTCR_TSTART;

      -- Save state
      PWM_States (Config.Pin).Frequency := Config.Frequency;
      PWM_States (Config.Pin).Duty := Config.Duty;
      PWM_States (Config.Pin).Enabled := True;
   end PWM_Init;

   -- Set frequency
   procedure PWM_Set_Frequency (Pin : PWM_Pin; Frequency : PWM_Frequency) is
      AGT_Reg  : access AGT_Registers_Type := Get_AGT (Pin);
      Prescaler : UInt8;
      Period    : UInt16;
      CMP       : UInt16;
   begin
      -- Stop, reconfigure, restart
      AGT_Reg.AGTCR := AGTCR_TSTOP;

      Calc_Params (Frequency, Prescaler, Period);
      AGT_Reg.AGTMR1 := Prescaler;
      AGT_Reg.AGT := Period;

      -- Recalculate duty
      CMP := UInt16 ((Natural (Period) * Natural (PWM_States (Pin).Duty)) / 255);
      AGT_Reg.AGTCMA := CMP;

      if PWM_States (Pin).Enabled then
         AGT_Reg.AGTCR := AGTCR_TSTART;
      end if;

      PWM_States (Pin).Frequency := Frequency;
   end PWM_Set_Frequency;

   -- Set duty cycle (0-255)
   procedure PWM_Set_Duty (Pin : PWM_Pin; Duty : PWM_Duty) is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (Pin);
      Period  : Natural := Natural (AGT_Reg.AGT);
      CMP     : UInt16;
   begin
      CMP := UInt16 ((Period * Natural (Duty)) / 255);
      AGT_Reg.AGTCMA := CMP;
      PWM_States (Pin).Duty := Duty;
   end PWM_Set_Duty;

   -- Set duty as percentage (0.0 - 100.0)
   procedure PWM_Set_Duty_Percent (Pin : PWM_Pin; Percent : Float) is
      Duty_Value : PWM_Duty;
   begin
      if Percent < 0.0 then
         Duty_Value := 0;
      elsif Percent > 100.0 then
         Duty_Value := 255;
      else
         Duty_Value := PWM_Duty (Integer (Percent * 2.55));
      end if;
      PWM_Set_Duty (Pin, Duty_Value);
   end PWM_Set_Duty_Percent;

   -- Stop PWM
   procedure PWM_Stop (Pin : PWM_Pin) is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (Pin);
   begin
      AGT_Reg.AGTCR := AGTCR_TSTOP;
      AGT_Reg.AGTIOC := 0;  -- Disable output
      PWM_States (Pin).Enabled := False;
   end PWM_Stop;

   -- Start PWM
   procedure PWM_Start (Pin : PWM_Pin) is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (Pin);
   begin
      AGT_Reg.AGTIOC := AGTIOC_TOE;
      AGT_Reg.AGTCR := AGTCR_TSTART;
      PWM_States (Pin).Enabled := True;
   end PWM_Start;

   -- Get duty cycle
   function PWM_Get_Duty (Pin : PWM_Pin) return PWM_Duty is
   begin
      return PWM_States (Pin).Duty;
   end PWM_Get_Duty;

   -- Get frequency
   function PWM_Get_Frequency (Pin : PWM_Pin) return PWM_Frequency is
   begin
      return PWM_States (Pin).Frequency;
   end PWM_Get_Frequency;

end HAL_PWM;
