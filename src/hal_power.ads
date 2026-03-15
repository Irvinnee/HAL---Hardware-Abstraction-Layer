-- Sleep / Power Management for Arduino Uno R4
-- Controls low-power modes of RA4M1

package HAL_Power is
   pragma Preelaborate;

   -- Sleep modes available on RA4M1
   type Sleep_Mode is
     (Sleep,             -- CPU stops, peripherals active, fast wake-up
      Deep_Sleep,        -- CPU + most clocks stop, selected wake sources
      Software_Standby,  -- Lowest power, RAM retained, slow wake-up
      Snooze);           -- Wake briefly for peripheral, then back to standby

   -- Wake-up sources
   type Wakeup_Source is
     (Wakeup_IRQ,        -- External pin interrupt (IRQ0-IRQ7)
      Wakeup_AGT,        -- AGT timer underflow
      Wakeup_RTC_Alarm,  -- RTC alarm
      Wakeup_RTC_Period, -- RTC periodic interrupt
      Wakeup_I2C,        -- I2C address match
      Wakeup_UART);      -- UART receive

   -- Enter sleep mode (WFI instruction)
   procedure Enter_Sleep (Mode : Sleep_Mode := Sleep);

   -- Configure wake-up source before entering sleep
   procedure Enable_Wakeup (Source : Wakeup_Source);

   -- Disable a wake-up source
   procedure Disable_Wakeup (Source : Wakeup_Source);

   -- Quick sleep: enter sleep, wake on any enabled interrupt
   procedure Sleep_Until_Interrupt;

   -- Sleep for N milliseconds using RTC/AGT as wakeup
   procedure Sleep_Ms (Milliseconds : Natural);

   -- Get last reset cause
   type Reset_Cause is
     (Power_On,          -- Power-on reset
      External,          -- External reset pin
      Watchdog,          -- Watchdog timer reset
      Software,          -- Software reset
      Low_Voltage,       -- Voltage detector reset
      Unknown);

   function Get_Reset_Cause return Reset_Cause;

   -- Software reset
   procedure System_Reset;

end HAL_Power;
