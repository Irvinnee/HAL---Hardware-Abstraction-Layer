-- HAL Platform definitions for Arduino Uno R4 Minima (Renesas RA4M1)
-- Basic hardware abstraction layer

package HAL_Platform is
   pragma Pure;

   -- Base types
   type UInt8  is mod 2**8  with Size => 8;
   type UInt16 is mod 2**16 with Size => 16;
   type UInt32 is mod 2**32 with Size => 32;

   -- Array types for buffer operations
   type UInt8_Array is array (Natural range <>) of UInt8;

   -- Port definitions
   type Port_Type is (PORT_0, PORT_1, PORT_2, PORT_3, PORT_4, PORT_5, PORT_6, PORT_9);
   
   -- Pin numbers per port (0-15 for most ports)
   type Pin_Number is range 0 .. 15;
   
   -- Pin modes
   type Pin_Mode is (Input, Output, Alternate, Analog);
   
   -- Pin states
   type Pin_State is (Low, High);
   
   -- Frequency types
   type Frequency_Hz is range 0 .. 2_000_000_000;  -- Up to 2 GHz
   
   -- Pin configuration record
   type Pin_Config is record
      Port : Port_Type;
      Pin  : Pin_Number;
      Mode : Pin_Mode;
   end record;
   
   -- Common pins for Arduino Uno R4 Minima
   -- Digital pins (D0-D13)
   LED_Pin        : constant Pin_Config := (Port => PORT_1, Pin => 2, Mode => Output);  -- Built-in LED (D13)
   RX_Pin         : constant Pin_Config := (Port => PORT_3, Pin => 0, Mode => Alternate); -- D0
   TX_Pin         : constant Pin_Config := (Port => PORT_3, Pin => 1, Mode => Alternate); -- D1

   -- I2C pins
   SDA_Pin        : constant Pin_Config := (Port => PORT_4, Pin => 7, Mode => Alternate); -- A4/SDA
   SCL_Pin        : constant Pin_Config := (Port => PORT_4, Pin => 0, Mode => Alternate); -- A5/SCL

   -- SPI pins
   MOSI_Pin       : constant Pin_Config := (Port => PORT_1, Pin => 9, Mode => Alternate); -- D11
   MISO_Pin       : constant Pin_Config := (Port => PORT_1, Pin => 10, Mode => Alternate); -- D12
   SCK_Pin        : constant Pin_Config := (Port => PORT_1, Pin => 2, Mode => Alternate); -- D13

   -- Interrupt-capable pins
   D2_Pin         : constant Pin_Config := (Port => PORT_3, Pin => 1, Mode => Input);  -- IRQ6
   D3_Pin         : constant Pin_Config := (Port => PORT_1, Pin => 5, Mode => Input);  -- IRQ5

end HAL_Platform;
