-- Example: Blink LED on Arduino Uno R4 Minima
-- Migającego LED na wbudowanym pinie D13

with HAL;
use HAL;

procedure Main is
   LED_Config : constant HAL.Platform.Pin_Config := 
      HAL.Platform.LED_Pin;  -- D13 - built-in LED
begin
   -- Initialize all hardware
   HAL.Initialize_All;

   -- Main loop - blink forever
   loop
      -- LED ON (set pin HIGH)
      HAL.GPIO.GPIO_Set (LED_Config);
      delay 1.0;  -- Wait 1 second

      -- LED OFF (set pin LOW)
      HAL.GPIO.GPIO_Clear (LED_Config);
      delay 1.0;  -- Wait 1 second
   end loop;
end Main;
