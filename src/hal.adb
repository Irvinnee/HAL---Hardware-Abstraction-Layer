-- HAL Implementation - Initialize all hardware modules

with HAL_GPIO;
with HAL_UART;
with HAL_ADC;
with HAL_PWM;
with HAL_Interrupts;
with HAL_SPI;
with HAL_I2C;
with HAL_Timer;
with HAL_RTC;
with HAL_Power;
with HAL_Pin_Interrupt;

package body HAL is

   procedure Initialize_All is
   begin
      -- Enable interrupts globally
      HAL_Interrupts.Enable_Interrupts;

      -- Initialize GPIO first (needed for all pin operations)
      HAL_GPIO.GPIO_Initialize_All;

      -- Initialize UART (Serial)
      HAL_UART.UART_Init (HAL_UART.Default_Config);

      -- Initialize ADC
      HAL_ADC.ADC_Init (HAL_ADC.Default_Config);

      -- Initialize RTC (real-time clock)
      HAL_RTC.RTC_Init;

      -- Pin interrupts ready
      HAL_Pin_Interrupt.Pin_IRQ_Initialize;

      -- SPI / I2C / Timer / PWM initialized on-demand
   end Initialize_All;

end HAL;
