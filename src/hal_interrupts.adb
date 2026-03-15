-- Interrupt handling implementation for ARM Cortex-M4 NVIC

with System.Machine_Code;
use System.Machine_Code;
with RA4M1_Registers;
use RA4M1_Registers;

package body HAL_Interrupts is

   -- Handler table (user-registered callbacks)
   type Handler_Array is array (IRQ_Number) of IRQ_Handler;
   Handlers : Handler_Array := (others => null);

   -- Helper: get ISER/ICER register and bit position for an IRQ
   procedure Get_IRQ_Reg_Bit (IRQ : IRQ_Number;
                               Reg_Index : out Natural;
                               Bit_Pos   : out Natural) is
   begin
      Reg_Index := Natural (IRQ) / 32;
      Bit_Pos   := Natural (IRQ) mod 32;
   end Get_IRQ_Reg_Bit;

   -- Enable a specific IRQ in NVIC
   procedure Enable_IRQ (IRQ : IRQ_Number) is
      Reg_Idx : Natural;
      Bit_Pos : Natural;
      Mask    : UInt32;
   begin
      Get_IRQ_Reg_Bit (IRQ, Reg_Idx, Bit_Pos);
      Mask := UInt32 (2 ** Bit_Pos);
      case Reg_Idx is
         when 0 => NVIC_ISER0 := Mask;
         when 1 => NVIC_ISER1 := Mask;
         when 2 => NVIC_ISER2 := Mask;
         when others => null;
      end case;
   end Enable_IRQ;

   -- Disable a specific IRQ
   procedure Disable_IRQ (IRQ : IRQ_Number) is
      Reg_Idx : Natural;
      Bit_Pos : Natural;
      Mask    : UInt32;
   begin
      Get_IRQ_Reg_Bit (IRQ, Reg_Idx, Bit_Pos);
      Mask := UInt32 (2 ** Bit_Pos);
      case Reg_Idx is
         when 0 => NVIC_ICER0 := Mask;
         when 1 => NVIC_ICER1 := Mask;
         when 2 => NVIC_ICER2 := Mask;
         when others => null;
      end case;
   end Disable_IRQ;

   -- Set interrupt priority
   procedure Set_Priority (IRQ : IRQ_Number; Priority : IRQ_Priority) is
      IPR_Addr : System.Address;
      IPR_Byte : UInt8;
      pragma Import (Ada, IPR_Byte);
   begin
      -- Each IRQ has 1 byte in IPR, only top 4 bits are used on Cortex-M4
      IPR_Addr := NVIC_IPR_Base + System.Storage_Elements.Storage_Offset (Natural (IRQ));
      for IPR_Byte'Address use IPR_Addr;
      pragma Volatile (IPR_Byte);
      IPR_Byte := UInt8 (Natural (Priority) * 16);  -- Shift to top 4 bits
   end Set_Priority;

   -- Clear pending interrupt
   procedure Clear_Pending (IRQ : IRQ_Number) is
      Reg_Idx : Natural;
      Bit_Pos : Natural;
      Mask    : UInt32;
   begin
      Get_IRQ_Reg_Bit (IRQ, Reg_Idx, Bit_Pos);
      Mask := UInt32 (2 ** Bit_Pos);
      -- Write to ICPR (same layout as ISER)
      case Reg_Idx is
         when 0 => NVIC_ICPR0 := Mask;
         when others => null;  -- Extend for more registers
      end case;
   end Clear_Pending;

   -- Check if interrupt is pending
   function Is_Pending (IRQ : IRQ_Number) return Boolean is
      Reg_Idx : Natural;
      Bit_Pos : Natural;
      Mask    : UInt32;
   begin
      Get_IRQ_Reg_Bit (IRQ, Reg_Idx, Bit_Pos);
      Mask := UInt32 (2 ** Bit_Pos);
      case Reg_Idx is
         when 0 => return (NVIC_ISPR0 and Mask) /= 0;
         when others => return False;
      end case;
   end Is_Pending;

   -- Global interrupt enable (CPSIE I)
   procedure Enable_Interrupts is
   begin
      Asm ("cpsie i", Volatile => True);
   end Enable_Interrupts;

   -- Global interrupt disable (CPSID I)
   procedure Disable_Interrupts is
   begin
      Asm ("cpsid i", Volatile => True);
   end Disable_Interrupts;

   -- Register a custom interrupt handler
   procedure Register_Handler (IRQ : IRQ_Number; Handler : IRQ_Handler) is
   begin
      Handlers (IRQ) := Handler;
   end Register_Handler;

end HAL_Interrupts;
