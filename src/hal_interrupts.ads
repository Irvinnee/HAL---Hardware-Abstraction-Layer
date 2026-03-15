-- Interrupt handling for Arduino Uno R4 (ARM Cortex-M4 NVIC)
-- Provides NVIC control and interrupt handler registration

package HAL_Interrupts is
   pragma Preelaborate;

   -- RA4M1 IRQ numbers (selected, commonly used)
   type IRQ_Number is range 0 .. 95;

   -- Common IRQ assignments for Arduino Uno R4 peripherals
   IRQ_PORT_0      : constant IRQ_Number := 0;   -- Port IRQ0
   IRQ_PORT_1      : constant IRQ_Number := 1;   -- Port IRQ1
   IRQ_PORT_2      : constant IRQ_Number := 2;   -- Port IRQ2
   IRQ_PORT_3      : constant IRQ_Number := 3;   -- Port IRQ3
   IRQ_PORT_4      : constant IRQ_Number := 4;   -- Port IRQ4
   IRQ_PORT_5      : constant IRQ_Number := 5;   -- Port IRQ5
   IRQ_PORT_6      : constant IRQ_Number := 6;   -- Port IRQ6
   IRQ_PORT_7      : constant IRQ_Number := 7;   -- Port IRQ7
   IRQ_AGT0_INT    : constant IRQ_Number := 32;  -- AGT0 underflow
   IRQ_AGT0_CMPA   : constant IRQ_Number := 33;  -- AGT0 compare match A
   IRQ_AGT0_CMPB   : constant IRQ_Number := 34;  -- AGT0 compare match B
   IRQ_AGT1_INT    : constant IRQ_Number := 35;  -- AGT1 underflow
   IRQ_IIC0_RXI    : constant IRQ_Number := 52;  -- IIC0 receive
   IRQ_IIC0_TXI    : constant IRQ_Number := 53;  -- IIC0 transmit
   IRQ_IIC0_ERI    : constant IRQ_Number := 56;  -- IIC0 error
   IRQ_SCI0_RXI    : constant IRQ_Number := 64;  -- SCI0 receive
   IRQ_SCI0_TXI    : constant IRQ_Number := 65;  -- SCI0 transmit
   IRQ_SCI0_TEI    : constant IRQ_Number := 66;  -- SCI0 transmit end
   IRQ_ADC0_CMPAI  : constant IRQ_Number := 72;  -- ADC0 scan complete
   IRQ_RTC_ALM     : constant IRQ_Number := 80;  -- RTC alarm
   IRQ_RTC_PRD     : constant IRQ_Number := 81;  -- RTC periodic

   -- Interrupt priority (0 = highest, 15 = lowest)
   type IRQ_Priority is range 0 .. 15;

   -- Interrupt handler callback type
   type IRQ_Handler is access procedure;

   -- Enable a specific IRQ in NVIC
   procedure Enable_IRQ (IRQ : IRQ_Number);

   -- Disable a specific IRQ in NVIC
   procedure Disable_IRQ (IRQ : IRQ_Number);

   -- Set interrupt priority
   procedure Set_Priority (IRQ : IRQ_Number; Priority : IRQ_Priority);

   -- Clear pending interrupt flag
   procedure Clear_Pending (IRQ : IRQ_Number);

   -- Check if interrupt is pending
   function Is_Pending (IRQ : IRQ_Number) return Boolean;

   -- Global interrupt enable (CPSIE I)
   procedure Enable_Interrupts;

   -- Global interrupt disable (CPSID I)
   procedure Disable_Interrupts;

   -- Register a custom interrupt handler
   procedure Register_Handler (IRQ : IRQ_Number; Handler : IRQ_Handler);

end HAL_Interrupts;
