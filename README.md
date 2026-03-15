# HAL - Hardware Abstraction Layer for Arduino Uno R4 Minima

Uproszczona biblioteka HAL dla Arduino Uno R4 Minima (Renesas RA4M1) napisana w Adzie.

## Struktura

```
src/
├── hal_platform.ads      - Definicje platform i typów
├── hal_gpio.ads/adb      - Sterownik GPIO (cyfrowe I/O)
├── hal_uart.ads/adb      - Sterownik UART (komunikacja szeregowa)
├── hal_adc.ads/adb       - Sterownik ADC (wejścia analogowe)
├── hal_pwm.ads/adb       - Sterownik PWM (modulacja szerokości impulsu)
├── hal.ads/adb           - Główny pakiet HAL
└── main.adb              - Przykład użycia
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
Komunikacja szeregowa USB na R4 Minima.

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

2. **Konwertuj** do HEX (Arduino format):
```bash
arm-none-eabi-objcopy -O ihex bin/main bin/main.hex
```

3. **Wgraj** na Arduino:
```bash
arduino-cli upload -b arduino:renesas_uno:uno_r4_minima \
  -p COM3 --input-file bin/main.elf
```

## Przykład: Migający LED

```ada
-- Blink LED on D13
with HAL;

procedure Main is
   LED_Config : constant HAL.GPIO.Pin_Config := 
      (Port => 1, Pin => 2, Mode => Output);
begin
   HAL.Initialize_All;
   
   loop
      HAL.GPIO.GPIO_Set(LED_Config);
      delay 1.0;  -- 1 sekunda
      
      HAL.GPIO.GPIO_Clear(LED_Config);
      delay 1.0;
   end loop;
end Main;
```

## Uwagi

1. **Włączenie niezbędne:** Ta biblioteka jest uproszczona. Do pełnej funkcjonalności potrzebujesz:
   - Konfiguracji taktowania systemowego (clock configuration)
   - Obsługi przerwań
   - Volatile access do rejestrów sprzętowych
   - Proper type definitions dla System.Storage_Elements

2. **Rejestr access:** Aktualnie używa `null` statements jako placeholders
   Implementacja wymaga: `pragma Volatile_Full_Access` dla access do rejestrów

3. **RA4M1 Dokumentacja:** https://www.renesas.com/

## Pełna dokumentacja rejestrów

Patrz dokumentacja Renesas RA4M1:
- GPIO: Port module
- UART: Serial Communication Interface (SCI)
- ADC: A/D Converter (ADC)
- Timer: Asynchronous General Purpose Timer (AGT)

## TODO

- [ ] Pełna implementacja register access
- [ ] Interrupt handling
- [ ] SPI driver
- [ ] I2C driver
- [ ] Timer driver
- [ ] RTC support
- [ ] Sleep modes
- [ ] Port interrupt support
