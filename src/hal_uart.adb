-- UART Implementation for Renesas RA4M1
-- Uses SCI (Serial Communication Interface) module 0

with System;
with RA4M1_Registers;
use RA4M1_Registers;

package body HAL_UART is

   -- Calculate BRR value for given baud rate
   -- Formula: BRR = (PCLK / (8 * 2^(2n-1) * baud)) - 1
   -- For PCLK = 48 MHz, n=0 (CKS=00):
   --   BRR = (48_000_000 / (32 * baud)) - 1
   function Baud_To_BRR (Baud : Baud_Rate) return UInt8 is
   begin
      case Baud is
         when Baud_9600   => return 155;   -- 48M / (32*9600) - 1
         when Baud_19200  => return 77;    -- 48M / (32*19200) - 1
         when Baud_115200 => return 12;    -- 48M / (32*115200) - 1
      end case;
   end Baud_To_BRR;

   -- Initialize UART via SCI0 registers
   procedure UART_Init (Config : UART_Config := Default_Config) is
      SMR_Value : UInt8 := 0;
   begin
      -- 1. Disable SCI0 transmit/receive
      SCI0.SCR := 0;

      -- 2. Configure SMR (Serial Mode Register)
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

      SCI0.SMR := SMR_Value;

      -- 3. Set baud rate
      SCI0.BRR := Baud_To_BRR (Config.Baud);

      -- 4. Wait 1 bit period for clock to stabilize
      -- (in real implementation: delay based on baud rate)

      -- 5. Enable transmit and receive
      --    SCR: TE=1 (bit 5), RE=1 (bit 4)
      SCI0.SCR := SCR_TE or SCR_RE;
   end UART_Init;

   -- Send character: wait for TDRE, then write to TDR
   procedure UART_Send_Char (Ch : Character) is
   begin
      -- Wait until Transmit Data Register is empty
      while (SCI0.SSR and SSR_TDRE) = 0 loop
         null;
      end loop;
      -- Write character
      SCI0.TDR := UInt8 (Character'Pos (Ch));
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
      -- Wait until Receive Data Register is full
      while (SCI0.SSR and SSR_RDRF) = 0 loop
         null;
      end loop;
      return Character'Val (SCI0.RDR);
   end UART_Receive_Char;

   -- Check if data available
   function UART_Data_Available return Boolean is
   begin
      return (SCI0.SSR and SSR_RDRF) /= 0;
   end UART_Data_Available;

   -- Flush: wait until transmit complete
   procedure UART_Flush is
   begin
      while (SCI0.SSR and SSR_TEND) = 0 loop
         null;
      end loop;
   end UART_Flush;

end HAL_UART;
