-- Timer implementation using AGT modules

with RA4M1_Registers;
use RA4M1_Registers;

package body HAL_Timer is

   -- PCLKB frequency (48 MHz for RA4M1 at default config)
   PCLKB_Hz : constant := 48_000_000;

   -- Millisecond counter (incremented by SysTick or AGT0)
   Millis_Counter : Natural := 0;
   pragma Volatile (Millis_Counter);

   -- Microsecond counter
   Micros_Counter : Natural := 0;
   pragma Volatile (Micros_Counter);

   -- Timer callbacks
   Timer0_CB : Timer_Callback := null;
   Timer1_CB : Timer_Callback := null;

   -- Get AGT registers for timer ID
   function Get_AGT (ID : Timer_ID) return access AGT_Registers_Type is
   begin
      case ID is
         when Timer_0 => return AGT0_Regs'Access;
         when Timer_1 => return AGT1_Regs'Access;
      end case;
   end Get_AGT;

   -- Calculate AGT counter value for given period in microseconds
   function Us_To_Count (Period_Us : Natural; Clock : Timer_Clock) return UInt16 is
      Clock_Hz : Natural;
   begin
      case Clock is
         when PCLKB       => Clock_Hz := PCLKB_Hz;
         when PCLKB_Div_2 => Clock_Hz := PCLKB_Hz / 2;
         when PCLKB_Div_8 => Clock_Hz := PCLKB_Hz / 8;
         when Subclock     => Clock_Hz := 32_768;
         when LOCO         => Clock_Hz := 32_768;  -- approx
      end case;

      -- Count = (Clock_Hz * Period_Us) / 1_000_000 - 1
      -- Use intermediate to avoid overflow
      declare
         Ticks : Natural := (Clock_Hz / 1_000) * Period_Us / 1_000;
      begin
         if Ticks > 65535 then
            return 65535;
         elsif Ticks = 0 then
            return 1;
         else
            return UInt16 (Ticks - 1);
         end if;
      end;
   end Us_To_Count;

   -- Initialize timer
   procedure Timer_Init (Config : Timer_Config) is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (Config.ID);
      AGTMR1_Val : UInt8 := 0;
      Count : UInt16;
   begin
      -- 1. Enable AGT clock (clear MSTPCRD bit)
      case Config.ID is
         when Timer_0 => MSTPCRD := MSTPCRD and (not 16#0000_0008#);  -- bit 3
         when Timer_1 => MSTPCRD := MSTPCRD and (not 16#0000_0004#);  -- bit 2
      end case;

      -- 2. Stop timer first
      AGT_Reg.AGTCR := AGTCR_TSTOP;

      -- 3. Configure mode
      case Config.Mode is
         when One_Shot         => AGTMR1_Val := 16#00#;
         when Periodic          => AGTMR1_Val := 16#00#;
         when Pulse_Output      => AGTMR1_Val := 16#01#;
         when Event_Counter     => AGTMR1_Val := 16#02#;
         when Pulse_Width_Meas  => AGTMR1_Val := 16#03#;
         when Period_Meas       => AGTMR1_Val := 16#04#;
      end case;

      -- 4. Configure clock source
      case Config.Clock is
         when PCLKB       => AGTMR1_Val := AGTMR1_Val or 16#00#;  -- TCK=000
         when PCLKB_Div_8 => AGTMR1_Val := AGTMR1_Val or 16#10#;  -- TCK=001
         when PCLKB_Div_2 => AGTMR1_Val := AGTMR1_Val or 16#30#;  -- TCK=011
         when Subclock     => AGTMR1_Val := AGTMR1_Val or 16#40#;  -- TCK=100
         when LOCO         => AGTMR1_Val := AGTMR1_Val or 16#60#;  -- TCK=110
      end case;

      AGT_Reg.AGTMR1 := AGTMR1_Val;

      -- 5. Set count value
      Count := Us_To_Count (Config.Period_Us, Config.Clock);
      AGT_Reg.AGT := Count;
   end Timer_Init;

   -- Start timer
   procedure Timer_Start (ID : Timer_ID) is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (ID);
   begin
      AGT_Reg.AGTCR := AGTCR_TSTART;
   end Timer_Start;

   -- Stop timer
   procedure Timer_Stop (ID : Timer_ID) is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (ID);
   begin
      AGT_Reg.AGTCR := AGTCR_TSTOP;
   end Timer_Stop;

   -- Reset timer
   procedure Timer_Reset (ID : Timer_ID) is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (ID);
   begin
      AGT_Reg.AGTCR := AGTCR_TSTOP;
      AGT_Reg.AGT := 16#FFFF#;
   end Timer_Reset;

   -- Get counter value
   function Timer_Get_Count (ID : Timer_ID) return Natural is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (ID);
   begin
      return Natural (AGT_Reg.AGT);
   end Timer_Get_Count;

   -- Set period in microseconds
   procedure Timer_Set_Period_Us (ID : Timer_ID; Period_Us : Natural) is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (ID);
   begin
      AGT_Reg.AGT := Us_To_Count (Period_Us, PCLKB_Div_8);
   end Timer_Set_Period_Us;

   -- Set period in milliseconds
   procedure Timer_Set_Period_Ms (ID : Timer_ID; Period_Ms : Natural) is
   begin
      Timer_Set_Period_Us (ID, Period_Ms * 1000);
   end Timer_Set_Period_Ms;

   -- Check underflow
   function Timer_Underflow (ID : Timer_ID) return Boolean is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (ID);
   begin
      return (AGT_Reg.AGTCR and AGTCR_TUNDF) /= 0;
   end Timer_Underflow;

   -- Clear underflow flag
   procedure Timer_Clear_Underflow (ID : Timer_ID) is
      AGT_Reg : access AGT_Registers_Type := Get_AGT (ID);
   begin
      AGT_Reg.AGTCR := AGT_Reg.AGTCR and (not AGTCR_TUNDF);
   end Timer_Clear_Underflow;

   -- Set callback
   procedure Timer_Set_Callback (ID : Timer_ID; Callback : Timer_Callback) is
   begin
      case ID is
         when Timer_0 => Timer0_CB := Callback;
         when Timer_1 => Timer1_CB := Callback;
      end case;
   end Timer_Set_Callback;

   -- Blocking delay (microseconds) using busy-wait on SysTick
   procedure Delay_Us (Microseconds : Natural) is
      Ticks : UInt32 := UInt32 (Microseconds * (PCLKB_Hz / 1_000_000));
   begin
      SYST_RVR := Ticks;
      SYST_CVR := 0;                                    -- Clear counter
      SYST_CSR := SYST_CSR_ENABLE or SYST_CSR_CLKSOURCE;  -- Start, use CPU clock

      -- Wait for COUNTFLAG
      while (SYST_CSR and SYST_CSR_COUNTFLAG) = 0 loop
         null;
      end loop;

      SYST_CSR := 0;  -- Stop SysTick
   end Delay_Us;

   -- Blocking delay (milliseconds)
   procedure Delay_Ms (Milliseconds : Natural) is
   begin
      for I in 1 .. Milliseconds loop
         Delay_Us (1000);
      end loop;
   end Delay_Ms;

   -- Millis counter
   function Millis return Natural is
   begin
      return Millis_Counter;
   end Millis;

   -- Micros counter
   function Micros return Natural is
   begin
      return Micros_Counter;
   end Micros;

end HAL_Timer;
