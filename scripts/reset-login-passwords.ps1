# Script untuk Reset / Provision Initial Password Akun IDER KOPI (Windows PowerShell)
# Usage: .\scripts\reset-login-passwords.ps1

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Reset Password Karyawan IDER KOPI Mobile " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "------------------------------------------"

$projectRoot = (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath "..")).Path
$composeFile = Join-Path -Path $projectRoot -ChildPath "docker-compose.yml"
$envFile = Join-Path -Path $projectRoot -ChildPath ".runtime\mobile-auth.env"

if (-not (Test-Path $composeFile -PathType Leaf)) {
    throw "docker-compose.yml tidak ditemukan di $projectRoot"
}

if (-not (Test-Path $envFile -PathType Leaf)) {
    throw "Environment file tidak ditemukan: $envFile"
}

$passwordConfigured = Get-Content $envFile | Where-Object {
    $_ -match '^INITIAL_EMPLOYEE_PASSWORD=.+$'
} | Select-Object -First 1

if (-not $passwordConfigured) {
    throw "INITIAL_EMPLOYEE_PASSWORD belum dikonfigurasi di $envFile"
}

Push-Location $projectRoot
try {
    docker compose --env-file $envFile config --quiet
    if ($LASTEXITCODE -ne 0) { throw "Konfigurasi Docker Compose tidak valid" }

    Write-Host "`n[PREVIEW] Akun karyawan yang memenuhi syarat reset:" -ForegroundColor Cyan
    docker compose --env-file $envFile --profile tools run --rm auth-provision reset_employee_passwords
    if ($LASTEXITCODE -ne 0) { throw "Preview reset gagal" }

    $confirmation = Read-Host "`nLanjutkan reset password seluruh karyawan aktif? [y/N]"
    if ($confirmation -notmatch '^[Yy]$') {
        Write-Host "[CANCELLED] Tidak ada password yang diubah." -ForegroundColor Yellow
        exit 0
    }

    Write-Host "`nMenggunakan password yang tersimpan aman di runtime env." -ForegroundColor Cyan
    docker compose --env-file $envFile --profile tools run --rm auth-password-reset
    if ($LASTEXITCODE -ne 0) { throw "Reset password gagal" }

    Write-Host "`n[SUCCESS] Reset password karyawan selesai. Periksa laporan JSON di atas." -ForegroundColor Green
}
finally {
    Pop-Location
}
