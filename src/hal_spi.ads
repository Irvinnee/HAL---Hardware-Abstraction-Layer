-- SPI Driver for Arduino Uno R4
-- Uses SCI module in Simple SPI mode
-- Default: SCI1 (D11=MOSI, D12=MISO, D13=SCK)

with HAL_Platform;
use HAL_Platform;

package HAL_SPI is
   pragma Preelaborate;

   -- SPI bus selection (maps to SCI modules)
   type SPI_Bus is (SPI_0, SPI_1);
   --  SPI_0 = SCI1 (D11/MOSI, D12/MISO, D13/SCK)
   --  SPI_1 = SCI9 (alternative pins)

   -- SPI mode (clock polarity + phase)
   type SPI_Mode is (Mode_0, Mode_1, Mode_2, Mode_3);
   --  Mode 0: CPOL=0, CPHA=0 (idle low, sample on rising)
   --  Mode 1: CPOL=0, CPHA=1 (idle low, sample on falling)
   --  Mode 2: CPOL=1, CPHA=0 (idle high, sample on falling)
   --  Mode 3: CPOL=1, CPHA=1 (idle high, sample on rising)

   -- SPI bit order
   type Bit_Order is (MSB_First, LSB_First);

   -- SPI clock divider
   type SPI_Clock_Div is (Div_2, Div_4, Div_8, Div_16, Div_32, Div_64, Div_128);

   -- SPI configuration
   type SPI_Config is record
      Bus       : SPI_Bus;
      Mode      : SPI_Mode;
      Order     : Bit_Order;
      Clock_Div : SPI_Clock_Div;
   end record;

   -- Default: SPI bus 0, Mode 0, MSB first, PCLK/4
   Default_Config : constant SPI_Config :=
     (Bus => SPI_0, Mode => Mode_0, Order => MSB_First, Clock_Div => Div_4);

   -- Initialize SPI
   procedure SPI_Init (Config : SPI_Config := Default_Config);

   -- Transfer single byte (send and receive simultaneously)
   function SPI_Transfer (Data : UInt8) return UInt8;

   -- Send single byte (ignore received data)
   procedure SPI_Send (Data : UInt8);

   -- Receive single byte (send 0xFF dummy)
   function SPI_Receive return UInt8;

   -- Transfer buffer (send and receive)
   procedure SPI_Transfer_Buffer
     (Tx_Buf : UInt8_Array;
      Rx_Buf : out UInt8_Array;
      Length : Natural);

   -- Send buffer
   procedure SPI_Send_Buffer (Buf : UInt8_Array; Length : Natural);

   -- Set CS (Chip Select) pin manually
   procedure SPI_CS_Low (CS_Pin : Pin_Config);
   procedure SPI_CS_High (CS_Pin : Pin_Config);

   -- Deinitialize SPI
   procedure SPI_Deinit;

end HAL_SPI;
