# Apotheosis Installer
# Run from a PC connected to the device via USB (Device Portal or PowerShell)
# Usage: .\Install-Apotheosis.ps1 -AppxPath .\Apotheosis_v0.1.8.6_ARM.appx -CerPath .\Apotheosis_v0.1.8.6_ARM.cer

param(
    [Parameter(Mandatory=$true)][string]$AppxPath,
    [Parameter(Mandatory=$true)][string]$CerPath,
    [string]$DeviceIP = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $AppxPath)) { throw "Appx not found: $AppxPath" }
if (-not (Test-Path $CerPath)) { throw "Cert not found: $CerPath" }

Write-Host "=== Apotheosis Installer ===" -ForegroundColor Cyan

# 1. Trust the certificate
Write-Host "`n[1/3] Trusting certificate..." -ForegroundColor Yellow
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CerPath)
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("Root", "LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("TrustedPeople", "LocalMachine")
$store.Open("ReadWrite")
$store.Add($cert)
$store.Close()
Write-Host "  Certificate trusted (Root + TrustedPeople)" -ForegroundColor Green

# 2. Install the appx
Write-Host "`n[2/3] Installing appx..." -ForegroundColor Yellow
if ($DeviceIP) {
    # Remote install via Device Portal
    $session = Invoke-RestMethod -Uri "http://$DeviceIP/api/app/packagemanager/token" -Method Post
    $token = $session.Token
    $bytes = [System.IO.File]::ReadAllBytes((Resolve-Path $AppxPath).Path)
    $body = @{ file = $bytes; token = $token }
    Invoke-RestMethod -Uri "http://$DeviceIP/api/appxdata" -Method Post -Body $body -ContentType "multipart/form-data"
    Write-Host "  Installed via Device Portal" -ForegroundColor Green
} else {
    # Local install
    Add-AppxPackage -Path $AppxPath
    Write-Host "  Installed locally" -ForegroundColor Green
}

# 3. Done
Write-Host "`n[3/3] Done!" -ForegroundColor Cyan
Write-Host "  Launch 'Apotheosis Browser' from the Start menu" -ForegroundColor Green