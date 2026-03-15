-- I2C (IIC) Driver for Arduino Uno R4
-- Uses dedicated IIC module (not SCI)
-- Default: IIC0 (A4=SDA, A5=SCL)

with HAL_Platform;
use HAL_Platform;

package HAL_I2C is
   pragma Preelaborate;

   -- I2C bus selection
   type I2C_Bus is (I2C_0, I2C_1);
   --  I2C_0 = IIC0 (A4/SDA, A5/SCL) - default Arduino I2C
   --  I2C_1 = IIC1 (alternative pins)

   -- I2C speed
   type I2C_Speed is (Standard_100K, Fast_400K, Fast_Plus_1M);

   -- I2C 7-bit address
   type I2C_Address is range 0 .. 127;

   -- I2C status
   type I2C_Status is (OK, NACK, Bus_Error, Timeout, Busy);

   -- I2C configuration
   type I2C_Config is record
      Bus   : I2C_Bus;
      Speed : I2C_Speed;
   end record;

   -- Default: Bus 0, 100 kHz
   Default_Config : constant I2C_Config :=
     (Bus => I2C_0, Speed => Standard_100K);

   -- Initialize I2C
   procedure I2C_Init (Config : I2C_Config := Default_Config);

   -- Write data to a slave device
   function I2C_Write
     (Addr   : I2C_Address;
      Data   : UInt8_Array;
      Length : Natural) return I2C_Status;

   -- Read data from a slave device
   function I2C_Read
     (Addr   : I2C_Address;
      Data   : out UInt8_Array;
      Length : Natural) return I2C_Status;

   -- Write then read (common pattern: write register address, read value)
   function I2C_Write_Read
     (Addr     : I2C_Address;
      Tx_Data  : UInt8_Array;
      Tx_Len   : Natural;
      Rx_Data  : out UInt8_Array;
      Rx_Len   : Natural) return I2C_Status;

   -- Write single byte to register
   function I2C_Write_Register
     (Addr     : I2C_Address;
      Register : UInt8;
      Value    : UInt8) return I2C_Status;

   -- Read single byte from register
   function I2C_Read_Register
     (Addr     : I2C_Address;
      Register : UInt8;
      Value    : out UInt8) return I2C_Status;

   -- Scan bus for devices (returns True if device responds)
   function I2C_Device_Present (Addr : I2C_Address) return Boolean;

   -- Deinitialize I2C
   procedure I2C_Deinit;

end HAL_I2C;
