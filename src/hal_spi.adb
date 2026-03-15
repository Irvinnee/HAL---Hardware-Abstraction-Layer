-- SPI Implementation using SCI in Simple SPI mode

with RA4M1_Registers;
use RA4M1_Registers;
with HAL_GPIO;

package body HAL_SPI is

   -- Currently active SCI module for SPI
   Current_Bus : SPI_Bus := SPI_0;

   -- Get SCI registers for current SPI bus
   function Get_SCI return access SCI_Registers_Type is
   begin
      case Current_Bus is
         when SPI_0 => return SCI1'Access;  -- SCI1 = default SPI
         when SPI_1 => return SCI9'Access;  -- SCI9 = alt SPI
      end case;
   end Get_SCI;

   -- Initialize SPI
   procedure SPI_Init (Config : SPI_Config := Default_Config) is
      SCI : access SCI_Registers_Type;
      SMR_Val : UInt8 := SMR_CM;  -- Clock synchronous mode
      BRR_Val : UInt8;
   begin
      Current_Bus := Config.Bus;
      SCI := Get_SCI;

      -- 1. Enable SCI module clock (clear appropriate MSTPCRB bit)
      --    SCI1: bit 30, SCI9: bit 22
      case Config.Bus is
         when SPI_0 => MSTPCRB := MSTPCRB and (not 16#4000_0000#);
         when SPI_1 => MSTPCRB := MSTPCRB and (not 16#0040_0000#);
      end case;

      -- 2. Disable SCI
      SCI.SCR := 0;

      -- 3. Set SMR for clock synchronous (SPI) mode
      --    CM=1 (bit 7), CKS bits for clock divider
      case Config.Clock_Div is
         when Div_2   => SMR_Val := SMR_Val or 16#00#;
         when Div_4   => SMR_Val := SMR_Val or 16#00#;
         when Div_8   => SMR_Val := SMR_Val or 16#01#;
         when Div_16  => SMR_Val := SMR_Val or 16#01#;
         when Div_32  => SMR_Val := SMR_Val or 16#02#;
         when Div_64  => SMR_Val := SMR_Val or 16#02#;
         when Div_128 => SMR_Val := SMR_Val or 16#03#;
      end case;
      SCI.SMR := SMR_Val;

      -- 4. Set BRR for clock speed
      case Config.Clock_Div is
         when Div_2   => BRR_Val := 0;
         when Div_4   => BRR_Val := 1;
         when Div_8   => BRR_Val := 0;
         when Div_16  => BRR_Val := 1;
         when Div_32  => BRR_Val := 0;
         when Div_64  => BRR_Val := 1;
         when Div_128 => BRR_Val := 0;
      end case;
      SCI.BRR := BRR_Val;

      -- 5. Configure SCMR (MSB/LSB first)
      case Config.Order is
         when MSB_First => SCI.SCMR := SCI.SCMR and (not 16#08#);  -- SDIR=0
         when LSB_First => SCI.SCMR := SCI.SCMR or 16#08#;         -- SDIR=1
      end case;

      -- 6. Enable transmit and receive
      SCI.SCR := SCR_TE or SCR_RE;
   end SPI_Init;

   -- Transfer single byte
   function SPI_Transfer (Data : UInt8) return UInt8 is
      SCI : access SCI_Registers_Type := Get_SCI;
   begin
      -- Wait for TDRE (transmit data register empty)
      while (SCI.SSR and SSR_TDRE) = 0 loop
         null;
      end loop;

      -- Write data
      SCI.TDR := Data;

      -- Wait for RDRF (receive data register full)
      while (SCI.SSR and SSR_RDRF) = 0 loop
         null;
      end loop;

      -- Read and return received data
      return SCI.RDR;
   end SPI_Transfer;

   -- Send single byte
   procedure SPI_Send (Data : UInt8) is
      Dummy : UInt8;
   begin
      Dummy := SPI_Transfer (Data);
   end SPI_Send;

   -- Receive single byte
   function SPI_Receive return UInt8 is
   begin
      return SPI_Transfer (16#FF#);  -- Send dummy 0xFF
   end SPI_Receive;

   -- Transfer buffer
   procedure SPI_Transfer_Buffer
     (Tx_Buf : UInt8_Array;
      Rx_Buf : out UInt8_Array;
      Length : Natural) is
   begin
      for I in 0 .. Length - 1 loop
         Rx_Buf (Rx_Buf'First + I) := SPI_Transfer (Tx_Buf (Tx_Buf'First + I));
      end loop;
   end SPI_Transfer_Buffer;

   -- Send buffer
   procedure SPI_Send_Buffer (Buf : UInt8_Array; Length : Natural) is
   begin
      for I in 0 .. Length - 1 loop
         SPI_Send (Buf (Buf'First + I));
      end loop;
   end SPI_Send_Buffer;

   -- Chip Select Low
   procedure SPI_CS_Low (CS_Pin : Pin_Config) is
   begin
      HAL_GPIO.GPIO_Clear (CS_Pin);
   end SPI_CS_Low;

   -- Chip Select High
   procedure SPI_CS_High (CS_Pin : Pin_Config) is
   begin
      HAL_GPIO.GPIO_Set (CS_Pin);
   end SPI_CS_High;

   -- Deinitialize
   procedure SPI_Deinit is
      SCI : access SCI_Registers_Type := Get_SCI;
   begin
      SCI.SCR := 0;  -- Disable transmit and receive
   end SPI_Deinit;

end HAL_SPI;
