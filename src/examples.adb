-- Advanced Examples: Arduino Uno R4 HAL Usage

-- Example 1: UART Echo - odbierz i wyślij z powrotem
--[[
with HAL;
use HAL;

procedure UART_Echo is
   Ch : Character;
begin
   HAL.Initialize_All;
   
   HAL.UART.UART_Send_Line ("Arduino R4 Echo Test");
   
   loop
      if HAL.UART.UART_Data_Available then
         Ch := HAL.UART.UART_Receive_Char;
         HAL.UART.UART_Send_Char (Ch);
      end if;
   end loop;
end UART_Echo;
--]]

-- Example 2: ADC Reader - czytanie wartości analogowej
--[[
with HAL;
use HAL;

procedure ADC_Reader is
   Raw_Value : Integer;
   Voltage : Float;
begin
   HAL.Initialize_All;
   
   loop
      Raw_Value := HAL.ADC.ADC_Read (HAL.ADC.A0);
      Voltage := HAL.ADC.ADC_Read_Voltage (HAL.ADC.A0);
      
      HAL.UART.UART_Send_String ("Raw: ");
      -- TODO: Integer to string conversion
      HAL.UART.UART_Send_Line ("");
      
      delay 0.1;  -- 100ms interval
   end loop;
end ADC_Reader;
--]]

-- Example 3: PWM LED Fade - zanik LED PWM
--[[
with HAL;
use HAL;

procedure PWM_Fade is
   Duty : Integer := 0;
   PWM_Config : HAL.PWM.PWM_Config := 
      (Pin => HAL.PWM.PWM_D3, Frequency => 1000, Duty => 0);
begin
   HAL.Initialize_All;
   HAL.PWM.PWM_Init (PWM_Config);
   
   loop
      -- Fade in
      while Duty <= 255 loop
         HAL.PWM.PWM_Set_Duty (HAL.PWM.PWM_D3, HAL.PWM.PWM_Duty (Duty));
         Duty := Duty + 1;
         delay 0.01;
      end loop;
      
      -- Fade out
      Duty := 255;
      while Duty >= 0 loop
         HAL.PWM.PWM_Set_Duty (HAL.PWM.PWM_D3, HAL.PWM.PWM_Duty (Duty));
         Duty := Duty - 1;
         delay 0.01;
      end loop;
   end loop;
end PWM_Fade;
--]]

-- Example 4: Multiple GPIO - kontrola wielu pinów
--[[
with HAL;
use HAL;

procedure GPIO_Sequence is
   Pin1 : constant HAL.Platform.Pin_Config := 
      (Port => 1, Pin => 0, Mode => Output);
   Pin2 : constant HAL.Platform.Pin_Config := 
      (Port => 1, Pin => 1, Mode => Output);
   Pin3 : constant HAL.Platform.Pin_Config := 
      (Port => 1, Pin => 2, Mode => Output);
begin
   HAL.Initialize_All;
   HAL.GPIO.GPIO_Init (Pin1);
   HAL.GPIO.GPIO_Init (Pin2);
   HAL.GPIO.GPIO_Init (Pin3);
   
   loop
      -- Pattern: 1-0-0 -> 0-1-0 -> 0-0-1
      HAL.GPIO.GPIO_Set (Pin1);
      HAL.GPIO.GPIO_Clear (Pin2);
      HAL.GPIO.GPIO_Clear (Pin3);
      delay 0.5;
      
      HAL.GPIO.GPIO_Clear (Pin1);
      HAL.GPIO.GPIO_Set (Pin2);
      HAL.GPIO.GPIO_Clear (Pin3);
      delay 0.5;
      
      HAL.GPIO.GPIO_Clear (Pin1);
      HAL.GPIO.GPIO_Clear (Pin2);
      HAL.GPIO.GPIO_Set (Pin3);
      delay 0.5;
   end loop;
end GPIO_Sequence;
--]]

-- Example 5: Sensor Read + LED Control
--[[
with HAL;
use HAL;

procedure Sensor_Control is
   Sensor_Value : Float;
   LED_Config : constant HAL.Platform.Pin_Config := HAL.Platform.LED_Pin;
begin
   HAL.Initialize_All;
   
   loop
      -- Read analog sensor
      Sensor_Value := HAL.ADC.ADC_Read_Voltage (HAL.ADC.A0);
      
      -- Control LED based on threshold (2.5V)
      if Sensor_Value > 2.5 then
         HAL.GPIO.GPIO_Set (LED_Config);
      else
         HAL.GPIO.GPIO_Clear (LED_Config);
      end if;
      
      -- Send status via UART
      HAL.UART.UART_Send_String ("Sensor: ");
      -- TODO: Float to string
      HAL.UART.UART_Send_Line ("");
      
      delay 0.5;
   end loop;
end Sensor_Control;
--]]

package Examples is
   pragma Pure;
   
   -- Uncomment one of above procedures to use
   -- Then in main.adb add: with Examples;
end Examples;
