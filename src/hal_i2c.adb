-- I2C Implementation using IIC module

with RA4M1_Registers;
use RA4M1_Registers;
with HAL_GPIO;
with HAL_Platform;
use HAL_Platform;

package body HAL_I2C is

   -- Currently selected bus
   Current_Bus : I2C_Bus := I2C_0;

   -- Get IIC registers
   function Get_IIC return access IIC_Registers_Type is
   begin
      case Current_Bus is
         when I2C_0 => return IIC0'Access;
         when I2C_1 => return IIC1'Access;
      end case;
   end Get_IIC;

   -- Wait for TDRE with timeout
   function Wait_TDRE return Boolean is
      IIC : access IIC_Registers_Type := Get_IIC;
      Timeout : Natural := 100_000;
   begin
      while (IIC.ICSR2 and ICSR2_TDRE) = 0 loop
         Timeout := Timeout - 1;
         if Timeout = 0 then
            return False;
         end if;
      end loop;
      return True;
   end Wait_TDRE;

   -- Wait for RDRF with timeout
   function Wait_RDRF return Boolean is
      IIC : access IIC_Registers_Type := Get_IIC;
      Timeout : Natural := 100_000;
   begin
      while (IIC.ICSR2 and ICSR2_RDRF) = 0 loop
         Timeout := Timeout - 1;
         if Timeout = 0 then
            return False;
         end if;
      end loop;
      return True;
   end Wait_RDRF;

   -- Wait for stop condition
   function Wait_Stop return Boolean is
      IIC : access IIC_Registers_Type := Get_IIC;
      Timeout : Natural := 100_000;
   begin
      while (IIC.ICSR2 and ICSR2_STOP) = 0 loop
         Timeout := Timeout - 1;
         if Timeout = 0 then
            return False;
         end if;
      end loop;
      -- Clear stop flag
      IIC.ICSR2 := IIC.ICSR2 and (not ICSR2_STOP);
      return True;
   end Wait_Stop;

   -- Initialize I2C
   procedure I2C_Init (Config : I2C_Config := Default_Config) is
      IIC : access IIC_Registers_Type;
   begin
      Current_Bus := Config.Bus;
      IIC := Get_IIC;

      -- 1. Enable IIC module clock (clear MSTPCRB bit)
      --    IIC0: bit 9, IIC1: bit 8
      case Config.Bus is
         when I2C_0 => MSTPCRB := MSTPCRB and (not 16#0000_0200#);
         when I2C_1 => MSTPCRB := MSTPCRB and (not 16#0000_0100#);
      end case;

      -- 2. Disable IIC before configuration
      IIC.ICCR1 := 0;

      -- 2b. Configure SDA/SCL pins via PFS (PSEL=07h = IIC)
      HAL_GPIO.GPIO_Set_Alternate (SDA_Pin, PSEL_IIC);
      HAL_GPIO.GPIO_Set_Alternate (SCL_Pin, PSEL_IIC);

      -- 3. Reset IIC
      IIC.ICCR1 := ICCR1_IICRST;
      IIC.ICCR1 := 0;

      -- 4. Set bit rate
      --    For PCLKB = 48 MHz:
      --    Standard (100K): ICBRL=0xFB, ICBRH=0xF8 (approx)
      --    Fast (400K):     ICBRL=0x3D, ICBRH=0x38
      --    Fast+ (1M):      ICBRL=0x17, ICBRH=0x12
      case Config.Speed is
         when Standard_100K =>
            IIC.ICMR1 := 16#28#;  -- CKS=5 (PCLKB/32)
            IIC.ICBRL := 16#FB#;
            IIC.ICBRH := 16#F8#;
         when Fast_400K =>
            IIC.ICMR1 := 16#18#;  -- CKS=3 (PCLKB/8)
            IIC.ICBRL := 16#3D#;
            IIC.ICBRH := 16#38#;
         when Fast_Plus_1M =>
            IIC.ICMR1 := 16#08#;  -- CKS=1 (PCLKB/2)
            IIC.ICBRL := 16#17#;
            IIC.ICBRH := 16#12#;
      end case;

      -- 5. Configure function enable register
      IIC.ICFER := 16#77#;  -- Enable timeout, master arbitration, NACK detection

      -- 6. Configure mode registers
      IIC.ICMR2 := 16#06#;  -- Timeout enable
      IIC.ICMR3 := ICMR3_ACKWP;  -- Allow ACKBT writes

      -- 7. Enable IIC
      IIC.ICCR1 := ICCR1_ICE;
   end I2C_Init;

   -- Write data to slave
   function I2C_Write
     (Addr   : I2C_Address;
      Data   : UInt8_Array;
      Length : Natural) return I2C_Status
   is
      IIC : access IIC_Registers_Type := Get_IIC;
   begin
      -- Check bus not busy
      if (IIC.ICCR2 and ICCR2_BBSY) /= 0 then
         return Busy;
      end if;

      -- Set master transmit mode
      IIC.ICCR2 := ICCR2_MST or ICCR2_TRS;

      -- Generate start condition
      IIC.ICCR2 := IIC.ICCR2 or ICCR2_ST;

      -- Wait for TDRE then send address (write: bit 0 = 0)
      if not Wait_TDRE then
         return Timeout;
      end if;
      IIC.ICDRT := UInt8 (Natural (Addr) * 2);  -- Address + W bit

      -- Check for NACK
      if (IIC.ICSR2 and ICSR2_NACKF) /= 0 then
         IIC.ICSR2 := IIC.ICSR2 and (not ICSR2_NACKF);
         IIC.ICCR2 := IIC.ICCR2 or ICCR2_SP;  -- Stop
         if not Wait_Stop then null; end if;
         return NACK;
      end if;

      -- Send data bytes
      for I in 0 .. Length - 1 loop
         if not Wait_TDRE then
            return Timeout;
         end if;

         -- Check NACK
         if (IIC.ICSR2 and ICSR2_NACKF) /= 0 then
            IIC.ICSR2 := IIC.ICSR2 and (not ICSR2_NACKF);
            IIC.ICCR2 := IIC.ICCR2 or ICCR2_SP;
            if not Wait_Stop then null; end if;
            return NACK;
         end if;

         IIC.ICDRT := Data (Data'First + I);
      end loop;

      -- Wait for last byte to finish
      if not Wait_TDRE then
         return Timeout;
      end if;

      -- Generate stop condition
      IIC.ICCR2 := IIC.ICCR2 or ICCR2_SP;
      if not Wait_Stop then
         return Timeout;
      end if;

      return OK;
   end I2C_Write;

   -- Read data from slave
   function I2C_Read
     (Addr   : I2C_Address;
      Data   : out UInt8_Array;
      Length : Natural) return I2C_Status
   is
      IIC : access IIC_Registers_Type := Get_IIC;
   begin
      if (IIC.ICCR2 and ICCR2_BBSY) /= 0 then
         return Busy;
      end if;

      -- Set master transmit (for address phase)
      IIC.ICCR2 := ICCR2_MST or ICCR2_TRS;

      -- Start
      IIC.ICCR2 := IIC.ICCR2 or ICCR2_ST;

      -- Send address (read: bit 0 = 1)
      if not Wait_TDRE then
         return Timeout;
      end if;
      IIC.ICDRT := UInt8 (Natural (Addr) * 2 + 1);  -- Address + R bit

      -- Switch to receive mode
      IIC.ICCR2 := IIC.ICCR2 and (not ICCR2_TRS);

      -- Read data bytes
      for I in 0 .. Length - 1 loop
         -- Last byte: send NACK
         if I = Length - 1 then
            IIC.ICMR3 := ICMR3_ACKWP or ICMR3_ACKBT;  -- NACK
         else
            IIC.ICMR3 := ICMR3_ACKWP;  -- ACK
         end if;

         if not Wait_RDRF then
            return Timeout;
         end if;

         Data (Data'First + I) := IIC.ICDRR;
      end loop;

      -- Stop
      IIC.ICCR2 := IIC.ICCR2 or ICCR2_SP;
      if not Wait_Stop then
         return Timeout;
      end if;

      return OK;
   end I2C_Read;

   -- Write then read
   function I2C_Write_Read
     (Addr     : I2C_Address;
      Tx_Data  : UInt8_Array;
      Tx_Len   : Natural;
      Rx_Data  : out UInt8_Array;
      Rx_Len   : Natural) return I2C_Status
   is
      IIC : access IIC_Registers_Type := Get_IIC;
   begin
      if (IIC.ICCR2 and ICCR2_BBSY) /= 0 then
         return Busy;
      end if;

      -- Master transmit
      IIC.ICCR2 := ICCR2_MST or ICCR2_TRS;
      IIC.ICCR2 := IIC.ICCR2 or ICCR2_ST;

      -- Send address (write)
      if not Wait_TDRE then return Timeout; end if;
      IIC.ICDRT := UInt8 (Natural (Addr) * 2);

      if (IIC.ICSR2 and ICSR2_NACKF) /= 0 then
         IIC.ICSR2 := IIC.ICSR2 and (not ICSR2_NACKF);
         IIC.ICCR2 := IIC.ICCR2 or ICCR2_SP;
         if not Wait_Stop then null; end if;
         return NACK;
      end if;

      -- Send TX data
      for I in 0 .. Tx_Len - 1 loop
         if not Wait_TDRE then return Timeout; end if;
         IIC.ICDRT := Tx_Data (Tx_Data'First + I);
      end loop;

      if not Wait_TDRE then return Timeout; end if;

      -- Repeated start
      IIC.ICCR2 := IIC.ICCR2 or ICCR2_RS;

      -- Send address (read)
      if not Wait_TDRE then return Timeout; end if;
      IIC.ICDRT := UInt8 (Natural (Addr) * 2 + 1);

      -- Switch to receive
      IIC.ICCR2 := IIC.ICCR2 and (not ICCR2_TRS);

      -- Read RX data
      for I in 0 .. Rx_Len - 1 loop
         if I = Rx_Len - 1 then
            IIC.ICMR3 := ICMR3_ACKWP or ICMR3_ACKBT;
         else
            IIC.ICMR3 := ICMR3_ACKWP;
         end if;

         if not Wait_RDRF then return Timeout; end if;
         Rx_Data (Rx_Data'First + I) := IIC.ICDRR;
      end loop;

      -- Stop
      IIC.ICCR2 := IIC.ICCR2 or ICCR2_SP;
      if not Wait_Stop then return Timeout; end if;

      return OK;
   end I2C_Write_Read;

   -- Write single register
   function I2C_Write_Register
     (Addr     : I2C_Address;
      Register : UInt8;
      Value    : UInt8) return I2C_Status
   is
      Buf : UInt8_Array (0 .. 1) := (Register, Value);
   begin
      return I2C_Write (Addr, Buf, 2);
   end I2C_Write_Register;

   -- Read single register
   function I2C_Read_Register
     (Addr     : I2C_Address;
      Register : UInt8;
      Value    : out UInt8) return I2C_Status
   is
      Tx : UInt8_Array (0 .. 0) := (0 => Register);
      Rx : UInt8_Array (0 .. 0);
      Status : I2C_Status;
   begin
      Status := I2C_Write_Read (Addr, Tx, 1, Rx, 1);
      Value := Rx (0);
      return Status;
   end I2C_Read_Register;

   -- Device present check
   function I2C_Device_Present (Addr : I2C_Address) return Boolean is
      IIC : access IIC_Registers_Type := Get_IIC;
   begin
      if (IIC.ICCR2 and ICCR2_BBSY) /= 0 then
         return False;
      end if;

      -- Try to address device (write mode)
      IIC.ICCR2 := ICCR2_MST or ICCR2_TRS;
      IIC.ICCR2 := IIC.ICCR2 or ICCR2_ST;

      if not Wait_TDRE then
         return False;
      end if;
      IIC.ICDRT := UInt8 (Natural (Addr) * 2);

      if not Wait_TDRE then
         IIC.ICCR2 := IIC.ICCR2 or ICCR2_SP;
         if not Wait_Stop then null; end if;
         return False;
      end if;

      -- Check for ACK/NACK
      if (IIC.ICSR2 and ICSR2_NACKF) /= 0 then
         IIC.ICSR2 := IIC.ICSR2 and (not ICSR2_NACKF);
         IIC.ICCR2 := IIC.ICCR2 or ICCR2_SP;
         if not Wait_Stop then null; end if;
         return False;  -- Device not found
      end if;

      -- Device responded with ACK
      IIC.ICCR2 := IIC.ICCR2 or ICCR2_SP;
      if not Wait_Stop then null; end if;
      return True;
   end I2C_Device_Present;

   -- Deinitialize
   procedure I2C_Deinit is
      IIC : access IIC_Registers_Type := Get_IIC;
   begin
      IIC.ICCR1 := 0;  -- Disable IIC
   end I2C_Deinit;

end HAL_I2C;
