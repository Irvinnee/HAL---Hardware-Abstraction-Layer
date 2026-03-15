# HAL - Hardware Abstraction Layer for Arduino Uno R4 Minima

Kompletna biblioteka HAL dla Arduino Uno R4 Minima (Renesas RA4M1, ARM Cortex-M4) napisana w Adzie z prawdziwym dostępem do rejestrów sprzętowych.

## Struktura

```
src/
├── hal_platform.ads         - Definicje platform, typów i pinów
├── ra4m1_registers.ads      - Definicje rejestrów sprzętowych (volatile)
├── hal_gpio.ads/adb         - Sterownik GPIO (cyfrowe I/O)
├── hal_uart.ads/adb         - Sterownik UART (komunikacja szeregowa SCI0)
├── hal_adc.ads/adb          - Sterownik ADC (wejścia analogowe)
├── hal_pwm.ads/adb          - Sterownik PWM (AGT timer output)
├── hal_interrupts.ads/adb   - Obsługa przerwań (NVIC)
├── hal_spi.ads/adb          - Sterownik SPI (SCI w trybie clock-sync)
├── hal_i2c.ads/adb          - Sterownik I2C (moduł IIC)
├── hal_timer.ads/adb        - Sterownik timerów (AGT0/AGT1)
├── hal_rtc.ads/adb          - Zegar czasu rzeczywistego (RTC)
├── hal_power.ads/adb        - Tryby uśpienia i zarządzanie energią
├── hal_pin_interrupt.ads/adb - Przerwania pin (IRQ zewnętrzne)
├── hal.ads/adb              - Główny pakiet HAL
├── main.adb                 - Przykład użycia (blink LED)
└── examples.adb             - Dodatkowe przykłady
linker/
└── memory.ld                - Skrypt linkera RA4M1 (256K Flash, 32K SRAM)
```

## Moduły

### GPIO (General Purpose Input/Output)
Kontrola pin cyfrowych (0/1).

```ada
GPIO_Init(Config);        -- Inicjalizacja pinu
GPIO_Set(Config);         -- Ustawienie HIGH
GPIO_Clear(Config);       -- Ustawienie LOW
GPIO_Toggle(Config);      -- Przełączenie stanu
GPIO_Write(Config, State); -- Zapis wartości
GPIO_Read(Config);        -- Odczyt wartości
```

### UART (Serial Communication)
Komunikacja szeregowa na D0/D1 przez SCI2 (P301/P302).
Uwaga: USB-CDC serial używa wbudowanego USB, nie SCI.

```ada
UART_Init;                -- Inicjalizacja (9600 baud)
UART_Send_Char(Ch);      -- Wysłanie znaku
UART_Send_String("foo"); -- Wysłanie tekstu
UART_Send_Line("bar");   -- Wysłanie z LF
UART_Receive_Char;       -- Odbiór znaku (blokujący)
UART_Data_Available;     -- Sprawdzenie dostępności danych
```

### ADC (Analog Input)
Wejścia analogowe A0-A7 (10-bitowe domyślnie).

```ada
ADC_Init;                -- Inicjalizacja
ADC_Read_Raw(A0);        -- Odczyt RAW (0-1023)
ADC_Read(A0);            -- Odczyt jako int
ADC_Read_Voltage(A0);    -- Odczyt jako napięcie (0-5V)
```

### PWM (Pulse Width Modulation)
Wyjścia PWM na pinach D3, D5, D6, D9, D10, D11.

```ada
Config : PWM_Config := (Pin => PWM_D3, Frequency => 1000, Duty => 128);
PWM_Init(Config);              -- Inicjalizacja
PWM_Set_Duty(D3, 200);         -- Ustaw duty (0-255)
PWM_Set_Duty_Percent(D3, 50.0); -- Ustaw duty (0-100%)
PWM_Set_Frequency(D3, 5000);   -- Zmień częstotliwość
PWM_Stop(D3);                  -- Zatrzymaj
PWM_Start(D3);                 -- Wznów
```

### Interrupts (Przerwania)
Kontrola NVIC ARM Cortex-M4.

```ada
Enable_IRQ (IRQ);              -- Włącz przerwanie
Disable_IRQ (IRQ);             -- Wyłącz przerwanie
Set_Priority (IRQ, 3);         -- Ustaw priorytet (0-15)
Clear_Pending (IRQ);           -- Wyczyść pending
Enable_Interrupts;             -- Globalne CPSIE I
Disable_Interrupts;            -- Globalne CPSID I
```

### SPI
Komunikacja SPI przez SCI w trybie clock-synchronous.

```ada
SPI_Init ((Bus => SPI_0, Mode => Mode_0, Clock_Div => Div_8, Order => MSB_First));
Rx := SPI_Transfer (16#AA#);          -- Wyślij/odbierz bajt
SPI_Send_Buffer (Buf, Buf'Length);     -- Wyślij bufor
SPI_CS_Low (CS_Pin);                   -- Chip Select aktywny
SPI_CS_High (CS_Pin);                  -- Chip Select nieaktywny
SPI_Deinit;                            -- Wyłącz SPI
```

### I2C
Magistrala I2C (IIC0/IIC1) w trybie master.

```ada
I2C_Init ((Bus => I2C_0, Speed => Fast_400K));
Status := I2C_Write (16#48#, Data, 2);       -- Zapis do slave
Status := I2C_Read (16#48#, Buf, 3);         -- Odczyt ze slave
Status := I2C_Write_Register (16#48#, 16#01#, 16#FF#); -- Zapis rejestru
Status := I2C_Read_Register (16#48#, 16#00#, Val);     -- Odczyt rejestru
Present := I2C_Device_Present (16#48#);       -- Skanowanie
```

### Timer
Timery AGT0/AGT1, delay, millis/micros.

