-- Pin Interrupt implementation using ICU (Interrupt Controller Unit)

with RA4M1_Registers;
use RA4M1_Registers;
with HAL_Interrupts;

package body HAL_Pin_Interrupt is

   -- Callback table
   type Callback_Array is array (IRQ_Channel) of Pin_IRQ_Callback;
   Callbacks : Callback_Array := (others => null);

   -- IRQ channel to NVIC IRQ number mapping
   function Channel_To_IRQ (Channel : IRQ_Channel) return HAL_Interrupts.IRQ_Number is
   begin
      case Channel is
         when IRQ0 => return HAL_Interrupts.IRQ_PORT_0;
         when IRQ1 => return HAL_Interrupts.IRQ_PORT_1;
         when IRQ2 => return HAL_Interrupts.IRQ_PORT_2;
         when IRQ3 => return HAL_Interrupts.IRQ_PORT_3;
         when IRQ4 => return HAL_Interrupts.IRQ_PORT_4;
         when IRQ5 => return HAL_Interrupts.IRQ_PORT_5;
         when IRQ6 => return HAL_Interrupts.IRQ_PORT_6;
         when IRQ7 => return HAL_Interrupts.IRQ_PORT_7;
      end case;
   end Channel_To_IRQ;

   -- Edge detect to IRQCR value
   function Edge_To_IRQCR (Edge : Edge_Detect) return UInt8 is
   begin
      case Edge is
         when Falling_Edge => return 16#00#;  -- IRQMD=00
         when Rising_Edge  => return 16#04#;  -- IRQMD=01
         when Both_Edges   => return 16#08#;  -- IRQMD=10
         when Low_Level    => return 16#0C#;  -- IRQMD=11
      end case;
   end Edge_To_IRQCR;

   -- Get IRQCR register for channel
   procedure Write_IRQCR (Channel : IRQ_Channel; Value : UInt8) is
      Ch_Num : Natural := IRQ_Channel'Pos (Channel);
      Addr   : System.Address := IRQCR_Address (Ch_Num);
      Reg    : UInt8;
      pragma Import (Ada, Reg);
      for Reg'Address use Addr;
      pragma Volatile (Reg);
   begin
      Reg := Value;
   end Write_IRQCR;

   -- Attach interrupt with config
   procedure Attach_Interrupt (Config : Pin_IRQ_Config) is
   begin
      -- Store callback
      Callbacks (Config.Channel) := Config.Callback;

      -- Configure edge detection in IRQCR
      Write_IRQCR (Config.Channel, Edge_To_IRQCR (Config.Edge));

      -- Enable in NVIC
      HAL_Interrupts.Clear_Pending (Channel_To_IRQ (Config.Channel));
      HAL_Interrupts.Enable_IRQ (Channel_To_IRQ (Config.Channel));
   end Attach_Interrupt;

   -- Attach interrupt (Arduino-style)
   procedure Attach_Interrupt
     (Pin      : Pin_Config;
      Channel  : IRQ_Channel;
      Edge     : Edge_Detect;
      Callback : Pin_IRQ_Callback)
   is
      Config : Pin_IRQ_Config := (Channel => Channel,
                                   Edge => Edge,
                                   Callback => Callback);
   begin
      -- Configure pin for IRQ input via PFS (set ISEL bit)
      -- This requires PFS write enable (PWPR)
      -- Simplified: assume pin is already configured

      Attach_Interrupt (Config);
   end Attach_Interrupt;

   -- Detach interrupt
   procedure Detach_Interrupt (Channel : IRQ_Channel) is
   begin
      HAL_Interrupts.Disable_IRQ (Channel_To_IRQ (Channel));
      Callbacks (Channel) := null;
   end Detach_Interrupt;

   -- Enable interrupt
   procedure Enable_Pin_IRQ (Channel : IRQ_Channel) is
   begin
      HAL_Interrupts.Enable_IRQ (Channel_To_IRQ (Channel));
   end Enable_Pin_IRQ;

   -- Disable interrupt
   procedure Disable_Pin_IRQ (Channel : IRQ_Channel) is
   begin
      HAL_Interrupts.Disable_IRQ (Channel_To_IRQ (Channel));
   end Disable_Pin_IRQ;

   -- Change edge detect
   procedure Set_Edge_Detect (Channel : IRQ_Channel; Edge : Edge_Detect) is
   begin
      Write_IRQCR (Channel, Edge_To_IRQCR (Edge));
   end Set_Edge_Detect;

   -- Check IRQ flag
   function IRQ_Flag_Set (Channel : IRQ_Channel) return Boolean is
   begin
      return HAL_Interrupts.Is_Pending (Channel_To_IRQ (Channel));
   end IRQ_Flag_Set;

   -- Clear flag
   procedure Clear_IRQ_Flag (Channel : IRQ_Channel) is
   begin
      HAL_Interrupts.Clear_Pending (Channel_To_IRQ (Channel));
   end Clear_IRQ_Flag;

   -- Initialize
   procedure Pin_IRQ_Initialize is
   begin
      -- Disable all pin interrupts initially
      for Ch in IRQ_Channel loop
         Detach_Interrupt (Ch);
      end loop;
   end Pin_IRQ_Initialize;

end HAL_Pin_Interrupt;
