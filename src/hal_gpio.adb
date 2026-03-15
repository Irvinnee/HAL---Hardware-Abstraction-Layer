-- GPIO Implementation for Renesas RA4M1
-- Uses memory-mapped volatile registers

with System;
with RA4M1_Registers;
use RA4M1_Registers;

package body HAL_GPIO is

   -- Get port register block for given port
   function Get_Port (Port : Port_Type) return access Port_Registers_Type is
   begin
      case Port is
         when PORT_0 => return PORT0'Access;
         when PORT_1 => return PORT1'Access;
         when PORT_2 => return PORT2'Access;
         when PORT_3 => return PORT3'Access;
         when PORT_4 => return PORT4'Access;
         when PORT_5 => return PORT5'Access;
         when others  => return PORT0'Access;  -- Fallback
      end case;
   end Get_Port;

   -- Get bit mask for a pin number
   function Pin_Mask (Pin : Pin_Number) return UInt16 is
   begin
      return UInt16 (2 ** Natural (Pin));
   end Pin_Mask;

   -- GPIO_Init: Initialize a GPIO pin
   procedure GPIO_Init (Pin_Config : HAL_Platform.Pin_Config) is
   begin
      GPIO_Set_Mode (Pin_Config, Pin_Config.Mode);
   end GPIO_Init;

   -- GPIO_Set_Mode: Configure pin mode via PCNTR1.PDR
   procedure GPIO_Set_Mode (Config : HAL_Platform.Pin_Config; Mode : Pin_Mode) is
      Regs : access Port_Registers_Type := Get_Port (Config.Port);
      Mask : UInt16 := Pin_Mask (Config.Pin);
      PCNTR1_Val : Port_PCNTR1_Type;
   begin
      PCNTR1_Val := Regs.PCNTR1;

      case Mode is
         when Input =>
            -- Clear PDR bit = input
            PCNTR1_Val.PDR := PCNTR1_Val.PDR and (not Mask);
         when Output =>
            -- Set PDR bit = output
            PCNTR1_Val.PDR := PCNTR1_Val.PDR or Mask;
         when Alternate =>
            -- Set via PFS register (PMR bit)
            PCNTR1_Val.PDR := PCNTR1_Val.PDR or Mask;
         when Analog =>
            -- Clear PDR, will configure via ADC
            PCNTR1_Val.PDR := PCNTR1_Val.PDR and (not Mask);
      end case;

      Regs.PCNTR1 := PCNTR1_Val;
   end GPIO_Set_Mode;

   -- GPIO_Write: Write value to pin
   procedure GPIO_Write (Config : HAL_Platform.Pin_Config; State : Pin_State) is
   begin
      case State is
         when Low  => GPIO_Clear (Config);
         when High => GPIO_Set (Config);
      end case;
   end GPIO_Write;

   -- GPIO_Read: Read pin state from PCNTR2.PIDR
   function GPIO_Read (Config : HAL_Platform.Pin_Config) return Pin_State is
      Regs : access Port_Registers_Type := Get_Port (Config.Port);
      Mask : UInt16 := Pin_Mask (Config.Pin);
   begin
      if (Regs.PCNTR2.PIDR and Mask) /= 0 then
         return High;
      else
         return Low;
      end if;
   end GPIO_Read;

   -- GPIO_Set: Set pin HIGH via PCNTR3.POSR (write-only set register)
   procedure GPIO_Set (Config : HAL_Platform.Pin_Config) is
      Regs : access Port_Registers_Type := Get_Port (Config.Port);
      Mask : UInt16 := Pin_Mask (Config.Pin);
      Val  : Port_PCNTR3_Type;
   begin
      -- POSR is write-only: writing 1 sets the pin HIGH
      Val.PORR := 0;
      Val.POSR := Mask;
      Regs.PCNTR3 := Val;
   end GPIO_Set;

   -- GPIO_Clear: Set pin LOW via PCNTR3.PORR (write-only reset register)
   procedure GPIO_Clear (Config : HAL_Platform.Pin_Config) is
      Regs : access Port_Registers_Type := Get_Port (Config.Port);
      Mask : UInt16 := Pin_Mask (Config.Pin);
      Val  : Port_PCNTR3_Type;
   begin
      -- PORR is write-only: writing 1 sets the pin LOW
      Val.PORR := Mask;
      Val.POSR := 0;
      Regs.PCNTR3 := Val;
   end GPIO_Clear;

   -- GPIO_Toggle: Toggle pin state
   procedure GPIO_Toggle (Config : HAL_Platform.Pin_Config) is
      Current : Pin_State := GPIO_Read (Config);
   begin
      case Current is
         when Low  => GPIO_Set (Config);
         when High => GPIO_Clear (Config);
      end case;
   end GPIO_Toggle;

   -- GPIO_Initialize_All: Enable port clocks
   procedure GPIO_Initialize_All is
   begin
      -- On RA4M1, GPIO ports are always clocked (no MSTP bit for GPIO)
      -- PFS write protection must be disabled to change pin functions:
      --   1. Write 0x00 to PWPR (clear B0WI)
      --   2. Write 0x40 to PWPR (set PFSWE)
      null;  -- Port clocks always on for RA4M1
   end GPIO_Initialize_All;

end HAL_GPIO;
