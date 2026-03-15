-- HAL Implementation - Initialize all hardware modules

with HAL_GPIO;
with HAL_UART;
with HAL_ADC;
with HAL_PWM;

package body HAL is

   procedure Initialize_All is
   begin
      -- Initialize GPIO first (needed for all pin operations)
      HAL_GPIO.GPIO_Initialize_All;
      
      -- Initialize UART (Serial)
      HAL_UART.UART_Init (HAL_UART.Default_Config);
      
      -- Initialize ADC
      HAL_ADC.ADC_Init (HAL_ADC.Default_Config);
      
      -- PWM will be initialized on-demand for each pin
   end Initialize_All;

end HAL;
