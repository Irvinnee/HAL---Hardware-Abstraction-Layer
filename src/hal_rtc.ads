-- RTC (Real Time Clock) Driver for Arduino Uno R4
-- Uses built-in RTC module with 32.768 kHz subclock

with HAL_Platform;

package HAL_RTC is
   pragma Preelaborate;

   -- Time representation
   type RTC_Time is record
      Hours   : Natural range 0 .. 23;
      Minutes : Natural range 0 .. 59;
      Seconds : Natural range 0 .. 59;
   end record;

   -- Date representation
   type RTC_Date is record
      Year    : Natural range 0 .. 99;   -- 2-digit year (00-99)
      Month   : Natural range 1 .. 12;
      Day     : Natural range 1 .. 31;
      Weekday : Natural range 0 .. 6;    -- 0=Sunday .. 6=Saturday
   end record;

   -- Full datetime
   type RTC_DateTime is record
      Date : RTC_Date;
      Time : RTC_Time;
   end record;

   -- Alarm configuration
   type RTC_Alarm is record
      Hours   : Natural range 0 .. 23;
      Minutes : Natural range 0 .. 59;
      Seconds : Natural range 0 .. 59;
      Weekday_Mask : UInt8;  -- bit 0=Sun, bit 1=Mon, etc.
   end record;

   -- Periodic interrupt frequency
   type RTC_Periodic is
     (Period_None,        -- No periodic interrupt
      Period_256Hz,       -- 256 Hz (3.9 ms)
      Period_128Hz,       -- 128 Hz
      Period_64Hz,        -- 64 Hz
      Period_32Hz,        -- 32 Hz
      Period_16Hz,        -- 16 Hz
      Period_8Hz,         -- 8 Hz
      Period_4Hz,         -- 4 Hz
      Period_2Hz,         -- 2 Hz (500 ms)
      Period_1Hz,         -- 1 Hz (1 second)
      Period_2s,          -- Every 2 seconds
      Period_1min);       -- Every minute

   -- Use platform UInt8 for alarm weekday mask
   subtype UInt8 is HAL_Platform.UInt8;

   -- Callback type
   type RTC_Callback is access procedure;

   -- Initialize RTC
   procedure RTC_Init;

   -- Set time
   procedure RTC_Set_Time (T : RTC_Time);

   -- Get current time
   function RTC_Get_Time return RTC_Time;

   -- Set date
   procedure RTC_Set_Date (D : RTC_Date);

   -- Get current date
   function RTC_Get_Date return RTC_Date;

   -- Set full datetime
   procedure RTC_Set_DateTime (DT : RTC_DateTime);

   -- Get full datetime
   function RTC_Get_DateTime return RTC_DateTime;

   -- Set alarm
   procedure RTC_Set_Alarm (A : RTC_Alarm);

   -- Enable/disable alarm interrupt
   procedure RTC_Enable_Alarm (Enable : Boolean := True);

   -- Set periodic interrupt
   procedure RTC_Set_Periodic (Period : RTC_Periodic);

   -- Register alarm callback
   procedure RTC_Set_Alarm_Callback (Callback : RTC_Callback);

   -- Register periodic callback
   procedure RTC_Set_Periodic_Callback (Callback : RTC_Callback);

   -- Check if alarm triggered
   function RTC_Alarm_Triggered return Boolean;

   -- Clear alarm flag
   procedure RTC_Clear_Alarm;

   -- Start RTC counting
   procedure RTC_Start;

   -- Stop RTC counting
   procedure RTC_Stop;

end HAL_RTC;
