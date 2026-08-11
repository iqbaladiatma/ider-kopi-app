# Script untuk Reset / Provision Initial Password Akun IDER KOPI (Windows PowerShell)
# Usage: .\scripts\reset-login-passwords.ps1

$ErrorActionPreference = "Stop"

$EMPLOYEE_PASSWORD = "iderkophebat"
$ADMIN_PASSWORD = "adminiderkophebat"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Reset Initial Password IDER KOPI Mobile  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Password Karyawan : $EMPLOYEE_PASSWORD" -ForegroundColor Yellow
Write-Host "Password Admin    : $ADMIN_PASSWORD" -ForegroundColor Yellow
Write-Host "------------------------------------------"

$backendDir = Join-Path -Path $PSScriptRoot -ChildPath "..\auth-backend"

if (Test-Path $backendDir) {
    Set-Location -Path $backendDir
    Write-Host "`n[1/1] Menjalankan reset_employee_passwords via Docker Compose..." -ForegroundColor Cyan
    docker compose run --rm -e INITIAL_EMPLOYEE_PASSWORD="$EMPLOYEE_PASSWORD" auth-api reset_employee_passwords --apply
    Write-Host "`n[SUCCESS] Seluruh password awal karyawan telah di-reset ke: '$EMPLOYEE_PASSWORD'" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] Direktori auth-backend tidak ditemukan!" -ForegroundColor Red
}
