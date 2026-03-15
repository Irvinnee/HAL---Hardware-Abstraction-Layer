-- UART Implementation for Renesas RA4M1
-- UNO R4 Minima hardware UART: SCI2  (D0/RX = P301, D1/TX = P302)
-- Note: USB-CDC serial uses the RA4M1 USB peripheral, not SCI.

with System;
with RA4M1_Registers;
use RA4M1_Registers;
with HAL_GPIO;
with HAL_Platform;
use HAL_Platform;

package body HAL_UART is

   -- Calculate BRR value for given baud rate
   -- Formula: BRR = (PCLK / (32 * baud)) - 1  (CKS=00, n=0)
   -- PCLK = 48 MHz
   function Baud_To_BRR (Baud : Baud_Rate) return UInt8 is
   begin
      case Baud is
         when Baud_9600   => return 155;   -- 48M / (32*9600) - 1
         when Baud_19200  => return 77;    -- 48M / (32*19200) - 1
         when Baud_115200 => return 12;    -- 48M / (32*115200) - 1
      end case;
   end Baud_To_BRR;

   -- Initialize UART via SCI2 registers
   procedure UART_Init (Config : UART_Config := Default_Config) is
      SMR_Value : UInt8 := 0;
   begin
      -- 0. Enable SCI2 module clock (MSTPCRB bit 29)
      MSTPCRB := MSTPCRB and (not 16#2000_0000#);

      -- 1. Disable SCI2 transmit/receive
      SCI2.SCR := 0;

      -- 2. Configure RX/TX pins via PFS
      --    D0/RX = P301: PSEL = 05h (SCI2 RXD2), PMR = 1
      --    D1/TX = P302: PSEL = 05h (SCI2 TXD2), PMR = 1, PDR = 1
      HAL_GPIO.GPIO_Set_Alternate (RX_Pin, PSEL_SCI1);   -- SCI2 uses PSEL=05h
      HAL_GPIO.GPIO_Set_Alternate (TX_Pin, PSEL_SCI1);

      -- 3. Configure SMR (Serial Mode Register)
      --    bit 7: CM=0 (async mode)
      --    bit 6: CHR (0=8bit, 1=9bit)
      --    bit 5: PE (parity enable)
      --    bit 4: PM (parity mode: 0=even, 1=odd)
      --    bit 3: STOP (0=1stop, 1=2stop)
      --    bits 1-0: CKS (clock select, 00=PCLK/1)

      case Config.Data is
         when Bits_8 => null;  -- CHR=0 default
         when Bits_9 => SMR_Value := SMR_Value or 16#40#;
      end case;

      case Config.Stop is
         when Stop_1 => null;  -- STOP=0 default
         when Stop_2 => SMR_Value := SMR_Value or 16#08#;
      end case;

      case Config.Parity is
         when None => null;  -- PE=0 default
         when Even => SMR_Value := SMR_Value or 16#20#;
         when Odd  => SMR_Value := SMR_Value or 16#30#;
      end case;

      SCI2.SMR := SMR_Value;

      -- 4. Set baud rate
      SCI2.BRR := Baud_To_BRR (Config.Baud);

      -- 5. Wait 1 bit period for clock to stabilize
      -- (in real implementation: delay based on baud rate)

      -- 6. Enable transmit and receive
      SCI2.SCR := SCR_TE or SCR_RE;
   end UART_Init;

   -- Send character: wait for TDRE, then write to TDR
   procedure UART_Send_Char (Ch : Character) is
   begin
      while (SCI2.SSR and SSR_TDRE) = 0 loop
         null;
      end loop;
      SCI2.TDR := UInt8 (Character'Pos (Ch));
   end UART_Send_Char;

   -- Send string
   procedure UART_Send_String (Str : String) is
   begin
      for Ch of Str loop
         UART_Send_Char (Ch);
      end loop;
   end UART_Send_String;

   -- Send string with newline
   procedure UART_Send_Line (Str : String) is
   begin
      UART_Send_String (Str);
      UART_Send_Char (Character'Val (13));  -- CR
      UART_Send_Char (Character'Val (10));  -- LF
   end UART_Send_Line;

   -- Receive character (blocking): wait for RDRF, then read RDR
   function UART_Receive_Char return Character is
   begin
      while (SCI2.SSR and SSR_RDRF) = 0 loop
         null;
      end loop;
      return Character'Val (SCI2.RDR);
   end UART_Receive_Char;

   -- Check if data available
   function UART_Data_Available return Boolean is
   begin
      return (SCI2.SSR and SSR_RDRF) /= 0;
   end UART_Data_Available;

   -- Flush: wait until transmit complete
   procedure UART_Flush is
   begin
      while (SCI2.SSR and SSR_TEND) = 0 loop
         null;
      end loop;
   end UART_Flush;

end HAL_UART;
