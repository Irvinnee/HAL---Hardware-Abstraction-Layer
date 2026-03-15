# ============================================================
# Arduino Uno R4 Minima - Ada Development Environment Setup
# Skrypt instalacji narzedzi na Windows
# ============================================================
# URUCHOM JAKO ADMINISTRATOR
# ============================================================

Write-Host "=== Arduino Uno R4 Ada - Instalacja ===" -ForegroundColor Green
Write-Host ""

# --- 1. Sprawdz czy Chocolatey jest zainstalowany ---
Write-Host "[1/6] Sprawdzam Chocolatey..." -ForegroundColor Yellow
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "  Instaluje Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "  Chocolatey zainstalowany!" -ForegroundColor Green
} else {
    Write-Host "  Chocolatey juz zainstalowany." -ForegroundColor Green
}

# --- 2. Instalacja Alire (menedzer pakietow Ada) ---
Write-Host ""
Write-Host "[2/6] Instaluje Alire (menedzer pakietow Ada)..." -ForegroundColor Yellow
Write-Host "  Pobierz Alire z: https://alire.ada-lang.io/" -ForegroundColor Cyan
Write-Host "  Bezposredni link: https://github.com/alire-project/alire/releases" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Po pobraniu .exe zainstaluj i dodaj do PATH." -ForegroundColor White
Write-Host "  Sprawdz: alr --version" -ForegroundColor White
Write-Host ""
Read-Host "  Nacisnij ENTER gdy Alire jest zainstalowane"

# --- 3. Instalacja GNAT ARM Embedded (kompilator Ada dla ARM) ---
Write-Host ""
Write-Host "[3/6] Instaluje GNAT ARM Embedded..." -ForegroundColor Yellow
Write-Host "  Uzywam Alire do pobrania kompilatora:" -ForegroundColor Cyan
alr toolchain --select gnat_arm_elf
Write-Host ""
Write-Host "  Sprawdz:" -ForegroundColor White
Write-Host "  arm-eabi-gcc --version" -ForegroundColor White

# --- 4. Instalacja svd2ada ---
Write-Host ""
Write-Host "[4/6] Instaluje svd2ada..." -ForegroundColor Yellow
Write-Host "  Pobierz svd2ada z GitHub:" -ForegroundColor Cyan
Write-Host "  https://github.com/AdaCore/svd2ada/releases" -ForegroundColor Cyan
Write-Host ""
Write-Host "  LUB zbuduj z zrodla:" -ForegroundColor Cyan
Write-Host "  git clone https://github.com/AdaCore/svd2ada.git" -ForegroundColor White
Write-Host "  cd svd2ada" -ForegroundColor White
Write-Host "  gprbuild -P svd2ada.gpr" -ForegroundColor White
Write-Host ""
Read-Host "  Nacisnij ENTER gdy svd2ada jest zainstalowane"

# --- 5. Instalacja arduino-cli ---
Write-Host ""
Write-Host "[5/6] Instaluje arduino-cli..." -ForegroundColor Yellow
if (-not (Get-Command arduino-cli -ErrorAction SilentlyContinue)) {
    choco install arduino-cli -y
    Write-Host "  arduino-cli zainstalowany!" -ForegroundColor Green
} else {
    Write-Host "  arduino-cli juz zainstalowany." -ForegroundColor Green
}

# Instalacja board package dla Arduino R4
Write-Host "  Instaluje board package Arduino R4..." -ForegroundColor Cyan
arduino-cli core install arduino:renesas_uno

# --- 6. Pobranie SVD dla Renesas RA4M1 ---
Write-Host ""
Write-Host "[6/6] Pobieranie SVD pliku dla RA4M1..." -ForegroundColor Yellow

$svdDir = "$PSScriptRoot\svd"
if (-not (Test-Path $svdDir)) {
    New-Item -ItemType Directory -Path $svdDir | Out-Null
}

# SVD plik z Renesas CMSIS Pack
$svdUrl = "https://raw.githubusercontent.com/renesas/fsp/master/ra/fsp/src/bsp/cmsis/Device/RENESAS/SVD/R7FA4M1AB.svd"
$svdFile = "$svdDir\R7FA4M1AB.svd"

Write-Host "  Pobieram SVD z: $svdUrl" -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $svdUrl -OutFile $svdFile -UseBasicParsing
    Write-Host "  SVD pobrany: $svdFile" -ForegroundColor Green
} catch {
    Write-Host "  BLAD: Nie udalo sie pobrac SVD automatycznie." -ForegroundColor Red
    Write-Host "  Pobierz recznie z:" -ForegroundColor Yellow
    Write-Host "  https://github.com/renesas/fsp/tree/master/ra/fsp/src/bsp/cmsis/Device/RENESAS/SVD" -ForegroundColor White
    Write-Host "  Plik: R7FA4M1AB.svd" -ForegroundColor White
    Write-Host "  Zapisz do: $svdDir\" -ForegroundColor White
}

# --- Podsumowanie ---
Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  INSTALACJA ZAKONCZONA" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Zainstalowane narzedzia:" -ForegroundColor White
Write-Host "  [1] Alire       - menedzer pakietow Ada" -ForegroundColor White
Write-Host "  [2] GNAT ARM    - kompilator Ada dla ARM" -ForegroundColor White
Write-Host "  [3] svd2ada     - generator bindingow z SVD" -ForegroundColor White
Write-Host "  [4] arduino-cli - narzedzie CLI Arduino" -ForegroundColor White
Write-Host "  [5] SVD plik    - definicja rejestrow RA4M1" -ForegroundColor White
Write-Host ""
Write-Host "Nastepny krok:" -ForegroundColor Yellow
Write-Host "  .\generate_bindings.ps1" -ForegroundColor Cyan
Write-Host ""
