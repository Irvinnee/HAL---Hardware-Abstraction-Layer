-- GPIO Implementation for Renesas RA4M1
-- Uses memory-mapped volatile registers with proper PFS configuration

with System;
with RA4M1_Registers;
use RA4M1_Registers;
with HAL_Platform;
use HAL_Platform;

package body HAL_GPIO is

   -- =============================================================
   -- PFS (Pin Function Select) helpers
   -- =============================================================

   -- Map Port_Type enum to the numeric port index used in register addressing
   function Port_Index (Port : Port_Type) return Natural is
   begin
      case Port is
         when PORT_0 => return 0;
         when PORT_1 => return 1;
         when PORT_2 => return 2;
         when PORT_3 => return 3;
         when PORT_4 => return 4;
         when PORT_5 => return 5;
         when PORT_6 => return 6;
         when PORT_9 => return 9;
      end case;
   end Port_Index;

   -- Read a 32-bit PFS register for a given port/pin
   function Read_PFS (Port : Port_Type; Pin : Pin_Number) return UInt32 is
      Addr : constant System.Address :=
        PFS_Address (Port_Index (Port), Natural (Pin));
      Reg : UInt32;
      pragma Import (Ada, Reg);
      for Reg'Address use Addr;
      pragma Volatile (Reg);
   begin
      return Reg;
   end Read_PFS;

   -- Write a 32-bit value to a PFS register (caller must have unlocked PWPR)
   procedure Write_PFS (Port : Port_Type; Pin : Pin_Number; Value : UInt32) is
      Addr : constant System.Address :=
        PFS_Address (Port_Index (Port), Natural (Pin));
      Reg : UInt32;
      pragma Import (Ada, Reg);
      for Reg'Address use Addr;
      pragma Volatile (Reg);
   begin
      Reg := Value;
   end Write_PFS;

   -- Unlock PFS registers for writing
   procedure PFS_Unlock is
   begin
      PWPR := 16#00#;         -- clear B0WI  (allow PFSWE writes)
      PWPR := PWPR_PFSWE;     -- set PFSWE   (allow PFS writes)
   end PFS_Unlock;

   -- Lock PFS registers against accidental writes
   procedure PFS_Lock is
   begin
      PWPR := 16#00#;         -- clear PFSWE
      PWPR := PWPR_B0WI;      -- set B0WI
   end PFS_Lock;

   -- =============================================================
   -- Port register helpers
   -- =============================================================

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

   -- =============================================================
   -- Public API
   -- =============================================================

   -- GPIO_Init: Initialize a GPIO pin (direction + PFS)
   procedure GPIO_Init (Pin_Config : HAL_Platform.Pin_Config) is
   begin
      GPIO_Set_Mode (Pin_Config, Pin_Config.Mode);
   end GPIO_Init;

   -- GPIO_Set_Mode: Configure pin mode via PDR + PFS
   procedure GPIO_Set_Mode (Config : HAL_Platform.Pin_Config; Mode : Pin_Mode) is
      Regs : access Port_Registers_Type := Get_Port (Config.Port);
      Mask : UInt16 := Pin_Mask (Config.Pin);
      PCNTR1_Val : Port_PCNTR1_Type;
      PFS_Val : UInt32;
   begin
      PCNTR1_Val := Regs.PCNTR1;

      case Mode is
         when Input =>
            -- 1. Set PFS: PMR=0 (GPIO), PSEL=0, PDR=0 (input)
            PFS_Unlock;
            Write_PFS (Config.Port, Config.Pin, 16#0000_0000#);
            PFS_Lock;
            -- 2. Clear PDR bit = input direction
            PCNTR1_Val.PDR := PCNTR1_Val.PDR and (not Mask);

         when Output =>
            -- 1. Set PFS: PMR=0 (GPIO), PSEL=0, PDR=1 (output)
            PFS_Unlock;
            Write_PFS (Config.Port, Config.Pin, 16#0000_0004#);  -- PDR bit
            PFS_Lock;
            -- 2. Set PDR bit = output direction
            PCNTR1_Val.PDR := PCNTR1_Val.PDR or Mask;

         when Alternate =>
            -- Direction handled by peripheral; set PDR for output-type peripherals
            PCNTR1_Val.PDR := PCNTR1_Val.PDR or Mask;
            -- PFS: PMR=1, PSEL set by caller via GPIO_Set_Alternate

         when Analog =>
            -- Clear PDR = input, PDR in PFS=0
            PFS_Unlock;
            Write_PFS (Config.Port, Config.Pin, 16#0000_0000#);
            PFS_Lock;
            PCNTR1_Val.PDR := PCNTR1_Val.PDR and (not Mask);
      end case;

      Regs.PCNTR1 := PCNTR1_Val;
   end GPIO_Set_Mode;

   -- GPIO_Set_Alternate: Switch a pin to a peripheral function.
   -- PSEL values are defined in HAL_Platform (PSEL_SCI0, PSEL_IIC, etc.)
   procedure GPIO_Set_Alternate (Config : HAL_Platform.Pin_Config;
                                  PSEL   : UInt8) is
      PFS_Val : UInt32 := 0;
   begin
      -- bit 24 = PMR (1 = peripheral mode)
      -- bits 20-16 = PSEL (5-bit field, but only low 5 matter)
      PFS_Val := 16#0100_0000#                            -- PMR = 1
                 or UInt32 (PSEL) * (2 ** 16);             -- PSEL in bits [20:16]

      PFS_Unlock;
      Write_PFS (Config.Port, Config.Pin, PFS_Val);
      PFS_Lock;
   end GPIO_Set_Alternate;

   -- GPIO_Set_Alternate_With_IRQ: Same as above but also enables ISEL (bit 26)
   procedure GPIO_Set_IRQ (Config : HAL_Platform.Pin_Config) is
      PFS_Val : UInt32 := 0;
   begin
      -- PMR=0 (GPIO mode for IRQ), ISEL=1 (enable IRQ input)
      PFS_Val := 16#0400_0000#;  -- ISEL bit 26

      PFS_Unlock;
      Write_PFS (Config.Port, Config.Pin, PFS_Val);
      PFS_Lock;
   end GPIO_Set_IRQ;

   -- =============================================================
   -- Basic I/O operations (unchanged – these only touch PORT regs)
   -- =============================================================

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

   -- GPIO_Initialize_All: Unlock PFS write-access and leave locked
   procedure GPIO_Initialize_All is
   begin
      -- Perform one unlock/lock cycle so the PWPR register is in a
      -- known state (B0WI=1). Individual GPIO_Init / GPIO_Set_Alternate
      -- calls unlock/lock as needed.
      PFS_Unlock;
      PFS_Lock;
   end GPIO_Initialize_All;

end HAL_GPIO;