```ada
Timer_Init ((ID => Timer_0, Mode => Periodic, Period_Us => 1000, Clock => PCLKB_Div_8));
Timer_Start (Timer_0);              -- Uruchom timer
Timer_Stop (Timer_0);               -- Zatrzymaj
Delay_Ms (500);                     -- Opóźnienie 500 ms
Delay_Us (100);                     -- Opóźnienie 100 µs
T := Millis;                        -- Czas od startu (ms)
```

### RTC (Zegar czasu rzeczywistego)
Zegar BCD z alarmami i przerwaniami periodycznymi.

```ada
RTC_Init;
RTC_Set_Time ((Hours => 14, Minutes => 30, Seconds => 0));
RTC_Set_Date ((Year => 25, Month => 1, Day => 15, Weekday => 3));
RTC_Start;
DT := RTC_Get_DateTime;             -- Odczyt daty i czasu
RTC_Set_Alarm ((Hours => 7, Minutes => 0, Seconds => 0, Weekday_Mask => 16#3E#));
RTC_Enable_Alarm;
RTC_Set_Periodic (Period_1Hz);       -- Przerwanie co sekundę
```

### Power (Zarządzanie energią)
Tryby uśpienia i reset.

```ada
Enter_Sleep (Sleep);                 -- Lekki sen (WFI)
Enter_Sleep (Deep_Sleep);            -- Głęboki sen
Enter_Sleep (Software_Standby);      -- Standby
Sleep_Ms (1000);                     -- Uśpij na 1s (SysTick wake)
Sleep_Until_Interrupt;               -- Czekaj na przerwanie
Cause := Get_Reset_Cause;            -- Powód ostatniego resetu
System_Reset;                        -- Reset programowy (AIRCR)
```

### Pin Interrupts (Przerwania na pinach)
Zewnętrzne przerwania IRQ0-IRQ7.

```ada
Attach_Interrupt (Pin_D2, IRQ0, Falling_Edge, My_Handler'Access);
Detach_Interrupt (IRQ0);
Enable_Pin_IRQ (IRQ0);
Set_Edge_Detect (IRQ0, Both_Edges);
if IRQ_Flag_Set (IRQ0) then ...
Clear_IRQ_Flag (IRQ0);
```

## Kompilacja

### Wymagania:
- GNAT ARM Embedded (kompilator Ada dla ARM)
- GPRBuild (build system dla Ada)

### Instalacja GNAT:
```bash
# Pobierz z https://alire.ada-lang.io/
alr install gnat_arm_embedded

# Lub bezpośrednio:
# https://www.adacore.com/download
```

### Budowanie:
```bash
gprbuild -P uno_r4_hal.gpr
```

## Wgrywanie na Arduino

### Wymagania:
- arduino-cli
- Bootloader Arduino R4 (wbudowany)

### Kroki:

1. **Kompiluj** do pliku ELF:
```bash
gprbuild -P uno_r4_hal.gpr
```

2. **Konwertuj** ELF do BIN (format Renesas bootloader):
```bash
arm-none-eabi-objcopy -O binary bin/main bin/main.bin
```

3. **Wgraj** na Arduino (podłącz USB, dobierz COM port):
```bash
arduino-cli upload -b arduino:renesas_uno:minima \
  -p COM3 --input-file bin/main.bin
```

> **Uwaga:** Arduino R4 Minima używa bootloadera Renesas (dfu-util/bossac),
> nie klasycznego avrdude. Alternatywnie można użyć `dfu-util` bezpośrednio.

## Przykład: Migający LED

```ada
-- Blink LED on D13 (P111)
with HAL;
use HAL;

procedure Main is
   LED : constant GPIO.Pin_Config := Platform.LED_Pin;
begin
   Initialize_All;
   GPIO.GPIO_Init (LED);
   
   loop
      GPIO.GPIO_Set (LED);
      delay 1.0;
      
      GPIO.GPIO_Clear (LED);
      delay 1.0;
   end loop;
end Main;
```

## Uwagi

1. **Volatile Register Access:** Wszystkie rejestry sprzętowe używają `Volatile_Full_Access` 
   przez `ra4m1_registers.ads`. Prawdziwe odczyty/zapisy hardware.

2. **svd2ada kompatybilność:** Można wygenerować bindingi z SVD za pomocą `generate_bindings.ps1`.
   Ręczne definicje w `ra4m1_registers.ads` służą jako fallback.

3. **RA4M1 Dokumentacja:** https://www.renesas.com/

## Pełna dokumentacja rejestrów

Patrz dokumentacja Renesas RA4M1:
- GPIO: Port module (PCNTR1-4)
- UART: Serial Communication Interface (SCI2 on D0/D1)
- ADC: A/D Converter (ADC0)
- Timer/PWM: Asynchronous General Purpose Timer (AGT0/1)
- SPI: SCI w trybie Clock Synchronous (SCI1/SCI9)
- I2C: I2C Bus Interface (IIC0/IIC1)
- RTC: Real Time Clock (BCD mode)
- Interrupts: Nested Vectored Interrupt Controller (NVIC)
- Power: System Control Block (SCB), Standby Control (SBYCR/SNZCR)
- Pin IRQ: Interrupt Controller Unit (ICU IRQCR)

## Status

- [x] Pełna implementacja register access (volatile)
- [x] Interrupt handling (NVIC enable/disable/priority)
- [x] SPI driver (SCI clock-sync mode)
- [x] I2C driver (IIC master read/write/scan)
- [x] Timer driver (AGT0/1, delay, millis/micros)
- [x] RTC support (BCD time/date, alarm, periodic)
- [x] Sleep modes (sleep/deep/standby/snooze)
- [x] Port interrupt support (IRQ0-7, edge detect)
