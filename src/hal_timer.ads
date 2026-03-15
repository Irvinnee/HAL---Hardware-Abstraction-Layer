-- Timer Driver for Arduino Uno R4
-- Uses AGT (Asynchronous General Purpose Timer) modules
-- AGT0 and AGT1 available

package HAL_Timer is
   pragma Preelaborate;

   -- Timer selection
   type Timer_ID is (Timer_0, Timer_1);
   --  Timer_0 = AGT0
   --  Timer_1 = AGT1

   -- Timer mode
   type Timer_Mode is
     (One_Shot,          -- Count once, stop
      Periodic,          -- Repeat after underflow
      Pulse_Output,      -- Generate pulse on output pin
      Event_Counter,     -- Count external events
      Pulse_Width_Meas,  -- Measure pulse width
      Period_Meas);      -- Measure period

   -- Timer clock source
   type Timer_Clock is
     (PCLKB,           -- Peripheral clock B (48 MHz)
      PCLKB_Div_2,     -- PCLKB / 2
      PCLKB_Div_8,     -- PCLKB / 8
      Subclock,         -- 32.768 kHz subclock
      LOCO);            -- Low-speed on-chip oscillator

   -- Timer prescaler (additional division)
   type Timer_Prescaler is range 1 .. 8;

   -- Timer configuration
   type Timer_Config is record
      ID        : Timer_ID;
      Mode      : Timer_Mode;
      Clock     : Timer_Clock;
      Period_Us : Natural;  -- Desired period in microseconds
   end record;

   -- Callback for timer interrupt
   type Timer_Callback is access procedure;

   -- Initialize timer
   procedure Timer_Init (Config : Timer_Config);

   -- Start timer
   procedure Timer_Start (ID : Timer_ID);

   -- Stop timer
   procedure Timer_Stop (ID : Timer_ID);

   -- Reset timer counter
   procedure Timer_Reset (ID : Timer_ID);

   -- Get current counter value
   function Timer_Get_Count (ID : Timer_ID) return Natural;

   -- Set period in microseconds
   procedure Timer_Set_Period_Us (ID : Timer_ID; Period_Us : Natural);

   -- Set period in milliseconds
   procedure Timer_Set_Period_Ms (ID : Timer_ID; Period_Ms : Natural);

   -- Check if timer underflow occurred
   function Timer_Underflow (ID : Timer_ID) return Boolean;

   -- Clear underflow flag
   procedure Timer_Clear_Underflow (ID : Timer_ID);

   -- Register callback for timer underflow interrupt
   procedure Timer_Set_Callback (ID : Timer_ID; Callback : Timer_Callback);

   -- Simple delay using timer (blocking)
   procedure Delay_Us (Microseconds : Natural);
   procedure Delay_Ms (Milliseconds : Natural);

   -- Millis counter (like Arduino millis())
   function Millis return Natural;

   -- Micros counter (like Arduino micros())
   function Micros return Natural;

end HAL_Timer;
