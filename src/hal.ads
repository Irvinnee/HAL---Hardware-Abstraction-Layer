-- HAL (Hardware Abstraction Layer) for Arduino Uno R4 Minima
-- Main package that exports all HAL modules

with HAL_Platform;
with HAL_GPIO;
with HAL_UART;
with HAL_ADC;
with HAL_PWM;

package HAL is
   pragma Pure;

   -- Re-export all modules for convenience
   package Platform renames HAL_Platform;
   package GPIO renames HAL_GPIO;
   package UART renames HAL_UART;
   package ADC renames HAL_ADC;
   package PWM renames HAL_PWM;

   -- Initialize all hardware
   procedure Initialize_All;

end HAL;
