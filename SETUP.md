# Arduino Uno R4 HAL - Setup Guide

## Wymagane narzędzia

### Windows

#### 1. Instalacja GNAT ARM Embedded

**Opcja A: Via Alire (polecane)**
```powershell
# Pobierz Alire z https://alire.ada-lang.io/
# Zainstaluj Alire (dodaj do PATH)

# Następnie:
alr install gnat_arm_embedded
```

**Opcja B: Bezpośredni download**
- Pobierz z: https://www.adacore.com/download
- Wyszukaj "GNAT ARM Embedded" dla Windows
- Zainstaluj (dodaj do PATH)

#### 2. Instalacja arduino-cli

```powershell
# Opcja A: Chocolatey (jeśli masz zainstalowany)
choco install arduino-cli

# Opcja B: Pobranie bezpośrednie
# https://arduino.cc/en/software#arduino-cli
# Rozpakuj i dodaj do PATH
```

#### 3. Sterowniki USB
Arduino R4 Minima automatycznie otrzymuje sterowniki na Windows 10/11.
Jeśli port COM nie pojawia się:
- https://support.arduino.cc/hc/en-us/articles/4411305694610

## Konfiguracja Arduino R4

```powershell
# Sprawdź dostępne porty
arduino-cli board list

# Zainstaluj board package dla Uno R4
arduino-cli core install arduino:renesas_uno

# Sprawdź instalację
arduino-cli board listall | findstr "R4"
```

## Budowanie projektu

```powershell
# Z folderu projektu (innehalts C:\Users\Asia\Projects\Radek)

# Kompiluj projekt
gprbuild -P uno_r4_hal.gpr

# Wynik w: bin/main
```

## Wgrywanie na Arduino

### Krok 1: Konwertuj na format Arduino (HEX)

```powershell
# Potrzebujesz arm-none-eabi-objcopy
# Zwykle dostarczany z GNAT ARM

arm-none-eabi-objcopy -O ihex bin\main bin\main.hex
```

### Krok 2: Wgraj na Arduino

```powershell
# Sprawdź port
arduino-cli board list

# Wgraj (zastąp COM3 Twoim portem)
arduino-cli upload -b arduino:renesas_uno:uno_r4_minima `
  -p COM3 --input-file bin\main.elf
```

### Krok 3: Monitor (opcjonalnie)

```powershell
arduino-cli monitor -p COM3

# Lub użyj innego serial monitora:
# - PuTTY
# - Arduino IDE Serial Monitor
# - Termite
```

## Troubleshooting

### Błąd: "gprbuild not found"
- Upewnij się, że GNAT jest w PATH
- `echo %PATH%` - sprawdź czy zawiera GNAT bin folder
- Restartuj PowerShell po dodaniu do PATH

### Błąd: "arduino-cli not found"
- Sprawdź: `where arduino-cli`
- Dodaj arduino-cli do PATH jeśli brakuje

### Błąd: "Board not detected"
- Sprawdź port COM: `arduino-cli board list`
- Zainstaluj sterowniki USB (patrz wyżej)
- Spróbuj inny kabel USB (niektóre to "data-only")

### Błąd podczas wgrywania
```powershell
# Czasami Arduino wymaga resetowania
# Przed wgraniem Arduino CLI robi to automatycznie

# Jeśli nie działa, ręczne resetowanie:
# Podłącz Arduino, czekaj 2 sekundy i wgraj
```

## Struktura katalogów

```
Radek/
├── src/
│   ├── hal.ads/adb           # Main HAL package
│   ├── hal_platform.ads      # Platform definitions
│   ├── hal_gpio.ads/adb      # GPIO driver
│   ├── hal_uart.ads/adb      # UART driver
│   ├── hal_adc.ads/adb       # ADC driver
│   ├── hal_pwm.ads/adb       # PWM driver
│   ├── main.adb              # Main program
│   └── examples.adb          # Example programs
├── obj/                       # Build objects (generated)
├── bin/                       # Executables (generated)
├── uno_r4_hal.gpr            # GNAT project file
├── README.md                  # Documentation
└── SETUP.md                   # This file
```

## Następne kroki

1. Edytuj `src/main.adb` aby zmienić program
2. Uruchom `gprbuild -P uno_r4_hal.gpr`
3. Konwertuj i wgraj: `arm-none-eabi-objcopy -O ihex bin\main bin\main.hex`
4. Wgraj: `arduino-cli upload -b arduino:renesas_uno:uno_r4_minima -p COM3 --input-file bin\main.elf`

## Dokumentacja

- **Arduino Uno R4 Minima**: https://docs.arduino.cc/hardware/uno-r4-minima/
- **Renesas RA4M1**: https://www.renesas.com/products/microcontrollers-microprocessors/ra-cortex-m-microcontrollers/ra4-group-high-integration-line
- **Ada Documentation**: https://www.adacore.com/resources

## Quick Reference

### Najbardziej potrzebne komendy

```powershell
# Kompiluj
gprbuild -P uno_r4_hal.gpr

# Konwertuj do HEX
arm-none-eabi-objcopy -O ihex bin\main bin\main.hex

# Wgraj
arduino-cli upload -b arduino:renesas_uno:uno_r4_minima -p COM3 --input-file bin\main.elf

# Monitor
arduino-cli monitor -p COM3
```

Powodzenia! 🚀
