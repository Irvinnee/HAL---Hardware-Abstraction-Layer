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
   
   -- ================================================================
   -- Arduino Uno R4 Minima pin mapping
   -- Source: ArduinoCore-renesas variants/MINIMA/variant.cpp
   -- ================================================================

   -- Digital pins D0-D13
   D0_Pin   : constant Pin_Config := (Port => PORT_3, Pin => 1,  Mode => Input);     -- P301  RX (SCI2)
   D1_Pin   : constant Pin_Config := (Port => PORT_3, Pin => 2,  Mode => Input);     -- P302  TX (SCI2)
   D2_Pin   : constant Pin_Config := (Port => PORT_1, Pin => 4,  Mode => Input);     -- P104  IRQ1
   D3_Pin   : constant Pin_Config := (Port => PORT_1, Pin => 5,  Mode => Input);     -- P105  IRQ0 / PWM
   D4_Pin   : constant Pin_Config := (Port => PORT_1, Pin => 6,  Mode => Input);     -- P106
   D5_Pin   : constant Pin_Config := (Port => PORT_1, Pin => 7,  Mode => Input);     -- P107  PWM
   D6_Pin   : constant Pin_Config := (Port => PORT_1, Pin => 11, Mode => Input);     -- P111  PWM
   D7_Pin   : constant Pin_Config := (Port => PORT_1, Pin => 12, Mode => Input);     -- P112
   D8_Pin   : constant Pin_Config := (Port => PORT_3, Pin => 4,  Mode => Input);     -- P304
   D9_Pin   : constant Pin_Config := (Port => PORT_3, Pin => 3,  Mode => Input);     -- P303  PWM
   D10_Pin  : constant Pin_Config := (Port => PORT_1, Pin => 3,  Mode => Input);     -- P103  PWM / SS
   D11_Pin  : constant Pin_Config := (Port => PORT_1, Pin => 9,  Mode => Input);     -- P109  PWM / MOSI
   D12_Pin  : constant Pin_Config := (Port => PORT_1, Pin => 10, Mode => Input);     -- P110  MISO
   D13_Pin  : constant Pin_Config := (Port => PORT_1, Pin => 11, Mode => Input);     -- P111  SCK / LED

   -- Analog pins A0-A5
   A0_Pin   : constant Pin_Config := (Port => PORT_0, Pin => 14, Mode => Analog);    -- P014
   A1_Pin   : constant Pin_Config := (Port => PORT_0, Pin => 0,  Mode => Analog);    -- P000
   A2_Pin   : constant Pin_Config := (Port => PORT_0, Pin => 1,  Mode => Analog);    -- P001
   A3_Pin   : constant Pin_Config := (Port => PORT_0, Pin => 2,  Mode => Analog);    -- P002
   A4_Pin   : constant Pin_Config := (Port => PORT_1, Pin => 1,  Mode => Analog);    -- P101  SDA (IIC1)
   A5_Pin   : constant Pin_Config := (Port => PORT_1, Pin => 0,  Mode => Analog);    -- P100  SCL (IIC1)

   -- Convenience aliases
   LED_Pin  : constant Pin_Config := (Port => PORT_1, Pin => 11, Mode => Output);    -- D13 = P111
   RX_Pin   : constant Pin_Config := (Port => PORT_3, Pin => 1,  Mode => Alternate); -- D0  = P301 (SCI2 RXD)
   TX_Pin   : constant Pin_Config := (Port => PORT_3, Pin => 2,  Mode => Alternate); -- D1  = P302 (SCI2 TXD)

   -- I2C pins  (IIC1 on UNO R4 Minima; IIC0 is not routed to headers)
   SDA_Pin  : constant Pin_Config := (Port => PORT_1, Pin => 1,  Mode => Alternate); -- A4 = P101
   SCL_Pin  : constant Pin_Config := (Port => PORT_1, Pin => 0,  Mode => Alternate); -- A5 = P100

   -- SPI pins
   MOSI_Pin : constant Pin_Config := (Port => PORT_1, Pin => 9,  Mode => Alternate); -- D11 = P109
   MISO_Pin : constant Pin_Config := (Port => PORT_1, Pin => 10, Mode => Alternate); -- D12 = P110
   SCK_Pin  : constant Pin_Config := (Port => PORT_1, Pin => 11, Mode => Alternate); -- D13 = P111

   -- ================================================================
   -- PFS PSEL codes (peripheral select for PmnPFS register bits 24-20)
   -- Reference: RA4M1 User's Manual Table 19.5
   -- ================================================================
   PSEL_GPIO     : constant UInt8 := 16#00#;  -- Hi-Z / GPIO
   PSEL_AGT      : constant UInt8 := 16#01#;  -- AGT
   PSEL_GPT1     : constant UInt8 := 16#02#;  -- GPT1
   PSEL_GPT2     : constant UInt8 := 16#03#;  -- GPT2
   PSEL_SCI0     : constant UInt8 := 16#04#;  -- SCI0/1 (UART/SPI)
   PSEL_SCI1     : constant UInt8 := 16#05#;  -- SCI2/9
   PSEL_SPI      : constant UInt8 := 16#06#;  -- RSPI
   PSEL_IIC      : constant UInt8 := 16#07#;  -- IIC
   PSEL_CLKOUT   : constant UInt8 := 16#09#;  -- Clock output
   PSEL_CAC_ADC  : constant UInt8 := 16#0E#;  -- CAC / ADC trigger

end HAL_Platform;
