-- ADC (Analog-to-Digital Converter) Driver for Arduino Uno R4
-- Provides analog input reading on pins A0-A7

with HAL_Platform;
use HAL_Platform;

package HAL_ADC is
   pragma Preelaborate;

   -- ADC resolution
   type ADC_Resolution is (Bits_10, Bits_12, Bits_14);

   -- ADC reference voltage
   type ADC_Reference is (Ref_Internal_VCC, Ref_External, Ref_Internal_1V);

   -- Analog input channels (A0-A7)
   type ADC_Channel is (A0, A1, A2, A3, A4, A5, A6, A7);

   -- ADC raw value
   type ADC_Value is range 0 .. 4095;  -- 12-bit maximum

   -- ADC configuration
   type ADC_Config is record
      Resolution : ADC_Resolution;
      Reference  : ADC_Reference;
   end record;

   -- Default: 10-bit resolution, VCC reference
   Default_Config : constant ADC_Config :=
      (Resolution => Bits_10, Reference => Ref_Internal_VCC);

   -- Initialize ADC module
   procedure ADC_Init (Config : ADC_Config := Default_Config);

   -- Read raw ADC value from a channel
   function ADC_Read_Raw (Channel : ADC_Channel) return ADC_Value;

   -- Read analog value (0 to resolution max)
   function ADC_Read (Channel : ADC_Channel) return Integer;

   -- Read as voltage (0..5V float)
   function ADC_Read_Voltage (Channel : ADC_Channel) return Float;

   -- Set resolution
   procedure ADC_Set_Resolution (Resolution : ADC_Resolution);

   -- Set reference voltage
   procedure ADC_Set_Reference (Reference : ADC_Reference);

end HAL_ADC;
