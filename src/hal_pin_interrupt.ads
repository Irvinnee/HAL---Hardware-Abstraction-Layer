-- Port (Pin) Interrupt Driver for Arduino Uno R4
-- External interrupts on digital pins (IRQ0-IRQ7)
-- Maps Arduino digital pins to RA4M1 IRQ channels

with HAL_Platform;
use HAL_Platform;

package HAL_Pin_Interrupt is
   pragma Preelaborate;

   -- Available external interrupt channels (IRQ0-IRQ7)
   type IRQ_Channel is (IRQ0, IRQ1, IRQ2, IRQ3, IRQ4, IRQ5, IRQ6, IRQ7);

   -- Edge detection mode
   type Edge_Detect is
     (Falling_Edge,     -- Trigger on HIGH -> LOW
      Rising_Edge,      -- Trigger on LOW -> HIGH
      Both_Edges,       -- Trigger on any change
      Low_Level);       -- Trigger while LOW

   -- Arduino pin to IRQ mapping (Uno R4 Minima)\n   --   D2 = P104 -> IRQ1\n   --   D3 = P105 -> IRQ0\n   --   D8 = P304 -> IRQ9 (if available)\n   -- See RA4M1 User's Manual Table 19.6 for IRQn-DS pin assignments

   -- Pin interrupt callback
   type Pin_IRQ_Callback is access procedure;

   -- Pin interrupt configuration
   type Pin_IRQ_Config is record
      Channel  : IRQ_Channel;
      Edge     : Edge_Detect;
      Callback : Pin_IRQ_Callback;
   end record;

   -- Attach interrupt to a pin
   procedure Attach_Interrupt (Config : Pin_IRQ_Config);

   -- Attach interrupt using Arduino-style (pin number)
   procedure Attach_Interrupt
     (Pin      : Pin_Config;
      Channel  : IRQ_Channel;
      Edge     : Edge_Detect;
      Callback : Pin_IRQ_Callback);

   -- Detach interrupt from a channel
   procedure Detach_Interrupt (Channel : IRQ_Channel);

   -- Enable interrupt on channel
   procedure Enable_Pin_IRQ (Channel : IRQ_Channel);

   -- Disable interrupt on channel (without detaching)
   procedure Disable_Pin_IRQ (Channel : IRQ_Channel);

   -- Change edge detection mode
   procedure Set_Edge_Detect (Channel : IRQ_Channel; Edge : Edge_Detect);

   -- Check if interrupt flag is set
   function IRQ_Flag_Set (Channel : IRQ_Channel) return Boolean;

   -- Clear interrupt flag
   procedure Clear_IRQ_Flag (Channel : IRQ_Channel);

   -- Initialize pin interrupt system (called by HAL.Initialize_All)
   procedure Pin_IRQ_Initialize;

end HAL_Pin_Interrupt;
