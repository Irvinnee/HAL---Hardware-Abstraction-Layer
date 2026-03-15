-- UART (Serial) Driver for Arduino Uno R4
-- Hardware UART on D0(RX)/D1(TX) via SCI2 (P301=RXD2, P302=TXD2)
-- Note: USB-CDC serial uses the RA4M1 USB peripheral, not SCI.

with HAL_Platform;
use HAL_Platform;

package HAL_UART is
   pragma Preelaborate;

   -- Baud rates
   type Baud_Rate is (Baud_9600, Baud_19200, Baud_115200);

   -- Data bits
   type Data_Bits is (Bits_8, Bits_9);

   -- Stop bits
   type Stop_Bits is (Stop_1, Stop_2);

   -- Parity
   type Parity_Type is (None, Even, Odd);

   -- UART configuration
   type UART_Config is record
      Baud   : Baud_Rate;
      Data   : Data_Bits;
      Stop   : Stop_Bits;
      Parity : Parity_Type;
   end record;

   -- Default configuration: 9600 baud, 8 data bits, 1 stop bit, no parity
   Default_Config : constant UART_Config := 
      (Baud => Baud_9600, Data => Bits_8, Stop => Stop_1, Parity => None);

   -- Initialize UART (SCI2 on D0/D1 header pins)
   procedure UART_Init (Config : UART_Config := Default_Config);

   -- Send a single character
   procedure UART_Send_Char (Ch : Character);

   -- Send a string
   procedure UART_Send_String (Str : String);

   -- Send a newline
   procedure UART_Send_Line (Str : String);

   -- Receive a single character (blocking)
   function UART_Receive_Char return Character;

   -- Check if data is available to receive
   function UART_Data_Available return Boolean;

   -- Flush the transmit buffer
   procedure UART_Flush;

end HAL_UART;
