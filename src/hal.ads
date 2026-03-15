-- HAL (Hardware Abstraction Layer) for Arduino Uno R4 Minima
-- Main package that exports all HAL modules

with HAL_Platform;
with HAL_GPIO;
with HAL_UART;
with HAL_ADC;
with HAL_PWM;
with HAL_Interrupts;
with HAL_SPI;
with HAL_I2C;
with HAL_Timer;
with HAL_RTC;
with HAL_Power;
with HAL_Pin_Interrupt;

package HAL is
   pragma Preelaborate;

   -- Re-export all modules for convenience
   package Platform      renames HAL_Platform;
   package GPIO          renames HAL_GPIO;
   package UART          renames HAL_UART;
   package ADC           renames HAL_ADC;
   package PWM           renames HAL_PWM;
   package Interrupts    renames HAL_Interrupts;
   package SPI           renames HAL_SPI;
   package I2C           renames HAL_I2C;
   package Timer         renames HAL_Timer;
   package RTC           renames HAL_RTC;
   package Power         renames HAL_Power;
   package Pin_Interrupt renames HAL_Pin_Interrupt;

   -- Initialize all hardware
   procedure Initialize_All;

end HAL;
