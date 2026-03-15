-- RTC Implementation for Renesas RA4M1

with RA4M1_Registers;
use RA4M1_Registers;

package body HAL_RTC is

   -- Local redefinition to avoid conflict with parent UInt8
   subtype Byte is RA4M1_Registers.UInt8;

   -- Callbacks
   Alarm_CB    : RTC_Callback := null;
   Periodic_CB : RTC_Callback := null;

   -- BCD to binary conversion
   function BCD_To_Bin (BCD : Byte) return Natural is
   begin
      return Natural (BCD / 16) * 10 + Natural (BCD mod 16);
   end BCD_To_Bin;

   -- Binary to BCD conversion
   function Bin_To_BCD (Bin : Natural) return Byte is
   begin
      return Byte (Bin / 10) * 16 + Byte (Bin mod 10);
   end Bin_To_BCD;

   -- Initialize RTC
   procedure RTC_Init is
   begin
      -- 1. Enable RTC clock in MSTPCRA (clear bit for RTC)
      -- RTC uses subclock (32.768 kHz) by default

      -- 2. Stop RTC for configuration
      RCR2 := 0;

      -- Wait for RCR2.START to clear
      while (RCR2 and RCR2_START) /= 0 loop
         null;
      end loop;

      -- 3. Reset RTC
      RCR2 := RCR2_RESET;
      while (RCR2 and RCR2_RESET) /= 0 loop
         null;
      end loop;

      -- 4. Set to BCD count mode (default)
      RCR2 := RCR2 and (not RCR2_CNTMD);

      -- 5. Configure RCR1 (disable all interrupts initially)
      RCR1 := 0;

      -- 6. Set subclock as clock source
      RCR4 := 0;  -- 0 = subclock
   end RTC_Init;

   -- Set time
   procedure RTC_Set_Time (T : RTC_Time) is
      Was_Running : Boolean := (RCR2 and RCR2_START) /= 0;
   begin
      -- Stop RTC
      if Was_Running then
         RCR2 := RCR2 and (not RCR2_START);
         while (RCR2 and RCR2_START) /= 0 loop null; end loop;
      end if;

      RTC.RSECCNT := Bin_To_BCD (T.Seconds);
      RTC.RMINCNT := Bin_To_BCD (T.Minutes);
      RTC.RHRCNT  := Bin_To_BCD (T.Hours);

      -- Restart if was running
      if Was_Running then
         RCR2 := RCR2 or RCR2_START;
      end if;
   end RTC_Set_Time;

   -- Get time
   function RTC_Get_Time return RTC_Time is
      T : RTC_Time;
   begin
      T.Seconds := BCD_To_Bin (RTC.RSECCNT and 16#7F#);
      T.Minutes := BCD_To_Bin (RTC.RMINCNT and 16#7F#);
      T.Hours   := BCD_To_Bin (RTC.RHRCNT and 16#3F#);
      return T;
   end RTC_Get_Time;

   -- Set date
   procedure RTC_Set_Date (D : RTC_Date) is
      Was_Running : Boolean := (RCR2 and RCR2_START) /= 0;
   begin
      if Was_Running then
         RCR2 := RCR2 and (not RCR2_START);
         while (RCR2 and RCR2_START) /= 0 loop null; end loop;
      end if;

      RTC.RYRCNT  := RA4M1_Registers.UInt16 (Bin_To_BCD (D.Year));
      RTC.RMONCNT := Bin_To_BCD (D.Month);
      RTC.RDAYCNT := Bin_To_BCD (D.Day);
      RTC.RWKCNT  := Byte (D.Weekday);

      if Was_Running then
         RCR2 := RCR2 or RCR2_START;
      end if;
   end RTC_Set_Date;

   -- Get date
   function RTC_Get_Date return RTC_Date is
      D : RTC_Date;
   begin
      D.Year    := BCD_To_Bin (Byte (RTC.RYRCNT and 16#00FF#));
      D.Month   := BCD_To_Bin (RTC.RMONCNT and 16#1F#);
      D.Day     := BCD_To_Bin (RTC.RDAYCNT and 16#3F#);
      D.Weekday := Natural (RTC.RWKCNT and 16#07#);
      return D;
   end RTC_Get_Date;

   -- Set datetime
   procedure RTC_Set_DateTime (DT : RTC_DateTime) is
   begin
      RTC_Set_Date (DT.Date);
      RTC_Set_Time (DT.Time);
   end RTC_Set_DateTime;

   -- Get datetime
   function RTC_Get_DateTime return RTC_DateTime is
      DT : RTC_DateTime;
   begin
      DT.Date := RTC_Get_Date;
      DT.Time := RTC_Get_Time;
      return DT;
   end RTC_Get_DateTime;

   -- Set alarm
   procedure RTC_Set_Alarm (A : RTC_Alarm) is
   begin
      RTC.RSECAR := Bin_To_BCD (A.Seconds) or 16#80#;  -- ENB bit
      RTC.RMINAR := Bin_To_BCD (A.Minutes) or 16#80#;
      RTC.RHRAR  := Bin_To_BCD (A.Hours)   or 16#80#;
      RTC.RWKAR  := A.Weekday_Mask or 16#80#;
   end RTC_Set_Alarm;

   -- Enable alarm interrupt
   procedure RTC_Enable_Alarm (Enable : Boolean := True) is
   begin
      if Enable then
         RCR1 := RCR1 or RCR1_AIE;
      else
         RCR1 := RCR1 and (not RCR1_AIE);
      end if;
   end RTC_Enable_Alarm;

   -- Set periodic interrupt
   procedure RTC_Set_Periodic (Period : RTC_Periodic) is
      PES_Val : Byte := 0;
   begin
      case Period is
         when Period_None   => PES_Val := 16#00#;
         when Period_256Hz  => PES_Val := 16#60#;
         when Period_128Hz  => PES_Val := 16#70#;
         when Period_64Hz   => PES_Val := 16#80#;
         when Period_32Hz   => PES_Val := 16#90#;
         when Period_16Hz   => PES_Val := 16#A0#;
         when Period_8Hz    => PES_Val := 16#B0#;
         when Period_4Hz    => PES_Val := 16#C0#;
         when Period_2Hz    => PES_Val := 16#D0#;
         when Period_1Hz    => PES_Val := 16#E0#;
         when Period_2s     => PES_Val := 16#F0#;
         when Period_1min   => PES_Val := 16#F0#;  -- closest approximation
      end case;

      -- Set PES bits in RCR1 [7:4] and enable PIE
      RCR1 := (RCR1 and 16#0F#) or PES_Val or RCR1_PIE;
   end RTC_Set_Periodic;

   -- Set alarm callback
   procedure RTC_Set_Alarm_Callback (Callback : RTC_Callback) is
   begin
      Alarm_CB := Callback;
   end RTC_Set_Alarm_Callback;

   -- Set periodic callback
   procedure RTC_Set_Periodic_Callback (Callback : RTC_Callback) is
   begin
      Periodic_CB := Callback;
   end RTC_Set_Periodic_Callback;

   -- Check alarm
   function RTC_Alarm_Triggered return Boolean is
   begin
      -- Check alarm flag in RSR (RTC Status Register)
      -- Simplified: check RCR1 alarm flag
      return False;  -- Need RSR register access
   end RTC_Alarm_Triggered;

   -- Clear alarm
   procedure RTC_Clear_Alarm is
   begin
      null;  -- Clear alarm flag in RSR
   end RTC_Clear_Alarm;

   -- Start RTC
   procedure RTC_Start is
   begin
      RCR2 := RCR2 or RCR2_START;
   end RTC_Start;

   -- Stop RTC
   procedure RTC_Stop is
   begin
      RCR2 := RCR2 and (not RCR2_START);
      while (RCR2 and RCR2_START) /= 0 loop
         null;
      end loop;
   end RTC_Stop;

end HAL_RTC;
