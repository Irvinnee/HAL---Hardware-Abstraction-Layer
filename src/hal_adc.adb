-- ADC Implementation for Renesas RA4M1

with System;
with System.Storage_Elements;
use System.Storage_Elements;
with RA4M1_Registers;
use RA4M1_Registers;

package body HAL_ADC is

   -- Current resolution setting
   Current_Resolution : ADC_Resolution := Bits_10;

   -- Max value for current resolution
   function Max_Raw_Value return Float is
   begin
      case Current_Resolution is
         when Bits_10 => return 1023.0;
         when Bits_12 => return 4095.0;
         when Bits_14 => return 16383.0;
      end case;
   end Max_Raw_Value;

   -- Channel to register index
   function Channel_Index (Channel : ADC_Channel) return Natural is
   begin
      case Channel is
         when A0 => return 0;
         when A1 => return 1;
         when A2 => return 2;
         when A3 => return 3;
         when A4 => return 4;
         when A5 => return 5;
         when A6 => return 6;
         when A7 => return 7;
      end case;
   end Channel_Index;

   -- Initialize ADC
   procedure ADC_Init (Config : ADC_Config := Default_Config) is
   begin
      -- 1. Enable ADC module clock (clear MSTPCRC bit 16)
      MSTPCRC := MSTPCRC and (not 16#0001_0000#);

      -- 2. Set resolution via ADCER register
      case Config.Resolution is
         when Bits_10 => ADC0.ADCER := 16#0002#;
         when Bits_12 => ADC0.ADCER := 16#0000#;
         when Bits_14 => ADC0.ADCER := 16#0006#;
      end case;

      Current_Resolution := Config.Resolution;

      -- 3. Set ADCSR for single scan mode, software trigger
      ADC0.ADCSR := 16#0000#;
   end ADC_Init;

   -- Read raw ADC value
   function ADC_Read_Raw (Channel : ADC_Channel) return ADC_Value is
      Ch_Idx : Natural := Channel_Index (Channel);
      Mask   : UInt16 := UInt16 (2 ** Ch_Idx);
      Data_Addr : System.Address := ADC_Data_Address (Ch_Idx);
      Result : UInt16;
      pragma Import (Ada, Result);
      for Result'Address use Data_Addr;
      pragma Volatile (Result);
   begin
      -- 1. Select channel in ADANSA0
      ADC0.ADANSA0 := Mask;

      -- 2. Start conversion (set ADST bit)
      ADC0.ADCSR := ADC0.ADCSR or ADCSR_ADST;

      -- 3. Wait for conversion complete (ADST clears when done)
      while (ADC0.ADCSR and ADCSR_ADST) /= 0 loop
         null;
      end loop;

      -- 4. Read result from ADDRn register
      return ADC_Value (Result and 16#0FFF#);
   end ADC_Read_Raw;

   -- Read ADC as integer value
   function ADC_Read (Channel : ADC_Channel) return Integer is
   begin
      return Integer (ADC_Read_Raw (Channel));
   end ADC_Read;

   -- Read as voltage
   function ADC_Read_Voltage (Channel : ADC_Channel) return Float is
      Raw : ADC_Value := ADC_Read_Raw (Channel);
      Vcc : constant Float := 5.0;
   begin
      return (Float (Raw) / Max_Raw_Value) * Vcc;
   end ADC_Read_Voltage;

   -- Set resolution
   procedure ADC_Set_Resolution (Resolution : ADC_Resolution) is
   begin
      Current_Resolution := Resolution;
      case Resolution is
         when Bits_10 => ADC0.ADCER := 16#0002#;
         when Bits_12 => ADC0.ADCER := 16#0000#;
         when Bits_14 => ADC0.ADCER := 16#0006#;
      end case;
   end ADC_Set_Resolution;

   -- Set reference voltage
   procedure ADC_Set_Reference (Reference : ADC_Reference) is
   begin
      case Reference is
         when Ref_Internal_VCC => null;
         when Ref_External     => null;
         when Ref_Internal_1V  => null;
      end case;
   end ADC_Set_Reference;

end HAL_ADC;

   -- Channel to register mapping
   function Get_Channel_Register_Index (Channel : ADC_Channel) return Integer is
   begin
      case Channel is
         when A0 => return 0;
         when A1 => return 1;
         when A2 => return 2;
         when A3 => return 3;
         when A4 => return 4;
         when A5 => return 5;
         when A6 => return 6;
         when A7 => return 7;
      end case;
   end Get_Channel_Register_Index;

   -- Initialize ADC
   procedure ADC_Init (Config : ADC_Config := Default_Config) is
   begin
      -- Enable ADC module clock
      -- Configure ADCSR (control register)
      -- - Set resolution (ADBIT bits)
      -- - Enable ADC
      -- Configure reference voltage
      -- - ADREFA: set to internal or external reference

      -- Simplified initialization
      null;
   end ADC_Init;

   -- Read raw ADC value
   function ADC_Read_Raw (Channel : ADC_Channel) return ADC_Value is
   begin
      -- Select channel via ADANSA0 register
      -- Start conversion (ADST bit in ADCSR)
      -- Wait for conversion complete (ADIF flag)
      -- Read from appropriate ADREG register
      return ADC_Value (0);  -- Placeholder
   end ADC_Read_Raw;

   -- Read ADC as integer value
   function ADC_Read (Channel : ADC_Channel) return Integer is
      Raw : ADC_Value := ADC_Read_Raw (Channel);
   begin
      return Integer (Raw);
   end ADC_Read;

   -- Read as voltage
   function ADC_Read_Voltage (Channel : ADC_Channel) return Float is
      Raw : ADC_Value := ADC_Read_Raw (Channel);
      Max_Value : Float := 1023.0;  -- 10-bit default
      Vcc : constant Float := 5.0;
   begin
      return (Float (Raw) / Max_Value) * Vcc;
   end ADC_Read_Voltage;

   -- Set resolution
   procedure ADC_Set_Resolution (Resolution : ADC_Resolution) is
   begin
      case Resolution is
         when Bits_10 =>
            -- Set ADBIT = 00 (10-bit)
            null;
         when Bits_12 =>
            -- Set ADBIT = 01 (12-bit)
            null;
         when Bits_14 =>
            -- Set ADBIT = 10 (14-bit)
            null;
      end case;
   end ADC_Set_Resolution;

   -- Set reference voltage
   procedure ADC_Set_Reference (Reference : ADC_Reference) is
   begin
      case Reference is
         when Ref_Internal_VCC =>
            -- ADREFA = 0: AVCC as reference
            null;
         when Ref_External =>
            -- ADREFA = 1: External VREF pin as reference
            null;
         when Ref_Internal_1V =>
            -- ADREFA = 2: Internal 1.2V reference
            null;
      end case;
   end ADC_Set_Reference;

end HAL_ADC;
