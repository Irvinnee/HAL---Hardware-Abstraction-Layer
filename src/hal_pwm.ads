-- PWM (Pulse Width Modulation) Driver for Arduino Uno R4
-- Provides PWM output on pins D3, D5, D6, D9, D10, D11

with HAL_Platform;
use HAL_Platform;

package HAL_PWM is
   pragma Preelaborate;

   -- PWM pins available on Arduino Uno R4 Minima
   type PWM_Pin is (PWM_D3, PWM_D5, PWM_D6, PWM_D9, PWM_D10, PWM_D11);

   -- PWM frequency options
   type PWM_Frequency is range 1 .. 1_000_000;  -- 1 Hz to 1 MHz

   -- PWM duty cycle (0-255 represents 0-100%)
   type PWM_Duty is range 0 .. 255;

   -- PWM configuration
   type PWM_Config is record
      Pin       : PWM_Pin;
      Frequency : PWM_Frequency;
      Duty      : PWM_Duty;
   end record;

   -- Initialize PWM output on a pin
   procedure PWM_Init (Config : PWM_Config);

   -- Set PWM frequency
   procedure PWM_Set_Frequency (Pin : PWM_Pin; Frequency : PWM_Frequency);

   -- Set PWM duty cycle (0-255)
   procedure PWM_Set_Duty (Pin : PWM_Pin; Duty : PWM_Duty);

   -- Set PWM duty cycle as percentage
   procedure PWM_Set_Duty_Percent (Pin : PWM_Pin; Percent : Float);

   -- Stop PWM on a pin
   procedure PWM_Stop (Pin : PWM_Pin);

   -- Start PWM on a pin
   procedure PWM_Start (Pin : PWM_Pin);

   -- Get current duty cycle
   function PWM_Get_Duty (Pin : PWM_Pin) return PWM_Duty;

   -- Get current frequency
   function PWM_Get_Frequency (Pin : PWM_Pin) return PWM_Frequency;

end HAL_PWM;
