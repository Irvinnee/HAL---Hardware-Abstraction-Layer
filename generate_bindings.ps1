# ============================================================
# Generowanie bindingow Ada z SVD (svd2ada)
# Uruchom po install.ps1
# ============================================================

Write-Host "=== Generowanie bindingow Ada z SVD ===" -ForegroundColor Green
Write-Host ""

$projectRoot = $PSScriptRoot
$svdFile = "$projectRoot\svd\R7FA4M1AB.svd"
$outputDir = "$projectRoot\src\svd"

# Sprawdz czy SVD istnieje
if (-not (Test-Path $svdFile)) {
    Write-Host "BLAD: Brak pliku SVD: $svdFile" -ForegroundColor Red
    Write-Host "Uruchom najpierw: .\install.ps1" -ForegroundColor Yellow
    exit 1
}

# Sprawdz czy svd2ada jest dostepne
if (-not (Get-Command svd2ada -ErrorAction SilentlyContinue)) {
    Write-Host "BLAD: svd2ada nie znalezione w PATH" -ForegroundColor Red
    Write-Host "Zainstaluj svd2ada i dodaj do PATH" -ForegroundColor Yellow
    exit 1
}

# Utworz folder wyjsciowy
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

# Generuj bindingi
Write-Host "Generuje bindingi z: $svdFile" -ForegroundColor Yellow
Write-Host "Do folderu: $outputDir" -ForegroundColor Yellow
Write-Host ""

svd2ada $svdFile `
    --output=$outputDir `
    --package=RA4M1 `
    --base-types-package=HAL `
    --gen-uint-always

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Bindingi wygenerowane pomyslnie!" -ForegroundColor Green
    Write-Host "Pliki w: $outputDir" -ForegroundColor White
    Write-Host ""
    
    # Lista wygenerowanych plikow
    Get-ChildItem $outputDir -Filter "*.ads" | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "Nastepny krok: gprbuild -P uno_r4_hal.gpr" -ForegroundColor Yellow
} else {
    Write-Host "BLAD: svd2ada nie powiodlo sie!" -ForegroundColor Red
    Write-Host "Sprawdz czy plik SVD jest poprawny." -ForegroundColor Yellow
}
