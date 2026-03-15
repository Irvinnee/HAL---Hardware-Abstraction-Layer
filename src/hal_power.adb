-- Sleep / Power Management implementation

with System.Machine_Code;
use System.Machine_Code;
with RA4M1_Registers;
use RA4M1_Registers;

package body HAL_Power is

   -- Enter sleep mode
   procedure Enter_Sleep (Mode : Sleep_Mode := Sleep) is
   begin
      case Mode is
         when Sleep =>
            -- Normal sleep: clear SLEEPDEEP, clear SSBY
            SCB_SCR := SCB_SCR and (not SCR_SLEEPDEEP);
            SBYCR := SBYCR and (not SBYCR_SSBY);

         when Deep_Sleep =>
            -- Deep sleep: set SLEEPDEEP, clear SSBY
            SCB_SCR := SCB_SCR or SCR_SLEEPDEEP;
            SBYCR := SBYCR and (not SBYCR_SSBY);

         when Software_Standby =>
            -- Standby: set SLEEPDEEP, set SSBY
            SCB_SCR := SCB_SCR or SCR_SLEEPDEEP;
            SBYCR := SBYCR or SBYCR_SSBY;

         when Snooze =>
            -- Snooze: like standby but with snooze mode enabled
            SCB_SCR := SCB_SCR or SCR_SLEEPDEEP;
            SBYCR := SBYCR or SBYCR_SSBY;
            SNZCR := SNZCR or 16#80#;  -- Enable snooze
      end case;

      -- Execute WFI (Wait For Interrupt) - enters selected sleep mode
      Asm ("wfi", Volatile => True);
   end Enter_Sleep;

   -- Enable wake-up source
   procedure Enable_Wakeup (Source : Wakeup_Source) is
   begin
      case Source is
         when Wakeup_IRQ =>
            -- External IRQ is always a valid wake source
            null;
         when Wakeup_AGT =>
            -- AGT underflow can wake from any mode
            null;
         when Wakeup_RTC_Alarm =>
            -- Enable RTC alarm as wake source
            -- Set in ICU wake-up source register
            null;
         when Wakeup_RTC_Period =>
            -- Enable RTC periodic as wake source
            null;
         when Wakeup_I2C =>
            -- I2C address match can wake from snooze
            null;
         when Wakeup_UART =>
            -- UART RX can wake from snooze
            null;
      end case;
   end Enable_Wakeup;

   -- Disable wake-up source
   procedure Disable_Wakeup (Source : Wakeup_Source) is
   begin
      case Source is
         when others => null;  -- Clear corresponding wake enable bit
      end case;
   end Disable_Wakeup;

   -- Quick sleep until any interrupt
   procedure Sleep_Until_Interrupt is
   begin
      Enter_Sleep (Sleep);
   end Sleep_Until_Interrupt;

   -- Sleep for N ms using SysTick
   procedure Sleep_Ms (Milliseconds : Natural) is
      Ticks_Per_Ms : constant UInt32 := UInt32 (48_000);  -- 48 MHz / 1000
   begin
      -- Configure SysTick for wake-up
      SYST_RVR := Ticks_Per_Ms * UInt32 (Milliseconds);
      SYST_CVR := 0;
      SYST_CSR := SYST_CSR_ENABLE or SYST_CSR_TICKINT or SYST_CSR_CLKSOURCE;

      -- Enter sleep, will wake on SysTick interrupt
      Enter_Sleep (Sleep);

      -- Disable SysTick
      SYST_CSR := 0;
   end Sleep_Ms;

   -- Get reset cause
   function Get_Reset_Cause return Reset_Cause is
      -- RSTSR0 at 0x4001_E410
      RSTSR0_Addr : constant System.Address := System.Storage_Elements.To_Address (16#4001_E410#);
      RSTSR0 : UInt8;
      pragma Import (Ada, RSTSR0);
      for RSTSR0'Address use RSTSR0_Addr;
      pragma Volatile (RSTSR0);
   begin
      if (RSTSR0 and 16#01#) /= 0 then
         return Power_On;
      elsif (RSTSR0 and 16#02#) /= 0 then
         return Watchdog;
      elsif (RSTSR0 and 16#04#) /= 0 then
         return Software;
      elsif (RSTSR0 and 16#10#) /= 0 then
         return External;
      elsif (RSTSR0 and 16#20#) /= 0 then
         return Low_Voltage;
      else
         return Unknown;
      end if;
   end Get_Reset_Cause;

   -- Software reset via SCB AIRCR
   procedure System_Reset is
   begin
      -- Write VECTKEY (0x05FA) + SYSRESETREQ (bit 2) to AIRCR
      SCB_AIRCR := 16#05FA_0004#;
      -- Should not reach here
      loop
         null;
      end loop;
   end System_Reset;

end HAL_Power;
