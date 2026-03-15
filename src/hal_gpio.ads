-- GPIO (General Purpose Input/Output) Driver for Arduino Uno R4
-- Provides basic digital I/O functionality

with HAL_Platform;
use HAL_Platform;

package HAL_GPIO is
   pragma Preelaborate;

   -- Initialize a pin with given configuration
   procedure GPIO_Init (Pin_Config : HAL_Platform.Pin_Config);

   -- Set a pin to output mode
   procedure GPIO_Set_Mode (Config : HAL_Platform.Pin_Config; Mode : Pin_Mode);

   -- Write a value to an output pin
   procedure GPIO_Write (Config : HAL_Platform.Pin_Config; State : Pin_State);

   -- Read the state of a pin
   function GPIO_Read (Config : HAL_Platform.Pin_Config) return Pin_State;

   -- Set multiple pins at once
   procedure GPIO_Set (Config : HAL_Platform.Pin_Config);

   -- Clear a pin (set to Low)
   procedure GPIO_Clear (Config : HAL_Platform.Pin_Config);

   -- Toggle a pin state
   procedure GPIO_Toggle (Config : HAL_Platform.Pin_Config);

   -- Initialize all GPIO ports
   procedure GPIO_Initialize_All;

end HAL_GPIO;
